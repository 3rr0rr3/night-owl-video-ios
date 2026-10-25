import SwiftUI

let ink = Color(red: 0.08, green: 0.09, blue: 0.17)
let mint = Color(red: 0.51, green: 0.94, blue: 0.74)
let coral = Color(red: 1, green: 0.46, blue: 0.40)
let gold = Color(red: 1, green: 0.79, blue: 0.35)
let palette: [Color] = [mint, coral, gold, .cyan, .pink, .purple]

@main struct NightOwlApp: App {
    @StateObject var store = Store()
    var body: some Scene { WindowGroup { GameView().environmentObject(store).preferredColorScheme(.dark) } }
}
struct Cutout: View {
    var index: Int
    var body: some View {
        ZStack {
            Ellipse().fill(.black.opacity(0.25)).frame(width: 64, height: 10).offset(y: 49)
            HStack(spacing: 4) { Capsule().fill(ink); Capsule().fill(ink) }.frame(width: 42, height: 19).offset(y: 40)
            RoundedRectangle(cornerRadius: 17).fill(palette[index % 6]).overlay(RoundedRectangle(cornerRadius: 17).stroke(ink, lineWidth: 2)).frame(width: 65, height: 48).offset(y: 14)
            Circle().fill(Color(red: 0.91, green: 0.73 - Double(index % 3) * 0.08, blue: 0.56)).overlay(Circle().stroke(ink, lineWidth: 2)).frame(width: 58, height: 57).offset(y: -21)
            Ellipse().fill(palette[(index + 2) % 6]).frame(width: 61, height: 23).offset(y: -43)
            HStack(spacing: -2) { eye; eye }.offset(y: -22)
            Path { p in p.move(to: CGPoint(x: 32, y: 45)); p.addQuadCurve(to: CGPoint(x: 46, y: 45), control: CGPoint(x: 39, y: 50)) }.stroke(ink, lineWidth: 1.5)
            Rectangle().fill(ink.opacity(0.5)).frame(width: 1, height: 30).offset(y: 19)
        }.frame(width: 80, height: 105)
    }
    var eye: some View { Ellipse().fill(.white).frame(width: 19, height: 23).overlay(Circle().fill(ink).frame(width: 3, height: 3)) }
}
struct ShopArt: View {
    @EnvironmentObject var game: Store
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 0.17, green: 0.18, blue: 0.29)
                VStack(spacing: 0) {
                    HStack { Text("NIGHT OWL").font(.system(size: 23, weight: .black, design: .rounded)).foregroundStyle(mint); Spacer(); Text("VHS • 1994").font(.caption.bold()).foregroundStyle(gold) }.padding(18)
                    HStack(spacing: 13) {
                        shelf("CULT CLASSICS", 0); shelf("NEW RELEASES", 3)
                        VStack { Image(systemName: "moon.stars.fill").font(.largeTitle).foregroundStyle(gold); Text(game.s.day % 3 == 0 ? "RAINY FRIDAY" : "MOVIE NIGHT").font(.system(size: 9, weight: .heavy)); Text("2 NIGHTS\n$4").font(.system(size: 19, weight: .black, design: .rounded)).foregroundStyle(mint) }.frame(width: 82, height: 113).background(ink).clipShape(RoundedRectangle(cornerRadius: 6))
                    }.padding(.horizontal, 16)
                    Rectangle().fill(Color(red: 0.29, green: 0.26, blue: 0.38)).frame(height: 95).overlay(alignment: .bottom) {
                        HStack(spacing: 1) { ForEach(0..<min(game.s.guests.count, 4), id: \.self) { n in Cutout(index: n + game.s.day) }; Spacer() }.padding(.leading, 15).offset(y: 2)
                    }
                }
                VStack { Spacer(); HStack { Text("▰ RETURNS \(game.s.returns.count)"); Spacer(); Text("◉ REGISTER") }.font(.system(size: 10, weight: .black, design: .monospaced)).foregroundStyle(mint).padding(12).background(ink).overlay(alignment: .top) { Rectangle().fill(coral).frame(height: 4) } }
                if game.s.decor > 0 { Image(systemName: "sparkles").foregroundStyle(gold).position(x: geo.size.width - 32, y: 30) }
            }
        }.frame(height: 275).clipShape(RoundedRectangle(cornerRadius: 18))
    }
    func shelf(_ title: String, _ start: Int) -> some View {
        VStack(spacing: 5) {
            Text(title).font(.system(size: 8, weight: .black)).foregroundStyle(gold)
            ForEach(0..<2) { row in
                HStack(spacing: 3) { ForEach(0..<6) { n in Rectangle().fill(palette[(start + row + n) % 6]).frame(height: 34).overlay(alignment: .bottom) { Rectangle().fill(ink.opacity(0.65)).frame(height: 9) } } }.padding(.horizontal, 5).padding(.bottom, 4).background(ink)
            }
        }
    }
}
struct GameView: View {
    @EnvironmentObject var game: Store
    let tabs = ["COUNTER", "RETURNS", "SHELVES", "STORE PC"]
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 17) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) { Text("NIGHT OWL").font(.system(size: 28, weight: .black, design: .rounded)); Text("VIDEO STORE SIMULATOR").font(.system(size: 10, weight: .bold, design: .monospaced)).tracking(2).foregroundStyle(mint) }
                    Spacer()
                    VStack(alignment: .trailing) { Text("$\(game.s.money)").font(.title2.bold()).foregroundStyle(gold); Text("LEVEL \(game.level)").font(.caption2.bold()).foregroundStyle(.secondary) }
                }
                HStack { Label("DAY \(game.s.day)", systemImage: "calendar"); Spacer(); Text(game.clock); Spacer(); Text(game.s.open ? "OPEN" : "CLOSED").foregroundStyle(game.s.open ? mint : coral) }.font(.system(size: 11, weight: .bold, design: .monospaced))
                ShopArt()
                HStack(alignment: .top, spacing: 10) { Image(systemName: "bubble.left.fill").foregroundStyle(mint); Text(game.message).font(.system(size: 13, weight: .medium)).fixedSize(horizontal: false, vertical: true) }.padding(14).frame(maxWidth: .infinity, alignment: .leading).background(.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 12))
                ScrollView(.horizontal, showsIndicators: false) { HStack(spacing: 8) { ForEach(tabs, id: \.self) { tab in Button { game.station = tab } label: { Text(tab).font(.system(size: 11, weight: .heavy)).padding(.horizontal, 14).padding(.vertical, 12).background(game.station == tab ? mint : .white.opacity(0.06)).foregroundStyle(game.station == tab ? ink : .white).clipShape(Capsule()) } } } }
                Group { switch game.station { case "COUNTER": counter; case "RETURNS": returns; case "SHELVES": shelves; default: pc } }
                HStack { Label("\(game.s.served) served", systemImage: "person.2"); Spacer(); Text("TODAY $\(game.s.sales)") }.font(.caption).foregroundStyle(.secondary)
                Text("BE KIND. REWIND.").font(.system(size: 10, weight: .heavy, design: .monospaced)).tracking(4).foregroundStyle(.white.opacity(0.25)).frame(maxWidth: .infinity).padding(.vertical, 12)
            }.padding(20).frame(maxWidth: 650)
        }.frame(maxWidth: .infinity).background(ink).onReceive(timer) { _ in game.tick() }
    }
    func action(_ title: String, _ symbol: String, color: Color = mint, enabled: Bool = true, run: @escaping () -> Void) -> some View {
        Button(action: run) { Label(title, systemImage: symbol).font(.system(size: 14, weight: .bold)).frame(maxWidth: .infinity).padding(14).background(color.opacity(enabled ? 0.16 : 0.04)).foregroundStyle(enabled ? color : .gray).clipShape(RoundedRectangle(cornerRadius: 12)) }.disabled(!enabled)
    }
    var counter: some View {
        VStack(alignment: .leading, spacing: 12) {
            title("THE RENTAL COUNTER", "\(game.s.guests.count) in line")
            if let g = game.s.guests.first {
                HStack { Cutout(index: game.s.day); VStack(alignment: .leading, spacing: 8) { Text(g.name).font(.title3.bold()); Text("“Got any \(g.genre.lowercased()) movies?”").font(.subheadline); if g.snack { Label("Popcorn combo +$3", systemImage: "popcorn.fill").font(.caption).foregroundStyle(gold) } } }
                if let i = g.movie { Text("▰  \(game.s.movies[i].title) • $\(game.price)").font(.headline).foregroundStyle(gold) }
                if g.movie == nil {
                    action("Choose a movie", "rectangle.stack") { game.station = "SHELVES" }
                    action("Reserve a title", "bookmark", color: gold) { game.reserve() }
                } else if !g.scanned { action("Scan VHS barcode", "barcode.viewfinder") { game.scan() } }
                else if !g.paid { action("Take $10 payment", "banknote") { game.payment() } }
                else {
                    Text("Change due: $\(10 - game.price) • counted: $\(game.change)").font(.subheadline.bold())
                    HStack { action("+$1", "plus") { game.change += 1 }; action("+$5", "plus") { game.change += 5 }; action("Reset", "arrow.counterclockwise", color: coral) { game.change = 0 } }
                    action("Give change & rent", "checkmark.circle") { game.checkout() }
                }
            } else { Text("The counter is quiet. Work on returns, clean up, or order new tapes.").foregroundStyle(.secondary).font(.subheadline); if !game.s.open { action("Open the store", "door.left.hand.open") { game.doors() } } else { action("Invite next customer", "person.badge.plus") { game.addGuest(); game.save() } } }
        }
    }
    var returns: some View {
        VStack(alignment: .leading, spacing: 12) {
            title("RETURN BIN", "\(game.s.returns.count) tapes")
            if let t = game.s.returns.first {
                Text(game.s.movies[t.movie].title).font(.title3.bold()).foregroundStyle(gold)
                Text("\(t.late ? "LATE · $2" : "ON TIME")   /   \(t.damaged ? "DAMAGED · $5" : "GOOD CONDITION")").font(.caption.bold()).foregroundStyle(coral)
                action(t.scanned ? "Checked in ✓" : "1. Scan return", "barcode", enabled: !t.scanned) { game.process("scan") }
                action(t.assessed ? "Fees reviewed ✓" : "2. Inspect & collect fees", "magnifyingglass", enabled: t.scanned && !t.assessed) { game.process("fee") }
                action(t.rewound ? "Rewound ✓" : "3. Rewind tape", "backward.end", enabled: !t.rewound) { game.process("rewind") }
                action("4. Shelve / set aside reservation", "books.vertical", enabled: t.scanned && t.assessed && t.rewound) { game.process("shelve") }
            } else { Text("All tapes checked in. Tomorrow brings more returns.").font(.subheadline).foregroundStyle(.secondary) }
            ForEach(game.s.held, id: \.self) { i in action("Collect: \(game.s.movies[i].title)", "bookmark.fill", color: gold) { game.collectHold(i) } }
            if !game.s.reservations.isEmpty { Text("Waiting for return: " + game.s.reservations.map { game.s.movies[$0].title }.joined(separator: ", ")).font(.caption).foregroundStyle(.secondary) }
        }
    }
    var shelves: some View {
        VStack(alignment: .leading, spacing: 12) {
            title("PICK THE PERFECT TAPE", "6 genres")
            if let g = game.s.guests.first { Text("Customer wants \(g.genre)").font(.caption.bold()).foregroundStyle(mint) }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(game.s.movies) { m in
                    Button { game.recommend(m.id); if game.s.guests.first?.movie != nil { game.station = "COUNTER" } } label: {
                        VStack(alignment: .leading, spacing: 7) {
                            ZStack { palette[m.id].opacity(0.18); VStack(spacing: 5) { Image(systemName: ["moon.stars", "eye", "face.smiling", "bolt", "heart", "magnifyingglass"][m.id]).font(.system(size: 29)); Text(m.title.uppercased()).font(.system(size: 16, weight: .black, design: .rounded)).multilineTextAlignment(.center) }.padding(12).foregroundStyle(palette[m.id]) }.frame(height: 115).clipShape(RoundedRectangle(cornerRadius: 7))
                            Text(m.genre).font(.system(size: 9, weight: .heavy)).foregroundStyle(palette[m.id]); Text("\(m.stock) on shelf · $4 rental").font(.caption2).foregroundStyle(.secondary)
                        }.padding(9).background(.white.opacity(0.04)).clipShape(RoundedRectangle(cornerRadius: 12))
                    }.buttonStyle(.plain)
                }
            }
        }
    }
    var pc: some View {
        VStack(alignment: .leading, spacing: 12) {
            title("STORE MANAGEMENT", "OWL-OS 94")
            Text("DAILY TASKS").font(.caption.bold()).foregroundStyle(gold)
            Text("Rent movies • Recommend genres • Make change\nScan returns • Collect fees • Rewind & shelve\nTake reservations • Serve popcorn • Order stock").font(.caption).foregroundStyle(.secondary).lineSpacing(5)
            action("Clean store · \(game.s.dirt) spills", "sparkles", color: gold) { game.clean() }
            action("Decorate & expand · $\(40 + game.s.decor * 30)", "paintbrush") { game.upgrade() }
            action(game.s.staff ? "Bea is hired · $15/day" : "Hire Bea · $60", "person.crop.circle.badge.plus", enabled: !game.s.staff) { game.hire() }
            Text("ORDER TAPES · $12 EACH").font(.caption.bold()).foregroundStyle(gold)
            ForEach(game.s.movies) { m in action("\(m.title) · stock \(m.stock)", "shippingbox", color: palette[m.id]) { game.buy(m.id) } }
            action("Close day & pay bills", "moon.zzz", color: coral) { game.nextDay() }
            Text("Autosaved on this iPhone. A day lasts about 20 minutes. Every third day brings a rainy-day rush. Staff clean and rewind; you handle rentals and fees.").font(.caption).foregroundStyle(.secondary)
        }
    }
    func title(_ text: String, _ detail: String) -> some View { HStack { Text(text).font(.system(size: 13, weight: .black, design: .monospaced)); Spacer(); Text(detail).font(.caption2).foregroundStyle(.secondary) } }
}
