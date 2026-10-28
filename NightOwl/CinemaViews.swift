import SwiftUI
import UniformTypeIdentifiers

struct ComfortOptions: View {
    @EnvironmentObject var game: Store
    var body: some View {
        VStack(alignment:.leading,spacing:12) {
            Toggle("Larger game text",isOn:$game.cinema.largeText)
            Text("Text can wrap and the screen scrolls. The iPhone’s text-size setting is used when this is off.").font(.caption).foregroundStyle(.secondary)
            Toggle("Gentle haptic feedback",isOn:$game.cinema.haptics)
            Text("Sound effects volume").font(.caption.bold()); Slider(value:$game.cinema.effectsVolume,in:0...1).accessibilityLabel("Sound effects volume")
            Text("Music and rain volume").font(.caption.bold()); Slider(value:$game.cinema.musicVolume,in:0...1).accessibilityLabel("Music volume")
            Toggle("Optional daily surprises",isOn:$game.cinema.surprises)
        }.onChange(of:game.cinema.largeText) { _ in game.save() }.onChange(of:game.cinema.haptics) { _ in game.save() }.onChange(of:game.cinema.effectsVolume) { _ in game.save() }.onChange(of:game.cinema.musicVolume) { _ in game.save() }.onChange(of:game.cinema.surprises) { _ in game.save() }
    }
}

