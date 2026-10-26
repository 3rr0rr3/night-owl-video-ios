import Foundation

struct DayReport: Codable, Identifiable {
    var id = UUID()
    var day: Int
    var revenue: Int
    var bonus: Int
    var purchases: Int
    var bills: Int
    var customers: Int
    var returns: Int
    var grant: Int
    var tomorrow: String
    var profit: Int { revenue + bonus - purchases - bills }
}
struct Experience: Codable {
    var tutorialDone = false
    var relaxed = false
    var autoChange = false
    var expenses = 0
    var bonus = 0
    var customers = 0
    var returns = 0
    var owned = ["poster-owl", "shelf-original", "counter-original"]
    var poster = "poster-owl"
    var shelf = "shelf-original"
    var counter = "counter-original"
    var report: DayReport? = nil
    var reportPending = false
}
struct ShopStyle: Identifiable {
    let id: String
    let name: String
    let group: String
    let cost: Int
    let rentals: Int
    static let all = [
        ShopStyle(id: "poster-owl",name: "Moon & stars",group: "POSTERS",cost: 0,rentals: 0),
        ShopStyle(id: "poster-space",name: "Space premiere",group: "POSTERS",cost: 20,rentals: 2),
        ShopStyle(id: "poster-creature",name: "Creature feature",group: "POSTERS",cost: 25,rentals: 5),
        ShopStyle(id: "shelf-original",name: "Midnight shelves",group: "SHELVES",cost: 0,rentals: 0),
        ShopStyle(id: "shelf-walnut",name: "Warm walnut",group: "SHELVES",cost: 30,rentals: 3),
        ShopStyle(id: "shelf-mint",name: "Mint trim",group: "SHELVES",cost: 35,rentals: 8),
        ShopStyle(id: "counter-original",name: "Classic coral",group: "COUNTERS",cost: 0,rentals: 0),
        ShopStyle(id: "counter-gold",name: "Golden hour",group: "COUNTERS",cost: 30,rentals: 4),
        ShopStyle(id: "counter-lavender",name: "Lavender nights",group: "COUNTERS",cost: 40,rentals: 10)
    ]
}
struct TaskHint {
    let title: String
    let detail: String
    let station: String
}
extension Store {
    var guiding: Bool { !experience.tutorialDone }
    var tutorialStep: Int {
        if !s.open && s.guests.isEmpty { return 1 }
        guard let guest = s.guests.first else { return 2 }
        if guest.movie == nil { return 2 }
        if !guest.scanned { return 3 }
        if !guest.paid { return 4 }
        return 5
    }
    var nextTask: TaskHint {
        if experience.reportPending { return TaskHint(title: "Your day is complete",detail: "Review your earnings and tomorrow’s plan.",station: "REPORT") }
        if let g = s.guests.first {
            if g.movie == nil {
                let available = s.movies.contains { $0.genre == g.genre && $0.stock > 0 }
                return TaskHint(title: available ? "Choose a \(g.genre.lowercased()) movie" : "Restock or reserve a movie",detail: "\(g.name) is waiting. \(available ? "Look for the highlighted genre on Shelves." : "Order a copy on Store PC, or reserve it at Counter.")",station: available ? "SHELVES" : "STORE PC")
            }
            if !g.scanned { return TaskHint(title: "Scan the VHS",detail: "Return to Counter and scan \(g.name)’s movie.",station: "COUNTER") }
            if !g.paid { return TaskHint(title: "Collect the $10 payment",detail: "The rental total is $\(price).",station: "COUNTER") }
            return TaskHint(title: "Give $\(10 - price) change and rent",detail: experience.autoChange ? "Automatic change is ready. Confirm the rental at Counter." : "Count the change, then tap Give change & rent.",station: "COUNTER")
        }
        if guiding { return TaskHint(title: "Open the store",detail: "Your first customer will help you learn. The clock pauses during this guide.",station: "COUNTER") }
        if !s.returns.isEmpty { return TaskHint(title: "Process \(s.returns.count) returned tapes",detail: "Scan, inspect fees, rewind, then shelve each tape.",station: "RETURNS") }
        if !s.held.isEmpty { return TaskHint(title: "Collect reserved rentals",detail: "Reserved copies are ready at Returns.",station: "RETURNS") }
        if canFinishChapter { return TaskHint(title: "Complete your story chapter",detail: "Your goals are complete. Collect the reward in Story.",station: "STORY") }
        if s.minutes >= 1200 { return TaskHint(title: "Close the day",detail: "The queue and return bin are clear. Review bills at Store PC.",station: "STORE PC") }
        if !s.open { return TaskHint(title: "Open the store",detail: "Start the next shift when you’re ready.",station: "COUNTER") }
        if s.dirt > 0 { return TaskHint(title: "Tidy up between customers",detail: "Clean \(s.dirt) spills at Store PC, or invite a customer at Counter.",station: "STORE PC") }
        return TaskHint(title: "Welcome the next customer",detail: "Invite someone at Counter or work on your Story goals.",station: "COUNTER")
    }
    func badge(_ tab: String) -> Int {
        switch tab {
        case "COUNTER": return s.guests.count
        case "RETURNS": return s.returns.count + s.held.count
        case "STORY": return canFinishChapter ? 1 : 0
        case "STORE PC": return s.dirt
        default: return 0
        }
    }
    func skipTutorial() { experience.tutorialDone = true; say("Guide finished. The next-task card is always here to help.") }
    func selected(_ group: String) -> String { group == "POSTERS" ? experience.poster : (group == "SHELVES" ? experience.shelf : experience.counter) }
    func selectStyle(_ item: ShopStyle) {
        guard ShopStyle.all.contains(where: { $0.id == item.id }) else { return }
        guard s.served >= item.rentals else { say("Unlock \(item.name) after \(item.rentals) rentals."); return }
        if !experience.owned.contains(item.id) {
            guard s.money >= item.cost else { say("Save $\(item.cost) for \(item.name)."); return }
            s.money -= item.cost; experience.expenses += item.cost; experience.owned.append(item.id)
            s.decor += 1
        }
        switch item.group { case "POSTERS": experience.poster = item.id; case "SHELVES": experience.shelf = item.id; default: experience.counter = item.id }
        say("\(item.name) is on display. Your store, your style.")
    }
    func dismissReport() { experience.reportPending = false; save() }
}
