import Foundation
import Combine

/// A manual target, held until the user changes it. Never resets at midnight.
final class TaperStore: ObservableObject {
    static let storageKey = "coffeeTaper.eighths.v1"
    @Published private(set) var eighths: Int
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let saved = defaults.object(forKey: Self.storageKey) as? Int {
            eighths = Self.clamp(saved)
        } else {
            eighths = 8
        }
    }

    var fraction: Double { Double(eighths) / 8 }
    var label: String { Self.labels[eighths] }
    var spokenLabel: String { Self.spokenLabels[eighths] }

    func setEighths(_ value: Int) {
        let next = Self.clamp(value)
        guard next != eighths else { return }
        eighths = next
        defaults.set(next, forKey: Self.storageKey)
    }

    static func level(at y: Double, height: Double) -> Int {
        guard height > 0, y.isFinite, height.isFinite else { return 8 }
        let position = min(1, max(0, y / height))
        return Int(((1 - position) * 8).rounded())
    }

    private static func clamp(_ value: Int) -> Int { min(8, max(0, value)) }
    private static let labels = ["0", "⅛", "¼", "⅜", "½", "⅝", "¾", "⅞", "1"]
    private static let spokenLabels = [
        "No coffee", "One eighth of a cup", "One quarter of a cup",
        "Three eighths of a cup", "Half a cup", "Five eighths of a cup",
        "Three quarters of a cup", "Seven eighths of a cup", "One full cup"
    ]
}
