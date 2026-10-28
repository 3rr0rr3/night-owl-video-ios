import SwiftUI

let ink = Color(red: 0.08, green: 0.09, blue: 0.17)
let mint = Color(red: 0.51, green: 0.94, blue: 0.74)
let coral = Color(red: 1, green: 0.46, blue: 0.40)
let gold = Color(red: 1, green: 0.79, blue: 0.35)
let palette: [Color] = [mint, coral, gold, .cyan, .pink, .purple]

@main struct NightOwlApp: App {
    @StateObject var store = Store()
    var body: some Scene { WindowGroup { StartGameView().environmentObject(store).preferredColorScheme(.dark) } }
}
struct Cutout: View {
    var index: Int
    var speaking = false
    var walkingPhase: Double? = nil
    var gesture = "idle"
    var gesturePhase: Double? = nil
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0, paused: reduceMotion || scenePhase != .active)) { timeline in
        let time = reduceMotion ? 0.0 : timeline.date.timeIntervalSinceReferenceDate
        let phase = (time + Double(index) * 0.71).truncatingRemainder(dividingBy: 4.7)
        let blink = !reduceMotion && phase > 4.53
        Canvas { context, _ in
            let painter = context
            let v = index % 6
            let extra = index >= 6
            let skin = [Color(red: 0.89, green: 0.68, blue: 0.49), Color(red: 0.64, green: 0.41, blue: 0.28), Color(red: 0.95, green: 0.74, blue: 0.63)][v % 3]
            let hair = [Color(red: 0.27, green: 0.18, blue: 0.14), Color(red: 0.32, green: 0.22, blue: 0.15), Color(red: 0.57, green: 0.25, blue: 0.13), ink, Color(red: 0.26, green: 0.16, blue: 0.12), Color(red: 0.62, green: 0.63, blue: 0.66)][v]
            let originalShirt = [Color(red: 0.34, green: 0.63, blue: 0.54), Color(red: 0.58, green: 0.33, blue: 0.27), Color(red: 0.77, green: 0.57, blue: 0.22), Color(red: 0.27, green: 0.47, blue: 0.62), Color(red: 0.61, green: 0.29, blue: 0.39), Color(red: 0.40, green: 0.35, blue: 0.49)][v]
            let shirt = extra ? [Color(red: 0.20, green: 0.57, blue: 0.58), Color(red: 0.70, green: 0.40, blue: 0.22), Color(red: 0.39, green: 0.44, blue: 0.29), Color(red: 0.51, green: 0.31, blue: 0.64), Color(red: 0.25, green: 0.43, blue: 0.61), Color(red: 0.52, green: 0.43, blue: 0.34)][v] : originalShirt
            func oval(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> Path { Path(ellipseIn: CGRect(x: x, y: y, width: w, height: h)) }
            func polygon(_ points: [CGPoint]) -> Path { Path { p in p.move(to: points[0]); for pt in points.dropFirst() { p.addLine(to: pt) }; p.closeSubpath() } }
            func draw(_ path: Path, _ color: Color, width: CGFloat = 1.4) {
                painter.fill(path, with: .color(color)); painter.stroke(path, with: .color(ink), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
            }
            func line(_ points: [CGPoint], _ color: Color = ink, width: CGFloat = 1.1) {
                let path = Path { p in p.move(to: points[0]); for pt in points.dropFirst() { p.addLine(to: pt) } }
                painter.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
            }
            painter.fill(oval(9, 123, 62, 6), with: .color(.black.opacity(0.25)))
            if extra && v == 0 { draw(oval(55, 17, 16, 40), hair) }
            if extra && v == 5 { draw(oval(51, 3, 15, 17), hair) }
            // Long trouser legs, adult shoulder width, and a visible neck replace the toddler silhouette.
            if let walk = walkingPhase {
                for leg in 0..<2 {
                    let base = CGFloat(leg == 0 ? 27 : 51)
                    let swing = sin(walk * 13 + Double(leg) * .pi)
                    let shift = CGFloat(swing) * 6
                    let lift = CGFloat(max(0,swing)) * 3
                    draw(polygon([CGPoint(x:base-7,y:92),CGPoint(x:base+7,y:92),CGPoint(x:base+6+shift,y:121-lift),CGPoint(x:base-6+shift,y:121-lift)]),Color(red:0.19,green:0.24,blue:0.31))
                    draw(Path(roundedRect:CGRect(x:base-10+shift,y:119-lift,width:20,height:7),cornerRadius:2),ink)
                }
            } else {
            draw(polygon([CGPoint(x: 20,y: 90),CGPoint(x: 60,y: 90),CGPoint(x: 57,y: 121),CGPoint(x: 44,y: 121),CGPoint(x: 40,y: 102),CGPoint(x: 36,y: 121),CGPoint(x: 22,y: 121)]), Color(red: 0.19, green: 0.24, blue: 0.31))
            draw(Path(roundedRect: CGRect(x: 17, y: 119, width: 20, height: 7), cornerRadius: 2), ink)
            draw(Path(roundedRect: CGRect(x: 43, y: 119, width: 20, height: 7), cornerRadius: 2), ink)
            }
            if (v == 2 || v == 4) && !(extra && v == 2) { draw(Path(roundedRect: CGRect(x: 19, y: 10, width: 43, height: 50), cornerRadius: 15), hair) }
            draw(Path(roundedRect: CGRect(x: 33, y: 43, width: 14, height: 19), cornerRadius: 3), skin)
            let gesturing = gesture != "idle"
            let torso = polygon([CGPoint(x: 31,y: 54),CGPoint(x: 16,y: 59),CGPoint(x: 8,y: 68),CGPoint(x: 10,y: 93),CGPoint(x: 19,y: 94),CGPoint(x: 20,y: 77),CGPoint(x: 20,y: 98),CGPoint(x: 60,y: 98),CGPoint(x: 60,y: 77),CGPoint(x: 62,y: 94),CGPoint(x: 71,y: 93),CGPoint(x: 73,y: 68),CGPoint(x: 64,y: 59),CGPoint(x: 49,y: 54),CGPoint(x: 40,y: 60)])
            let sleevelessLeft = polygon([CGPoint(x:31,y:54),CGPoint(x:19,y:60),CGPoint(x:20,y:98),CGPoint(x:60,y:98),CGPoint(x:60,y:77),CGPoint(x:62,y:94),CGPoint(x:71,y:93),CGPoint(x:73,y:68),CGPoint(x:64,y:59),CGPoint(x:49,y:54),CGPoint(x:40,y:60)])
            draw(gesturing ? sleevelessLeft : torso, shirt, width: 1.8)
            if !gesturing { draw(Path(roundedRect: CGRect(x: 10, y: 92, width: 8, height: 13), cornerRadius: 3), skin) }
            draw(Path(roundedRect: CGRect(x: 63, y: 92 + (speaking ? CGFloat(sin(time * 6)) * 1.5 : 0), width: 8, height: 13), cornerRadius: 3), skin)
            if !gesturing { line([CGPoint(x: 15,y: 73),CGPoint(x: 14,y: 91)], ink.opacity(0.5)) }
            line([CGPoint(x: 66,y: 73),CGPoint(x: 67,y: 91)], ink.opacity(0.5))
            if v == 1 || v == 4 {
                draw(polygon([CGPoint(x: 32,y: 55),CGPoint(x: 40,y: 61),CGPoint(x: 48,y: 55),CGPoint(x: 45,y: 94),CGPoint(x: 35,y: 94)]), Color(red: 0.91, green: 0.87, blue: 0.78), width: 0.6)
                line([CGPoint(x: 30,y: 56),CGPoint(x: 25,y: 70),CGPoint(x: 34,y: 73),CGPoint(x: 40,y: 95)], width: 1.3)
                line([CGPoint(x: 50,y: 56),CGPoint(x: 55,y: 70),CGPoint(x: 46,y: 73),CGPoint(x: 40,y: 95)], width: 1.3)
            } else if v == 2 {
                painter.stroke(Path(ellipseIn: CGRect(x: 31, y: 54, width: 18, height: 10)), with: .color(ink), lineWidth: 1.2)
                line([CGPoint(x: 31,y: 61),CGPoint(x: 40,y: 74),CGPoint(x: 49,y: 61)], gold, width: 0.9)
                draw(oval(38, 73, 4, 4), gold, width: 0.6)
            } else {
                draw(polygon([CGPoint(x: 31,y: 54),CGPoint(x: 40,y: 61),CGPoint(x: 34,y: 67),CGPoint(x: 28,y: 57)]), shirt.opacity(0.8), width: 0.9)
                draw(polygon([CGPoint(x: 49,y: 54),CGPoint(x: 40,y: 61),CGPoint(x: 46,y: 67),CGPoint(x: 52,y: 57)]), shirt.opacity(0.8), width: 0.9)
                line([CGPoint(x: 40,y: 62),CGPoint(x: 40,y: 97)], ink.opacity(0.55), width: 0.8)
                for y in [72, 82, 92] { painter.fill(oval(42, CGFloat(y), 1.6, 1.6), with: .color(ink)) }
                draw(Path(roundedRect: CGRect(x: 48, y: 73, width: 8, height: 9), cornerRadius: 1), shirt, width: 0.7)
            }
            line([CGPoint(x: 21,y: 98),CGPoint(x: 59,y: 98)], ink, width: 2.5)
            draw(Path(roundedRect: CGRect(x: 37, y: 96, width: 6, height: 4), cornerRadius: 0.5), gold, width: 0.6)
            if extra && v == 0 {
                line([CGPoint(x: 31,y: 54),CGPoint(x: 40,y: 63),CGPoint(x: 49,y: 54)], skin, width: 2)
                draw(Path(roundedRect: CGRect(x: 49,y: 72,width: 8,height: 12),cornerRadius: 1), .white, width: 0.5)
                line([CGPoint(x: 53,y: 74),CGPoint(x: 53,y: 79)], coral, width: 1.1)
                line([CGPoint(x: 51,y: 76),CGPoint(x: 55,y: 76)], coral, width: 1.1)
            }
            if extra && v == 1 {
                draw(polygon([CGPoint(x: 28,y: 61),CGPoint(x: 52,y: 61),CGPoint(x: 57,y: 97),CGPoint(x: 23,y: 97)]), Color(red: 0.90,green: 0.85,blue: 0.73), width: 0.8)
                line([CGPoint(x: 30,y: 64),CGPoint(x: 40,y: 71),CGPoint(x: 50,y: 64)], shirt, width: 2)
                draw(Path(roundedRect: CGRect(x: 30,y: 80,width: 20,height: 9),cornerRadius: 1), Color(red: 0.83,green: 0.75,blue: 0.59), width: 0.7)
            }
            if extra && v == 2 {
                line([CGPoint(x: 22,y: 92),CGPoint(x: 59,y: 92)], Color(red: 0.41,green: 0.24,blue: 0.14), width: 5)
                draw(Path(roundedRect: CGRect(x: 46,y: 90,width: 10,height: 12),cornerRadius: 1), Color(red: 0.45,green: 0.28,blue: 0.17), width: 0.7)
                line([CGPoint(x: 51,y: 84),CGPoint(x: 51,y: 94)], .gray, width: 2)
                line([CGPoint(x: 48,y: 83),CGPoint(x: 51,y: 87),CGPoint(x: 54,y: 83)], .gray, width: 1.6)
            }
            if extra && v == 4 {
                draw(Path(roundedRect: CGRect(x: 27,y: 69,width: 26,height: 28),cornerRadius: 2), Color(red: 0.23,green: 0.33,blue: 0.45), width: 0.8)
                line([CGPoint(x: 29,y: 57),CGPoint(x: 32,y: 73)], Color(red: 0.23,green: 0.33,blue: 0.45), width: 4)
                line([CGPoint(x: 51,y: 57),CGPoint(x: 48,y: 73)], Color(red: 0.23,green: 0.33,blue: 0.45), width: 4)
                draw(oval(30,70,3,3), gold, width: 0.3); draw(oval(47,70,3,3), gold, width: 0.3)
            }
            if gesturing {
                let arm = CustomerArmPose(gesture:gesture,time:reduceMotion ? 0 : (gesturePhase ?? time))
                // Replace the original left arm, using this customer's own colors.
                line([arm.shoulder,arm.elbow],ink,width:11)
                line([arm.shoulder,arm.elbow],shirt,width:8)
                line([arm.elbow,arm.wrist],ink,width:9)
                line([arm.elbow,arm.wrist],shirt,width:6.5)
                draw(oval(arm.wrist.x-3.8,arm.wrist.y-3.8,7.6,7.6),skin,width:1)
                if gesture == "waiting" {
                    draw(oval(arm.wrist.x-9,arm.wrist.y-3,5.5,5.5),gold,width:0.7)
                    line([CGPoint(x:arm.wrist.x-6,y:arm.wrist.y-2),CGPoint(x:arm.wrist.x-6,y:arm.wrist.y)],ink,width:0.7)
                }
            }
            // Adult facial details remain on the larger chibi portrait head.
            draw(oval(18, 25, 7, 12), skin)
            draw(oval(55, 25, 7, 12), skin)
            let face = Path { p in
                p.move(to: CGPoint(x: 24,y: 16)); p.addQuadCurve(to: CGPoint(x: 56,y: 16), control: CGPoint(x: 40,y: 0))
                p.addLine(to: CGPoint(x: 57,y: 34)); p.addLine(to: CGPoint(x: 53,y: 46)); p.addQuadCurve(to: CGPoint(x: 40,y: 52), control: CGPoint(x: 49,y: 51))
                p.addQuadCurve(to: CGPoint(x: 27,y: 46), control: CGPoint(x: 32,y: 51)); p.addLine(to: CGPoint(x: 23,y: 34)); p.closeSubpath()
            }
            draw(face, skin, width: 1.7)
            let hairlines: [[CGPoint]] = [
                [CGPoint(x: 23,y: 31),CGPoint(x: 21,y: 15),CGPoint(x: 28,y: 8),CGPoint(x: 45,y: 6),CGPoint(x: 56,y: 12),CGPoint(x: 58,y: 30),CGPoint(x: 53,y: 25),CGPoint(x: 52,y: 15),CGPoint(x: 31,y: 18),CGPoint(x: 27,y: 24)],
                [CGPoint(x: 23,y: 30),CGPoint(x: 21,y: 16),CGPoint(x: 30,y: 8),CGPoint(x: 48,y: 7),CGPoint(x: 58,y: 18),CGPoint(x: 57,y: 30),CGPoint(x: 53,y: 21),CGPoint(x: 46,y: 16),CGPoint(x: 28,y: 20),CGPoint(x: 27,y: 30)],
                [CGPoint(x: 22,y: 36),CGPoint(x: 19,y: 18),CGPoint(x: 28,y: 9),CGPoint(x: 44,y: 6),CGPoint(x: 58,y: 17),CGPoint(x: 59,y: 37),CGPoint(x: 54,y: 31),CGPoint(x: 52,y: 20),CGPoint(x: 41,y: 15),CGPoint(x: 28,y: 24),CGPoint(x: 26,y: 37)],
                [CGPoint(x: 23,y: 28),CGPoint(x: 22,y: 16),CGPoint(x: 27,y: 10),CGPoint(x: 47,y: 8),CGPoint(x: 56,y: 15),CGPoint(x: 57,y: 29),CGPoint(x: 53,y: 22),CGPoint(x: 52,y: 16),CGPoint(x: 29,y: 17),CGPoint(x: 27,y: 28)],
                [CGPoint(x: 22,y: 44),CGPoint(x: 20,y: 17),CGPoint(x: 29,y: 7),CGPoint(x: 45,y: 6),CGPoint(x: 58,y: 16),CGPoint(x: 59,y: 45),CGPoint(x: 54,y: 43),CGPoint(x: 52,y: 18),CGPoint(x: 40,y: 14),CGPoint(x: 28,y: 23),CGPoint(x: 27,y: 44)],
                [CGPoint(x: 23,y: 30),CGPoint(x: 21,y: 17),CGPoint(x: 27,y: 11),CGPoint(x: 33,y: 10),CGPoint(x: 36,y: 14),CGPoint(x: 44,y: 14),CGPoint(x: 48,y: 10),CGPoint(x: 55,y: 14),CGPoint(x: 58,y: 30),CGPoint(x: 54,y: 28),CGPoint(x: 50,y: 18),CGPoint(x: 46,y: 20),CGPoint(x: 34,y: 20),CGPoint(x: 29,y: 17),CGPoint(x: 27,y: 30)]
            ]
            if !(extra && v == 2) { draw(polygon(hairlines[v]), hair, width: 1.2) }
            if extra && v == 1 { painter.fill(oval(29, 9, 22, 9), with: .color(skin)) }
            if extra && v == 3 { draw(oval(20, 4, 39, 18), hair, width: 1.1) }
            if v == 2 && !extra { for x in [25, 32, 39, 46, 53] { draw(oval(CGFloat(x) - 3, 8, 9, 9), hair, width: 0.6) } }
            if (v == 0 || v == 3) && !(extra && v == 0) {
                let beard = polygon([CGPoint(x: 26,y: 34),CGPoint(x: 30,y: 39),CGPoint(x: 35,y: 40),CGPoint(x: 40,y: 38),CGPoint(x: 46,y: 40),CGPoint(x: 51,y: 38),CGPoint(x: 55,y: 34),CGPoint(x: 52,y: 46),CGPoint(x: 45,y: 50),CGPoint(x: 36,y: 50),CGPoint(x: 28,y: 45)])
                painter.fill(beard, with: .color(hair.opacity(v == 0 ? 0.65 : 0.9)))
            }
            if blink {
                line([CGPoint(x: 29,y: 30),CGPoint(x: 37,y: 30)], width: 1.1)
                line([CGPoint(x: 44,y: 30),CGPoint(x: 52,y: 30)], width: 1.1)
            } else {
            draw(oval(28, 26, 10, 7), .white, width: 0.65)
            draw(oval(43, 26, 10, 7), .white, width: 0.65)
            painter.fill(oval(32, 27, 3.5, 5), with: .color(ink))
            painter.fill(oval(46, 27, 3.5, 5), with: .color(ink))
            }
            line([CGPoint(x: 28,y: 23),CGPoint(x: 36,y: 22)], hair, width: 1.6)
            line([CGPoint(x: 44,y: 22),CGPoint(x: 52,y: 23)], hair, width: 1.6)
            line([CGPoint(x: 40,y: 27),CGPoint(x: 38,y: 36),CGPoint(x: 43,y: 37)], ink.opacity(0.65), width: 0.85)
            if v == 1 || v == 5 {
                painter.stroke(Path(roundedRect: CGRect(x: 26, y: 24, width: 14, height: 11), cornerRadius: 3), with: .color(ink), lineWidth: 1.2)
                painter.stroke(Path(roundedRect: CGRect(x: 41, y: 24, width: 14, height: 11), cornerRadius: 3), with: .color(ink), lineWidth: 1.2)
                line([CGPoint(x: 40,y: 28),CGPoint(x: 41,y: 28)])
                line([CGPoint(x: 23,y: 26),CGPoint(x: 26,y: 27)])
                line([CGPoint(x: 55,y: 27),CGPoint(x: 57,y: 26)])
            }
            if v == 5 && !extra {
                draw(polygon([CGPoint(x: 31,y: 40),CGPoint(x: 39,y: 38),CGPoint(x: 47,y: 40),CGPoint(x: 48,y: 43),CGPoint(x: 40,y: 41),CGPoint(x: 32,y: 43)]), hair, width: 0.5)
                line([CGPoint(x: 30,y: 19),CGPoint(x: 34,y: 18)], ink.opacity(0.35), width: 0.6)
                line([CGPoint(x: 46,y: 18),CGPoint(x: 50,y: 19)], ink.opacity(0.35), width: 0.6)
            }
            if extra && v == 3 {
                let band = Path { p in p.move(to: CGPoint(x: 20,y: 31)); p.addQuadCurve(to: CGPoint(x: 60,y: 31),control: CGPoint(x: 40,y: -4)) }
                painter.stroke(band,with: .color(.gray),lineWidth: 2.2)
                draw(Path(roundedRect: CGRect(x: 17,y: 25,width: 7,height: 15),cornerRadius: 2), ink,width: 0.6)
                draw(Path(roundedRect: CGRect(x: 56,y: 25,width: 7,height: 15),cornerRadius: 2), ink,width: 0.6)
            }
            let smile = Path { p in p.move(to: CGPoint(x: 34,y: 43)); p.addQuadCurve(to: CGPoint(x: 47,y: 42), control: CGPoint(x: 41,y: 47)) }
            painter.stroke(smile, with: .color(v == 2 || v == 4 ? Color(red: 0.53, green: 0.19, blue: 0.22) : ink), style: StrokeStyle(lineWidth: 1.1, lineCap: .round))
            if speaking && !reduceMotion { draw(oval(35, 41, 11, 2 + CGFloat(abs(sin(time * 9))) * 4), ink, width: 0.5) }
            line([CGPoint(x: 29,y: 36),CGPoint(x: 27,y: 39)], ink.opacity(0.3), width: 0.6)
            line([CGPoint(x: 52,y: 36),CGPoint(x: 54,y: 39)], ink.opacity(0.3), width: 0.6)
            line([CGPoint(x: 36,y: 48),CGPoint(x: 44,y: 48)], ink.opacity(0.25), width: 0.6)
        }.frame(width: 80, height: 130)
        .scaleEffect(x: 1 + (reduceMotion ? 0 : sin(time * 1.8 + Double(index)) * 0.004), y: 1 + (reduceMotion ? 0 : sin(time * 1.8 + Double(index)) * 0.008), anchor: .bottom)
        .rotationEffect(.degrees(reduceMotion ? 0 : sin(time * 1.4 + Double(index)) * 0.45), anchor: .bottom)
        }
        .accessibilityLabel("Adult cartoon customer")
    }
}
struct ShopArt: View {
    @EnvironmentObject var game: Store
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 0.17, green: 0.18, blue: 0.29)
                VStack(spacing: 0) {
                    HStack { Text("NIGHT OWL").font(.system(size: 23, weight: .black, design: .rounded)).foregroundStyle(mint); Spacer(); Text("VHS • 1994").font(.caption.bold()).foregroundStyle(gold) }.padding(18)
                    HStack(spacing: 13) {
                        shelf("CULT CLASSICS", 0).onTapGesture { game.station = "SHELVES" }; shelf("NEW RELEASES", 3).onTapGesture { game.station = "SHELVES" }
                        VStack { Image(systemName: game.experience.poster == "poster-space" ? "sparkles" : (game.experience.poster == "poster-creature" ? "eye.fill" : "moon.stars.fill")).font(.largeTitle).foregroundStyle(gold); Text(game.experience.poster == "poster-space" ? "SPACE PREMIERE" : (game.experience.poster == "poster-creature" ? "CREATURE NIGHT" : (game.s.day % 3 == 0 ? "RAINY FRIDAY" : "MOVIE NIGHT"))).font(.system(size: 9, weight: .heavy)); VStack(spacing: 1) { Text("2 NIGHTS").font(.system(size: 10, weight: .black)).lineLimit(1); Text("$4").font(.system(size: 22, weight: .black, design: .rounded)) }.foregroundStyle(mint) }.frame(width: 82, height: 113).background(ink).clipShape(RoundedRectangle(cornerRadius: 6))
                    }.padding(.horizontal, 16)
                    Rectangle().fill(Color(red: 0.29, green: 0.26, blue: 0.38)).frame(height: 95).overlay(alignment: .bottom) {
                        HStack(spacing: 1) { ForEach(Array(game.s.guests.prefix(4))) { guest in
                            Cutout(index: guest.characterIndex, speaking: game.speakingGuest == guest.id)
                                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                        }; Spacer() }.padding(.leading, 15).offset(y: 2).animation(reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.8), value: game.s.guests.map { $0.id })
                    }
                }
                VStack { Spacer(); HStack { Button("▰ RETURNS \(game.s.returns.count)") { game.station = "RETURNS" }.frame(minHeight:44); Spacer(); Button("◉ REGISTER") { game.station = "COUNTER" }.frame(minHeight:44) }.font(.system(size: 10, weight: .black, design: .monospaced)).foregroundStyle(mint).padding(.horizontal,12).background(ink).overlay(alignment: .top) { Rectangle().fill(game.experience.counter == "counter-gold" ? gold : (game.experience.counter == "counter-lavender" ? Color.purple : coral)).frame(height: 4) } }
                ShopAmbience()
                if game.s.decor > 0 { Image(systemName: game.storyFinished ? "star.circle.fill" : "sparkles").foregroundStyle(gold).position(x: geo.size.width - 32, y: 30) }
            }
        }.frame(height: 275).clipShape(RoundedRectangle(cornerRadius: 18))
    }
    func shelf(_ title: String, _ start: Int) -> some View {
        VStack(spacing: 5) {
            Text(title).font(.system(size: 8, weight: .black)).foregroundStyle(gold)
            ForEach(0..<2) { row in
                HStack(spacing: 3) { ForEach(0..<3) { n in VHSCover(movie: game.s.movies[(start + row * 3 + n) % 6]).frame(height: 43) } }.padding(.horizontal, 5).padding(.bottom, 4).background(game.experience.shelf == "shelf-mint" ? mint.opacity(0.6) : (game.experience.shelf == "shelf-walnut" ? Color.brown : ink))
            }
        }
    }
}
struct GameView: View {
    @EnvironmentObject var game: Store
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showReport = false
    let tabs = ["COUNTER", "RETURNS", "SHELVES", "STORY", "STORE PC"]
    var body: some View {
        ScrollViewReader { proxy in
        ScrollView {
            VStack(alignment: .leading, spacing: 17) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) { Text("NIGHT OWL").font(.system(size: 28, weight: .black, design: .rounded)); Text("VIDEO STORE SIMULATOR").font(.system(size: 10, weight: .bold, design: .monospaced)).tracking(2).foregroundStyle(mint) }
                    Spacer()
                    VStack(alignment: .trailing) { Text("$\(game.s.money)").font(.title2.bold()).foregroundStyle(gold); Text("LEVEL \(game.level)").font(.caption2.bold()).foregroundStyle(.secondary) }
                }
                HStack { Label("DAY \(game.s.day)", systemImage: "calendar"); Spacer(); Text(game.clock); Spacer(); Text(game.s.open ? "OPEN" : "CLOSED").foregroundStyle(game.s.open ? mint : coral) }.font(.system(size: 11, weight: .bold, design: .monospaced))
                if game.station != "COUNTER" && game.station != "RETURNS" {
                ShopArt().overlay(alignment: .topTrailing) {
                    if game.earned > 0 { Text("+$\(game.earned)").font(.title2.bold()).foregroundStyle(gold).padding(14).background(ink.opacity(0.9),in: Capsule()).padding().transition(.move(edge: .bottom).combined(with: .opacity)) }
                }.animation(reduceMotion ? nil : .easeOut(duration: 0.45), value: game.earned)
                }
                HStack(alignment: .top, spacing: 10) { Image(systemName: "bubble.left.fill").foregroundStyle(mint); Text(game.message).font(.system(size: 13, weight: .medium)).fixedSize(horizontal: false, vertical: true) }.padding(14).frame(maxWidth: .infinity, alignment: .leading).background(.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 12))
                Text("\(game.todayEvent.title.uppercased()) · \(game.reputationName)").font(.system(size: 10,weight: .bold,design: .monospaced)).foregroundStyle(gold)
                NextTaskCard { withAnimation { proxy.scrollTo("station-actions",anchor: .top) } }
                Button { withAnimation { game.station = "STORY" } } label: {
                    HStack { Image(systemName: game.storyFinished ? "star.fill" : "book.closed.fill"); Text(game.storyFinished ? "MAPLE STREET MOVIE NIGHT · SAVED" : "STORY \(game.story.chapter + 1)/7 · \(game.chapter.title)").font(.system(size: 11, weight: .bold)); Spacer(); Image(systemName: "chevron.right") }.foregroundStyle(gold)
                }.buttonStyle(.plain)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(),spacing: 6),count: 3),spacing: 6) {
                    ForEach(tabs,id: \.self) { tab in
                        Button { game.station = tab; withAnimation { proxy.scrollTo("station-actions",anchor: .top) } } label: {
                            HStack(spacing: 4) {
                                Text(tab).font(.system(size: 10,weight: .heavy)).lineLimit(1).minimumScaleFactor(0.75)
                                if game.badge(tab) > 0 { Text("\(game.badge(tab))").font(.system(size: 10,weight: .black)).padding(4).background(ink.opacity(0.15),in: Circle()) }
                            }.frame(maxWidth: .infinity,minHeight: 44).background(game.station == tab ? mint : .white.opacity(0.06),in: RoundedRectangle(cornerRadius: 12)).foregroundStyle(game.station == tab ? ink : .white)
                        }.accessibilityLabel("\(tab), \(game.badge(tab)) pending")
                    }
                }
                Group { switch game.station { case "COUNTER": counter.disabled(game.counterWalking || game.moviePickup != nil); case "RETURNS": returns; case "SHELVES": shelves; case "STORY": StoryPanel(); default: pc } }.id("station-actions")
                HStack { Label("\(game.s.served) served", systemImage: "person.2"); Spacer(); Text("TODAY $\(game.s.sales)") }.font(.caption).foregroundStyle(.secondary)
                Text("BE KIND. REWIND.").font(.system(size: 10, weight: .heavy, design: .monospaced)).tracking(4).foregroundStyle(.white.opacity(0.25)).frame(maxWidth: .infinity).padding(.vertical, 12)
            }.padding(20).frame(maxWidth: 650)
        }.frame(maxWidth: .infinity).background(ink).animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: game.s.guests.map { $0.id })
        .safeAreaInset(edge:.top,spacing:0) { if game.station == "COUNTER" || game.station == "RETURNS" { SellingScene(isReturn:game.station == "RETURNS").environmentObject(game).padding(.horizontal,12).padding(.vertical,4).background(ink) } }
        .safeAreaInset(edge:.bottom,spacing:4) {
            if game.lifeEvent != nil || game.celebration != nil {
                VStack(spacing:4) { ShopActionScene(); CelebrationBanner() }.padding(.horizontal,12).padding(.bottom,4).background(ink)
            }
        }
        .onChange(of:game.station) { station in
            if station == "RETURNS", let tape = game.s.returns.first { game.shopAction(.returnDrop,"Returned VHS drops into the bin",movie:tape.movie) }
        }
        .sheet(isPresented: $showReport,onDismiss: { game.dismissReport() }) { DayReportView().environmentObject(game) }
        .onAppear { showReport = game.experience.reportPending }
        .onChange(of: game.experience.reportPending) { pending in if pending { showReport = true } }

    }
    }
    func action(_ title: String, _ symbol: String, color: Color = mint, enabled: Bool = true, run: @escaping () -> Void) -> some View {
        Button { withAnimation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.8)) { run() } } label: { Label(title, systemImage: symbol).font(.system(size: 14, weight: .bold)).frame(maxWidth: .infinity).padding(14).background(color.opacity(enabled ? 0.16 : 0.04)).foregroundStyle(enabled ? color : .gray).clipShape(RoundedRectangle(cornerRadius: 12)) }.disabled(!enabled)
    }
    var counter: some View {
        VStack(alignment: .leading, spacing: 12) {
            title("THE RENTAL COUNTER", "\(game.s.guests.count) in line")
            if let g = game.s.guests.first {
                HStack { VStack(alignment: .leading, spacing: 8) { Text(g.name).font(.title3.bold()); Text(g.regular.role).font(.caption2).foregroundStyle(mint); Text("“\(game.request(g))”").font(.subheadline); if g.snack { Label("Popcorn combo +$3", systemImage: "popcorn.fill").font(.caption).foregroundStyle(gold) } } }
                action("Talk to \(g.name)", "bubble.left.and.bubble.right", color: gold) { game.talk() }
                if let i = g.movie { VHSCover(movie: game.s.movies[i]).frame(width: 95); Text("▰  \(game.s.movies[i].title) • $\(game.price)").font(.headline).foregroundStyle(gold) }
                if g.movie == nil {
                    action("Choose a movie", "rectangle.stack") { game.station = "SHELVES" }
                    action("Reserve a title", "bookmark", color: gold, enabled: !game.guiding) { game.reserve() }
                } else if !g.scanned { action("Scan VHS barcode", "barcode.viewfinder") { game.scan() } }
                else if !g.paid { action("Take $10 payment", "banknote") { game.payment() } }
                else {
                    Text("Change due: $\(10 - game.price) • counted: $\(game.change)").font(.subheadline.bold())
                    if game.experience.autoChange { Label("Correct change counted automatically",systemImage: "checkmark.circle.fill").font(.caption).foregroundStyle(mint) }
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
                VHSCover(movie: game.s.movies[t.movie]).frame(width: 110)
                Text(game.s.movies[t.movie].title).font(.title3.bold()).foregroundStyle(gold)
                Text("\(t.late ? "LATE · $2" : "ON TIME")   /   \(t.damaged ? "DAMAGED · $5" : "GOOD CONDITION")").font(.caption.bold()).foregroundStyle(coral)
                ChoreBench()
                RewindDeck(active: game.rewinding != nil)
                action(t.scanned ? "Checked in ✓" : "1. Scan return", "barcode", enabled: !t.scanned) { game.process("scan") }
                action(t.assessed ? "Fees reviewed ✓" : "2. Inspect & collect fees", "magnifyingglass", enabled: t.scanned && !t.assessed) { game.process("fee") }
                action(t.rewound ? "Rewound ✓" : (game.rewinding != nil ? "Rewinding…" : "3. Rewind tape"), "backward.end", enabled: !t.rewound && game.rewinding == nil) { game.startRewind() }
                action("4. Shelve / set aside reservation", "books.vertical", enabled: t.scanned && t.assessed && t.rewound) { game.process("shelve") }
            } else { Text("All tapes checked in. Tomorrow brings more returns.").font(.subheadline).foregroundStyle(.secondary) }
            ForEach(game.s.held, id: \.self) { i in action("Collect: \(game.s.movies[i].title)", "bookmark.fill", color: gold) { game.collectHold(i) } }
            if !game.s.reservations.isEmpty { Text("Waiting for return: " + game.s.reservations.map { game.s.movies[$0].title }.joined(separator: ", ")).font(.caption).foregroundStyle(.secondary) }
        }
    }
    var shelves: some View { FilmBrowser() }
    var pc: some View {
        VStack(alignment: .leading, spacing: 12) {
            title("STORE MANAGEMENT", "OWL-OS 94")
            DisclosureGroup("Customer notebook") { CustomerNotebook().padding(.top,12) }.tint(mint)
            DisclosureGroup("Equipment upgrades") { EquipmentPanel().padding(.top,12) }.tint(mint)
            DisclosureGroup("Optional surprises") { SurprisePanel().padding(.top,12) }.tint(mint)
            DisclosureGroup("Export / import shop") { BackupPanel().padding(.top,12) }.tint(mint)
            DisclosureGroup("Events, friends & rare tapes") { NeighborhoodPanel().padding(.top,12) }.tint(mint)
            DisclosureGroup("Hands-on chores") { ChoreBench().padding(.top,12) }.tint(mint)
            Text("DAILY TASKS").font(.caption.bold()).foregroundStyle(gold)
            Text("Rent movies • Recommend genres • Make change\nScan returns • Collect fees • Rewind & shelve\nTake reservations • Serve popcorn • Order stock").font(.caption).foregroundStyle(.secondary).lineSpacing(5)
            action("Clean store · \(game.s.dirt) spills", "sparkles", color: gold) { game.clean() }
            DisclosureGroup("Customize your shop") { StyleShop().padding(.top,12) }.tint(mint)
            DisclosureGroup("Play options") { PlayOptions().padding(.top,12) }.tint(mint)
            action(game.s.staff ? "Bea is hired · $15/day" : "Hire Bea · $60", "person.crop.circle.badge.plus", enabled: !game.s.staff) { game.hire() }
            DisclosureGroup("Order films · $\(game.orderCost) per copy") { FilmBrowser(ordering:true).padding(.top,12) }.tint(mint)
            if game.experience.report != nil { action("View last shift summary", "chart.bar.doc.horizontal",color: gold) { showReport = true } }
            action("Close day & pay bills", "moon.zzz", color: coral,enabled: game.canCloseShift) { game.nextDay() }
            if !game.canCloseShift { Text("Finish the queue. Your return carryover capacity is \(game.carryReturns).").font(.caption).foregroundStyle(.secondary) }
            Text("Autosaved on this iPhone. A normal day lasts about 20 minutes; Relaxed mode doubles it. Every third day brings a rainy-day rush. Staff clean and rewind; you handle rentals and fees.").font(.caption).foregroundStyle(.secondary)
        }
    }
    func title(_ text: String, _ detail: String) -> some View { HStack { Text(text).font(.system(size: 13, weight: .black, design: .monospaced)); Spacer(); Text(detail).font(.caption2).foregroundStyle(.secondary) } }
}