struct FilmBrowser: View {
    @EnvironmentObject var game: Store
    var ordering = false
    @State private var search = ""
    @State private var genre = "ALL"
    @State private var tag = "ALL"
    @State private var available = false
    var filtered: [Movie] { game.s.movies.filter { movie in
        let details = FilmLibrary.details(movie)
        return (genre == "ALL" || genre == movie.genre) && (tag == "ALL" || details.tags.contains(tag)) && (!available || movie.stock > 0) && (search.isEmpty || (movie.title + " " + details.synopsis + " " + details.tags.joined(separator:" ")).localizedCaseInsensitiveContains(search))
    }.sorted { $0.title < $1.title } }
    var body: some View {
        VStack(alignment:.leading,spacing:14) {
            if !ordering { BrowsingScene() }
            TextField("Search title, mood or synopsis",text:$search).textFieldStyle(.roundedBorder).autocorrectionDisabled()
            HStack { Picker("Genre",selection:$genre) { Text("All genres").tag("ALL"); ForEach(FilmLibrary.genres,id:\.self) { Text($0.capitalized).tag($0) } }; Picker("Mood",selection:$tag) { Text("All moods").tag("ALL"); ForEach(["adventure","chaotic","city","cozy","funny","gentle","mystery","nostalgic","rescue","space","spooky","strange","sweet","thrilling"],id:\.self) { Text($0.capitalized).tag($0) } } }
            Toggle("In stock only",isOn:$available).font(.caption).tint(mint)
            Text("\(filtered.count) of \(game.s.movies.count) films · \(ordering ? "$\(game.orderCost) per copy" : "$4 rental")").font(.caption).foregroundStyle(.secondary)
            if let guest = game.s.guests.first, !ordering { Text("For \(guest.name): \(game.request(guest)) · \(guest.genre)").font(.caption).foregroundStyle(mint) }
            if filtered.isEmpty { Text("No matching films. Try another mood or clear the search.").font(.subheadline) }
            LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible())],spacing:14) {
                ForEach(filtered) { movie in
                    VStack(alignment:.leading,spacing:8) {
                        VHSCover(movie:movie).frame(height:180)
                        Text(movie.genre).font(.caption2.bold()).foregroundStyle(palette[movie.id % 6])
                        Text(FilmLibrary.details(movie).tags.joined(separator:" · ")).font(.caption2).foregroundStyle(gold)
                        Text(FilmLibrary.details(movie).synopsis).font(.caption).fixedSize(horizontal:false,vertical:true)
                        Text("\(movie.stock) on shelf").font(.caption2)
                        Button(ordering ? "Order · $\(game.orderCost)" : "Recommend") {
                            if ordering { game.buy(movie.id) } else { game.recommend(movie.id); if game.s.guests.first?.movie != nil { game.station = "COUNTER" } }
                        }.font(.caption.bold()).frame(maxWidth:.infinity,minHeight:44).background(mint.opacity(0.15),in:RoundedRectangle(cornerRadius:10)).foregroundStyle(mint)
                            .disabled(ordering ? game.s.money < game.orderCost : (movie.stock == 0 || game.s.guests.first == nil || game.s.guests.first?.movie != nil))
                    }.padding(10).background(.white.opacity(0.04),in:RoundedRectangle(cornerRadius:12))
                        .overlay(RoundedRectangle(cornerRadius:12).stroke(game.s.guests.first?.genre == movie.genre && !ordering ? mint : .clear,lineWidth:2))
                }
            }
        }
    }
}
struct CustomerNotebook: View {
    @EnvironmentObject var game: Store
    var body: some View {
        VStack(alignment:.leading,spacing:16) {
            Text("CUSTOMER NOTEBOOK").font(.headline).foregroundStyle(gold)
            Text("Favorites, recent rentals and current requests stay with this shop.").font(.caption).foregroundStyle(.secondary)
            ForEach(Cast.all) { person in
                DisclosureGroup {
                    Text(person.bio).font(.caption)
                    Text("Friendship: \(game.bond(person.id))/6 · Favorite: \(person.genre)").font(.caption).foregroundStyle(mint)
                    ForEach(Array(game.cinema.history[String(person.id),default:[]].reversed().enumerated()),id:\.offset) { _,id in
                        if game.s.movies.indices.contains(id) { Text("▰ \(game.s.movies[id].title)").font(.caption) }
                    }
                    if game.cinema.history[String(person.id),default:[]].isEmpty { Text("No rentals recorded yet.").font(.caption).foregroundStyle(.secondary) }
                    ForEach(game.s.guests.filter { $0.name == person.name }) { guest in Text("Waiting: \(game.request(guest))").font(.caption).foregroundStyle(gold) }
                    if !game.s.reservations.isEmpty { Text("Shop reservations: " + game.s.reservations.map { game.s.movies[$0].title }.joined(separator:", ")).font(.caption2) }
                } label: { HStack { Text(person.name); Spacer(); Text("♥ \(game.bond(person.id))").font(.caption).foregroundStyle(.pink) } }
            }
        }
    }
}
struct EquipmentPanel: View {
    @EnvironmentObject var game: Store
    let items = [("rewinder","Fast rewinder",50,"Rewinds in 1 second instead of 3."),("bin","Larger return bin",45,"Carry up to 4 unprocessed returns into tomorrow."),("desk","Second checkout desk",75,"A second waiting desk raises queue capacity from 5 to 7."),("ordering","Wholesale ordering",60,"New stock costs $10 per copy instead of $12.")]
    var body: some View {
        VStack(alignment:.leading,spacing:14) {
            ForEach(items,id:\.0) { item in
                VStack(alignment:.leading,spacing:6) {
                    Text(item.1).font(.headline); Text(item.3).font(.caption).foregroundStyle(.secondary)
                    Button(game.cinema.upgrades.contains(item.0) ? "Installed ✓" : "Install · $\(item.2)") { game.equipment(item.0) }.buttonStyle(.bordered).tint(mint).disabled(game.cinema.upgrades.contains(item.0) || game.s.money < item.2)
                }
            }
        }
    }
}
struct SurprisePanel: View {
    @EnvironmentObject var game: Store
    @State private var result = ""
    var body: some View {
        VStack(alignment:.leading,spacing:12) {
            Text("TODAY’S SURPRISE").font(.caption.bold()).foregroundStyle(gold)
            if game.experience.relaxed || !game.cinema.surprises { Text("Surprises are off. Enable them in Play Options; Relaxed mode always skips them.").font(.caption) }
            else if let surprise = game.cinema.surprise {
                Text(surprise).font(.headline)
                if game.cinema.surpriseDone { Label("Solved for today",systemImage:"checkmark.circle.fill").foregroundStyle(mint) }
                else if surprise == "Surprise delivery" { Button("Open the donated box") { game.finishSurprise() }.buttonStyle(.bordered) }
                else {
                    let target = (game.s.day * 7) % game.s.movies.count
                    Text(surprise == "Missing favorite" ? "A regular remembers this story: \(FilmLibrary.details(game.s.movies[target]).synopsis) Find the title." : "The case has the wrong tape. Its label says \(game.s.movies[target].genre). Choose the correct replacement.").font(.caption)
                    ForEach([target,(target+1)%game.s.movies.count,(target+2)%game.s.movies.count].sorted(),id:\.self) { id in
                        Button(game.s.movies[id].title) { if id == target { game.finishSurprise(movie:id); result = "" } else { result = "Not quite. Check the clue again." } }.buttonStyle(.bordered)
                    }
                    Text(result).font(.caption).foregroundStyle(coral)
                }
            } else { Text("Open the shop and finish the first-customer guide to find an optional surprise.").font(.caption) }
        }
    }
}
struct ShopBackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data
    init(data:Data) { self.data = data }
    init(configuration:ReadConfiguration) throws { guard let data = configuration.file.regularFileContents else { throw BackupError.invalid }; self.data = data }
    func fileWrapper(configuration:WriteConfiguration) throws -> FileWrapper { FileWrapper(regularFileWithContents:data) }
}
struct BackupPanel: View {
    @EnvironmentObject var game: Store
    @State private var exporting = false
    @State private var importing = false
    @State private var pending: Data?
    @State private var document = ShopBackupDocument(data:Data())
    @State private var status = ""
    @State private var confirm = false
    var body: some View {
        VStack(alignment:.leading,spacing:14) {
            Text("Backups include this shop’s story, settings, friends and collection. Imported data replaces only the selected shop; a local copy is kept first.").font(.caption).foregroundStyle(.secondary)
            Button("Export Shop \(game.selectedSlot + 1) to Files") { do { document = ShopBackupDocument(data:try game.exportShop()); exporting = true } catch { status = "Could not create the backup." } }.buttonStyle(.bordered)
            Button("Import a Night Owl backup") { importing = true }.buttonStyle(.bordered)
            if let old = UserDefaults.standard.data(forKey:"nightowl.before-import.\(game.selectedSlot)") { Button("Restore the shop from before your last import") { pending = old; confirm = true }.buttonStyle(.bordered) }
            Text(status).font(.caption).foregroundStyle(mint)
        }
        .fileExporter(isPresented:$exporting,document:document,contentType:.json,defaultFilename:"NightOwl-Shop\(game.selectedSlot+1)-Day\(game.s.day)") { result in if case .success = result { status = "Backup exported. Keep a copy in Files or transfer it to your other iPhone." } }
        .fileImporter(isPresented:$importing,allowedContentTypes:[.json]) { result in
            do { let url = try result.get(); let access = url.startAccessingSecurityScopedResource(); defer { if access { url.stopAccessingSecurityScopedResource() } }; let size = try url.resourceValues(forKeys:[.fileSizeKey]).fileSize ?? 0; guard size <= 1_000_000 else { throw BackupError.invalid }; let data = try Data(contentsOf:url); _ = try game.validateBackup(data); pending = data; confirm = true } catch { status = "This is not a supported Night Owl backup. Your shop has not changed." }
        }
        .alert("Replace Shop \(game.selectedSlot+1)?",isPresented:$confirm) { Button("Cancel",role:.cancel) { pending = nil }; Button("Import backup",role:.destructive) { do { if let pending { try game.importShop(pending); status = "Backup imported." } } catch { status = "Import failed; current shop retained." }; pending = nil } } message: { Text("Other save slots stay untouched. A local backup of this shop is kept before importing.") }
    }
}
