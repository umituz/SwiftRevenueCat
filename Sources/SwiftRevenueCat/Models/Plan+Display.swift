extension Plan {

    public var isAnnual: Bool { packageType == .annual }

    public var isWeekly: Bool { packageType == .weekly }

    public var isMonthly: Bool { packageType == .monthly }

    public var isLifetime: Bool { packageType == .lifetime }

    public var displaySubtitle: String {
        if let offerDescription {
            return offerDescription
        }
        return "\(price)\(period)"
    }
}