struct RewindDeck: View {
    var active: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0, paused: !active || reduceMotion)) { timeline in
            let angle = active && !reduceMotion ? timeline.date.timeIntervalSinceReferenceDate * -540 : 0
            HStack(spacing: 20) {
                Image(systemName: "circle.dotted").font(.system(size: 36, weight: .bold)).rotationEffect(.degrees(angle))
                VStack(spacing: 5) { Text(active ? "◀◀ REWINDING" : "BE KIND. REWIND.").font(.system(size: 11,weight: .black,design: .monospaced)); if active { ProgressView().tint(mint) } else { Text("NIGHT OWL VHS DECK").font(.system(size: 8,design: .monospaced)).foregroundStyle(.secondary) } }
                Image(systemName: "circle.dotted").font(.system(size: 36, weight: .bold)).rotationEffect(.degrees(angle))
            }.foregroundStyle(mint).frame(maxWidth: .infinity).frame(height: 82).background(.black.opacity(0.35),in: RoundedRectangle(cornerRadius: 12))
        }
    }
}
struct StoryPanel: View {
    @EnvironmentObject var game: Store
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if game.storyFinished {
                Label("THE OWL STAYS LIT",systemImage: "star.circle.fill").font(.title3.bold()).foregroundStyle(gold)
                Text("Your community movie night brings Maple Street together. Frank screens the recovered home movie, Nina's article helps secure a new lease, and June's shop has a future.").font(.subheadline)
                Text("Tonight's double bill: \(game.story.theme ?? "Neighborhood favorites"). Continue running Night Owl in free play.").font(.caption).foregroundStyle(mint)
            } else {
                Text("CHAPTER \(game.story.chapter + 1) OF 7").font(.system(size: 10,weight: .bold,design: .monospaced)).foregroundStyle(gold)
                HStack(alignment: .top, spacing: 12) {
                    Cutout(index: game.chapter.lead).scaleEffect(0.8).frame(width: 66,height: 110)
                    VStack(alignment: .leading, spacing: 7) { Text(game.chapter.title).font(.title3.bold()).fixedSize(horizontal: false, vertical: true); Text(game.chapter.speaker).font(.caption.bold()).foregroundStyle(mint) }
                }
                Text(game.chapter.text).font(.subheadline).lineSpacing(4)
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(game.storyGoals) { goal in
                        HStack { Image(systemName: goal.complete ? "checkmark.circle.fill" : "circle").foregroundStyle(goal.complete ? mint : .secondary); Text(goal.label).font(.caption); Spacer(); Text("\(min(goal.value, goal.target))/\(goal.target)").font(.system(size: 11,weight: .bold,design: .monospaced)).foregroundStyle(goal.complete ? mint : .secondary) }
                    }
                }.padding(14).background(.white.opacity(0.05),in: RoundedRectangle(cornerRadius: 12))
                if game.story.chapter == 1 && game.story.theme == nil {
                    Text("Choose your double bill. This becomes your festival theme.").font(.caption).foregroundStyle(.secondary)
                    HStack { storyButton("Creature feature", "eye") { game.chooseTheme("Creature feature") }; storyButton("Space double bill", "moon.stars") { game.chooseTheme("Space double bill") } }
                }
                if game.story.chapter == 5 && game.story.pledged < 40 { storyButton("Pledge $40 for the projector", "film") { game.pledge() } }
                Button { withAnimation { game.finishChapter() } } label: {
                    Label(game.story.chapter == 6 ? "Start movie night · +$100" : "Complete chapter · +$\(game.chapter.reward)", systemImage: "checkmark.seal.fill").font(.subheadline.bold()).padding(14).frame(maxWidth: .infinity).background(game.canFinishChapter ? mint.opacity(0.18) : .white.opacity(0.04),in: RoundedRectangle(cornerRadius: 12)).foregroundStyle(game.canFinishChapter ? mint : .gray)
                }.disabled(!game.canFinishChapter)
                Text("Goals carry across days. Talk to customers at the counter; the chapter's featured regular will visit while you work.").font(.caption).foregroundStyle(.secondary)
            }
            DisclosureGroup {
                LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())],alignment: .leading,spacing: 14) {
                    ForEach(Cast.all) { person in
                        VStack(alignment: .leading,spacing: 6) {
                            Cutout(index: person.id).frame(maxWidth: .infinity)
                            Text(person.name).font(.headline).foregroundStyle(palette[person.id % 6])
                            Text(person.role).font(.system(size: 10,weight: .bold)).foregroundStyle(mint)
                            Text(person.bio).font(.caption2).foregroundStyle(.secondary).fixedSize(horizontal: false,vertical: true)
                        }.padding(10).frame(maxWidth: .infinity,alignment: .leading).background(.white.opacity(0.04),in: RoundedRectangle(cornerRadius: 12))
                    }
                }.padding(.top,12)
            } label: { Text("MEET THE 12 REGULARS").font(.system(size: 12,weight: .bold,design: .monospaced)).foregroundStyle(gold) }
            Text("NIGHT OWL · MAPLE STREET, 1994").font(.system(size: 9,weight: .bold,design: .monospaced)).foregroundStyle(.secondary)
        }
    }
    func storyButton(_ title: String,_ icon: String,run: @escaping () -> Void) -> some View {
        Button { withAnimation { run() } } label: { Label(title,systemImage: icon).font(.caption.bold()).padding(12).frame(maxWidth: .infinity).foregroundStyle(gold).background(gold.opacity(0.12),in: RoundedRectangle(cornerRadius: 10)) }
    }
}
