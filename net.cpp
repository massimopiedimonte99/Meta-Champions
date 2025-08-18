#include "net.h"
#include <QNetworkRequest>
#include <QUrl>
#include <QJsonDocument>

Net::Net(QObject *parent)
{
    // Inizializzo la connessione
    connect(&m_manager, &QNetworkAccessManager::finished, this, &Net::onReplyFinished);
}

void Net::onReplyFinished(QNetworkReply* reply)
{
    // Gestione Eccezioni
    QVariant statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
    if(statusCode.isValid()) {
        int code = statusCode.toInt();
        if(code < 200 || code >= 300) {
            QString errMsg = QString("HTTP %1: %2").arg(code).arg(reply->readAll());
            emit errorOccurred(errMsg);
            reply->deleteLater();
            return;
        }
    }

    if(reply->error() != QNetworkReply::NoError) {
        emit errorOccurred(reply->errorString());
        reply->deleteLater();
        return;
    }

    switch(m_mode)
    {
    case RequestMode::FetchChampions:   rf__FetchChampions(reply);  break;
    case RequestMode::FetchGames:       rf__FetchGames(reply);      break;
    case RequestMode::FetchGamesIds:    rf__FetchGamesIds(reply);   break;
    case RequestMode::FetchMatches:     rf__FetchMatchInfo(reply);  break;
        break;
    }


    reply->deleteLater();
}

// Metodi per elaborare le risposte in formato JSON
void Net::rf__FetchChampions(QNetworkReply* reply)
{
    QJsonDocument json = QJsonDocument::fromJson(reply->readAll());

    if(json.isObject()) {
        emit championsFetched(json.object());
    }
    else emit errorOccurred("Risposta non valida");
}

void Net::rf__FetchGames(QNetworkReply* reply)
{
    QJsonDocument json = QJsonDocument::fromJson(reply->readAll());

    m_winCounter = -1; // Resetta il valore del contatore (se resta a -1 significa che non sono state trovate informazioni)

    if(json.isArray()) {
        QJsonArray array = json.array();

        int dummyCounter = 0;
        for (const QJsonValue &value : array) {
            // TODO: Mappare in un DTO "obj"
            QJsonObject obj = value.toObject();

            // Se l'account è attivo colleziona il PUUID in una coda FIFO
            // NB. il dummyCounter serve solo a non sforare con le limitazioni della Riot API
            if(!obj["inactive"].toBool()) {
                m_puuids.enqueue(obj["puuid"].toString());
            }
            if(++dummyCounter == 1) break;
        }

        // Per ogni PUUID
        processNextMatchByPuuid();

    }
    else emit errorOccurred("Risposta non valida");
}

void Net::rf__FetchGamesIds(QNetworkReply* reply)
{
    QJsonDocument json = QJsonDocument::fromJson(reply->readAll());

    if(json.isArray()) {
        QJsonArray array = json.array();

        for (const QJsonValue &value : array) {
            // TODO: Mappare in un DTO "obj"
            m_matches.enqueue(value.toString());
        }

        // Per ogni Match ID
        processNextMatchInfoByMatchId();
    }
    else emit errorOccurred("Risposta non valida");

    processNextMatchByPuuid();
}

void Net::rf__FetchMatchInfo(QNetworkReply* reply)
{
    QJsonDocument json = QJsonDocument::fromJson(reply->readAll());

    if(json.isObject()) {
        // TODO: Mappare in un DTO la risposta (troncando il JSON nelle parti che mi interessano)
        QJsonArray infoList = json.object().value("info").toObject().value("participants").toArray();

        for (const QJsonValue &v : infoList) {
            bool isSelectedSummoner = v.toObject().value("championName").toString().compare(m_summonerName, Qt::CaseInsensitive) == 0;
            bool isWin = v.toObject().value("win").toBool();

            if(isSelectedSummoner && m_winCounter == -1) m_winCounter = 0;
            if(isSelectedSummoner && isWin) m_winCounter++;
        }

        // SE...
        //  m_winCounter > 0    - Calcola win-rate
        //  m_winCounter = 0    - Il summoner è stato trovato nel pool di match analizzati ma non ha vittorie (restituisci N.D.)
        //  m_winCounter = -1   - Il summoner non è stato trovato nel pool di match analizzati
        if(m_winCounter == -1 || m_winCounter == 0) emit gamesFetched(generateResult("N"));
        else                                        emit gamesFetched(generateResult("S"));



    }
    else emit errorOccurred("Risposta non valida");

    processNextMatchInfoByMatchId();
}

