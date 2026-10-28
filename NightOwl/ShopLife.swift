import SwiftUI

// Presentation follows real shop actions; it never changes money, stock or patience.
struct LifeClock<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduced
    @Environment(\.scenePhase) private var phase
    var content: (Double) -> Content
    var body: some View {
        TimelineView(.animation(minimumInterval:1.0/20,paused:reduced || phase != .active)) { tick in
            content(reduced ? 0 : tick.date.timeIntervalSinceReferenceDate)
        }
    }
}

struct CustomerGesture: View {
    var index: Int
    var mood: String
    var time: Double
    var body: some View {
        let wave = sin(time * 8)
        ZStack(alignment:.topTrailing) {
            Cutout(index:index,speaking:mood == "talk")
                .rotationEffect(.degrees(mood == "unsure" ? wave * 3 : (mood == "waiting" ? sin(time * 2) : 0)),anchor:.bottom)
            if mood != "idle" {
                Capsule().fill(palette[index % 6]).frame(width:12,height:30)
                    .overlay(alignment:.top) { Circle().fill(Color(red:0.85,green:0.65,blue:0.48)).frame(width:13,height:13) }
                    .overlay { if mood == "waiting" { Circle().fill(gold).frame(width:9,height:9).overlay { Rectangle().fill(ink).frame(width:1,height:4) }.offset(y:-5) } }
                    .rotationEffect(.degrees(mood == "happy" || mood == "talk" ? -28 + wave * 18 : -65 + wave * 6),anchor:.bottom)
                    .offset(x:-3,y:mood == "waiting" ? 65 : 35)
                Text(mood == "happy" ? "♥" : (mood == "unsure" ? "?" : (mood == "waiting" ? "◷" : "♪")))
                    .font(.system(size:16,weight:.black)).foregroundStyle(gold).offset(x:4,y:-5)
            }
        }.frame(width:80,height:130)
    }
}

struct BrowsingScene: View {
    @EnvironmentObject var game: Store
    var body: some View {
        if let guest = game.s.guests.first, guest.movie == nil {
            LifeClock { time in
                let beat = time.truncatingRemainder(dividingBy:10)
                let walking = beat < 3 || beat > 7
                let x = beat < 3 ? beat / 3 : (beat > 7 ? (10 - beat) / 3 : 1)
                GeometryReader { geo in
                    ZStack(alignment:.topLeading) {
                        HStack(spacing:4) { ForEach(Array(game.s.movies.prefix(6))) { movie in VHSCover(movie:movie).frame(height:65) } }.padding(12)
                        Rectangle().fill(ink).frame(height:5).offset(y:76)
                        Cutout(index:guest.characterIndex,walkingPhase:walking ? time : nil)
                            .rotationEffect(.degrees(!walking ? sin(time * 2) * 4 : 0))
                            .overlay(alignment:.trailing) {
                                if !walking, let movie = game.s.movies.first(where: { $0.genre == guest.genre }) {
                                    VHSCover(movie:movie).frame(width:25,height:35).rotationEffect(.degrees(sin(time * 3) * 12)).offset(x:-4,y:5)
                                }
                            }.scaleEffect(0.8).position(x:50 + x * max(0,geo.size.width - 110),y:92)
                        if game.unsureGuest == guest.id { Text("?").font(.title.bold()).foregroundStyle(gold).position(x:geo.size.width/2,y:20) }
                        Text(game.unsureGuest == guest.id ? "A different genre, please…" : (walking ? "\(guest.name) is browsing…" : "\(guest.name) is reading the cover")).font(.caption2.bold()).foregroundStyle(mint).position(x:geo.size.width/2,y:157)
                    }
                }
            }.frame(height:172).background(.white.opacity(0.04),in:RoundedRectangle(cornerRadius:12))
                .accessibilityLabel("\(guest.name) browses the shelves and inspects a VHS cover")
        }
    }
}

struct ShopAmbience: View {
    @EnvironmentObject var game: Store
    var body: some View {
        LifeClock { time in
            GeometryReader { geo in
                ZStack {
                    Image(systemName:"fanblades.fill").font(.system(size:22)).foregroundStyle(.white.opacity(0.28)).rotationEffect(.degrees(time * 45)).position(x:geo.size.width/2,y:18)
                    Text(game.s.open ? "OPEN" : "CLOSED").font(.system(size:8,weight:.black,design:.monospaced)).foregroundStyle(game.s.open ? mint : coral)
                        .shadow(color:mint.opacity(0.5),radius:3 + sin(time * 2)).position(x:geo.size.width-32,y:46)
                    RoundedRectangle(cornerRadius:3).fill(.black).frame(width:39,height:24)
                        .overlay { Image(systemName:"play.rectangle.fill").foregroundStyle(mint.opacity(0.45 + 0.15 * sin(time * 3))).font(.system(size:19)) }.position(x:34,y:47)
                    if game.s.day % 3 == 0 {
                        Canvas { ctx,size in
                            for n in 0..<12 {
                                let x = CGFloat(n * 7 % 59)
                                let y = (time * 29 + Double(n * 11)).truncatingRemainder(dividingBy:65)
                                let path = Path { p in p.move(to:CGPoint(x:x,y:y)); p.addLine(to:CGPoint(x:x-2,y:y+8)) }
                                ctx.stroke(path,with:.color(.cyan.opacity(0.45)),lineWidth:1)
                            }
                        }.frame(width:60,height:65).background(.blue.opacity(0.08)).clipped().position(x:geo.size.width-38,y:110)
                    }
                }
            }
        }.allowsHitTesting(false).accessibilityHidden(true)
    }
}

