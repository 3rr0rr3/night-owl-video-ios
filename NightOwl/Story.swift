import Foundation

struct Regular: Identifiable {
    let id: Int
    let name: String
    let role: String
    let genre: String
    let bio: String
    let lines: [String]
}
enum Cast {
    static let all: [Regular] = [
        Regular(id: 0, name: "Milo", role: "Night-shift electrician · 34", genre: "SCI-FI", bio: "Fixed the owl sign for your aunt. Hopes the shop stays open after his late shifts.", lines: ["June always saved the weird space movies for me. Keep that tradition alive?", "I can fix a projector. Getting everyone in the same room is the tricky part.", "That owl sign looks better every night."]),
        Regular(id: 1, name: "Jules", role: "Accountant & horror fan · 38", genre: "HORROR", bio: "Balances books by day and runs the neighborhood horror club by night.", lines: ["Something scary, please. I've already survived tax season.", "A lease is numbers. A neighborhood is people. We'll need both.", "I brought the horror club. They promise to behave."]),
        Regular(id: 2, name: "Bea", role: "Former cinema usher · 42", genre: "ROMANCE", bio: "Knows every regular and still remembers the old cinema's closing night.", lines: ["Your aunt let people stay until the credits finished. That's why they came back.", "I can help with returns. Nobody should run this place alone.", "For the first time in years, this feels like opening night."]),
        Regular(id: 3, name: "Otis", role: "Bus driver · 45", genre: "ACTION", bio: "His last route passes every business on Maple Street. He knows who needs a little help.", lines: ["Last bus is at eleven. Save me something with a car chase.", "I'll put a movie-night flyer on the bus. Half the street rides with me.", "Sold out? That's the kind of traffic jam I like."]),
        Regular(id: 4, name: "Nina", role: "Local reporter · 36", genre: "COMEDY", bio: "Refuses to write another story about a beloved shop shutting its doors.", lines: ["Tell me why this place matters. The real story, not a sales pitch.", "Give me a tidy shop, a team, and a reason to send people here.", "Tomorrow's headline: Maple Street Shows Up."]),
        Regular(id: 5, name: "Frank", role: "Retired projectionist · 67", genre: "FAMILY", bio: "Ran the long-closed Rialto cinema. Carries a notebook of films he still wants to screen.", lines: ["Your aunt and I held the first Maple Street screening right outside this shop.", "Somewhere in these returns is a tape of that night. I'd like to see it again.", "You didn't save a building. You gave us somewhere to meet."]),
        Regular(id: 6, name: "Zoe", role: "Emergency-room nurse · 32", genre: "COMEDY", bio: "Organizes movie nights for coworkers coming off exhausting hospital shifts.", lines: ["Twelve-hour shift. Something funny and a bag of popcorn, please.", "Rainy Fridays are our only night off together. We need this place.", "The whole night crew is coming. I told them to bring chairs."]),
        Regular(id: 7, name: "Gus", role: "Diner owner · 51", genre: "ACTION", bio: "Runs the diner next door. Believes every great screening needs great food.", lines: ["I'll trade you my best popcorn recipe for a decent action movie.", "If you cover the projector rental, I'll feed the volunteers.", "I haven't seen this many people on Maple Street since '84."]),
        Regular(id: 8, name: "Ravi", role: "VCR repair technician · 40", genre: "SCI-FI", bio: "Repairs old machines and keeps the neighborhood's home movies from disappearing.", lines: ["A tape with no label? Don't toss it. There might be a memory on it.", "Clean those returns carefully. I'll see what I can recover.", "Picture's a little fuzzy. The memory isn't."]),
        Regular(id: 9, name: "Dana", role: "Community-radio DJ · 35", genre: "HORROR", bio: "Hosts Midnight Static and can turn a quiet event into the talk of the town.", lines: ["I'm building a midnight double bill. Give me your strangest horror tape.", "You get the screening ready. I'll get it on the air.", "This is Dana, broadcasting live from a very crowded video store."]),
        Regular(id: 10, name: "Marisol", role: "Garage owner · 46", genre: "ACTION", bio: "Builds things to last. Offers a truck and a toolbox whenever Maple Street needs them.", lines: ["I like my movies like my engines: loud and a little ridiculous.", "I'll haul the screen. Otis can handle the chairs.", "Don't thank me yet. You're helping repaint my garage next month."]),
        Regular(id: 11, name: "Evelyn", role: "Librarian · 61", genre: "ROMANCE", bio: "Keeps the town archive and remembers the stories that never made the newspapers.", lines: ["June wrote notes inside her favorite tape cases. You might find one.", "A place survives when people feel they belong there.", "I've saved a space in the archive for tonight's photograph."])
    ]
}
extension Guest {
    var characterIndex: Int { Cast.all.firstIndex { $0.name == name } ?? 0 }
    var regular: Regular { Cast.all[characterIndex] }
}
struct StoryProgress: Codable {
    var chapter = 0
    var rentals = 0
    var returns = 0
    var snacks = 0
    var cleanups = 0
    var orders = 0
    var talked: [Int] = []
    var theme: String? = nil
    var pledged = 0
}
struct Chapter {
    let title: String
    let speaker: String
    let text: String
    let lead: Int
    let reward: Int
}
struct StoryGoal: Identifiable {
    var id: String { label }
    let label: String
    let value: Int
    let target: Int
    var complete: Bool { value >= target }
}
enum Storybook {
    static let sceneLines = [
        "June gave me a spare bulb for the owl sign. Said you'd need it one day. Let's get your first customers through the door.",
        "Before the Rialto closed, your aunt and I screened films right outside this shop. What do you say we give Maple Street one more movie night?",
        "The whole night crew got caught in the rain. Three movies, some popcorn, and somewhere to sit. That would mean more than you know.",
        "This unlabeled tape has June's handwriting on the case. Check the returns carefully. I think I can bring that old screening back to life.",
        "Show me a shop with a future: a team, a little care, and people coming through the door. That's the story I want to write.",
        "Dana's on the radio, Marisol has the truck, and I've got the food. Cover the projector rental, and we'll make this happen together.",
        "Projector's warm. The chairs are full. Finish up here, then come outside. June would've loved to see this."
    ]
    static let chapters: [Chapter] = [
        Chapter(title: "The Keys to Night Owl", speaker: "Aunt June's letter", text: "You inherit a struggling video shop on Maple Street in 1994. June has left one request: keep a light on for the neighborhood. A property company wants the block, and the lease renewal is coming. First, remind people why they loved this little shop.", lead: 0, reward: 20),
        Chapter(title: "The Last Screening", speaker: "Frank", text: "Before the Rialto closed, June and Frank screened movies outside Night Owl every summer. Frank wants one more movie night. Ask the regulars what they remember, order a fresh tape, and choose the double bill that will bring them back together.", lead: 5, reward: 25),
        Chapter(title: "Rain on Friday", speaker: "Zoe", text: "A downpour sends the hospital night crew into your shop. Zoe wants somewhere her coworkers can laugh after a hard week. Keep the rentals moving, make the popcorn combos, and clean up after the rush. Word of mouth starts here.", lead: 6, reward: 35),
        Chapter(title: "A Tape With No Label", speaker: "Ravi", text: "Ravi spots an unlabeled cassette among the old returns. It might contain footage of the very first Maple Street screening. Check the tapes back in and ask him to restore it. A home movie could remind the town what it's about to lose.", lead: 8, reward: 30),
        Chapter(title: "One More Chance", speaker: "Nina", text: "Nina will write about the shop, but she needs more than nostalgia. Build a team, brighten the store, and prove customers are coming back. Her article could convince the landlord that Night Owl deserves a new lease.", lead: 4, reward: 40),
        Chapter(title: "The Block Shows Up", speaker: "Gus", text: "Dana has put the event on the radio. Marisol has a truck, Otis has the chairs, and Gus will feed the volunteers. Pledge $40 for the projector rental and help the last customers choose their films. This time, you don't have to do it alone.", lead: 7, reward: 50),
        Chapter(title: "Lights on Maple Street", speaker: "Aunt June's last note", text: "The screen is up outside the store. Frank has the restored home movie, and the whole block is waiting. Finish the final rentals and returns, then roll the credits on a night that can give Night Owl a future.", lead: 5, reward: 100)
    ]
}
