import SwiftUI

struct SellingScene: View {
    @EnvironmentObject var game: Store
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var phase
    var isReturn = false
    @State private var animating = false
    private var event: DeskEvent? { guard let value = game.deskEvent, Date().timeIntervalSince(value.started) < value.duration else { return nil }; return value }
    var body: some View {
        TimelineView(.animation(minimumInterval:1.0/30,paused:!animating || reduceMotion || phase != .active)) { clock in
            let cue = event
            let elapsed = cue.map { max(0,clock.date.timeIntervalSince($0.started)) } ?? 0
            let progress = reduceMotion ? 1 : min(1,elapsed / 0.9)
            let selling = cue?.kind == .sale
            let guest = selling ? cue?.customerIndex : game.s.guests.first?.characterIndex
            VStack(spacing:0) {
                HStack { Label(isReturn ? "RETURN DESK" : "YOUR RENTAL COUNTER",systemImage:"person.crop.rectangle"); Spacer(); Text("$\(game.s.money)").foregroundStyle(gold) }.font(.system(size:10,weight:.black,design:.monospaced)).padding(.horizontal,12).padding(.top,10)
                GeometryReader { geo in
                    let width = geo.size.width
                    ZStack(alignment:.topLeading) {
                        Rectangle().fill(Color(red:0.19,green:0.21,blue:0.31)).frame(height:112)
                        HStack(alignment:.top) {
                            VStack(spacing:0) { Text("YOU · SHOPKEEPER").font(.system(size:8,weight:.heavy)).foregroundStyle(mint); Cutout(index:0).offset(y:2) }
                            Spacer()
                            if !isReturn, let guest { VStack(spacing:0) { Text(selling ? "THANK YOU!" : (game.s.guests.first?.name.uppercased() ?? "CUSTOMER")).font(.system(size:8,weight:.heavy)).foregroundStyle(gold); Cutout(index:guest).offset(y:2) } }
                        }.padding(.horizontal,16).padding(.top,7)
                        // The shopkeeper reaches across the actual counter during scanning.
                        if cue?.kind == .scan && !reduceMotion {
                            Capsule().fill(mint).frame(width:56,height:15).rotationEffect(.degrees(-18 + progress * 18),anchor:.leading).position(x:89,y:91)
                            Circle().fill(Color(red:0.87,green:0.66,blue:0.47)).frame(width:16,height:16).position(x:113 + progress * 28,y:88)
                        }
                        Rectangle().fill(Color(red:0.35,green:0.26,blue:0.29)).frame(height:70).offset(y:105)
                        Rectangle().fill(coral).frame(height:5).offset(y:105)
                        register(cue,elapsed:elapsed).position(x:width * 0.58,y:124)
                        scanner(cue,progress:progress).position(x:width * 0.30,y:130)
                        if cue?.kind == .payment && (!reduceMotion && elapsed < 1.05) {
                            Text("$10").font(.system(size:11,weight:.black,design:.monospaced)).foregroundStyle(ink).frame(width:40,height:20).background(mint,in:RoundedRectangle(cornerRadius:3))
                                .rotationEffect(.degrees(-12 + progress * 12)).position(x:width * (0.85 - progress * 0.27),y:81 + progress * 52)
                        }
                        if selling, let cue {
                            HStack(spacing:2) { ForEach(0..<min(6,cue.change)) { _ in Circle().fill(gold).frame(width:8,height:8) } }
                                .position(x:width * (reduceMotion ? 0.83 : 0.59 + progress * 0.24),y:145)
                            if let id = cue.movieID, game.s.movies.indices.contains(id) {
                                VHSCover(movie:game.s.movies[id]).frame(width:32,height:42).rotationEffect(.degrees(8)).position(x:width * (reduceMotion ? 0.88 : 0.72 + progress * 0.16),y:118)
                            }
                        }
                    }.clipped()
                }.frame(height:175)
                HStack(spacing:6) {
                    Image(systemName:cue?.kind == .scan ? "barcode.viewfinder" : (cue?.kind == .sale ? "checkmark.circle.fill" : "person.fill"))
                    Text(status(cue)).lineLimit(2).minimumScaleFactor(0.8)
                }.font(.system(size:10,weight:.bold)).foregroundStyle(mint).frame(maxWidth:.infinity,minHeight:30).padding(.horizontal,8).background(ink)
            }.background(ink).clipShape(RoundedRectangle(cornerRadius:14)).overlay(RoundedRectangle(cornerRadius:14).stroke(.white.opacity(0.12)))
        }.frame(height:233)
        .onChange(of:game.deskEvent?.id) { _ in animating = true }
        .task(id:game.deskEvent?.id) {
            guard let event = game.deskEvent else { return }
            animating = true
            let remaining = max(0,event.duration - Date().timeIntervalSince(event.started))
            try? await Task.sleep(nanoseconds:UInt64(remaining * 1_000_000_000))
            if !Task.isCancelled { animating = false }
        }
        .accessibilityElement(children:.ignore).accessibilityLabel("Your shopkeeper at the \(isReturn ? "return desk" : "rental counter"). \(status(event))")
    }
    private func status(_ cue:DeskEvent?) -> String {
        guard let cue else { return isReturn ? "Scan and process returned tapes below" : (game.s.guests.isEmpty ? "Ready for the next customer" : "Serving \(game.s.guests[0].name) · use the controls below") }
        switch cue.kind {
        case .scan: return "Scanned: \(cue.title)"
        case .payment: return "$10 received · prepare $\(cue.change) change"
        case .sale: return "Rental complete · $\(cue.amount) sale · $\(cue.change) change"
        case .fee: return "$\(cue.amount) return fees collected"
        }
    }
    private func scanner(_ cue:DeskEvent?,progress:Double) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius:6).fill(.black.opacity(0.65)).frame(width:68,height:34)
            RoundedRectangle(cornerRadius:3).fill(cue?.kind == .scan ? mint.opacity(0.5) : coral.opacity(0.6)).frame(width:48,height:12)
            if cue?.kind == .scan {
                ZStack {
                    RoundedRectangle(cornerRadius:3).fill(Color(white:0.18))
                    VStack(spacing:2) { Text("VHS").font(.system(size:7,weight:.black)).foregroundStyle(gold); HStack(spacing:1) { ForEach(0..<12) { n in Rectangle().fill(ink).frame(width:n % 3 == 0 ? 3 : 1) } }.frame(height:13).padding(3).background(.white) }
                }.frame(width:51,height:36).offset(x:reduceMotion ? 0 : -34 + progress * 57,y:-9)
            } else { Text("SCAN").font(.system(size:7,weight:.black)).foregroundStyle(.white) }
        }
    }
    private func register(_ cue:DeskEvent?,elapsed:Double) -> some View {
        let cash = cue != nil && cue?.kind != .scan
        let drawer = cash && elapsed < 1.7
        let receipt = cue?.kind == .sale || cue?.kind == .fee
        return ZStack(alignment:.bottom) {
            if receipt {
                VStack(spacing:2) { Text("NIGHT OWL").font(.system(size:5,weight:.heavy)); Text("$\(cue?.amount ?? 0)").font(.system(size:9,weight:.black,design:.monospaced)); Rectangle().fill(ink.opacity(0.3)).frame(width:20,height:1); Text("THANK YOU").font(.system(size:4,weight:.bold)) }.foregroundStyle(ink).padding(4).frame(width:40,height:42).background(.white)
                    .offset(x:27,y:reduceMotion ? -30 : -14 - min(1,elapsed / 1.0) * 20)
            }
            VStack(spacing:0) {
                Text(cue?.kind == .payment ? "PAID 10" : (cash ? "$\(cue?.amount ?? 0)" : "READY"))
                    .font(.system(size:11,weight:.black,design:.monospaced)).foregroundStyle(mint).frame(width:78,height:22).background(.black,in:RoundedRectangle(cornerRadius:3))
                HStack(spacing:3) { ForEach(0..<5) { _ in RoundedRectangle(cornerRadius:1).fill(Color(white:0.7)).frame(width:10,height:5) } }.frame(width:94,height:15).background(Color(white:0.30))
                HStack(spacing:3) { ForEach(0..<3) { _ in Rectangle().fill(mint.opacity(0.5)).frame(width:19,height:8) }; Circle().fill(gold).frame(width:7,height:7) }.frame(width:94,height:drawer ? 21 : 10).background(Color(white:0.15))
                    .offset(y:drawer && !reduceMotion ? 5 : 0)
            }
        }.frame(width:104,height:75)
    }
}
