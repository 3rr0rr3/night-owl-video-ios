import Foundation

// Coordinates share the customer's 80 × 130 canvas. The shoulder never moves
// independently of the body, so there is no detached overlay or extra arm.
struct CustomerArmPose {
    let shoulder = CGPoint(x:19,y:63)
    let elbow: CGPoint
    let wrist: CGPoint
    init(gesture: String,time: Double) {
        let sway = sin(time * 4)
        switch gesture {
        case "waiting": elbow = CGPoint(x:12,y:83); wrist = CGPoint(x:32,y:82 + sway)
        case "unsure": elbow = CGPoint(x:7,y:60); wrist = CGPoint(x:21,y:38 + sway)
        case "happy": elbow = CGPoint(x:8,y:61); wrist = CGPoint(x:8 + sway * 3,y:43 + sway * 2)
        default: elbow = CGPoint(x:10,y:78); wrist = CGPoint(x:23,y:66 + sway * 3)
        }
    }
}

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
