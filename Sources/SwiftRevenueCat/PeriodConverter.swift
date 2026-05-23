import Foundation
import RevenueCat

enum PeriodConverter {

    private static let daysPerWeek = 7
    private static let daysPerMonth = 30
    private static let daysPerYear = 365

    static func daysInPeriod(_ period: SubscriptionPeriod) -> Int {
        let days: Int
        switch period.unit {
        case .day:
            days = period.value
        case .week:
            days = period.value * daysPerWeek
        case .month:
            days = period.value * daysPerMonth
        case .year:
            days = period.value * daysPerYear
        @unknown default:
            days = period.value
        }
        return days
    }

    static func toDateComponents(_ period: SubscriptionPeriod) -> DateComponents {
        switch period.unit {
        case .day:   return DateComponents(day: period.value)
        case .week:  return DateComponents(weekOfMonth: period.value)
        case .month: return DateComponents(month: period.value)
        case .year:  return DateComponents(year: period.value)
        @unknown default: return DateComponents()
        }
    }
}