struct ShopActionScene: View {
    @EnvironmentObject var game: Store
    @Environment(\.accessibilityReduceMotion) private var reduced
    var body: some View {
        if let event = game.lifeEvent {
            LifeClock { time in
                let elapsed = reduced ? 2.5 : max(0,time - event.started.timeIntervalSinceReferenceDate)
                let p = min(1,elapsed / 2.8)
                VStack(spacing:3) {
                    GeometryReader { geo in
                        let width = geo.size.width
                        ZStack(alignment:.topLeading) {
                            HStack(spacing:3) { ForEach(0..<10) { n in Rectangle().fill(palette[n % 6]).frame(width:12,height:35) } }.padding(5).background(ink).position(x:width-88,y:40)
                            if event.kind == .restock {
                                PlayerPortrait(walkingPhase:reduced ? nil : elapsed).scaleEffect(0.63)
                                    .overlay(alignment:.trailing) { VStack(spacing:1) { ForEach(0..<3) { n in Rectangle().fill(palette[n]).frame(width:28,height:8) } }.offset(x:-10,y:5).opacity(p < 0.8 ? 1 : 0) }
                                    .position(x:42 + (width-120) * p,y:49)
                                if p >= 0.8 { Image(systemName:"checkmark").foregroundStyle(mint).position(x:width-88,y:18) }
                            } else if event.kind == .returnDrop || event.kind == .rewindDone {
                                RoundedRectangle(cornerRadius:5).fill(.black.opacity(0.5)).frame(width:100,height:45).position(x:width/2,y:70)
                                Image(systemName:event.kind == .returnDrop ? "tray.fill" : "backward.end.fill").foregroundStyle(mint).position(x:width/2,y:76)
                                if let id = event.movie, game.s.movies.indices.contains(id) {
                                    VHSCover(movie:game.s.movies[id]).frame(width:35,height:46)
                                        .rotationEffect(.degrees(event.kind == .returnDrop ? -15 * (1-p) : 0))
                                        .position(x:width/2,y:event.kind == .returnDrop ? 15 + 50 * p : 40)
                                        .opacity(event.kind == .returnDrop && p > 0.9 ? 0.25 : 1)
                                }
                                if event.kind == .rewindDone { Text("CLICK! ✓").font(.caption.bold()).foregroundStyle(gold).position(x:width/2+75,y:45) }
                            } else {
                                let opening = event.kind == .opening
                                RoundedRectangle(cornerRadius:5).fill(mint.opacity(opening ? 0.1 + p * 0.3 : 0.4 - p * 0.3)).frame(width:115,height:80).position(x:width/2,y:48)
                                Text(opening ? "OPEN" : "CLOSED").font(.headline).foregroundStyle(opening ? mint : coral)
                                    .rotation3DEffect(.degrees(reduced ? 0 : (1-p)*180),axis:(x:0,y:1,z:0)).position(x:width/2,y:40)
                                Rectangle().fill(Color.gray.opacity(0.65)).frame(width:115,height:opening ? 70 * (1-p) : 70 * p).position(x:width/2,y:opening ? 5 + 35*(1-p) : 5 + 35*p)
                                PlayerPortrait(walkingPhase:reduced ? nil : elapsed).scaleEffect(0.65).position(x:width/2-85,y:48)
                            }
                        }.clipped()
                    }.frame(height:96)
                    Text(event.title).font(.caption.bold()).foregroundStyle(mint).lineLimit(2)
                }.padding(8).frame(maxWidth:.infinity).background(ink,in:RoundedRectangle(cornerRadius:12))
                    .overlay(RoundedRectangle(cornerRadius:12).stroke(mint.opacity(0.25)))
            }.accessibilityElement(children:.ignore).accessibilityLabel(event.title)
        }
    }
}

struct CelebrationBanner: View {
    @EnvironmentObject var game: Store
    var body: some View {
        if let reward = game.celebration {
            LifeClock { time in
                let elapsed = max(0,time - reward.started.timeIntervalSinceReferenceDate)
                HStack {
                    Image(systemName:reward.rare ? "sparkles" : "heart.fill").foregroundStyle(gold)
                        .scaleEffect(1 + 0.12 * sin(elapsed * 5))
                    Text(reward.title).font(.caption.bold()).fixedSize(horizontal:false,vertical:true)
                    Spacer()
                    if reward.rare, let id = reward.movie, game.s.movies.indices.contains(id) { VHSCover(movie:game.s.movies[id]).frame(width:31,height:42) }
                }.padding(12).background(ink,in:RoundedRectangle(cornerRadius:12)).overlay(RoundedRectangle(cornerRadius:12).stroke(gold.opacity(0.5)))
            }.accessibilityElement(children:.combine)
        }
    }
}
