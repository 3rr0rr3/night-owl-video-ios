import Foundation

@main struct StoreTests {
    @MainActor static func main() {
        UserDefaults.standard.removeObject(forKey: "nightowl.save")
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
        UserDefaults.standard.removeObject(forKey: "nightowl.save")
        print("PASS: checkout, change, snacks, fees, returns, reservations, ordering, cleaning, closing, persistence")
    }
}
