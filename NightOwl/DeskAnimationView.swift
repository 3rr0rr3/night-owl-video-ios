import SwiftUI

struct DeskFeedback: View {
    @EnvironmentObject var game: Store
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var phase
    var body: some View {
        Group {
            if let event = game.deskEvent {
                DeskEventCard(event: event,reduceMotion: reduceMotion,active: phase == .active).id(event.id)
            }
        }.allowsHitTesting(false)
    }
}

struct DeskEventCard: View {
    let event: DeskEvent
    var reduceMotion = false
    var active = true
    @State private var visible = true
    var body: some View {
        Group {
            if visible {
                TimelineView(.animation(minimumInterval: 1.0 / 30,paused: reduceMotion || !active)) { clock in
                    let elapsed = max(0,clock.date.timeIntervalSince(event.started))
                    VStack(spacing: 8) {
                        if event.kind == .scan { scanner(elapsed) } else { register(elapsed) }
                        Text(event.title).font(.subheadline.bold()).lineLimit(2).multilineTextAlignment(.center)
                        Text(caption(elapsed)).font(.system(size: 11,weight: .bold,design: .monospaced)).foregroundStyle(mint)
                    }.padding(16).frame(maxWidth: 350).background(ink,in: RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(mint.opacity(0.7),lineWidth: 2))
                        .shadow(color: .black.opacity(0.4),radius: 12,y: 5)
                }.padding(.horizontal,18).padding(.bottom,12)
            }
        }
        .task(id: event.id) {
            let remaining = max(0,event.duration - Date().timeIntervalSince(event.started))
            guard remaining > 0 else { visible = false; return }
            try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
            guard !Task.isCancelled else { return }
            visible = false
        }
        .accessibilityElement(children: .combine)
    }
    func caption(_ elapsed: Double) -> String {
        switch event.kind {
        case .scan: return elapsed < 0.65 && !reduceMotion ? "READING BARCODE…" : "✓ BARCODE ACCEPTED"
        case .payment: return "$10 RECEIVED · CHANGE $\(event.change)"
        case .sale: return "RENTAL $\(event.amount) · CHANGE $\(event.change)"
        case .fee: return "FEES COLLECTED · $\(event.amount)"
        }
    }
    func scanner(_ elapsed: Double) -> some View {
        let sweep = reduceMotion ? 0.5 : min(1,elapsed / 0.7)
        let accepted = reduceMotion || elapsed >= 0.7
        return HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(Color(red: 0.20,green: 0.23,blue: 0.31))
                VStack(spacing: 5) {
                    Text("NIGHT OWL · VHS").font(.system(size: 8,weight: .black,design: .monospaced)).foregroundStyle(gold)
                    ZStack(alignment: .top) {
                        Color.white
                        HStack(spacing: 2) { ForEach(0..<25,id: \.self) { n in Rectangle().fill(ink).frame(width: n % 3 == 0 ? 4 : 2) } }.padding(.vertical,4)
                        if !reduceMotion { Rectangle().fill(coral).frame(height: 3).shadow(color: coral,radius: 5).offset(y: CGFloat(sweep) * 35) }
                    }.frame(width: 136,height: 40).clipped()
                }.padding(10)
            }.frame(width: 165,height: 82).rotationEffect(.degrees(reduceMotion ? 0 : -4 + sweep * 4))
            Image(systemName: accepted ? "checkmark.circle.fill" : "barcode.viewfinder").font(.system(size: 32,weight: .bold)).foregroundStyle(accepted ? mint : coral)
        }
    }
    func register(_ elapsed: Double) -> some View {
        let open = reduceMotion ? 0.0 : (elapsed < 0.25 ? elapsed / 0.25 : (elapsed < 1.65 ? 1 : max(0,1 - (elapsed - 1.65) / 0.4)))
        let travel = reduceMotion ? 1.0 : min(1,elapsed / 0.6)
        return ZStack {
            VStack(spacing: 0) {
                Text(event.kind == .payment ? "PAID $10" : "+$\(event.amount)")
                    .font(.system(size: 22,weight: .black,design: .monospaced)).foregroundStyle(mint)
                    .frame(width: 142,height: 34).background(.black,in: RoundedRectangle(cornerRadius: 6))
                HStack(spacing: 5) { ForEach(0..<5) { _ in RoundedRectangle(cornerRadius: 2).fill(gold.opacity(0.85)).frame(width: 16,height: 9) } }.frame(width: 172,height: 25).background(Color(red: 0.29,green: 0.31,blue: 0.40))
                ZStack {
                    RoundedRectangle(cornerRadius: 5).fill(Color(red: 0.15,green: 0.18,blue: 0.26))
                    HStack(spacing: 4) { ForEach(0..<3) { _ in RoundedRectangle(cornerRadius: 2).fill(mint.opacity(0.65)).frame(width: 33,height: 14) }; Circle().fill(gold).frame(width: 13,height: 13) }
                }.frame(width: 172,height: 27).offset(y: CGFloat(open) * 17)
            }
            if event.kind == .payment {
                Text("$10").font(.system(size: 15,weight: .black,design: .monospaced)).foregroundStyle(ink).padding(8).background(mint,in: RoundedRectangle(cornerRadius: 4))
                    .offset(x: CGFloat(1 - travel) * 100,y: -44 + CGFloat(travel) * 64).opacity(reduceMotion ? 1 : (elapsed < 0.65 ? 1 : 0))
            } else {
                VStack(spacing: 2) {
                    Text("NIGHT OWL").font(.system(size: 7,weight: .black))
                    Text("$\(event.amount)").font(.system(size: 12,weight: .black,design: .monospaced))
                    Text("THANK YOU").font(.system(size: 6,weight: .bold))
                }.foregroundStyle(ink).padding(7).background(Color.white,in: RoundedRectangle(cornerRadius: 2))
                    .offset(x: 100,y: reduceMotion ? 0 : CGFloat(1 - travel) * 25 - 14)
                if event.kind == .sale {
                    HStack(spacing: 3) { ForEach(0..<3) { _ in Circle().fill(gold).frame(width: 12,height: 12) } }
                        .offset(x: reduceMotion ? -105 : -50 - CGFloat(travel) * 55,y: reduceMotion ? 0 : 20 - CGFloat(travel) * 30)
                }
            }
        }.frame(height: 112)
    }
}
