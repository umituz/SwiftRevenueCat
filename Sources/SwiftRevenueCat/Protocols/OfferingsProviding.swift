import Foundation

@MainActor
public protocol OfferingsProviding: AnyObject {
    func fetchOfferings() async
    func refreshStatus() async
}
