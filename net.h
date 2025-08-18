#ifndef NET_H
#define NET_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonObject>
#include <QJsonArray>
#include <QQueue>

class Net : public QObject
{
    Q_OBJECT
public:
    Net(QObject* parent = nullptr);

    Q_INVOKABLE void fetchChampions();
    Q_INVOKABLE void fetchGames(const QString &summonerName);
    void fetchGamesIds(const QString &puuid);
    void fetchMatchInfo(const QString &matchId);

    enum RequestMode {
        FetchChampions,         // 0. Test
        FetchGames,             // 1. Ottengo i PUUIDs dei giocatori che hanno disputato incontri in Plat+ nella modalità Ranked SoloQ
        FetchGamesIds,          // 2. Ottengo gli ID dei match basandomi sui PUUIDs precedentemente ottenuti
        FetchMatches,           // 3. Ottengo le informazioni dei match -- Se il summoner che mi interessa è giocato in quel match calcolo il win-rate
    };

    struct SummonerInfoDto {
        QString summonerName;
        float winRate;

        SummonerInfoDto(QString _summonerName, float _winRate) : summonerName(std::move(_summonerName)), winRate(_winRate) {};
    };

    QString apiKey() const;
    void setApiKey(const QString &newApiKey);

    QString regionInfo() const;
    void setRegionInfo(const QString &newRegionInfo);

    QString mode() const;
    void setMode(const QString &newMode);

    // Metodi per elaborare le risposte in formato JSON
    void rf__FetchChampions(QNetworkReply* reply);
    void rf__FetchGames(QNetworkReply* reply);
    void rf__FetchGamesIds(QNetworkReply* reply);
    void rf__FetchMatchInfo(QNetworkReply* reply);

signals:
    void errorOccurred(QString errorMsg);
    void championsFetched(QJsonObject obj);
    void gamesFetched(QVariantMap res);

private:
    QNetworkAccessManager m_manager;
    QString m_apiKey;
    QString m_regionInfo;
    RequestMode m_mode;

    QQueue<QString> m_puuids;
    QQueue<QString> m_matches;

    QString m_summonerName;

    /** Incrementa questo valore per ottenere un pool di incontri maggiori e rendere la statistica così più veritiera
        Lascio il counter basso per rispettare le limitazioni offerte dal piano gratuito della Riot API */
    size_t m_matchesPerPuuid = 1;

    int16_t     m_winCounter;
    uint16_t    m_winRate;

    bool checkApiKey();
    QString normalizeSummonerName(const QString &summonerName);
    void processNextMatchByPuuid();
    void processNextMatchInfoByMatchId();
    float calculateWinRate();
    QVariantMap generateResult(QString flagCanGenerate);

private slots:
    void onReplyFinished(QNetworkReply* reply);
};

#endif // NET_H
