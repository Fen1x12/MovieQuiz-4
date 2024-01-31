import Foundation

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount, corectAnswerAll, totalAnswerAll
    }
    var totalAccuracy: Double {
        get {
            print("### get totalAccuracy: \(userDefaults.double(forKey: Keys.total.rawValue))")
            return userDefaults.double(forKey: Keys.total.rawValue)
        }
        set {
            print("### set totalAccuracy: \(newValue)")
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    var corectAnswerAll: Int {
        get {
            print("### get corectAnswerAll: \(userDefaults.integer(forKey: Keys.corectAnswerAll.rawValue))")
            return userDefaults.integer(forKey: Keys.corectAnswerAll.rawValue)
        }
        set {
            print("### set corectAnswerAll: \(newValue)")
            userDefaults.set(newValue, forKey: Keys.corectAnswerAll.rawValue)
        }
    }
    
    var totalAnswerAll: Int {
        get {
            print("### get totalAnswerAll: \(userDefaults.integer(forKey: Keys.totalAnswerAll.rawValue))")
            return userDefaults.integer(forKey: Keys.totalAnswerAll.rawValue)
        }
        set {
            print("### set totalAnswerAll: \(newValue)")
            userDefaults.set(newValue, forKey: Keys.totalAnswerAll.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            print("### get gamesCount: \(userDefaults.integer(forKey: Keys.gamesCount.rawValue))")
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            print("### set gamesCount: \(newValue)")
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    func store(correct count: Int, total amount: Int) {
        let newRecord = GameRecord(correct: count, total: amount, date: Date())
        if newRecord.isBetterThan(bestGame) {
            bestGame = newRecord
        }
        gamesCount += 1
        //let totalCorrectAnswers = bestGame.correct + count
        //let totalQuestions = bestGame.total + amount
        //totalAccuracy = Double(totalCorrectAnswers) / Double(totalQuestions)
        totalAccuracy = Double(corectAnswerAll) / Double(totalAnswerAll)
    }
}
