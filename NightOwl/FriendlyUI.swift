import SwiftUI

struct GameStatusBar: View {
    @EnvironmentObject var game: Store
    var body: some View {
        HStack(spacing:10) {
            Label("Day \(game.s.day)",systemImage:"calendar").font(.caption.bold())
            Text(game.clock).font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            Text(game.s.open ? "Open" : "Closed").font(.caption.bold()).foregroundStyle(game.s.open ? mint : coral)
            Spacer(minLength:4)
            Text("$\(game.s.money)").font(.headline.monospacedDigit()).foregroundStyle(gold)
        }.padding(.horizontal,16).padding(.vertical,8).background(ink)
            .accessibilityElement(children:.combine).accessibilityLabel("Day \(game.s.day), \(game.clock), shop \(game.s.open ? "open" : "closed"), \(game.s.money) dollars")
    }
}

struct StationBar: View {
    @EnvironmentObject var game: Store
    private let stations = ["COUNTER","RETURNS","SHELVES","MORE"]
    private func name(_ station: String) -> String { ["COUNTER":"Counter","RETURNS":"Returns","SHELVES":"Films","MORE":"More"][station] ?? station }
    private func symbol(_ station: String) -> String { ["COUNTER":"creditcard","RETURNS":"tray.and.arrow.down","SHELVES":"rectangle.stack","MORE":"square.grid.2x2"][station] ?? "square" }
    var body: some View {
        HStack(spacing:4) {
            ForEach(stations,id:\.self) { station in
                let selected = game.station == station || (station == "MORE" && !stations.contains(game.station))
                Button { game.station = station } label: {
                    VStack(spacing:4) {
                        Image(systemName:symbol(station)).font(.system(size:20,weight:.semibold))
                            .overlay(alignment:.topTrailing) {
                                if game.badge(station) > 0 { Text("\(game.badge(station))").font(.system(size:9,weight:.black)).foregroundStyle(ink).padding(3).background(gold,in:Circle()).offset(x:12,y:-5) }
                            }
                        Text(name(station)).font(.caption2.bold()).lineLimit(1).minimumScaleFactor(0.8)
                    }.frame(maxWidth:.infinity,minHeight:56).foregroundStyle(selected ? ink : .white.opacity(0.8)).background(selected ? mint : .clear,in:RoundedRectangle(cornerRadius:12))
                }.buttonStyle(.plain).accessibilityLabel("\(name(station)), \(game.badge(station)) pending").accessibilityAddTraits(selected ? .isSelected : [])
            }
        }.padding(.horizontal,10).padding(.top,8).padding(.bottom,4).background(ink).overlay(alignment:.top) { Rectangle().fill(.white.opacity(0.12)).frame(height:1) }
    }
}

struct GameFeedback: View {
    @EnvironmentObject var game: Store
    @State private var expanded = false
    var body: some View {
        Button { expanded.toggle() } label: {
            HStack(alignment:.top,spacing:10) {
                Image(systemName:"bubble.left.fill").foregroundStyle(mint)
                Text(game.message).font(.subheadline).lineLimit(expanded ? nil : 2).multilineTextAlignment(.leading).foregroundStyle(.white)
                Spacer(minLength:0)
                Image(systemName:expanded ? "chevron.up" : "chevron.down").font(.caption).foregroundStyle(.secondary)
            }.padding(12).frame(maxWidth:.infinity,minHeight:44,alignment:.leading).background(.white.opacity(0.05),in:RoundedRectangle(cornerRadius:12))
        }.buttonStyle(.plain).accessibilityLabel(game.message).accessibilityHint("Double tap to expand or collapse message").onChange(of:game.message) { _ in expanded = false }
    }
}

struct MoreStations: View {
    @EnvironmentObject var game: Store
    var body: some View {
        VStack(alignment:.leading,spacing:14) {
            Text("Your video store").font(.title2.bold())
            NextTaskCard()
            link("Shop management","Stock, equipment, styles and settings","STORE PC","building.2")
            link("Around town","Trade tapes, plan movie club and set weekly goals","TOWN","building.2")
            link("Story",game.storyFinished ? "Maple Street movie night is saved" : "Chapter \(game.story.chapter+1): \(game.chapter.title)","STORY","book.closed")
            link("Customer notebook","Favorites, friendships and recent rentals","NOTEBOOK","person.text.rectangle")
            DisclosureGroup("View the shop") { ShopArt().padding(.top,12); FloorPlanScene().padding(.top,12) }.tint(mint)
            DisclosureGroup("How to play") {
                Text("Counter: choose a movie, scan it, take payment and give change. Returns: follow the highlighted next step to check in each tape. Films: search or filter to find a good match. Pause saves your progress and returns to the title screen. You can hide the desk scene for more space.").font(.subheadline).padding(.top,10)
            }.tint(mint)
            Label(game.seasonName,systemImage:game.seasonSymbol).font(.headline).foregroundStyle(gold)
            Text(game.seasonStory).font(.subheadline).foregroundStyle(.secondary)
            Text("\(game.reputationName) · Level \(game.level) · \(game.s.served) customers served").font(.caption).foregroundStyle(.secondary)
        }
    }
    private func link(_ title: String,_ detail: String,_ station: String,_ icon: String) -> some View {
        Button { game.station = station } label: {
            HStack(spacing:12) {
                Image(systemName:icon).font(.title2).foregroundStyle(mint).frame(width:32)
                VStack(alignment:.leading,spacing:4) { Text(title).font(.headline); Text(detail).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal:false,vertical:true) }
                Spacer(minLength:0); Image(systemName:"chevron.right").font(.caption).foregroundStyle(mint)
            }.foregroundStyle(.white).padding(16).frame(maxWidth:.infinity,minHeight:72).background(.white.opacity(0.06),in:RoundedRectangle(cornerRadius:14))
        }.buttonStyle(.plain)
    }
}

