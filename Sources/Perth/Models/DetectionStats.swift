import Foundation
import Combine

struct DailyStat: Identifiable {
    let id: String // "yyyy-MM-dd"
    let date: Date
    var count: Int
    var byType: [PatternType: Int]
}

class DetectionStats: ObservableObject {
    @Published var dailyStats: [DailyStat] = []

    private let key = "detectionStatsData"
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    init() {
        loadStats()
    }

    func record(patterns: [SensitiveDataMatch]) {
        let today = dateFormatter.string(from: Date())

        if let idx = dailyStats.firstIndex(where: { $0.id == today }) {
            dailyStats[idx].count += patterns.count
            for p in patterns {
                dailyStats[idx].byType[p.patternType, default: 0] += 1
            }
        } else {
            var byType: [PatternType: Int] = [:]
            for p in patterns { byType[p.patternType, default: 0] += 1 }
            let stat = DailyStat(id: today, date: Date(), count: patterns.count, byType: byType)
            dailyStats.insert(stat, at: 0)
        }

        // Keep last 30 days
        if dailyStats.count > 30 {
            dailyStats = Array(dailyStats.prefix(30))
        }
        saveStats()
    }

    var todayCount: Int {
        let today = dateFormatter.string(from: Date())
        return dailyStats.first(where: { $0.id == today })?.count ?? 0
    }

    var weekCount: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        return dailyStats.filter { $0.date >= weekAgo }.reduce(0) { $0 + $1.count }
    }

    var topPatternThisWeek: PatternType? {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        var totals: [PatternType: Int] = [:]
        for stat in dailyStats where stat.date >= weekAgo {
            for (type, count) in stat.byType {
                totals[type, default: 0] += count
            }
        }
        return totals.max(by: { $0.value < $1.value })?.key
    }

    private func saveStats() {
        var data: [[String: Any]] = []
        for stat in dailyStats {
            var byTypeRaw: [String: Int] = [:]
            for (k, v) in stat.byType { byTypeRaw[k.rawValue] = v }
            data.append([
                "id": stat.id,
                "date": stat.date.timeIntervalSince1970,
                "count": stat.count,
                "byType": byTypeRaw,
            ])
        }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func loadStats() {
        guard let data = UserDefaults.standard.array(forKey: key) as? [[String: Any]] else { return }
        dailyStats = data.compactMap { dict in
            guard let id = dict["id"] as? String,
                  let ts = dict["date"] as? TimeInterval,
                  let count = dict["count"] as? Int else { return nil }
            let byTypeRaw = dict["byType"] as? [String: Int] ?? [:]
            var byType: [PatternType: Int] = [:]
            for (k, v) in byTypeRaw {
                if let pt = PatternType(rawValue: k) { byType[pt] = v }
            }
            return DailyStat(id: id, date: Date(timeIntervalSince1970: ts), count: count, byType: byType)
        }
    }

    func exportJSON() -> String {
        var result: [[String: Any]] = []
        for stat in dailyStats {
            var byTypeRaw: [String: Int] = [:]
            for (k, v) in stat.byType { byTypeRaw[k.rawValue] = v }
            result.append(["date": stat.id, "count": stat.count, "byType": byTypeRaw])
        }
        guard let data = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted),
              let str = String(data: data, encoding: .utf8) else { return "[]" }
        return str
    }
}
