import Foundation

enum CustomerWalkStage { case waiting, arriving, handoff, leaving }
enum CustomerWalking {
    static let arrival = 1.35
    static let departure = 1.6
    static let handoff = 0.85
    static func progress(_ elapsed: Double,duration: Double) -> Double { min(1,max(0,elapsed / duration)) }
    static func position(stage: CustomerWalkStage,elapsed: Double,width: Double) -> Double {
        let counter = width * 0.83
        let door = width + 48
        switch stage {
        case .arriving: return door + (counter - door) * progress(elapsed,duration:arrival)
        case .leaving: return counter + (door - counter) * progress(elapsed,duration:departure)
        default: return counter
        }
    }
}
struct CounterCustomer {
    var id: UUID
    var index: Int
    var name: String
    var movie: Int? = nil
    init(_ guest: Guest) { id = guest.id; index = guest.characterIndex; name = guest.name }
}
