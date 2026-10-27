import SwiftUI

struct NeighborhoodPanel: View {
    @EnvironmentObject var game: Store
    var body: some View {
        VStack(alignment: .leading,spacing: 16) {
            Label("\(game.reputationName) · \(game.neighborhood.reputation)/100",systemImage: "star.fill").font(.headline).foregroundStyle(gold)
            Text("Good rentals, repaired cases and event goals build your reputation. A popular shop attracts visitors faster and unlocks better deliveries.").font(.caption).foregroundStyle(.secondary)
            Text(game.todayEvent.title).font(.headline).foregroundStyle(mint)
            Text(game.todayEvent.detail).font(.caption)
            ProgressView(value: Double(min(game.experience.customers,game.todayEvent.target)),total: Double(game.todayEvent.target)).tint(mint)
            Text(game.neighborhood.eventClaimedDay == game.s.day ? "Event bonus received!" : "\(game.experience.customers)/\(game.todayEvent.target) rentals today").font(.caption.bold())
            Text("RARE VHS COLLECTION · \(game.neighborhood.rare.count)/6").font(.caption.bold()).foregroundStyle(gold)
            Button("Search today’s donation box") { game.donationBox() }.buttonStyle(.bordered).tint(mint).disabled(game.neighborhood.searchedDay == game.s.day)
            Button("Trade one spare VHS for a rare edition") { game.tradeSpareTape() }.buttonStyle(.bordered).tint(gold).disabled(game.neighborhood.reputation < 10 || game.neighborhood.tradedDay == game.s.day || game.neighborhood.rare.count == 6)
            Text("Trading unlocks at 10 reputation and uses one stock copy, once per day.").font(.caption2).foregroundStyle(.secondary)
            LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())],spacing: 12) {
                ForEach(game.s.movies) { movie in
                    VStack {
                        VHSCover(movie: movie,rare: true).opacity(game.neighborhood.rare.contains(movie.id) ? 1 : 0.2)
                        Text(game.neighborhood.rare.contains(movie.id) ? "Collector’s cut · owned" : "Find through gifts, deliveries & donations").font(.caption2).multilineTextAlignment(.center)
                    }
                }
            }
            Text("MAPLE STREET FRIENDSHIPS").font(.caption.bold()).foregroundStyle(gold)
            ForEach(Cast.all) { person in
                HStack { Cutout(index: person.id).scaleEffect(0.45).frame(width: 44,height: 65); VStack(alignment: .leading) { Text(person.name).bold(); Text("Favorite: \(person.genre.capitalized)").font(.caption); Text(game.bond(person.id) >= 3 ? "Friend · gift received" : "Talk and serve rentals to become friends").font(.caption2).foregroundStyle(.secondary) }; Spacer(); Text("♥ \(game.bond(person.id))/6").font(.caption.bold()).foregroundStyle(.pink) }
            }
        }
    }
}
struct ChoreBench: View {
    @EnvironmentObject var game: Store
    @State private var wipe: Set<Int> = []
    @State private var target = 0
    @State private var repairs: Set<Int> = []
    var body: some View {
        VStack(alignment: .leading,spacing: 14) {
            Text("HANDS-ON CHORES").font(.caption.bold()).foregroundStyle(gold)
            Text("Wipe every patch to clean a spill. Drag a ready tape onto its shelf. Repair a damaged case after inspecting its fees.").font(.caption).foregroundStyle(.secondary)
            if game.s.dirt > 0 {
                GeometryReader { geo in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12).fill(.brown.opacity(0.25))
                        HStack { ForEach(0..<6) { n in Circle().fill(.brown.opacity(wipe.contains(n) ? 0 : 0.85)).frame(width: 25,height: 25) } }
                        Text("WIPE \(wipe.count)/6").font(.caption2.bold()).offset(y: 30)
                    }.contentShape(Rectangle()).gesture(DragGesture(minimumDistance: 0).onChanged { value in
                        let n = min(5,max(0,Int(value.location.x / max(1,geo.size.width) * 6)))
                        wipe.insert(n)
                        if wipe.count == 6 { game.clean(); wipe = [] }
                    })
                }.frame(height: 90)
                Button("Clean one spill (tap alternative)") { game.clean(); wipe = [] }.font(.caption).frame(minHeight: 44)
            } else { Label("Floor is spotless",systemImage: "checkmark.circle").foregroundStyle(mint) }
            if let tape = game.s.returns.first {
                if tape.scanned && tape.assessed && tape.rewound {
                    HStack { VHSCover(movie: game.s.movies[tape.movie]).frame(width: 65).onDrag { NSItemProvider(object: tape.id.uuidString as NSString) }; Spacer(); Text("DROP VHS HERE\n\(game.s.movies[tape.movie].genre)").font(.caption.bold()).multilineTextAlignment(.center).padding(20).background(mint.opacity(0.15),in: RoundedRectangle(cornerRadius: 12)).onDrop(of: ["public.text"],isTargeted: nil) { providers in
                        guard let provider = providers.first else { return false }
                        provider.loadObject(ofClass: NSString.self) { item,_ in
                            guard let id = item as? String else { return }
                            Task { @MainActor in if game.s.returns.first?.id.uuidString == id { game.process("shelve") } }
                        }; return true
                    } }
                }
                if tape.damaged && tape.assessed {
                    Text("Repair case: press all three cracked corners").font(.caption)
                    HStack { ForEach(0..<3) { n in Button { repairs.insert(n); if repairs.count == 3 { game.repairCase(tape.id); repairs = [] } } label: { Image(systemName: repairs.contains(n) ? "checkmark.circle.fill" : "bandage.fill").frame(maxWidth: .infinity,minHeight: 48).background(.white.opacity(0.06),in: RoundedRectangle(cornerRadius: 8)) } } }
                }
            }
        }.onChange(of: game.s.returns.first?.id) { _ in repairs = [] }
    }
}
struct SaveSlotsView: View {
    @EnvironmentObject var game: Store
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Text("Three independent shops. Switching saves your current shop first.").font(.subheadline).foregroundStyle(.secondary)
                ForEach(0..<3) { slot in
                    let info = game.slotInfo(slot)
                    Button { game.switchSlot(slot); dismiss() } label: {
                        HStack { Image(systemName: slot == game.selectedSlot ? "checkmark.circle.fill" : "building.2.fill"); VStack(alignment: .leading,spacing: 5) { Text("SHOP \(slot + 1)").bold(); Text(info.map { "Day \($0.shop.day) · $\($0.shop.money) · \($0.shop.served) rentals" } ?? (slot == game.selectedSlot && game.hasSavedGame ? "Current shop · Day \(game.s.day)" : "Empty — start a fresh shop")).font(.caption) }; Spacer() }.padding(18).frame(maxWidth: .infinity).background(.white.opacity(0.06),in: RoundedRectangle(cornerRadius: 14))
                    }.buttonStyle(.plain).foregroundStyle(slot == game.selectedSlot ? mint : .white)
                }
                Spacer()
            }.padding(24).background(ink).navigationTitle("Save slots").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }.preferredColorScheme(.dark)
    }
}
