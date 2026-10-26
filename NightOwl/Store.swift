import Foundation
import Combine

struct Movie: Codable, Identifiable {
    var id: Int
    var title: String
    var genre: String
    var stock: Int = 3
}
struct Tape: Codable, Identifiable {
    var id = UUID()
    var movie: Int
    var rewound = false
    var scanned = false
    var late = false
    var damaged = false
    var assessed = false
}
struct Guest: Codable, Identifiable {
    var id = UUID()
    var name: String
    var genre: String
    var movie: Int? = nil
    var scanned = false
    var paid = false
    var cash = 10
    var snack = false
    var reserved = false
}
struct Save: Codable {
    var day = 1
    var money = 150
    var xp = 0
    var served = 0
    var sales = 0
    var open = false
    var minutes = 600
    var dirt = 2
    var decor = 0
    var staff = false
    var movies = [Movie(id: 0, title: "Moon Mall", genre: "SCI-FI"), Movie(id: 1, title: "Camp After Dark", genre: "HORROR"), Movie(id: 2, title: "Rad Dad", genre: "COMEDY"), Movie(id: 3, title: "Last Bus Hero", genre: "ACTION"), Movie(id: 4, title: "Love on Tape", genre: "ROMANCE"), Movie(id: 5, title: "Tiny Detectives", genre: "FAMILY")]
    var guests: [Guest] = []
    var returns = [Tape(movie: 0, late: true), Tape(movie: 1, damaged: true)]
    var rentals: [Int] = []
    var reservations: [Int] = []
    var held: [Int] = []
}
@MainActor final class Store: ObservableObject {
    @Published var s: Save
    @Published var message = "Welcome to Night Owl. Open the doors when you're ready."
    @Published var station = "COUNTER"
    @Published var change = 0
    @Published var story = StoryProgress()
    @Published var speakingGuest: UUID? = nil
    @Published var rewinding: UUID? = nil
    @Published var earned = 0
    @Published var effectID = UUID()
    var names: [String] { Cast.all.map { $0.name } }
    init() {
        if let data = UserDefaults.standard.data(forKey: "nightowl.save"), let saved = try? JSONDecoder().decode(Save.self, from: data) { s = saved } else { s = Save() }
        if let data = UserDefaults.standard.data(forKey: "nightowl.story"), let saved = try? JSONDecoder().decode(StoryProgress.self, from: data) { story = saved }
    }
    var chapter: Chapter { Storybook.chapters[min(story.chapter, Storybook.chapters.count - 1)] }
    var storyFinished: Bool { story.chapter >= Storybook.chapters.count }
    var storyGoals: [StoryGoal] {
        guard !storyFinished else { return [] }
        func g(_ text: String, _ value: Int, _ target: Int) -> StoryGoal { StoryGoal(label: text, value: value, target: target) }
        switch story.chapter {
        case 0: return [g("Rent 2 movies", story.rentals, 2), g("Process a return", story.returns, 1)]
        case 1: return [g("Talk to 3 different regulars", story.talked.count, 3), g("Order a tape", story.orders, 1), g("Choose the movie-night theme", story.theme == nil ? 0 : 1, 1)]
        case 2: return [g("Rent 3 movies", story.rentals, 3), g("Sell a popcorn combo", story.snacks, 1), g("Clean 2 spills", story.cleanups, 2)]
        case 3: return [g("Process 3 returns", story.returns, 3), g("Talk to Ravi", story.talked.contains(8) ? 1 : 0, 1)]
        case 4: return [g("Hire Bea", s.staff ? 1 : 0, 1), g("Decorate the store", s.decor, 1), g("Rent 2 movies", story.rentals, 2)]
        case 5: return [g("Pledge $40 for the projector", story.pledged, 40), g("Rent 4 movies", story.rentals, 4), g("Talk to Gus", story.talked.contains(7) ? 1 : 0, 1)]
        default: return [g("Rent 5 movies", story.rentals, 5), g("Process 2 returns", story.returns, 2)]
        }
    }
    var canFinishChapter: Bool { !storyFinished && storyGoals.allSatisfy { $0.complete } }
    func chooseTheme(_ theme: String) {
        guard story.chapter == 1, story.theme == nil, ["Creature feature", "Space double bill"].contains(theme) else { return }
        story.theme = theme; say("Movie night theme chosen: \(theme). Frank is finding the perfect second feature.")
    }
    func talk() {
        guard let guest = s.guests.first else { return }
        let i = guest.characterIndex
        if !story.talked.contains(i) { story.talked.append(i) }
        speakingGuest = guest.id
        let words = !storyFinished && chapter.lead == i ? Storybook.sceneLines[story.chapter] : guest.regular.lines[min(story.chapter / 3, 2)]
        say("\(guest.name): “\(words)”")
        Task { try? await Task.sleep(nanoseconds: 4_000_000_000); if self.speakingGuest == guest.id { self.speakingGuest = nil } }
    }
    func pledge() {
        guard story.chapter == 5, story.pledged < 40 else { return }
        guard s.money >= 40 else { say("Save $40 for the projector rental."); return }
        s.money -= 40; story.pledged = 40; say("Projector reserved. Gus is bringing food; Marisol is picking up the screen.")
    }
    func finishChapter() {
        guard canFinishChapter else { say("Complete this chapter's goals first. Progress carries across days."); return }
        let reward = chapter.reward
        let theme = story.theme
        let pledged = story.pledged
        let next = story.chapter + 1
        story = StoryProgress(); story.chapter = next; story.theme = theme; story.pledged = pledged
        s.money += reward; s.xp += 20; cashBurst(reward)
        if storyFinished {
            say("The \(theme ?? "neighborhood") screening is a hit. Nina's article helps secure a new lease. June's owl sign stays lit. Thank you for keeping Night Owl alive. Keep playing in free play!")
        } else { say("Chapter complete! +$\(reward). Next: \(chapter.title). Open STORY to read the next scene.") }
    }
    func cashBurst(_ amount: Int) {
        earned = amount
        let token = UUID(); effectID = token
        Task { try? await Task.sleep(nanoseconds: 2_000_000_000); if self.effectID == token { self.earned = 0 } }
    }
    func startRewind() {
        guard let tape = s.returns.first, !tape.rewound, rewinding == nil else { return }
        rewinding = tape.id; say("Rewinding… watch the reels. This takes a few seconds.")
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if self.s.returns.first?.id == tape.id { self.process("rewind") }
            self.rewinding = nil
        }
    }
    var hasSavedGame: Bool { UserDefaults.standard.data(forKey: "nightowl.save") != nil }
    func newGame() {
        s = Save(); story = StoryProgress(); speakingGuest = nil; rewinding = nil; earned = 0; effectID = UUID(); change = 0; station = "COUNTER"
        message = "Aunt June left you the keys. Explore Night Owl and open the store when you're ready."
        save()
    }
    var price: Int { 4 + ((s.guests.first?.snack ?? false) ? 3 : 0) }
    var level: Int { 1 + s.xp / 50 }
    var clock: String { String(format: "%02d:%02d", s.minutes / 60, s.minutes % 60) }
    func save() {
        if let data = try? JSONEncoder().encode(s) { UserDefaults.standard.set(data, forKey: "nightowl.save") }
        if let data = try? JSONEncoder().encode(story) { UserDefaults.standard.set(data, forKey: "nightowl.story") }
    }
    func say(_ text: String) { message = text; save() }
    func addGuest() {
        guard s.guests.count < 5 else { return }
        let lead = chapter.lead
        let needsLead = !storyFinished && !story.talked.contains(lead) && !s.guests.contains { $0.name == Cast.all[lead].name }
        let n = needsLead ? lead : (s.served + s.guests.count + s.day * 3) % names.count
        let person = Cast.all[n]
        s.guests.append(Guest(name: person.name, genre: person.genre, snack: (s.served + s.guests.count) % 3 == 1))
    }

    func tick() {
        guard s.open else { return }
        s.minutes += 1
        if s.minutes % (s.day % 3 == 0 ? 14 : 22) == 0 { addGuest() }
        if s.minutes % 47 == 0 { s.dirt = min(8, s.dirt + 1) }
        if s.staff && s.minutes % 15 == 0 { if !s.returns.isEmpty { s.returns[0].rewound = true }; s.dirt = max(0, s.dirt - 1) }
        if s.minutes >= 1200 { s.open = false; say("Closing time. Finish the queue and returns, then close the day.") }
        save()
    }
    func doors() {
        guard !s.open else { return }
        s.open = true; if s.minutes >= 1200 { s.minutes = 600 }; addGuest(); say("Doors open! Match a movie to each customer's request.")
    }
    func recommend(_ i: Int) {
        guard !s.guests.isEmpty, s.guests[0].movie == nil else { return }
        guard s.movies[i].stock > 0 else { say("Out of stock. Order more on the store PC."); return }
        guard s.movies[i].genre == s.guests[0].genre else { say("That's not the genre they asked for. Try another shelf."); return }
        s.guests[0].movie = i; say("Great recommendation. Scan the VHS at the counter.")
    }
    func scan() { guard !s.guests.isEmpty, s.guests[0].movie != nil else { say("Choose a movie from the shelves first."); return }; s.guests[0].scanned = true; say("Rental scanned. Collect payment, then count out the change.") }
    func payment() { guard !s.guests.isEmpty, s.guests[0].scanned else { return }; s.guests[0].paid = true; change = 0; say("Customer handed you $10. Count $\(10 - price) change.") }
    func checkout() {
        guard let g = s.guests.first, let i = g.movie, g.paid else { return }
        guard change == 10 - price else { say("Check your change. The total is $\(price), paid $10."); return }
        let total = price
        story.rentals += 1; if g.snack { story.snacks += 1 }; cashBurst(total)
        s.movies[i].stock -= 1; s.rentals.append(i); s.money += total; s.sales += total; s.served += 1; s.xp += 8; s.guests.removeFirst(); change = 0
        say("Be kind, rewind! Rental complete. +$\(total)")
    }
    func reserve() {
        guard let g = s.guests.first, g.movie == nil else { return }
        let i = s.movies.firstIndex(where: { $0.genre == g.genre })!
        guard !s.reservations.contains(i), !s.held.contains(i) else { say("That title already has a reservation."); return }
        s.reservations.append(i); s.guests.removeFirst(); s.xp += 3; say("\(g.name)'s reservation is logged. Set the next returned copy aside.")
    }
    func process(_ task: String) {
        guard !s.returns.isEmpty else { return }
        switch task {
        case "scan": s.returns[0].scanned = true; say("Return checked into the system.")
        case "fee":
            guard s.returns[0].scanned, !s.returns[0].assessed else { return }
            let fee = (s.returns[0].late ? 2 : 0) + (s.returns[0].damaged ? 5 : 0)
            s.money += fee; s.sales += fee; s.returns[0].assessed = true; say(fee > 0 ? "Collected $\(fee) in late / damage fees. Customer grumbles." : "No fees. Thanks for returning on time!")
        case "rewind": s.returns[0].rewound = true; say("Whirrr… tape rewound to the beginning.")
        default:
            let t = s.returns[0]
            guard t.scanned && t.assessed && t.rewound else { say("Scan, inspect fees, and rewind this tape first."); return }
            if s.reservations.contains(t.movie) { s.reservations.removeAll { $0 == t.movie }; s.held.append(t.movie); say("Reserved copy set aside. Collect it from the reservations desk.") }
            else { s.movies[t.movie].stock += 1; say("Tape shelved in \(s.movies[t.movie].genre).") }
            s.returns.removeFirst(); s.xp += 5; story.returns += 1
        }
        save()
    }
    func collectHold(_ i: Int) { guard s.held.contains(i) else { return }; story.rentals += 1; cashBurst(4); s.held.removeAll { $0 == i }; s.rentals.append(i); s.money += 4; s.sales += 4; s.xp += 5; say("Reserved rental collected. +$4") }
    func buy(_ i: Int) { guard s.money >= 12 else { say("You need $12 to order a tape."); return }; s.money -= 12; s.movies[i].stock += 1; story.orders += 1; say("Delivery arrived: \(s.movies[i].title). +1 copy") }
    func clean() { guard s.dirt > 0 else { say("The store is spotless."); return }; s.dirt -= 1; s.xp += 2; story.cleanups += 1; say("Spill cleaned. A tidy store keeps customers happy.") }
    func upgrade() { let cost = 40 + s.decor * 30; guard s.money >= cost else { say("Save $\(cost) for the next store upgrade."); return }; s.money -= cost; s.decor += 1; s.xp += 10; say("New posters and shelf space! Store style upgraded.") }
    func hire() { guard !s.staff, s.money >= 60 else { say("Hiring costs $60; wages are $15 per day."); return }; s.money -= 60; s.staff = true; say("Bea joined the team. She helps clean and rewind during opening hours.") }
    func nextDay() {
        guard s.guests.isEmpty && s.returns.isEmpty else { say("Finish the queue and return bin before closing."); return }
        guard s.open || s.minutes >= 1200 || s.sales > 0 || !s.rentals.isEmpty else { say("Open the store and finish a shift before starting a new day."); return }
        let bills = 15 + (s.staff ? 15 : 0); s.money -= bills
        for (n, i) in s.rentals.enumerated() { s.returns.append(Tape(movie: i, late: n % 3 == 0, damaged: n % 5 == 2)) }
        s.rentals = []; s.day += 1; s.minutes = 600; s.open = false; s.sales = 0; s.dirt = min(8, s.dirt + 1)
        if s.money < 0 { s.money = 25; say("A $25 emergency grant keeps your shop afloat. Day \(s.day) is ready.") } else { say("Paid $\(bills) in bills. Day \(s.day) is ready; yesterday's rentals are in the return bin.") }
    }
}
