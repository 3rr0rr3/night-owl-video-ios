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

enum ClerkHandoff {
    static let duration = 2.4
    static let transfer = 1.55
    static func ease(_ value: Double) -> Double { let p = min(1,max(0,value)); return p*p*(3-2*p) }
    static func x(width: Double,time: Double) -> Double {
        let service = max(56,min(width-80,width*0.83-38))
        let approach = time < 0.7 ? ease(time/0.7) : (time < 1.9 ? 1 : 1-ease((time-1.9)/0.5))
        return 56 + (service-56)*approach
    }
    static func walking(_ time: Double) -> Bool { time >= 0 && (time < 0.7 || (time >= 1.9 && time < duration)) }
    static func bob(_ time: Double) -> Double { walking(time) ? abs(sin(time*13))*1.5 : 0 }
    static func reach(_ time: Double) -> Double {
        if time < 1.2 { return ease((time-0.7)/0.5) }
        if time < transfer { return 1 }
        return 1-ease((time-transfer)/0.35)
    }
    static func customerDrop(_ time: Double) -> Double { 30*ease((time-transfer)/(duration-transfer)) }
    static func arm(width: Double,time: Double) -> (shoulder:CGPoint,elbow:CGPoint,wrist:CGPoint) {
        let cx = x(width:width,time:time), r = reach(time), b = bob(time)
        return (CGPoint(x:cx+20,y:89-b),CGPoint(x:cx+30+9*r,y:105+10*r-b),CGPoint(x:cx+25+(width*0.83+26-cx-25)*r,y:113+30*r-b))
    }
    static func tape(width: Double,time: Double) -> CGPoint {
        if time >= transfer { return CGPoint(x:width*0.83+32,y:134+customerDrop(time)) }
        let hand = arm(width:width,time:time).wrist
        return CGPoint(x:hand.x+6,y:hand.y-9)
    }
}
enum CustomerWalkStage { case waiting, arriving, handoff, leaving }
enum CustomerWalking {
    static let arrival = 1.35
    static let departure = 1.6
    static let handoff = ClerkHandoff.duration
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
