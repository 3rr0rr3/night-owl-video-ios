import Foundation

struct UsedTapeOffer: Codable {
    var day: Int
    var movie: Int
    var grade: Int
    var inspected = false
    var attempts = 0
    var fairPrice: Int { [4,6,8][grade] }
    var condition: String { ["Worn case · playback tested", "Good case · clean playback", "Excellent collector copy"][grade] }
}
struct TownArticle: Codable, Identifiable {
    var id = UUID()
    var day: Int
    var title: String
    var body: String
}
struct ExpansionProgress: Codable {
    var layout = ["shelves":0,"posters":2,"counter":6,"snacks":8]
    var staffJob = "balanced"
    var week = 1
    var weeklyGoal: String? = nil
    var weeklyMoney = 0
    var weeklyFriends = 0
    var weeklyCollection = 0
    var weeklyClaimed = false
    var seasonalRentals = 0
    var seasonalClaimed = false
    var usedOffer: UsedTapeOffer? = nil
    var usedDoneDay = 0
    var clubDay = 0
    var clubFilms = [0,2]
    var clubHost = 0
    var clubSnacks = true
    var clubResult = ""
    var articles: [TownArticle] = []
}
struct FilmCredits {
    static let actors = ["Alex Vale","Maya Reed","Sam Rivers","Jules Park","Robin West","Casey Stone"]
    static func actor(_ film: Movie) -> String { actors[(film.id / 6 + film.id % 6) % actors.count] }
    static func minutes(_ film: Movie) -> Int { 78 + (film.id * 7 % 48) }
}
extension Store {
    var shopWeek: Int { (s.day - 1) / 7 + 1 }
    var seasonIndex: Int { (shopWeek - 1) % 4 }
    var seasonName: String { ["Spring rewind","Summer blockbusters","Halloween after dark","Winter movie nights"][seasonIndex] }
    var seasonGenre: String { ["ROMANCE","ACTION","HORROR","FAMILY"][seasonIndex] }
    var seasonSymbol: String { ["leaf.fill","sun.max.fill","moon.stars.fill","snowflake"][seasonIndex] }
    var seasonStory: String { ["Marisol is organizing a spring double bill. Help the neighborhood discover a new favorite.","Gus wants a summer stunt-movie marathon. The block is trading recommendations.","Nina is collecting spooky Maple Street stories for a Halloween issue. Horror rentals are in demand.","Frank is planning a cozy holiday screening. Family movies bring the neighborhood together."][seasonIndex] }
    var forecastGenres: [String] { Array(Set([seasonGenre,todayEvent.genre ?? Cast.all[(s.day * 3) % 12].genre])).sorted() }
    var lowStock: [Movie] { s.movies.filter { $0.stock < 2 } }
    func syncExpansionWeek() {
        guard expansion.week != shopWeek else { return }
        expansion.week = shopWeek; expansion.weeklyGoal = nil; expansion.weeklyMoney = 0; expansion.weeklyFriends = 0; expansion.weeklyCollection = 0; expansion.weeklyClaimed = false
        expansion.seasonalRentals = 0; expansion.seasonalClaimed = false
        publishArticle(seasonName,seasonStory)
    }
    func publishArticle(_ title: String,_ body: String) {
        expansion.articles.insert(TownArticle(day:s.day,title:title,body:body),at:0)
        expansion.articles = Array(expansion.articles.prefix(8))
    }
    func arrange(_ fixture: String,at cell: Int) {
        guard ["shelves","posters","counter","snacks"].contains(fixture),(0..<9).contains(cell),let old = expansion.layout[fixture] else { return }
        if let other = expansion.layout.first(where: { $0.value == cell && $0.key != fixture }) { expansion.layout[other.key] = old }
        expansion.layout[fixture] = cell; save()
    }
    func assignStaff(_ job: String) {
        guard s.staff,["balanced","cleaning","rewinding","restocking"].contains(job) else { return }
        expansion.staffJob = job; say("Bea’s assignment: \(job). She works every 15 shop minutes while open.")
    }
    func staffShift() {
        guard s.staff else { return }
        switch expansion.staffJob {
        case "cleaning": s.dirt = max(0,s.dirt - 1)
        case "rewinding":
            if let i = s.returns.firstIndex(where: { !$0.rewound }) { s.returns[i].rewound = true; shopAction(.rewindDone,"Bea rewound a returned tape",movie:s.returns[i].movie) }
        case "restocking":
            if s.returns.first.map({ $0.scanned && $0.assessed && $0.rewound }) == true { process("shelve") }
        default:
            if !s.returns.isEmpty { s.returns[0].rewound = true }; s.dirt = max(0,s.dirt - 1)
        }
    }
    var weeklyValue: Int { expansion.weeklyGoal == "income" ? expansion.weeklyMoney : (expansion.weeklyGoal == "friends" ? expansion.weeklyFriends : expansion.weeklyCollection) }
    var weeklyTarget: Int { expansion.weeklyGoal == "income" ? 80 : (expansion.weeklyGoal == "friends" ? 8 : 3) }
    func chooseWeekly(_ goal: String) {
        syncExpansionWeek()
        guard expansion.weeklyGoal == nil,["income","friends","collection"].contains(goal) else { return }
        expansion.weeklyGoal = goal; say("Week \(shopWeek) goal chosen. Your progress this week counts toward it.")
    }
    func claimWeekly() {
        syncExpansionWeek()
        guard expansion.weeklyGoal != nil,!expansion.weeklyClaimed,weeklyValue >= weeklyTarget else { return }
        expansion.weeklyClaimed = true
        let reward = expansion.weeklyGoal == "income" ? 35 : 25
        s.money += reward; experience.bonus += reward
        if expansion.weeklyGoal == "friends" { neighborhood.reputation = min(100,neighborhood.reputation + 5) }
        if expansion.weeklyGoal == "collection", let id = (0..<6).first(where: { !neighborhood.rare.contains($0) }) { discoverRare(id) }
        publishArticle("Night Owl meets its weekly goal","The neighborhood celebrates your \(expansion.weeklyGoal ?? "shop") project. The reward has been paid once.")
        celebrate("Weekly goal complete · +$\(reward)"); say("Weekly reward collected! +$\(reward). Choose a new goal next week.")
    }
    func recommendationHint(_ guest: Guest) -> String {
        let mode = guest.characterIndex % 4
        let favorite = s.movies.first(where: { $0.genre == guest.genre }) ?? s.movies[0]
        if mode == 1 { return "A \(FilmLibrary.details(favorite).tags[0]) movie, or any \(guest.genre.lowercased()) film." }
        if mode == 2 { return "Anything starring \(FilmCredits.actor(favorite)), or a \(guest.genre.lowercased()) movie." }
        if mode == 3 { return "A movie under 95 minutes, or a \(guest.genre.lowercased()) favorite." }
        return "A \(guest.genre.lowercased()) film. A \(FilmLibrary.details(favorite).tags[0]) mood would be perfect."
    }
    func thoughtfulMatch(_ film: Movie,_ guest: Guest) -> Bool {
        let favorite = s.movies.first(where: { $0.genre == guest.genre }) ?? s.movies[0]
        switch guest.characterIndex % 4 {
        case 1: return FilmLibrary.details(film).tags.contains(FilmLibrary.details(favorite).tags[0])
        case 2: return FilmCredits.actor(film) == FilmCredits.actor(favorite)
        case 3: return FilmCredits.minutes(film) < 95
        default: return film.genre == guest.genre && FilmLibrary.details(film).tags.contains(FilmLibrary.details(favorite).tags[0])
        }
    }
    func accepts(_ film: Movie,_ guest: Guest) -> Bool {
        film.genre == guest.genre || (!guiding && names.contains(guest.name) && thoughtfulMatch(film,guest))
    }
    func recordExpansionRental(_ guest: Guest,movie: Int,total: Int) {
        syncExpansionWeek(); expansion.weeklyMoney += total
        if thoughtfulMatch(s.movies[movie],guest) { befriend(guest.characterIndex) }
        if s.movies[movie].genre == seasonGenre {
            expansion.seasonalRentals += 1
            if expansion.seasonalRentals >= 3 && !expansion.seasonalClaimed {
                expansion.seasonalClaimed = true; s.money += 20; experience.bonus += 20
                publishArticle("\(seasonName) is a hit", "Three themed rentals helped bring Maple Street together. Night Owl earned a $20 event bonus.")
                celebrate("Seasonal project complete · +$20")
            }
        }
    }
    func prepareUsedOffer() {
        guard expansion.usedDoneDay != s.day, expansion.usedOffer?.day != s.day else { return }
        expansion.usedOffer = UsedTapeOffer(day:s.day,movie:(s.day * 7) % s.movies.count,grade:s.day % 3); save()
    }
    func inspectUsedTape() {
        prepareUsedOffer()
        guard expansion.usedDoneDay != s.day,expansion.usedOffer != nil else { return }
        expansion.usedOffer?.inspected = true; say("Case and playback inspected. Choose a fair offer or pass.")
    }
    func offerUsed(_ amount: Int) {
        guard let offer = expansion.usedOffer,offer.day == s.day,offer.inspected,expansion.usedDoneDay != s.day,offer.attempts < 2 else { return }
        guard [offer.fairPrice+2,offer.fairPrice,max(1,offer.fairPrice-2)].contains(amount),s.money >= amount else { say("You need enough shop money for that offer."); return }
        if amount < offer.fairPrice { expansion.usedOffer?.attempts += 1; say("The seller declines. Try a fair price; two declined offers end today’s negotiation."); return }
        expansion.usedDoneDay = s.day; s.money -= amount; experience.expenses += amount; s.movies[offer.movie].stock += 1
        syncExpansionWeek(); expansion.weeklyCollection += 1
        if s.day % 4 == 0 { discoverRare(offer.movie) }
        shopAction(.restock,"Used VHS acquired · \(s.movies[offer.movie].title)",movie:offer.movie)
        publishArticle("A second life for a VHS","A neighbor sold Night Owl a copy of \(s.movies[offer.movie].title). It is back on the shelf.")
        say("Deal! Paid $\(amount) for one inspected tape. No more purchases from this seller today.")
    }
    func passUsed() { guard expansion.usedDoneDay != s.day else { return }; expansion.usedDoneDay = s.day; say("Offer passed. Another neighbor may bring a tape tomorrow.") }
    var canHostClub: Bool { canCloseShift && expansion.clubDay != s.day && s.money >= (expansion.clubSnacks ? 8 : 4) && expansion.clubFilms.count == 2 && Set(expansion.clubFilms).count == 2 && expansion.clubFilms.allSatisfy({ s.movies.indices.contains($0) && s.movies[$0].stock > 0 }) }
    func hostClub() {
        guard canHostClub else { say("Finish the queue and returns, choose two different in-stock films, and save the screening budget."); return }
        let cost = expansion.clubSnacks ? 8 : 4
        expansion.clubDay = s.day; s.open = false; s.minutes = 1200; s.money -= cost; experience.expenses += cost
        let audience = (0..<4).map { (expansion.clubHost + $0 * 3) % 12 }
        var reactions: [String] = []; var tips = 0
        for i in audience {
            let person = Cast.all[i]
            let likes = expansion.clubFilms.contains { s.movies[$0].genre == person.genre }
            befriend(i); if likes { befriend(i) }
            tips += (likes ? 4 : 2) + (expansion.clubSnacks ? 1 : 0)
            reactions.append("\(person.name): \(likes ? "Loved the double bill!" : "Enjoyed spending time with everyone.")\(expansion.clubSnacks ? " The snacks were a hit." : "")")
        }
        s.money += tips; experience.bonus += tips
        expansion.clubResult = reactions.joined(separator:"\n") + "\nBudget: $\(cost) · Donations: $\(tips)."
        publishArticle("Maple Street movie club",expansion.clubFilms.map { s.movies[$0].title }.joined(separator:" + ") + " brought four neighbors together. " + reactions[0])
        celebrate("Movie club complete · four friendships grew")
        say("Screening complete. The shop is closed for tonight. Read the audience reactions in Town, then close the day when ready.")
    }
}
