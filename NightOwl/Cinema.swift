import Foundation

struct CinemaProgress: Codable {
    var history: [String:[Int]] = [:]
    var upgrades: [String] = []
    var surpriseDay = 0
    var surprise: String? = nil
    var surpriseDone = false
    var surprises = true
    var largeText = false
    var effectsVolume = 0.45
    var musicVolume = 0.28
    var haptics = false
}
struct FilmDetails {
    let title: String
    let synopsis: String
    let tags: [String]
}
enum FilmLibrary {
    static let genres = ["SCI-FI","HORROR","COMEDY","ACTION","ROMANCE","FAMILY"]
    static let extras: [FilmDetails] = [
        FilmDetails(title:"Orbit Diner",synopsis:"A waitress serves the galaxy’s strangest road trip crew.",tags:["funny","space"]),
        FilmDetails(title:"The Last Light",synopsis:"A lighthouse keeper hears a voice beneath the waves.",tags:["spooky","mystery"]),
        FilmDetails(title:"Weekend Substitute",synopsis:"An exhausted teacher accidentally joins a talent contest.",tags:["funny","cozy"]),
        FilmDetails(title:"Neon Pursuit",synopsis:"A bicycle courier races a stolen disk across the city.",tags:["thrilling","city"]),
        FilmDetails(title:"Letters in June",synopsis:"Two pen pals finally meet at a seaside bookshop.",tags:["sweet","cozy"]),
        FilmDetails(title:"The Kite Club",synopsis:"Neighborhood children build a kite that carries a secret.",tags:["adventure","gentle"]),
        FilmDetails(title:"Planet Post Office",synopsis:"A lost letter sends a rookie pilot beyond the star charts.",tags:["space","adventure"]),
        FilmDetails(title:"House on Channel Nine",synopsis:"A television broadcast reveals a room that does not exist.",tags:["spooky","strange"]),
        FilmDetails(title:"Uncle’s Big Break",synopsis:"An amateur magician gets booked for the wrong wedding.",tags:["funny","chaotic"]),
        FilmDetails(title:"Harbor Run",synopsis:"A retired coastguard must stop a midnight smuggling convoy.",tags:["thrilling","rescue"]),
        FilmDetails(title:"Secondhand Summer",synopsis:"Two rivals restore a vintage shop before the summer fair.",tags:["sweet","funny"]),
        FilmDetails(title:"Maple Street Mystery",synopsis:"Three young sleuths follow clues to a missing parade float.",tags:["mystery","gentle"]),
        FilmDetails(title:"Tomorrow’s Arcade",synopsis:"An arcade cabinet opens a door to next Thursday.",tags:["strange","funny"]),
        FilmDetails(title:"Pumpkin Radio",synopsis:"A late-night DJ receives calls from an abandoned town.",tags:["spooky","mystery"]),
        FilmDetails(title:"Pizza for the Mayor",synopsis:"A delivery driver becomes a small-town election hero.",tags:["funny","city"]),
        FilmDetails(title:"Rooftop Rescue",synopsis:"A window cleaner and a firefighter race against a storm.",tags:["rescue","thrilling"]),
        FilmDetails(title:"One More Dance",synopsis:"Former dance partners reunite to save their old ballroom.",tags:["sweet","nostalgic"]),
        FilmDetails(title:"Captain Cardboard",synopsis:"A homemade spaceship launches a backyard adventure.",tags:["adventure","funny"]),
        FilmDetails(title:"The Quiet Comet",synopsis:"An astronomer and a robot follow a singing comet.",tags:["space","gentle"]),
        FilmDetails(title:"Basement Matinee",synopsis:"A forgotten film reel brings its monster into the theater.",tags:["spooky","strange"]),
        FilmDetails(title:"Hotel Hiccups",synopsis:"A sleepy hotel staff hides a runaway performing goat.",tags:["funny","chaotic"]),
        FilmDetails(title:"Desert Frequency",synopsis:"A radio mechanic guides a stranded convoy through danger.",tags:["thrilling","adventure"]),
        FilmDetails(title:"Rain Check Romance",synopsis:"Missed buses keep bringing two strangers together.",tags:["sweet","city"]),
        FilmDetails(title:"The Lantern Parade",synopsis:"A lost dog helps two siblings find their way home.",tags:["gentle","cozy"])
    ]
    static func details(_ movie: Movie) -> FilmDetails {
        if movie.id >= 6 && movie.id < 30 { return extras[movie.id - 6] }
        let descriptions = ["A closed shopping mall becomes a gateway to another galaxy.","Campers discover that the woods are watching them.","An ordinary dad tries to become the coolest guy in town.","A bus driver takes an unexpected detour into danger.","A forgotten videotape reunites two old flames.","Small-town sleuths follow a trail of unusually large clues."]
        let tags = [["space","adventure"],["spooky","mystery"],["funny","cozy"],["thrilling","city"],["sweet","nostalgic"],["mystery","gentle"]]
        return FilmDetails(title:movie.title,synopsis:descriptions[movie.id % 6],tags:tags[movie.id % 6])
    }
}
enum BackupError: Error { case invalid }
extension Store {
    func expandCatalog() {
        guard s.movies.count == 6 else { return }
        for (index,film) in FilmLibrary.extras.enumerated() { s.movies.append(Movie(id:index+6,title:film.title,genre:FilmLibrary.genres[index % 6],stock:2)) }
    }
    func remember(_ guest: Guest,_ movie: Int) {
        let key = String(guest.characterIndex)
        cinema.history[key,default:[]].append(movie)
        cinema.history[key] = Array(cinema.history[key,default:[]].suffix(10))
    }
    var orderCost: Int { cinema.upgrades.contains("ordering") ? 10 : 12 }
    var carryReturns: Int { cinema.upgrades.contains("bin") ? 4 : 0 }
    var canCloseShift: Bool { s.guests.isEmpty && s.returns.count <= carryReturns }
    func equipment(_ id: String) {
        let prices = ["rewinder":50,"bin":45,"desk":75,"ordering":60]
        guard let cost = prices[id], !cinema.upgrades.contains(id), s.money >= cost else { say("This upgrade is owned or needs more shop money."); return }
        s.money -= cost; experience.expenses += cost; cinema.upgrades.append(id); say("Equipment installed! Its benefits start immediately.")
    }
    func offerSurprise() {
        guard cinema.surprises, !experience.relaxed, !guiding, cinema.surpriseDay != s.day else { return }
        cinema.surpriseDay = s.day; cinema.surpriseDone = false
        cinema.surprise = ["Missing favorite","Mixed-up case","Surprise delivery"][s.day % 3]
    }
    func finishSurprise(movie: Int? = nil) {
        guard cinema.surprises, !experience.relaxed, cinema.surprise != nil, !cinema.surpriseDone else { return }
        if cinema.surprise != "Surprise delivery" && movie != (s.day * 7) % s.movies.count { return }
        cinema.surpriseDone = true
        if cinema.surprise == "Surprise delivery" { let id = (s.day * 7) % s.movies.count; s.movies[id].stock += 1; say("A regular donated a copy of \(s.movies[id].title)!") }
        else { s.money += 5; experience.bonus += 5; neighborhood.reputation = min(100,neighborhood.reputation + 1); say("Request solved! A grateful regular left a $5 tip.") }
    }
    func exportShop() throws -> Data {
        try JSONEncoder().encode(ShopSlot(shop:s,story:story,experience:experience,neighborhood:neighborhood,cinema:cinema))
    }
    func validateBackup(_ data: Data) throws -> ShopSlot {
        guard data.count <= 1_000_000 else { throw BackupError.invalid }
        let slot = try JSONDecoder().decode(ShopSlot.self,from:data)
        let shop = slot.shop; let count = shop.movies.count
        guard (6...30).contains(count), shop.movies.enumerated().allSatisfy({ $0.offset == $0.element.id && (0...9999).contains($0.element.stock) && FilmLibrary.genres.contains($0.element.genre) }), (1...99999).contains(shop.day), (-10000...10000000).contains(shop.money), (0...1440).contains(shop.minutes), (0...7).contains(slot.story.chapter), shop.guests.count <= 7 else { throw BackupError.invalid }
        let ids = shop.returns.map { $0.movie } + shop.rentals + shop.reservations + shop.held + shop.guests.compactMap { $0.movie }
        guard ids.allSatisfy({ (0..<count).contains($0) }), slot.neighborhood.rare.allSatisfy({ (0..<count).contains($0) }) else { throw BackupError.invalid }
        if let cinema = slot.cinema {
            guard (0...1).contains(cinema.effectsVolume), (0...1).contains(cinema.musicVolume), cinema.upgrades.allSatisfy({ ["rewinder","bin","desk","ordering"].contains($0) }), cinema.history.values.flatMap({$0}).allSatisfy({ (0..<count).contains($0) }) else { throw BackupError.invalid }
        }
        return slot
    }
    func importShop(_ data: Data) throws {
        let slot = try validateBackup(data)
        if let backup = try? exportShop() { UserDefaults.standard.set(backup,forKey:"nightowl.before-import.\(selectedSlot)") }
        s = slot.shop; story = slot.story; experience = slot.experience; neighborhood = slot.neighborhood; cinema = slot.cinema ?? CinemaProgress()
        clearShopLife(); expandCatalog(); moviePickup = nil; counterWalking = false; counterPresentedID = nil; deskEvent = nil; rewinding = nil; speakingGuest = nil; change = 0; earned = 0; effectID = UUID(); station = "COUNTER"
        restorePendingPickup()
        say("Backup imported into Shop \(selectedSlot + 1). Your previous shop was backed up first.")
    }
}