struct ReturnDeskPanel: View {
    @EnvironmentObject var game: Store
    var dockedActions = false
    var body: some View {
        VStack(alignment:.leading,spacing:14) {
            Text("Movie returns").font(.title2.bold())
            if let tape = game.s.returns.first {
                HStack(alignment:.top,spacing:14) {
                    VHSCover(movie:game.s.movies[tape.movie]).frame(width:72,height:100)
                    VStack(alignment:.leading,spacing:6) {
                        Text(game.s.movies[tape.movie].title).font(.headline)
                        Text("\(game.s.returns.count) tape\(game.s.returns.count == 1 ? "" : "s") in the bin").font(.caption).foregroundStyle(.secondary)
                        Text(tape.late ? "Late return · $2" : "Returned on time").font(.caption).foregroundStyle(tape.late ? gold : mint)
                        Text(tape.damaged ? "Damaged case · $5" : "Case in good condition").font(.caption).foregroundStyle(tape.damaged ? coral : mint)
                    }
                }
                HStack(spacing:6) {
                    step("Scan",done:tape.scanned); step("Fees",done:tape.assessed); step("Rewind",done:tape.rewound); step("Shelve",done:false)
                }
                if game.rewinding != nil { RewindDeck(active:true) }
                if !dockedActions { ReturnActionButton() }
                if game.rewinding != nil { Text("Wait for the reels to stop. Your next action will appear here.").font(.caption).foregroundStyle(mint) }
                DisclosureGroup("Case repairs & hands-on tasks") { ChoreBench().padding(.top,12) }.tint(mint)
            } else {
                Label("All returns are checked in",systemImage:"checkmark.circle.fill").foregroundStyle(mint).font(.headline)
                Text("Serve the next customer or plan your shop activities.").font(.subheadline).foregroundStyle(.secondary)
                Button("Go to counter") { game.station = "COUNTER" }.buttonStyle(.borderedProminent).tint(mint).foregroundStyle(ink).frame(minHeight:44)
            }
            if !game.s.held.isEmpty { Text("Ready reservations").font(.headline); ForEach(game.s.held,id:\.self) { id in Button("Collect \(game.s.movies[id].title) · $4") { game.collectHold(id) }.buttonStyle(.bordered).tint(gold).frame(minHeight:44) } }
            if !game.s.reservations.isEmpty { Text("Waiting for return: " + game.s.reservations.map { game.s.movies[$0].title }.joined(separator:", ")).font(.caption).foregroundStyle(.secondary) }
        }
    }
    private func step(_ name: String,done: Bool) -> some View { VStack(spacing:4) { Image(systemName:done ? "checkmark.circle.fill" : "circle"); Text(name).font(.caption2) }.foregroundStyle(done ? mint : .secondary).frame(maxWidth:.infinity).padding(.vertical,8).background(.white.opacity(0.04),in:RoundedRectangle(cornerRadius:8)) }
}

