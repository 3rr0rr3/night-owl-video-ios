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
        Canvas { context, _ in
            let painter = context
            let variant = index % 6
            let skin = [Color(red: 0.96, green: 0.78, blue: 0.58), Color(red: 0.82, green: 0.55, blue: 0.38), Color(red: 0.97, green: 0.71, blue: 0.61)][index % 3]
            let hair = [Color(red: 0.30, green: 0.17, blue: 0.12), gold, Color(red: 0.69, green: 0.24, blue: 0.10), Color(red: 0.13, green: 0.12, blue: 0.19), Color(red: 0.38, green: 0.20, blue: 0.13), Color(red: 0.52, green: 0.54, blue: 0.61)][variant]
            func oval(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> Path { Path(ellipseIn: CGRect(x: x, y: y, width: w, height: h)) }
            func draw(_ path: Path, _ color: Color, width: CGFloat = 1.8) {
                painter.fill(path, with: .color(color))
                painter.stroke(path, with: .color(ink), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
            }
            func line(_ points: [CGPoint], _ color: Color = ink, width: CGFloat = 2) {
                let p = Path { p in guard let first = points.first else { return }; p.move(to: first); for point in points.dropFirst() { p.addLine(to: point) } }
                painter.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
            }
            painter.fill(oval(8, 97, 64, 7), with: .color(.black.opacity(0.25)))
            draw(oval(18, 91, 21, 10), ink)
            draw(oval(42, 91, 21, 10), ink)
            let jacket = Path { p in
                p.move(to: CGPoint(x: 25, y: 55)); p.addQuadCurve(to: CGPoint(x: 8, y: 76), control: CGPoint(x: 6, y: 56))
                p.addLine(to: CGPoint(x: 10, y: 94)); p.addQuadCurve(to: CGPoint(x: 70, y: 94), control: CGPoint(x: 40, y: 101))
                p.addLine(to: CGPoint(x: 73, y: 76)); p.addQuadCurve(to: CGPoint(x: 55, y: 55), control: CGPoint(x: 74, y: 59)); p.closeSubpath()
            }
            draw(jacket, palette[variant], width: 2.2)
            line([CGPoint(x: 19, y: 72), CGPoint(x: 17, y: 87)], ink.opacity(0.55), width: 1.4)
            line([CGPoint(x: 62, y: 72), CGPoint(x: 64, y: 87)], ink.opacity(0.55), width: 1.4)
            draw(oval(7, 85, 12, 10), skin)
            draw(oval(62, 85, 12, 10), skin)
            line([CGPoint(x: 40, y: 66), CGPoint(x: 40, y: 94)], ink.opacity(0.65), width: 1.4)
            for y in [74, 82, 90] { painter.fill(oval(43, CGFloat(y), 2, 2), with: .color(ink)) }
            draw(oval(5, 29, 13, 16), skin)
            draw(oval(63, 29, 13, 16), skin)
            draw(oval(11, 5, 59, 61), skin, width: 2.3)
            painter.fill(oval(16, 45, 12, 7), with: .color(coral.opacity(0.35)))
            painter.fill(oval(55, 45, 12, 7), with: .color(coral.opacity(0.35)))
            // Six deliberately uneven hairstyles: spikes, swoop, curls, crop, bob, and a quiff.
            let hairPoints: [[CGPoint]] = [
                [CGPoint(x: 12,y: 26), CGPoint(x: 11,y: 10), CGPoint(x: 21,y: 12), CGPoint(x: 21,y: 1), CGPoint(x: 33,y: 8), CGPoint(x: 40,y: 0), CGPoint(x: 47,y: 8), CGPoint(x: 60,y: 3), CGPoint(x: 68,y: 17), CGPoint(x: 64,y: 24), CGPoint(x: 53,y: 16), CGPoint(x: 44,y: 21), CGPoint(x: 31,y: 14), CGPoint(x: 24,y: 22)],
                [CGPoint(x: 12,y: 27), CGPoint(x: 13,y: 12), CGPoint(x: 25,y: 3), CGPoint(x: 48,y: 2), CGPoint(x: 66,y: 11), CGPoint(x: 69,y: 25), CGPoint(x: 58,y: 19), CGPoint(x: 56,y: 12), CGPoint(x: 43,y: 23), CGPoint(x: 29,y: 25), CGPoint(x: 36,y: 13), CGPoint(x: 23,y: 19)],
                [CGPoint(x: 11,y: 29), CGPoint(x: 9,y: 15), CGPoint(x: 17,y: 9), CGPoint(x: 26,y: 4), CGPoint(x: 44,y: 3), CGPoint(x: 59,y: 8), CGPoint(x: 70,y: 19), CGPoint(x: 67,y: 30), CGPoint(x: 57,y: 18), CGPoint(x: 47,y: 24), CGPoint(x: 39,y: 16), CGPoint(x: 29,y: 22), CGPoint(x: 21,y: 17)],
                [CGPoint(x: 12,y: 25), CGPoint(x: 13,y: 12), CGPoint(x: 25,y: 5), CGPoint(x: 56,y: 5), CGPoint(x: 68,y: 15), CGPoint(x: 68,y: 27), CGPoint(x: 61,y: 19), CGPoint(x: 54,y: 21), CGPoint(x: 47,y: 17), CGPoint(x: 40,y: 20), CGPoint(x: 32,y: 17), CGPoint(x: 25,y: 21), CGPoint(x: 19,y: 18)],
                [CGPoint(x: 11,y: 43), CGPoint(x: 8,y: 20), CGPoint(x: 18,y: 7), CGPoint(x: 39,y: 1), CGPoint(x: 60,y: 7), CGPoint(x: 72,y: 22), CGPoint(x: 70,y: 47), CGPoint(x: 63,y: 44), CGPoint(x: 61,y: 19), CGPoint(x: 42,y: 14), CGPoint(x: 25,y: 26), CGPoint(x: 20,y: 17), CGPoint(x: 18,y: 43)],
                [CGPoint(x: 12,y: 26), CGPoint(x: 13,y: 14), CGPoint(x: 25,y: 9), CGPoint(x: 27,y: 1), CGPoint(x: 39,y: 5), CGPoint(x: 46,y: 0), CGPoint(x: 59,y: 7), CGPoint(x: 68,y: 19), CGPoint(x: 66,y: 28), CGPoint(x: 57,y: 18), CGPoint(x: 45,y: 20), CGPoint(x: 34,y: 14), CGPoint(x: 24,y: 22)]
            ]
            let hairPath = Path { p in let points = hairPoints[variant]; p.move(to: points[0]); for point in points.dropFirst() { p.addLine(to: point) }; p.closeSubpath() }
            draw(hairPath, hair, width: 1.7)
            if variant == 2 {
                for x in [17, 28, 39, 50, 61] { draw(oval(CGFloat(x) - 5, 4 + CGFloat(x % 3), 13, 13), hair, width: 1.2) }
            }
            // Oversized eyes, offset pupils and raised brows make each face more expressive.
            draw(oval(20, 24, 21, 25), .white, width: 0.9)
            draw(oval(40, 23, 21, 25), .white, width: 0.9)
            let gaze = CGFloat(variant % 3 - 1) * 1.5
            painter.fill(oval(29 + gaze, 33, 6, 8), with: .color(ink))
            painter.fill(oval(48 + gaze, 32, 6, 8), with: .color(ink))
            painter.fill(oval(30 + gaze, 34, 2, 2), with: .color(.white))
            painter.fill(oval(49 + gaze, 33, 2, 2), with: .color(.white))
            line([CGPoint(x: 22,y: 21), CGPoint(x: 32,y: variant % 2 == 0 ? 17 : 20)], width: 2.2)
            line([CGPoint(x: 49,y: 18), CGPoint(x: 59,y: 21)], width: 2.2)
            painter.fill(oval(38, 44, 7, 5), with: .color(Color(red: 0.68, green: 0.38, blue: 0.27).opacity(0.5)))
            let smile = Path { p in
                p.move(to: CGPoint(x: 29, y: 52)); p.addQuadCurve(to: CGPoint(x: 54, y: 51), control: CGPoint(x: 41, y: variant % 2 == 0 ? 57 : 53))
                p.addQuadCurve(to: CGPoint(x: 29, y: 52), control: CGPoint(x: 43, y: variant % 2 == 0 ? 70 : 65)); p.closeSubpath()
            }
            draw(smile, ink, width: 1.1)
            painter.fill(Path(roundedRect: CGRect(x: 34, y: 53, width: 15, height: 3), cornerRadius: 1), with: .color(.white))
            if variant % 2 == 0 { painter.fill(oval(39, 59, 9, 3), with: .color(coral)) }
            if variant == 0 || variant == 4 {
                for x in [20, 24, 58, 62] { painter.fill(oval(CGFloat(x), 47, 1.6, 1.6), with: .color(hair.opacity(0.7))) }
            }
        }.frame(width: 80, height: 105)
        .accessibilityLabel("Hatless cartoon customer")
    }
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
