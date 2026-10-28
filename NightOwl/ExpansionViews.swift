import SwiftUI

struct ForecastCard: View {
    @EnvironmentObject var game: Store
    var body: some View {
        VStack(alignment:.leading,spacing:8) {
            Label("DAY \(game.s.day) · STOCK FORECAST",systemImage:"chart.bar.fill").font(.caption.bold()).foregroundStyle(gold)
            Text("Likely demand: " + game.forecastGenres.map { $0.capitalized }.joined(separator:" and ")).font(.subheadline.bold())
            Text("Based on this season and today’s visitors; actual requests vary.").font(.caption).foregroundStyle(.secondary)
            if game.lowStock.isEmpty { Text("All titles have at least two copies.").font(.caption).foregroundStyle(mint) }
            else { Text("Low stock: " + game.lowStock.prefix(5).map { "\($0.title) (\($0.stock))" }.joined(separator:", ")).font(.caption).foregroundStyle(coral) }
        }.padding(12).frame(maxWidth:.infinity,alignment:.leading).background(.white.opacity(0.05),in:RoundedRectangle(cornerRadius:12))
    }
}

struct CheckoutPanel: View {
    @EnvironmentObject var game: Store
    @Environment(\.dynamicTypeSize) private var textSize
    var body: some View {
        VStack(alignment:.leading,spacing:12) {
            if let guest = game.s.guests.first {
                HStack { Text(guest.name).font(.title2.bold()); Spacer(); Text("\(game.s.guests.count) in line").font(.caption).foregroundStyle(.secondary) }
                if let id = guest.movie, game.s.movies.indices.contains(id) {
                    HStack(alignment:.top,spacing:12) {
                        VHSCover(movie:game.s.movies[id]).frame(width:52,height:72)
                        VStack(alignment:.leading,spacing:5) {
                            Text(game.s.movies[id].title).font(.headline)
                            Text("Total $\(game.price)\(guest.snack ? " · includes popcorn" : " · two nights")").font(.subheadline.bold()).foregroundStyle(gold)
                            Text(guest.paid ? "Paid $10 · change due $\(10-game.price)" : "Payment not received").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    Text(guest.paid ? "3 OF 3 · CHANGE & HANDOFF" : (guest.scanned ? "2 OF 3 · PAYMENT" : "1 OF 3 · SCAN")).font(.caption2.bold()).foregroundStyle(mint)
                } else {
                    Text(game.guiding ? game.request(guest) : game.recommendationHint(guest)).font(.subheadline).fixedSize(horizontal:false,vertical:true)
                }
                if guest.paid {
                    Text("Change counted: $\(game.change) of $\(10-game.price)").font(.subheadline.bold()).foregroundStyle(game.change == 10-game.price ? mint : gold)
                    if !game.experience.autoChange { changeControls }
                    if game.change != 10-game.price {
                        Text(game.change < 10-game.price ? "Add $\(10-game.price-game.change) more change." : "Remove $\(game.change-(10-game.price)) or reset.").font(.caption).foregroundStyle(gold)
                    }
                }
                Button { advance(guest) } label: {
                    Label(nextTitle(guest),systemImage:guest.movie == nil ? "rectangle.stack" : (guest.paid ? "checkmark.circle.fill" : (guest.scanned ? "banknote" : "barcode.viewfinder")))
                        .font(.headline).frame(maxWidth:.infinity,minHeight:54).foregroundStyle(ink).background(mint,in:RoundedRectangle(cornerRadius:12))
                }.disabled(game.counterWalking || game.moviePickup != nil || (guest.paid && game.change != 10-game.price)).opacity(guest.paid && game.change != 10-game.price ? 0.5 : 1)
                HStack {
                    Button("Talk to \(guest.name)") { game.talk() }.frame(minHeight:44)
                    Spacer()
                    if guest.movie == nil && !game.guiding { Button("Reserve instead") { game.reserve() }.frame(minHeight:44) }
                }.font(.subheadline).tint(gold)
                if guest.movie != nil {
                    DisclosureGroup("Customer request & match") {
                        Text(game.recommendationHint(guest)).font(.subheadline).padding(.top,8)
                        if let id = guest.movie, game.thoughtfulMatch(game.s.movies[id],guest) { Label("Thoughtful match · extra friendship",systemImage:"heart.fill").font(.caption).foregroundStyle(mint) }
                    }.tint(mint)
                }
            } else {
                Text(game.s.open ? "Ready for the next customer" : "Ready to open?").font(.title2.bold())
                Text(game.s.open ? "Invite a customer, handle returns or explore More." : "Check the forecast and open the doors when you’re ready.").font(.subheadline).foregroundStyle(.secondary)
                Button(game.s.open ? "Invite next customer" : "Open the store") { if game.s.open { game.addGuest(); game.save() } else { game.doors() } }
                    .font(.headline).frame(maxWidth:.infinity,minHeight:54).foregroundStyle(ink).background(mint,in:RoundedRectangle(cornerRadius:12))
                ForecastCard()
            }
        }
    }
    private var changeControls: some View {
        LazyVGrid(columns:Array(repeating:GridItem(.flexible(),spacing:8),count:textSize >= .xxxLarge ? 2 : 4),spacing:8) {
            changeButton("−$1",enabled:game.change > 0) { game.change = max(0,game.change-1) }
            changeButton("+$1") { game.change += 1 }
            changeButton("+$5") { game.change += 5 }
            changeButton("Reset") { game.change = 0 }
        }
    }
    private func changeButton(_ title: String,enabled: Bool = true,action: @escaping () -> Void) -> some View {
        Button(action:action) { Text(title).font(.subheadline.bold()).lineLimit(1).minimumScaleFactor(0.8).frame(maxWidth:.infinity,minHeight:44).foregroundStyle(mint).background(mint.opacity(0.12),in:RoundedRectangle(cornerRadius:10)) }.disabled(!enabled).opacity(enabled ? 1 : 0.4)
    }
    private func nextTitle(_ guest: Guest) -> String {
        if game.counterWalking { return "Customer is approaching…" }
        if game.moviePickup != nil { return "Getting your movie…" }
        if guest.movie == nil { return "Choose a movie" }
        return guest.paid ? "Give change & rent" : (guest.scanned ? "Take $10 payment" : "Scan VHS barcode")
    }
    private func advance(_ guest: Guest) {
        if guest.movie == nil { game.station = "SHELVES" }
        else if !guest.scanned { game.scan() }
        else if !guest.paid { game.payment() }
        else { game.checkout() }
    }
}

struct FloorPlanScene: View {
    @EnvironmentObject var game: Store
    var editing = false
    @State private var selected = "shelves"
    private let fixtures = ["shelves","posters","counter","snacks"]
    var body: some View {
        VStack(alignment:.leading,spacing:10) {
            Text("YOUR SHOP FLOOR PLAN").font(.caption.bold()).foregroundStyle(mint)
            if editing {
                Picker("Move fixture",selection:$selected) { ForEach(fixtures,id:\.self) { Text($0.capitalized).tag($0) } }.pickerStyle(.menu).tint(mint)
                Text("Choose a fixture, then tap a square. Occupied squares swap places.").font(.caption).foregroundStyle(.secondary)
            }
            LazyVGrid(columns:Array(repeating:GridItem(.flexible(),spacing:5),count:3),spacing:5) {
                ForEach(0..<9,id:\.self) { cell in
                    let fixture = game.expansion.layout.first(where: { $0.value == cell })?.key
                    Button {
                        if editing { game.arrange(selected,at:cell) }
                        else if let fixture { game.station = fixture == "shelves" ? "SHELVES" : (fixture == "counter" ? "COUNTER" : (fixture == "posters" ? "STORY" : "TOWN")) }
                    } label: {
                        VStack(spacing:4) {
                            if let fixture {
                                Image(systemName:symbol(fixture)).font(.title2).foregroundStyle(fixture == "snacks" ? gold : mint)
                                Text(fixture.capitalized).font(.caption2.bold())
                                if fixture == "shelves" { HStack(spacing:2) { ForEach(0..<6) { n in Rectangle().fill(palette[n]).frame(width:5,height:12) } } }
                            } else { Image(systemName:"square.dashed").foregroundStyle(.white.opacity(0.15)); Text(editing ? "Place here" : "Aisle").font(.caption2).foregroundStyle(.secondary) }
                        }.frame(maxWidth:.infinity,minHeight:82).background(fixture == selected && editing ? mint.opacity(0.18) : .white.opacity(0.05),in:RoundedRectangle(cornerRadius:8))
                    }.buttonStyle(.plain).accessibilityLabel("Square \(cell+1), \(fixture ?? "empty"). \(editing ? "Place selected fixture" : "Open station")")
                }
            }
            Text("ENTRY / EXIT").font(.caption2.monospaced()).foregroundStyle(gold).frame(maxWidth:.infinity)
        }
    }
    private func symbol(_ fixture: String) -> String { ["shelves":"books.vertical.fill","posters":"photo.artframe","counter":"creditcard.fill","snacks":"popcorn.fill"][fixture] ?? "square" }
}

struct WeeklyProjectPanel: View {
    @EnvironmentObject var game: Store
    var body: some View {
        VStack(alignment:.leading,spacing:10) {
            Text("WEEK \(game.shopWeek) · DAYS \((game.shopWeek-1)*7+1)–\(game.shopWeek*7)").font(.caption.bold()).foregroundStyle(gold)
            if let goal = game.expansion.weeklyGoal {
                Text(goal == "income" ? "Earn $80 from rentals" : (goal == "friends" ? "Earn 8 friendship points" : "Acquire 3 used copies or new rare tapes")).font(.headline)
                ProgressView(value:Double(min(game.weeklyValue,game.weeklyTarget)),total:Double(game.weeklyTarget)).tint(mint)
                Text("\(game.weeklyValue) / \(game.weeklyTarget)").font(.caption)
                Button(game.expansion.weeklyClaimed ? "Reward collected" : "Claim weekly reward") { game.claimWeekly() }.buttonStyle(.borderedProminent).tint(mint).foregroundStyle(ink).disabled(game.expansion.weeklyClaimed || game.weeklyValue < game.weeklyTarget)
            } else {
                Text("Choose one project for this week. The choice stays until next week; progress already earned this week counts.").font(.caption)
                Button("Rental income · reward $35") { game.chooseWeekly("income") }
                Button("Friendships · reward $25 + reputation") { game.chooseWeekly("friends") }
                Button("Collection · reward $25 + a missing rare tape") { game.chooseWeekly("collection") }
            }
            Divider()
            Label(game.seasonName,systemImage:game.seasonSymbol).font(.headline).foregroundStyle(gold)
            Text(game.seasonStory).font(.caption)
            Text("Rent 3 \(game.seasonGenre.lowercased()) films this season: \(min(3,game.expansion.seasonalRentals))/3 · \(game.expansion.seasonalClaimed ? "$20 bonus paid" : "$20 bonus")").font(.caption).foregroundStyle(mint)
        }.tint(mint)
    }
}

struct StaffAssignmentPanel: View {
    @EnvironmentObject var game: Store
    var body: some View {
        VStack(alignment:.leading,spacing:10) {
            if game.s.staff {
                Text("Bea works every 15 shop minutes. Current assignment: \(game.expansion.staffJob).").font(.caption)
                ForEach(["balanced","cleaning","rewinding","restocking"],id:\.self) { job in
                    Button { game.assignStaff(job) } label: { HStack { Text(job.capitalized); Spacer(); if game.expansion.staffJob == job { Image(systemName:"checkmark") } }.frame(minHeight:44) }.tint(mint)
                }
                Text("Restocking handles the first returned tape only after you have scanned it, assessed fees and rewound it. Bea never creates free stock.").font(.caption).foregroundStyle(.secondary)
            } else { Text("Hire Bea for $60, then assign her work here. Wages are $15 per day.").font(.caption); Button("Hire Bea · $60") { game.hire() }.buttonStyle(.bordered).disabled(game.s.money < 60) }
        }
    }
}

struct UsedTapeDesk: View {
    @EnvironmentObject var game: Store
    var body: some View {
        VStack(alignment:.leading,spacing:14) {
            Text("SECONDHAND VHS DESK").font(.headline).foregroundStyle(mint)
            Text("One neighbor offers a tape each day. Inspect it before negotiating; buying adds one rental copy to your stock.").font(.caption)
            if game.expansion.usedDoneDay == game.s.day { Label("Today’s offer is finished. Check tomorrow.",systemImage:"checkmark.circle").foregroundStyle(mint) }
            else if let offer = game.expansion.usedOffer,offer.day == game.s.day,game.s.movies.indices.contains(offer.movie) {
                let film = game.s.movies[offer.movie]
                HStack { Cutout(index:game.s.day % 12); VHSCover(movie:film).frame(width:85,height:120) }
                Text("\(Cast.all[game.s.day % 12].name) is asking $\(offer.fairPrice+2)").font(.headline)
                if offer.inspected {
                    Text(offer.condition).foregroundStyle(gold)
                    Text("Estimated fair value: $\(offer.fairPrice).\(game.s.day % 4 == 0 ? " Collector edition markings found!" : "")").font(.caption)
                    if offer.attempts < 2 {
                        ForEach([max(1,offer.fairPrice-2),offer.fairPrice,offer.fairPrice+2],id:\.self) { price in Button("Offer $\(price)") { game.offerUsed(price) }.buttonStyle(.bordered).disabled(game.s.money < price) }
                    } else { Text("The seller has ended negotiations for today.").font(.caption).foregroundStyle(coral) }
                } else { Button("Inspect case & test playback") { game.inspectUsedTape() }.buttonStyle(.borderedProminent).tint(mint).foregroundStyle(ink) }
                Button("Pass on this tape") { game.passUsed() }.tint(.gray)
            }
        }.onAppear { game.prepareUsedOffer() }.onChange(of:game.s.day) { _ in game.prepareUsedOffer() }
    }
}

struct MovieClubPanel: View {
    @EnvironmentObject var game: Store
    private var stocked: [Movie] { game.s.movies.filter { $0.stock > 0 } }
    var body: some View {
        VStack(alignment:.leading,spacing:12) {
            Text("MAPLE STREET MOVIE CLUB").font(.headline).foregroundStyle(mint)
            Text("Plan an after-hours double bill for four regulars. Hosting closes the shop for tonight; finish the queue and returns first. Screening copies remain in stock.").font(.caption)
            ForEach(0..<2) { slot in
                Picker(slot == 0 ? "First feature" : "Second feature",selection:Binding(get:{ game.expansion.clubFilms[slot] },set:{ game.expansion.clubFilms[slot] = $0; game.save() })) {
                    ForEach(game.s.movies) { film in Text("\(film.title) · \(film.genre)").tag(film.id) }
                }.tint(mint)
            }
            Picker("Invite with",selection:$game.expansion.clubHost) { ForEach(Cast.all) { person in Text("\(person.name) + three neighbors").tag(person.id) } }.tint(mint).onChange(of:game.expansion.clubHost) { _ in game.save() }
            Toggle("Prepare popcorn and drinks",isOn:$game.expansion.clubSnacks).tint(mint).onChange(of:game.expansion.clubSnacks) { _ in game.save() }
            Text("Budget $\(game.expansion.clubSnacks ? 8 : 4) · audience donations depend on the films and snacks.").font(.caption).foregroundStyle(gold)
            Button(game.expansion.clubDay == game.s.day ? "Tonight’s screening is complete" : "Host screening · closes shop tonight") { game.hostClub() }.buttonStyle(.borderedProminent).tint(mint).foregroundStyle(ink).disabled(!game.canHostClub)
            if !game.expansion.clubResult.isEmpty { Text(game.expansion.clubResult).font(.subheadline).fixedSize(horizontal:false,vertical:true).padding(12).background(.white.opacity(0.05),in:RoundedRectangle(cornerRadius:10)) }
        }
    }
}

struct TownNewspaper: View {
    @EnvironmentObject var game: Store
    var body: some View {
        VStack(alignment:.leading,spacing:14) {
            Text("THE MAPLE STREET GAZETTE").font(.title2.bold()).foregroundStyle(gold)
            Text("DAY \(game.s.day) · WEEK \(game.shopWeek)").font(.caption.monospaced())
            Divider()
            Text("Night Owl: \(game.reputationName)").font(.headline)
            Text("\(game.s.served) customers served · Reputation \(game.neighborhood.reputation)/100. \(game.storyFinished ? "Maple Street movie night saved the shop." : game.chapter.title)").font(.subheadline)
            Text(game.seasonName).font(.headline).foregroundStyle(mint)
            Text(game.seasonStory).font(.subheadline)
            Text("COMING UP: \(game.todayEvent.title). Spotlight: \(game.forecastGenres.joined(separator:", ")).").font(.caption).foregroundStyle(gold)
            ForEach(game.expansion.articles) { article in
                Divider(); Text("DAY \(article.day) · \(article.title)").font(.headline); Text(article.body).font(.subheadline)
            }
            if game.expansion.articles.isEmpty { Text("Your used-tape deals, screenings and weekly achievements will make the local pages.").font(.caption).foregroundStyle(.secondary) }
        }
    }
}

struct TownHub: View {
    @EnvironmentObject var game: Store
    @State private var section = "Shop"
    var body: some View {
        VStack(alignment:.leading,spacing:18) {
            Text("NIGHT OWL · AROUND TOWN").font(.headline).foregroundStyle(mint)
            Picker("Town activity",selection:$section) { ForEach(["Shop","Trade","Club","News"],id:\.self) { Text($0).tag($0) } }.pickerStyle(.segmented)
            switch section {
            case "Trade": UsedTapeDesk()
            case "Club": MovieClubPanel()
            case "News": TownNewspaper()
            default:
                ForecastCard()
                DisclosureGroup("Arrange your floor plan") { FloorPlanScene(editing:true).padding(.top,12) }.tint(mint)
                DisclosureGroup("Assign Bea’s tasks") { StaffAssignmentPanel().padding(.top,12) }.tint(mint)
                WeeklyProjectPanel()
            }
        }.onAppear { game.syncExpansionWeek() }
    }
}
