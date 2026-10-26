import Foundation

struct DeskEvent: Identifiable {
    enum Kind { case scan, payment, sale, fee }
    let id = UUID()
    let kind: Kind
    let title: String
    var amount = 0
    var change = 0
    let started = Date()
    var duration: Double { kind == .scan ? 1.8 : 2.6 }
}
extension Store {
    func deskCue(_ kind: DeskEvent.Kind,_ title: String,amount: Int = 0,change: Int = 0) {
        deskEvent = DeskEvent(kind: kind,title: title,amount: amount,change: change)
    }
}
