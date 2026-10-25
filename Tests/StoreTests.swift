import Foundation

@main struct StoreTests {
    @MainActor static func main() async {
        UserDefaults.standard.removeObject(forKey: "nightowl.save")
        UserDefaults.standard.removeObject(forKey: "nightowl.story")
        let store = Store()
        store.s = Save()
        store.s.guests = [Guest(name: "Test", genre: "SCI-FI")]
        store.recommend(1)
        assert(store.s.guests[0].movie == nil, "Reject incorrect genre")
        store.recommend(0)
        store.scan()
        store.payment()
        store.change = 5
        store.checkout()
        assert(store.s.served == 0, "Reject incorrect change")
        store.change = 6
        store.checkout()
        assert(store.s.served == 1 && store.s.money == 154)
        assert(store.s.movies[0].stock == 2 && store.s.rentals == [0])
        store.s.guests = [Guest(name: "Snack", genre: "COMEDY", snack: true)]
        store.recommend(2); store.scan(); store.payment(); store.change = 3; store.checkout()
        assert(store.s.money == 161 && store.s.served == 2, "Popcorn total and change")
        assert(store.message.hasSuffix("+$7"), "Receipt message matches the popcorn rental total")
        store.s.returns = [Tape(movie: 0, late: true, damaged: true)]
        store.process("shelve")
        assert(store.s.returns.count == 1, "Incomplete returns cannot be shelved")
        store.process("scan"); store.process("fee"); store.process("fee")
        assert(store.s.money == 168, "Fees collected once")
        store.process("rewind"); store.process("shelve")
        assert(store.s.returns.isEmpty && store.s.movies[0].stock == 3)
        store.s.guests = [Guest(name: "Hold", genre: "SCI-FI")]
        store.reserve()
        assert(store.s.reservations == [0])
        store.s.movies[0].stock = 2
        store.s.returns = [Tape(movie: 0)]
        store.process("scan"); store.process("fee"); store.process("rewind"); store.process("shelve")
        assert(store.s.held == [0] && store.s.movies[0].stock == 2)
        store.collectHold(0)
        assert(store.s.held.isEmpty && store.s.rentals.last == 0)
        store.s.money = 0
        let copies = store.s.movies[0].stock
        store.buy(0)
        assert(store.s.movies[0].stock == copies, "Reject unaffordable stock")
        store.s.money = 100
        store.buy(0)
        assert(store.s.money == 88 && store.s.movies[0].stock == copies + 1)
        store.s.dirt = 1; store.clean(); store.clean()
        assert(store.s.dirt == 0)
        store.s.open = true; store.s.minutes = 1199; store.tick()
        assert(!store.s.open && store.s.minutes == 1200)
        store.s.guests = []; store.s.returns = []
        let rented = store.s.rentals.count
        store.nextDay()
        assert(store.s.day == 2 && store.s.returns.count == rented && store.s.rentals.isEmpty)
        store.save()
        let restored = Store()
        assert(restored.s.day == store.s.day && restored.s.money == store.s.money)
        assert(restored.s.returns.count == store.s.returns.count)
        let campaign = Store()
        campaign.s = Save(); campaign.story = StoryProgress()
        assert(Cast.all.count == 12 && Set(Cast.all.map { $0.name }).count == 12)
        assert(Cast.all.allSatisfy { $0.id >= 0 && $0.id < 12 })
        campaign.story.talked = [campaign.chapter.lead]
        var visitors = Set<String>()
        for n in 0..<12 { campaign.s.guests = []; campaign.s.served = n; campaign.addGuest(); visitors.insert(campaign.s.guests[0].name); assert(campaign.s.guests[0].regular.genre == campaign.s.guests[0].genre) }
        assert(visitors.count == 12, "Every regular can visit")
        campaign.s = Save(); campaign.story = StoryProgress()
        func rent(_ i: Int, snack: Bool = false) {
            campaign.s.guests = [Guest(name: Cast.all[i].name, genre: Cast.all[i].genre, snack: snack)]
            let movie = campaign.s.movies.firstIndex { $0.genre == Cast.all[i].genre }!
            if campaign.s.movies[movie].stock == 0 { campaign.s.movies[movie].stock = 1 }
            campaign.recommend(movie); campaign.scan(); campaign.payment(); campaign.change = 10 - campaign.price; campaign.checkout()
        }
        func processReturn() { campaign.process("scan"); campaign.process("fee"); campaign.process("rewind"); campaign.process("shelve") }
        let before = campaign.s.money
        campaign.finishChapter(); assert(campaign.story.chapter == 0 && campaign.s.money == before)
        rent(0); rent(1); processReturn()
        assert(campaign.canFinishChapter); campaign.finishChapter()
        assert(campaign.story.chapter == 1 && campaign.story.rentals == 0)
        let paidOnce = campaign.s.money; campaign.finishChapter(); assert(campaign.s.money == paidOnce)
        for n in [5, 6, 8] { campaign.s.guests = [Guest(name: Cast.all[n].name, genre: Cast.all[n].genre)]; campaign.talk(); campaign.talk() }
        assert(campaign.story.talked.count == 3, "Repeat dialogue does not count as a different regular")
        campaign.chooseTheme("invalid"); assert(campaign.story.theme == nil)
        campaign.chooseTheme("Creature feature"); campaign.chooseTheme("Space double bill")
        assert(campaign.story.theme == "Creature feature", "Theme choice is preserved")
        campaign.buy(0); assert(campaign.canFinishChapter); campaign.finishChapter()
        rent(6, snack: true); rent(7); rent(9)
        campaign.s.dirt = 2; campaign.clean(); campaign.clean()
        assert(campaign.canFinishChapter); campaign.finishChapter()
        campaign.s.guests = []; campaign.addGuest(); assert(campaign.s.guests.first?.name == "Ravi", "Featured story guest visits")
        campaign.talk()
        campaign.s.returns = [Tape(movie: 0), Tape(movie: 1), Tape(movie: 2)]
        for _ in 0..<3 { processReturn() }
        assert(campaign.canFinishChapter); campaign.finishChapter()
        campaign.hire(); campaign.upgrade(); rent(3); rent(4)
        assert(campaign.canFinishChapter); campaign.finishChapter()
        campaign.s.guests = [Guest(name: "Gus", genre: "ACTION")]; campaign.talk()
        campaign.pledge(); let afterPledge = campaign.s.money; campaign.pledge(); assert(campaign.s.money == afterPledge)
        for n in 0..<4 { rent(n) }
        assert(campaign.canFinishChapter); campaign.finishChapter()
        for n in 0..<5 { rent(n) }
        campaign.s.returns = [Tape(movie: 0),Tape(movie: 1)]
        processReturn(); processReturn()
        assert(campaign.canFinishChapter); campaign.finishChapter()
        assert(campaign.storyFinished && campaign.story.theme == "Creature feature")
        let endingMoney = campaign.s.money; campaign.finishChapter(); assert(campaign.s.money == endingMoney)
        campaign.save(); let savedCampaign = Store()
        assert(savedCampaign.storyFinished && savedCampaign.story.theme == "Creature feature")
        campaign.s.returns = [Tape(movie: 0)]
        campaign.startRewind(); campaign.startRewind()
        assert(campaign.rewinding != nil && !campaign.s.returns[0].rewound, "Rewind is asynchronous")
        try? await Task.sleep(nanoseconds: 3_300_000_000)
        assert(campaign.rewinding == nil && campaign.s.returns[0].rewound)
        // A pre-story save must survive without a story-progress key.
        var oldSave = Save(); oldSave.day = 9; oldSave.money = 321
        UserDefaults.standard.set(try! JSONEncoder().encode(oldSave), forKey: "nightowl.save")
        UserDefaults.standard.removeObject(forKey: "nightowl.story")
        let migrated = Store()
        assert(migrated.s.day == 9 && migrated.s.money == 321 && migrated.story.chapter == 0)
        UserDefaults.standard.removeObject(forKey: "nightowl.story")
        print("PASS: 12 visitors, stable portraits, seven story chapters, rewards, dialogue, theme, pledges, ending, migration, animated rewind")
        UserDefaults.standard.removeObject(forKey: "nightowl.save")
        print("PASS: checkout, change, snacks, fees, returns, reservations, ordering, cleaning, closing, persistence")
    }
}
