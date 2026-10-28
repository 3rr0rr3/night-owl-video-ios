import Foundation

@main struct StoreTests {
    @MainActor static func main() async {
        for key in ["nightowl.cinema","nightowl.before-import.0","nightowl.neighborhood","nightowl.active-slot","nightowl.slot.0","nightowl.slot.1","nightowl.slot.2"] { UserDefaults.standard.removeObject(forKey: key) }
        UserDefaults.standard.removeObject(forKey: "nightowl.experience")
        UserDefaults.standard.removeObject(forKey: "nightowl.save")
        UserDefaults.standard.removeObject(forKey: "nightowl.story")
        let store = Store()
        store.s = Save()
        store.s.guests = [Guest(name: "Test", genre: "SCI-FI")]
        store.scan(); assert(store.deskEvent == nil, "No scan animation without a selected tape")
        store.recommend(1)
        assert(store.s.guests[0].movie == nil, "Reject incorrect genre")
        store.recommend(0)
        store.scan()
        assert(store.deskEvent?.kind == .scan && store.deskEvent?.title == "Moon Mall")
        let scanID = store.deskEvent!.id; store.scan(); assert(store.deskEvent?.id == scanID, "Repeated scan does not retrigger")
        store.payment()
        assert(store.deskEvent?.kind == .payment && store.deskEvent?.amount == 10 && store.deskEvent?.change == 6)
        let paymentID = store.deskEvent!.id; store.payment(); assert(store.deskEvent?.id == paymentID, "Repeated payment does not retrigger")
        store.change = 5
        store.checkout()
        assert(store.s.served == 0 && store.deskEvent?.id == paymentID, "Reject incorrect change without success animation")
        store.change = 6
        store.checkout()
        assert(store.deskEvent?.kind == .sale && store.deskEvent?.amount == 4 && store.deskEvent?.change == 6)
        assert(store.deskEvent?.movieID == 0 && store.deskEvent?.customerIndex != nil, "Counter retains the served guest and tape after checkout")
        assert(store.s.served == 1 && store.s.money == 154)
        assert(store.s.movies[0].stock == 2 && store.s.rentals == [0])
        store.s.guests = [Guest(name: "Snack", genre: "COMEDY", snack: true)]
        store.recommend(2); store.scan(); store.payment(); store.change = 3; store.checkout()
        assert(store.s.money == 161 && store.s.served == 2, "Popcorn total and change")
        assert(store.message.hasSuffix("+$7"), "Receipt message matches the popcorn rental total")
        store.s.returns = [Tape(movie: 0, late: true, damaged: true)]
        store.process("shelve")
        assert(store.s.returns.count == 1, "Incomplete returns cannot be shelved")
        store.process("scan"); assert(store.deskEvent?.kind == .scan && store.deskEvent?.title.hasPrefix("Return:") == true)
        store.process("fee"); let feeID = store.deskEvent!.id; store.process("fee")
        assert(store.deskEvent?.kind == .fee && store.deskEvent?.amount == 7 && store.deskEvent?.id == feeID)
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
        assert(restored.deskEvent == nil, "Transient animations never replay from saves")
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
        let town = Store(); town.newGame(); town.skipTutorial()
        town.s.guests = [Guest(name: Cast.all[0].name,genre: Cast.all[0].genre)]
        town.talk(); let firstBond = town.bond(0); town.talk(); assert(town.bond(0) == firstBond, "Chat reward once per regular per day")
        town.befriend(0); town.befriend(0); town.befriend(0)
        assert(town.bond(0) == 4 && town.neighborhood.gifts == [0] && town.neighborhood.rare == [0])
        town.donationBox(); let collected = town.neighborhood.rare.count; town.donationBox(); assert(town.neighborhood.rare.count == collected)
        town.neighborhood.reputation = 10; let spareCopies = town.s.movies.map { $0.stock }.reduce(0,+)
        town.tradeSpareTape(); town.tradeSpareTape()
        assert(town.s.movies.map { $0.stock }.reduce(0,+) == spareCopies - 1 && town.neighborhood.rare.count == collected + 1)
        town.experience.customers = town.todayEvent.target
        let eventCash = town.s.money; town.completeEvent(); town.completeEvent()
        assert(town.s.money == eventCash + 15 && town.neighborhood.eventClaimedDay == town.s.day)
        town.s.day = 2; assert(town.todayEvent.genre == "SCI-FI")
        town.s.day = 3; assert(town.todayEvent.title == "Rainy-day rush")
        let moodGuest = Guest(name: "Test",genre: "HORROR"); assert(town.request(moodGuest).contains("spooky"))
        town.neighborhood.moods = false; assert(town.request(moodGuest).contains("horror"))
        town.s.returns = [Tape(movie: 0,damaged: true)]
        let caseID = town.s.returns[0].id; town.repairCase(caseID); assert(town.s.returns[0].damaged)
        town.process("scan"); town.process("fee"); let cashAfterFee = town.s.money
        town.repairCase(caseID); let repairXP = town.s.xp; town.repairCase(caseID)
        assert(!town.s.returns[0].damaged && town.s.money == cashAfterFee && town.s.xp == repairXP)
        town.neighborhood.reputation = 25; town.story.orders = 2
        let deliveryStock = town.s.movies[2].stock; town.buy(2); assert(town.s.movies[2].stock == deliveryStock + 2 && town.neighborhood.rare.contains(2))
        town.s.money = 777; town.neighborhood.music = true; town.save()
        town.switchSlot(1); assert(!town.hasSavedGame && town.slotInfo(0)?.shop.money == 777)
        town.newGame(); town.s.money = 222; town.save(); town.switchSlot(0)
        assert(town.s.money == 777 && town.neighborhood.music && town.neighborhood.rare.count >= 3)
        town.switchSlot(1); assert(town.s.money == 222)
        town.switchSlot(2); assert(!town.hasSavedGame)
        town.switchSlot(0); assert(town.s.money == 777)
        print("PASS: friendships, gifts, repeat-chat guards, donations, trades, event rewards, mood hints, repairs, reputation deliveries and independent save slots")
        let library = Store(); library.newGame()
        assert(library.s.movies.count == 30 && Set(library.s.movies.map { $0.title }).count == 30)
        assert(library.s.movies.enumerated().allSatisfy { $0.offset == $0.element.id })
        assert(library.s.movies.allSatisfy { FilmLibrary.details($0).tags.count == 2 && !FilmLibrary.details($0).synopsis.isEmpty })
        var legacyShop = Save(); legacyShop.money = 456; legacyShop.movies[0].stock = 1
        library.s = legacyShop; library.expandCatalog(); library.expandCatalog()
        assert(library.s.money == 456 && library.s.movies[0].stock == 1 && library.s.movies.count == 30)
        library.s.guests = [Guest(name:Cast.all[0].name,genre:"SCI-FI")]
        library.recommend(6); library.scan(); library.payment(); library.change = 6; library.checkout()
        assert(library.cinema.history["0"] == [6])
        library.s.money = 500
        for upgrade in ["rewinder","bin","desk","ordering"] { library.equipment(upgrade) }
        assert(library.s.money == 270 && library.orderCost == 10 && library.carryReturns == 4)
        library.equipment("rewinder"); assert(library.s.money == 270)
        let orderMoney = library.s.money; library.buy(10); assert(library.s.money == orderMoney - 10)
        library.s.guests = []; library.skipTutorial()
        for _ in 0..<9 { library.addGuest() }; assert(library.s.guests.count == 7)
        library.s.guests = []; library.s.returns = [Tape(movie:0),Tape(movie:1)]; library.s.open = true
        assert(library.canCloseShift)
        library.startRewind(); try? await Task.sleep(nanoseconds:1_300_000_000); assert(library.s.returns[0].rewound)
        library.cinema.surpriseDay = 0; library.cinema.surprise = nil; library.experience.relaxed = true; library.offerSurprise(); assert(library.cinema.surprise == nil)
        library.experience.relaxed = false; library.offerSurprise(); let beforeSurprise = library.s.money
        library.finishSurprise(movie:0); assert(library.s.money == beforeSurprise)
        library.finishSurprise(movie:(library.s.day*7)%library.s.movies.count); library.finishSurprise(movie:(library.s.day*7)%library.s.movies.count)
        assert(library.s.money == beforeSurprise + 5)
        let exported = try! library.exportShop(); let decoded = try! library.validateBackup(exported)
        assert(decoded.cinema?.history["0"] == [6] && decoded.shop.movies.count == 30)
        let sourceMoney = library.s.money; library.s.money = 18; try! library.importShop(exported)
        assert(library.s.money == sourceMoney && UserDefaults.standard.data(forKey:"nightowl.before-import.0") != nil)
        do { try library.importShop(Data("bad backup".utf8)); assertionFailure("Invalid backup accepted") } catch {}
        assert(library.s.money == sourceMoney)
        var invalid = decoded; invalid.shop.returns = [Tape(movie:999)]
        do { try library.importShop(try JSONEncoder().encode(invalid)); assertionFailure("Invalid tape ID accepted") } catch {}
        let legacyBundle = ShopSlot(shop:Save(),story:StoryProgress(),experience:Experience(),neighborhood:Neighborhood())
        try! library.importShop(try! JSONEncoder().encode(legacyBundle)); assert(library.s.movies.count == 30)
        library.s.money = 333; library.cinema.largeText = true; library.save(); library.switchSlot(1); library.switchSlot(0)
        assert(library.s.money == 333 && library.cinema.largeText)
        print("PASS: 30-film migration and metadata, rental notebook, equipment effects, seven-customer queue, fast rewind, optional surprises, validated backup round-trip and legacy import")
        let laneWidth = 360.0
        assert(CustomerWalking.position(stage:.arriving,elapsed:0,width:laneWidth) > laneWidth + 40)
        assert(abs(CustomerWalking.position(stage:.arriving,elapsed:CustomerWalking.arrival,width:laneWidth) - laneWidth * 0.83) < 0.001)
        assert(CustomerWalking.position(stage:.arriving,elapsed:0.4,width:laneWidth) > CustomerWalking.position(stage:.arriving,elapsed:0.9,width:laneWidth))
        assert(CustomerWalking.position(stage:.leaving,elapsed:0.4,width:laneWidth) < CustomerWalking.position(stage:.leaving,elapsed:1.0,width:laneWidth))
        assert(CustomerWalking.position(stage:.leaving,elapsed:20,width:laneWidth) > laneWidth + 40)
        assert(CustomerWalking.progress(-1,duration:1) == 0 && CustomerWalking.progress(20,duration:1) == 1)
        assert(CustomerWalking.position(stage:.handoff,elapsed:0.5,width:laneWidth) == laneWidth * 0.83)
        let visitor = Guest(name:Cast.all[6].name,genre:Cast.all[6].genre)
        let snapshot = CounterCustomer(visitor)
        assert(snapshot.id == visitor.id && snapshot.index == 6 && snapshot.name == visitor.name)
        print("PASS: customer arrival and exit endpoints, direction, handoff position, time clamps and stable visitor identity")
        let retrieval = Store(); retrieval.newGame(); retrieval.s.guests = [Guest(name:Cast.all[0].name,genre:"SCI-FI")]
        retrieval.recommend(0)
        let pickup = retrieval.moviePickup!
        assert(pickup.guestID == retrieval.s.guests[0].id && pickup.movie == 0)
        assert(ClerkPickupMotion.depth(stage:.toShelf,time:0) == 0)
        assert(ClerkPickupMotion.depth(stage:.toShelf,time:1.3) == 1)
        assert(ClerkPickupMotion.depth(stage:.collecting,time:0.2) == 1)
        assert(ClerkPickupMotion.depth(stage:.returning,time:0) == 1)
        assert(ClerkPickupMotion.depth(stage:.returning,time:1.3) == 0)
        assert(ClerkPickupMotion.depth(stage:.waiting,time:9) == 0)
        let stale = MoviePickup(guestID:pickup.guestID,movie:0); retrieval.finishPickup(stale); assert(retrieval.moviePickup?.id == pickup.id)
        retrieval.finishPickup(pickup); assert(retrieval.moviePickup == nil && retrieval.s.movies[0].stock == 3)
        retrieval.save(); let resumed = Store(); assert(resumed.moviePickup?.movie == 0 && resumed.s.guests.first?.movie == 0)
        retrieval.scan(); retrieval.save(); let scanned = Store(); assert(scanned.moviePickup == nil)
        print("PASS: selected-tape pickup identity, backroom and return endpoints, stale completion guard, stock safety and unscanned-save resume")
        let living = Store(); living.newGame(); living.experience.tutorialDone = true
        living.doors(); assert(living.lifeEvent?.kind == .opening)
        let openingID = living.lifeEvent!.id
        living.doors(); assert(living.lifeEvent?.id == openingID, "Already-open doors must not replay")
        let stock = living.s.movies[0].stock
        living.buy(0); assert(living.lifeEvent?.kind == .restock && living.s.movies[0].stock == stock + 1)
        living.s.money = 0; let restockID = living.lifeEvent!.id
        living.buy(0); assert(living.lifeEvent?.id == restockID, "Rejected purchases must not animate")
        living.neighborhood.rare = []; living.discoverRare(0)
        let rareID = living.celebration!.id
        living.discoverRare(0); assert(living.celebration?.id == rareID && living.neighborhood.rare == [0])
        living.neighborhood.friendship["1"] = 2; living.befriend(1)
        assert(living.bond(1) == 3 && living.celebration != nil)
        living.save(); let lifeReload = Store(); assert(lifeReload.lifeEvent == nil && lifeReload.celebration == nil)
        living.shopAction(.returnDrop,"First",movie:0)
        try? await Task.sleep(nanoseconds:1_500_000_000)
        living.shopAction(.rewindDone,"Newer",movie:1)
        let newestID = living.lifeEvent!.id
        try? await Task.sleep(nanoseconds:1_900_000_000)
        assert(living.lifeEvent?.id == newestID, "Old timer must not clear the latest animation")
        try? await Task.sleep(nanoseconds:1_400_000_000)
        assert(living.lifeEvent == nil)
        living.newGame(); assert(living.lifeEvent == nil && living.celebration == nil && living.unsureGuest == nil)
        print("PASS: action-linked opening/restocking, rejected-action guards, rare discovery once, friendship milestones, transient saves and stale animation timers")
        migrated.newGame()
        assert(migrated.deskEvent == nil)
        assert(migrated.s.day == 1 && migrated.s.money == 150 && migrated.story.chapter == 0 && !migrated.s.open && migrated.s.rentals.isEmpty)
        let newSave = Store(); assert(newSave.hasSavedGame && newSave.s.money == 150 && newSave.s.day == 1)
        print("PASS: scan, payment, sale and return-fee animations; rejected and duplicate actions; transient effect save safety")
        print("PASS: New Game and Continue save state")
        UserDefaults.standard.removeObject(forKey: "nightowl.story")
        print("PASS: 12 visitors, stable portraits, seven story chapters, rewards, dialogue, theme, pledges, ending, migration, animated rewind")
        UserDefaults.standard.removeObject(forKey: "nightowl.save")
        print("PASS: checkout, change, snacks, fees, returns, reservations, ordering, cleaning, closing, persistence")
    }
}
