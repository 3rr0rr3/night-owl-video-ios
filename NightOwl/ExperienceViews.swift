import SwiftUI

struct NextTaskCard: View {
    @EnvironmentObject var game: Store
    var onGo: () -> Void = {}
    var body: some View {
        VStack(alignment: .leading,spacing: 10) {
            HStack {
                Label(game.guiding ? "FIRST CUSTOMER · \(game.tutorialStep)/5" : "UP NEXT",systemImage: game.guiding ? "sparkles" : "arrow.right.circle.fill").font(.caption.bold()).foregroundStyle(mint)
                Spacer()
                if game.guiding { Button("Skip guide") { game.skipTutorial() }.font(.caption).foregroundStyle(.secondary) }
            }
            Text(game.nextTask.title).font(.headline)
            Text(game.nextTask.detail).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false,vertical: true)
            if game.guiding { ProgressView(value: Double(game.tutorialStep - 1),total: 5).tint(mint) }
            Button { game.station = game.nextTask.station == "REPORT" ? "STORE PC" : game.nextTask.station; onGo() } label: {
                Label("Go to \(game.nextTask.station == "REPORT" ? "Store PC" : game.nextTask.station.capitalized)",systemImage: "arrow.right").font(.subheadline.bold()).frame(maxWidth: .infinity,minHeight: 44).background(mint.opacity(0.15),in: RoundedRectangle(cornerRadius: 10)).foregroundStyle(mint)
            }
        }.padding(14).background(.white.opacity(0.05),in: RoundedRectangle(cornerRadius: 14))
    }
}
struct PlayOptions: View {
    @EnvironmentObject var game: Store
    var body: some View {
        VStack(alignment: .leading,spacing: 14) {
            Text("PLAY YOUR WAY").font(.caption.bold()).foregroundStyle(gold)
            Toggle("Relaxed mode",isOn: $game.experience.relaxed)
            Text("Half-speed clock and customer arrivals. No score or reward penalty. The first-customer guide always pauses the clock.").font(.caption).foregroundStyle(.secondary)
            Toggle("Automatic change",isOn: $game.experience.autoChange)
            Text("Counts the correct change for you. You still confirm every rental.").font(.caption).foregroundStyle(.secondary)
        }.tint(mint).onChange(of: game.experience.relaxed) { _ in game.save() }.onChange(of: game.experience.autoChange) { _ in game.save() }
    }
}
struct StyleShop: View {
    @EnvironmentObject var game: Store
    var body: some View {
        VStack(alignment: .leading,spacing: 14) {
            Text("MAKE NIGHT OWL YOURS").font(.caption.bold()).foregroundStyle(gold)
            Text("Unlock styles by completing rentals. Buy once, then switch for free. Your choices appear in the shop illustration.").font(.caption).foregroundStyle(.secondary)
            ForEach(["POSTERS","SHELVES","COUNTERS"],id: \.self) { group in
                Text(group).font(.caption2.bold()).foregroundStyle(mint)
                ForEach(ShopStyle.all.filter { $0.group == group }) { item in
                    let owned = game.experience.owned.contains(item.id)
                    let locked = game.s.served < item.rentals
                    let selected = game.selected(group) == item.id
                    Button { game.selectStyle(item) } label: {
                        HStack {
                            Image(systemName: selected ? "checkmark.circle.fill" : (locked ? "lock.fill" : "paintbrush.fill")).foregroundStyle(selected ? mint : gold)
                            Text(item.name).font(.subheadline)
                            Spacer()
                            Text(selected ? "Selected" : (locked ? "\(game.s.served)/\(item.rentals) rentals" : (owned ? "Use" : "$\(item.cost)"))).font(.caption.bold())
                        }.padding(12).frame(minHeight: 44).background(.white.opacity(0.05),in: RoundedRectangle(cornerRadius: 10))
                    }.buttonStyle(.plain).disabled(locked || (!owned && game.s.money < item.cost)).opacity(locked ? 0.6 : 1)
                }
            }
        }
    }
}
struct DayReportView: View {
    @EnvironmentObject var game: Store
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                if let report = game.experience.report {
                    VStack(alignment: .leading,spacing: 18) {
                        Label("DAY \(report.day) COMPLETE",systemImage: "moon.stars.fill").font(.title2.bold()).foregroundStyle(mint)
                        Text("\(report.customers) rentals · \(report.returns) returns processed").font(.subheadline)
                        row("Rentals & fees",report.revenue)
                        row("Story rewards",report.bonus)
                        row("Stock, staff & upgrades",-report.purchases)
                        row("Rent & daily wages",-report.bills)
                        Divider()
                        row("Net profit",report.profit)
                        if report.grant > 0 { row("Emergency support",report.grant) }
                        Text("TOMORROW’S PLAN").font(.caption.bold()).foregroundStyle(gold)
                        Text(report.tomorrow).font(.subheadline).fixedSize(horizontal: false,vertical: true)
                        if !game.storyFinished {
                            Text("STORY GOALS").font(.caption.bold()).foregroundStyle(gold)
                            ForEach(game.storyGoals.filter { !$0.complete }) { goal in Text("• \(goal.label) · \(min(goal.value,goal.target))/\(goal.target)").font(.caption) }
                        }
                        Button("Ready for tomorrow") { game.dismissReport(); dismiss() }.font(.headline).frame(maxWidth: .infinity,minHeight: 50).background(mint,in: RoundedRectangle(cornerRadius: 12)).foregroundStyle(ink)
                    }.padding(24)
                }
            }.background(ink).navigationTitle("Shift summary").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { game.dismissReport(); dismiss() } } }
        }.preferredColorScheme(.dark)
    }
    func row(_ title: String,_ value: Int) -> some View {
        HStack { Text(title); Spacer(); Text(value < 0 ? "−$\(-value)" : "$\(value)").bold().foregroundStyle(value < 0 ? coral : mint) }.font(.subheadline)
    }
}
