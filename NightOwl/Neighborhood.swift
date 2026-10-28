import Foundation

struct Neighborhood: Codable {
    var friendship: [String:Int] = [:]
    var chatted: [String:Int] = [:]
    var gifts: [Int] = []
    var reputation = 0
    var rare: [Int] = []
    var searchedDay = 0
    var tradedDay = 0
    var eventClaimedDay = 0
    var effects = true
    var music = false
    var moods = true
}
struct ShopSlot: Codable {
    var shop: Save
    var story: StoryProgress
    var experience: Experience
    var neighborhood: Neighborhood
    var cinema: CinemaProgress? = nil
    var expansion: ExpansionProgress? = nil
}
struct ShopEvent {
    let title: String
    let detail: String
    let target: Int
    let genre: String?
    static let schedule = [
        ShopEvent(title: "Neighborhood movie night",detail: "Serve 4 rentals and earn a $15 community tip.",target: 4,genre: nil),
        ShopEvent(title: "Midnight sci-fi premiere",detail: "Sci-fi fans are visiting. Serve 5 rentals for a $20 event bonus.",target: 5,genre: "SCI-FI"),
        ShopEvent(title: "Rainy-day rush",detail: "More visitors, cozy rain and a horror spotlight. Serve 6 rentals for $25.",target: 6,genre: "HORROR"),
        ShopEvent(title: "Comedy weekend",detail: "Comedy is on the marquee. Serve 5 rentals for $20.",target: 5,genre: "COMEDY")
    ]
}
extension Store {
    var todayEvent: ShopEvent { ShopEvent.schedule[(s.day - 1) % ShopEvent.schedule.count] }
    var reputationName: String { neighborhood.reputation >= 60 ? "Town favorite" : (neighborhood.reputation >= 25 ? "Local favorite" : "New on the block") }
    func bond(_ index: Int) -> Int { neighborhood.friendship[String(index),default: 0] }
    func befriend(_ index: Int) {
        let key = String(index)
        syncExpansionWeek()
        let previous = bond(index)
        neighborhood.friendship[key] = min(6,previous + 1)
        expansion.weeklyFriends += bond(index) - previous
        if bond(index) != previous && [3,6].contains(bond(index)) { celebrate("\(Cast.all[index].name) · \(bond(index) == 6 ? "Best friends!" : "New friendship badge!")") }
        if bond(index) >= 3 && !neighborhood.gifts.contains(index) {
            neighborhood.gifts.append(index)
            discoverRare(index % 6)
        }
    }
    func discoverRare(_ id: Int) {
        let edition = id % 6
        if !neighborhood.rare.contains(edition) { neighborhood.rare.append(edition); syncExpansionWeek(); expansion.weeklyCollection += 1; celebrate("Rare VHS discovered · \(s.movies[edition].title)",movie:edition,rare:true) }
    }
    func donationBox() {
        guard neighborhood.searchedDay != s.day else { say("The donation box is empty. Check again tomorrow."); return }
        neighborhood.searchedDay = s.day
        if let next = (0..<6).first(where: { !neighborhood.rare.contains($0) }) {
            discoverRare(next); say("Found a collector’s edition of \(s.movies[next].title)! Display it in your collection.")
        } else { say("Your rare VHS collection is complete. The neighbors are impressed!") }
    }
    func tradeSpareTape() {
        guard neighborhood.reputation >= 10 else { say("Reach 10 reputation to join the VHS trading circle."); return }
        guard neighborhood.tradedDay != s.day, let rare = (0..<6).first(where: { !neighborhood.rare.contains($0) }), let spare = s.movies.firstIndex(where: { $0.stock > 1 }) else { say("Trade once a day with a spare tape; your collection may already be complete."); return }
        s.movies[spare].stock -= 1; neighborhood.tradedDay = s.day; discoverRare(rare)
        say("Traded one spare \(s.movies[spare].title) for a collector’s cut of \(s.movies[rare].title).")
    }
    func completeEvent() {
        guard experience.customers >= todayEvent.target, neighborhood.eventClaimedDay != s.day else { return }
        neighborhood.eventClaimedDay = s.day
        let reward = 15 + (todayEvent.target - 4) * 5
        s.money += reward; experience.bonus += reward; neighborhood.reputation = min(100,neighborhood.reputation + 5)
        cashBurst(reward)
    }
    func request(_ guest: Guest) -> String {
        guard neighborhood.moods else { return "Got any \(guest.genre.lowercased()) movies?" }
        switch guest.genre {
        case "SCI-FI": return "Something with strange planets and a big adventure."
        case "HORROR": return "Something spooky for a dark, rainy night."
        case "COMEDY": return "A funny movie to shake off a long shift."
        case "ACTION": return "Big stunts, a brave hero, and plenty of excitement."
        case "ROMANCE": return "Something sweet for a cozy date night."
        default: return "A clever mystery the whole family can enjoy."
        }
    }
    func friendLine(_ index: Int) -> String {
        guard bond(index) >= 3 else { return "" }
        let lines = ["I still remember the first tape I rented here.","I’m writing down your recommendations for my next free weekend.","This shop feels like a second home after a long day.","Let’s put together a staff-picks shelf someday.","Our movie club is getting bigger thanks to you.","I found an old screening flyer for your collection.","The night crew keeps asking what you recommend next.","I’ll bring snacks when you host the next screening.","That old home movie means more to us than you know.","I told my coworkers this is the best shop on Maple Street.","I’m sketching a new poster for the neighborhood screening.","I’ve started saving ticket stubs from our movie nights."]
        return " " + lines[index % lines.count] + (bond(index) == 6 ? " Whatever happens, you’ve got a friend on Maple Street." : "")
    }
    func repairCase(_ id: UUID) {
        guard let index = s.returns.firstIndex(where: { $0.id == id }), s.returns[index].damaged, s.returns[index].assessed else { return }
        s.returns[index].damaged = false; s.xp += 2; neighborhood.reputation = min(100,neighborhood.reputation + 1)
        say("Case repaired! The tape is ready for another movie night.")
    }
    func slotInfo(_ slot: Int) -> ShopSlot? {
        guard let data = UserDefaults.standard.data(forKey: "nightowl.slot.\(slot)") else { return nil }
        return try? JSONDecoder().decode(ShopSlot.self,from: data)
    }
    func switchSlot(_ slot: Int) {
        guard (0..<3).contains(slot), slot != selectedSlot else { return }
        if hasSavedGame { save() }
        clearShopLife()
        selectedSlot = slot; UserDefaults.standard.set(slot,forKey: "nightowl.active-slot")
        moviePickup = nil
        counterWalking = false; counterPresentedID = nil
        deskEvent = nil; rewinding = nil; speakingGuest = nil; change = 0; earned = 0; station = "COUNTER"
        if let saved = slotInfo(slot) {
            s = saved.shop; story = saved.story; experience = saved.experience; neighborhood = saved.neighborhood; cinema = saved.cinema ?? CinemaProgress(); expansion = saved.expansion ?? ExpansionProgress(); expandCatalog(); syncExpansionWeek()
            restorePendingPickup()
            say("Shop \(slot + 1) loaded. Welcome back to Night Owl.")
        } else {
            s = Save(); story = StoryProgress(); experience = Experience(); neighborhood = Neighborhood(); cinema = CinemaProgress(); expansion = ExpansionProgress(); expandCatalog()
            for key in ["nightowl.save","nightowl.story","nightowl.experience","nightowl.neighborhood","nightowl.cinema","nightowl.expansion"] { UserDefaults.standard.removeObject(forKey: key) }
            message = "Shop \(slot + 1) is empty. Start Game to open a new shop."
        }
    }
}
