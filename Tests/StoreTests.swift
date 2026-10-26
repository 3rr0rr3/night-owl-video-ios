import Foundation

@main struct StoreTests {
    @MainActor static func main() async {
        UserDefaults.standard.removeObject(forKey: "nightowl.experience")
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
        UserDefaults.standard.removeObject(forKey: "nightowl.experience")
        let migrated = Store()
        assert(migrated.experience.tutorialDone, "Legacy saves skip new-player tutorial")
        assert(migrated.s.day == 9 && migrated.s.money == 321 && migrated.story.chapter == 0)
        let guided = Store(); guided.newGame()
        assert(guided.guiding && guided.tutorialStep == 1 && guided.nextTask.station == "COUNTER")
        guided.doors(); let firstGuest = guided.s.guests[0]
        guided.addGuest(); assert(guided.s.guests.count == 1, "Guide isolates one customer")
        let pausedClock = guided.s.minutes; guided.tick(); assert(guided.s.minutes == pausedClock)
        assert(guided.tutorialStep == 2 && guided.badge("COUNTER") == 1 && guided.badge("RETURNS") == 2)
        let movie = guided.s.movies.first { $0.genre == firstGuest.genre }!.id
        guided.recommend(movie); assert(guided.tutorialStep == 3 && guided.nextTask.station == "COUNTER")
        guided.scan(); assert(guided.tutorialStep == 4)
        guided.experience.autoChange = true; guided.payment(); assert(guided.tutorialStep == 5 && guided.change == 10 - guided.price)
        guided.change = 999; guided.checkout()
        assert(!guided.guiding && guided.s.served == 1 && guided.experience.customers == 1)
        guided.experience.relaxed = true
        let slowClock = guided.s.minutes; guided.tick(); guided.tick(); assert(guided.s.minutes == slowClock + 1)
        guided.experience.relaxed = false; guided.tick(); assert(guided.s.minutes == slowClock + 2)
        let locked = ShopStyle.all.first { $0.id == "poster-space" }!
        let beforeStyle = guided.s.money; guided.selectStyle(locked); assert(guided.s.money == beforeStyle)
        guided.s.served = 10; guided.selectStyle(locked)
        assert(guided.experience.poster == locked.id && guided.s.money == beforeStyle - 20 && guided.s.decor == 1)
        guided.selectStyle(locked); assert(guided.s.money == beforeStyle - 20, "Owned styles never charge twice")
        guided.s.money = 0; let shelf = ShopStyle.all.first { $0.id == "shelf-mint" }!
        guided.selectStyle(shelf); assert(!guided.experience.owned.contains(shelf.id))
        guided.s.money = 100; guided.buy(0)
        guided.s.guests = []; guided.s.returns = []; guided.s.sales = 11; guided.experience.bonus = 30; guided.experience.returns = 2
        let oldDay = guided.s.day; guided.nextDay()
        let report = guided.experience.report!
        assert(report.day == oldDay && report.revenue == 11 && report.bonus == 30 && report.purchases == 32 && report.bills == 15 && report.profit == -6)
        assert(report.customers == 1 && report.returns == 2 && guided.experience.reportPending)
        assert(guided.experience.expenses == 0 && guided.experience.customers == 0 && guided.s.day == oldDay + 1)
        let reportID = report.id; guided.nextDay(); assert(guided.experience.report?.id == reportID, "Cannot close an unplayed day")
        guided.save(); let savedExperience = Store()
        assert(savedExperience.experience.poster == locked.id && savedExperience.experience.report?.id == reportID && savedExperience.experience.autoChange)
        guided.dismissReport(); assert(!guided.experience.reportPending)
        guided.newGame(); assert(guided.guiding && guided.experience.autoChange && guided.experience.poster == "poster-owl" && guided.experience.report == nil)
        guided.skipTutorial(); assert(!guided.guiding)
        print("PASS: guided rental steps, clock pause, badges, automatic change, relaxed clock, style locks and purchases, report accounting, migration and persistence")
        migrated.newGame()
        assert(migrated.s.day == 1 && migrated.s.money == 150 && migrated.story.chapter == 0 && !migrated.s.open && migrated.s.rentals.isEmpty)
        let newSave = Store(); assert(newSave.hasSavedGame && newSave.s.money == 150 && newSave.s.day == 1)
        print("PASS: New Game and Continue save state")
        UserDefaults.standard.removeObject(forKey: "nightowl.story")
        print("PASS: 12 visitors, stable portraits, seven story chapters, rewards, dialogue, theme, pledges, ending, migration, animated rewind")
        UserDefaults.standard.removeObject(forKey: "nightowl.save")
        print("PASS: checkout, change, snacks, fees, returns, reservations, ordering, cleaning, closing, persistence")
    }
}