// Q_INVOKABLE
void Net::fetchChampions()
{
    if(checkApiKey()) {
        // Connessione alla Riot API - Fetch Champions
        QString url = QString("https://euw1.api.riotgames.com/lol/platform/v3/champion-rotations?api_key=%1").arg(m_apiKey);
        QNetworkRequest request((QUrl(url)));
        request.setRawHeader("X-Riot-Token", m_apiKey.toUtf8());
        m_mode = RequestMode::FetchChampions;
        m_manager.get(request);
    }
}

void Net::fetchGames(const QString &summonerName)
{
    if(checkApiKey()) {
        // Normalizzo l'input utente per renderlo conforme al formato fornito dalla Riot API e lo assegno alla mia variabile interna
        m_summonerName = normalizeSummonerName(summonerName);

        // Connessione alla Riot API - Fetch Games
        QString url = QString("https://euw1.api.riotgames.com/lol/league-exp/v4/entries/%1/%2/%3?page=1&api_key=%4").arg("RANKED_SOLO_5x5", "PLATINUM", "I", m_apiKey);
        QNetworkRequest request((QUrl(url)));
        request.setRawHeader("X-Riot-Token", m_apiKey.toUtf8());
        m_mode = RequestMode::FetchGames;
        m_manager.get(request);
    }
}

void Net::fetchGamesIds(const QString &puuid)
{
    if(checkApiKey()) {
        // Connessione alla Riot API - Fetch Games ID
        QString url = QString("https://europe.api.riotgames.com/lol/match/v5/matches/by-puuid/%1/ids?type=ranked&start=0&count=%2&api_key=%3").arg(puuid).arg(m_matchesPerPuuid).arg(m_apiKey);
        QNetworkRequest request((QUrl(url)));
        request.setRawHeader("X-Riot-Token", m_apiKey.toUtf8());
        m_mode = RequestMode::FetchGamesIds;
        m_manager.get(request);
    }
}

void Net::fetchMatchInfo(const QString &matchId)
{
    if(checkApiKey()) {
        // Connessione alla Riot API - Fetch Games ID
        QString url = QString("https://europe.api.riotgames.com/lol/match/v5/matches/%1?api_key=%2").arg(matchId, m_apiKey);
        QNetworkRequest request((QUrl(url)));
        request.setRawHeader("X-Riot-Token", m_apiKey.toUtf8());
        m_mode = RequestMode::FetchMatches;
        m_manager.get(request);
    }
}

// Utilities & queue management methods
bool Net::checkApiKey() {
    // Controllo API Key
    if(m_apiKey.isEmpty()) {
        emit errorOccurred("API Key non trovata");
        return false;
    }

    return true;
}

QString Net::normalizeSummonerName(const QString &summonerName)
{
    QString cleaned = summonerName;
    cleaned = cleaned.remove(QRegularExpression("[^A-Za-z0-9]")).toLower();
    cleaned[0] = cleaned[0].toUpper();
    return cleaned;
}

float Net::calculateWinRate()
{
    return (static_cast<float>(m_winCounter) / m_matchesPerPuuid) * 100;
}

QVariantMap Net::generateResult(QString flagCanGenerate)
{
    Net::SummonerInfoDto app = flagCanGenerate.compare("S", Qt::CaseInsensitive) == 0 ?
                                Net::SummonerInfoDto(m_summonerName, calculateWinRate()) :
                                Net::SummonerInfoDto(m_summonerName, -1);

    QVariantMap res;
    res["summonerName"] = app.summonerName;
    res["winRate"] = app.winRate;

    return res;
}

void Net::processNextMatchByPuuid()
{
    if(m_puuids.isEmpty()) {
        return;
    }

    QString puuid = m_puuids.dequeue();
    fetchGamesIds(puuid);
}

void Net::processNextMatchInfoByMatchId()
{
    if(m_matches.isEmpty()) {
        return;
    }

    QString match = m_matches.dequeue();
    fetchMatchInfo(match);
}

// Getter & Setter
QString Net::apiKey() const { return m_apiKey; }
void Net::setApiKey(const QString &newApiKey) { m_apiKey = newApiKey; }
QString Net::regionInfo() const { return m_regionInfo; }
void Net::setRegionInfo(const QString &newRegionInfo) { m_regionInfo = newRegionInfo; }