struct ManagementPanel: View {
    @EnvironmentObject var game: Store
    var onReport: () -> Void
    @State private var section = "Daily"
    @State private var confirmClose = false
    var body: some View {
        VStack(alignment:.leading,spacing:16) {
            Text("Shop management").font(.title2.bold())
            Picker("Manage",selection:$section) { ForEach(["Daily","Stock","Style","Settings"],id:\.self) { Text($0).tag($0) } }.pickerStyle(.segmented)
            switch section {
            case "Stock":
                DisclosureGroup("Equipment upgrades") { EquipmentPanel().padding(.top,12) }.tint(mint)
                Text("Order movies").font(.headline)
                FilmBrowser(ordering:true)
            case "Style": StyleShop()
            case "Settings":
                PlayOptions()
                DisclosureGroup("Save backup · export or import") { BackupPanel().padding(.top,12) }.tint(mint)
                Text("Progress saves automatically on this iPhone. Pause saves and returns to the title screen.").font(.caption).foregroundStyle(.secondary)
            default:
                ForecastCard()
                Button("Clean store · \(game.s.dirt) spills") { game.clean() }.buttonStyle(.bordered).tint(mint).frame(minHeight:44).disabled(game.s.dirt == 0)
                DisclosureGroup("Bea’s work assignment") { StaffAssignmentPanel().padding(.top,12) }.tint(mint)
                DisclosureGroup("Events, friends & rare tapes") { NeighborhoodPanel().padding(.top,12) }.tint(mint)
                DisclosureGroup("Daily surprises") { SurprisePanel().padding(.top,12) }.tint(mint)
                DisclosureGroup("Hands-on chores") { ChoreBench().padding(.top,12) }.tint(mint)
                if game.experience.report != nil { Button("View last shift summary",action:onReport).buttonStyle(.bordered).frame(minHeight:44) }
                Divider()
                Text("End your shift").font(.headline)
                Text(closeReason).font(.caption).foregroundStyle(.secondary)
                Button("Close day & pay $\(15 + (game.s.staff ? 15 : 0)) bills") { confirmClose = true }.buttonStyle(.borderedProminent).tint(coral).foregroundStyle(ink).frame(minHeight:50).disabled(!game.canCloseShift || !shiftStarted)
            }
        }.confirmationDialog("Close this day?",isPresented:$confirmClose,titleVisibility:.visible) {
            Button("Pay bills & start next day") { game.nextDay() }
            Button("Keep playing",role:.cancel) {}
        } message: { Text("Finish day \(game.s.day), pay $\(15 + (game.s.staff ? 15 : 0)) in bills and prepare tomorrow’s returns. Your shift summary opens next.") }
    }
    private var shiftStarted: Bool { game.s.open || game.s.minutes >= 1200 || game.s.sales > 0 || !game.s.rentals.isEmpty }
    private var closeReason: String {
        if !shiftStarted { return "Open the store and work a shift first." }
        if !game.s.guests.isEmpty { return "Serve or reserve movies for the \(game.s.guests.count) waiting customers first." }
        if game.s.returns.count > game.carryReturns { return "Process \(game.s.returns.count-game.carryReturns) more returns. Your carryover limit is \(game.carryReturns)." }
        return "The queue is clear and your return carryover limit is met. Closing advances to tomorrow."
    }
}

struct CheckoutActionButton: View {
    @EnvironmentObject var game: Store
    private var wrongChange: Bool { game.s.guests.first?.paid == true && game.change != 10-game.price }
    var body: some View {
        Button(action:advance) {
            Label(title,systemImage:game.s.guests.first?.paid == true ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                .font(.headline).frame(maxWidth:.infinity,minHeight:54).padding(.horizontal,8).foregroundStyle(ink).background(mint,in:RoundedRectangle(cornerRadius:12))
        }.disabled(game.counterWalking || game.moviePickup != nil || wrongChange).opacity(wrongChange ? 0.5 : 1)
    }
    private var title: String {
        if game.counterWalking { return "Please wait for customer…" }
        if game.moviePickup != nil { return "Getting your movie…" }
        guard let guest = game.s.guests.first else { return game.s.open ? "Invite next customer" : "Open the store" }
        if guest.movie == nil { return "Choose a movie" }
        if !guest.scanned { return "Scan VHS barcode" }
        if !guest.paid { return "Take $10 payment" }
        return wrongChange ? "Count $\(10-game.price) change first" : "Give change & rent"
    }
    private func advance() {
        guard !game.counterWalking, game.moviePickup == nil else { return }
        guard let guest = game.s.guests.first else { if game.s.open { game.addGuest(); game.save() } else { game.doors() }; return }
        if guest.movie == nil { game.station = "SHELVES" }
        else if !guest.scanned { game.scan() }
        else if !guest.paid { game.payment() }
        else { game.checkout() }
    }
}

struct ReturnActionButton: View {
    @EnvironmentObject var game: Store
    var body: some View {
        if let tape = game.s.returns.first {
            Button { advance(tape) } label: {
                Label(title(tape),systemImage:"arrow.right.circle.fill").font(.headline).frame(maxWidth:.infinity,minHeight:54).padding(.horizontal,8).foregroundStyle(ink).background(mint,in:RoundedRectangle(cornerRadius:12))
            }.disabled(game.rewinding != nil)
        }
    }
    private func title(_ tape: Tape) -> String {
        if !tape.scanned { return "Scan returned tape" }
        if !tape.assessed { let fee = (tape.late ? 2 : 0) + (tape.damaged ? 5 : 0); return fee > 0 ? "Collect $\(fee) return fees" : "Confirm no fees" }
        if !tape.rewound { return game.rewinding == nil ? "Rewind tape" : "Rewinding…" }
        return game.s.reservations.contains(tape.movie) ? "Set aside reserved copy" : "Put tape back on shelf"
    }
    private func advance(_ tape: Tape) {
        guard game.rewinding == nil else { return }
        if !tape.scanned { game.process("scan") } else if !tape.assessed { game.process("fee") } else if !tape.rewound { game.startRewind() } else { game.process("shelve") }
    }
}
