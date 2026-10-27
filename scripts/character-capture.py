from pathlib import Path
source = Path('NightOwl/NightOwl.swift').read_text(encoding='utf-8-sig')
a=source.index('@main struct NightOwlApp:');b=source.index('struct Cutout:')
source=source[:a]+source[b:]
source += r'''
@main struct CharacterCaptureApp: App {
    @StateObject var store: Store
    init() {
        let s = Store()
        s.s = Save(); s.story = StoryProgress(); s.s.open = true
        s.s.guests = [6,7,8].map { Guest(name: Cast.all[$0].name,genre: Cast.all[$0].genre,snack: $0 == 6) }
        s.message = "Zoe: “A movie night for the night crew? Count us in.”"
        s.speakingGuest = s.s.guests.first?.id
        if ProcessInfo.processInfo.arguments.contains("--motion") {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                s.recommend(2); s.scan()
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                s.payment()
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                s.change = 3; s.checkout()
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                s.talk()
            }
        }
        s.experience = Experience(); s.experience.tutorialDone = true
        if ProcessInfo.processInfo.arguments.contains("--tutorial") { s.experience.tutorialDone = false; s.s.guests = []; s.s.open = false }
        if ProcessInfo.processInfo.arguments.contains("--styles") { s.s.served = 10; s.s.money = 200; for id in ["poster-space","shelf-walnut","counter-gold"] { s.selectStyle(ShopStyle.all.first { $0.id == id }!) } }
        if ProcessInfo.processInfo.arguments.contains("--summary") { s.experience.report = DayReport(day: 1,revenue: 47,bonus: 30,purchases: 12,bills: 15,customers: 8,returns: 4,grant: 0,tomorrow: "Day 2: 8 returns expected. Check stock, process returns, and continue your Story goals.") }
        s.neighborhood = Neighborhood()
        if ProcessInfo.processInfo.arguments.contains("--neighborhood") { s.neighborhood.rare = [0,1,3]; s.neighborhood.reputation = 30; s.neighborhood.friendship = ["0":3,"6":6] }
        s.expandCatalog()
        _store = StateObject(wrappedValue: s)
    }
    var body: some Scene {
        WindowGroup {
            if ProcessInfo.processInfo.arguments.contains("--portrait") {
                VStack(spacing:24) {
                    Text("YOUR NIGHT OWL SHOPKEEPER").font(.system(size:20,weight:.black,design:.rounded)).foregroundStyle(mint)
                    PlayerPortrait().scaleEffect(2.8).frame(width:240,height:365)
                    Text("Swept dark hair · rectangular glasses\nShort beard · blue crew-neck tee").font(.subheadline).multilineTextAlignment(.center).foregroundStyle(.white.opacity(0.8))
                    Text("ORIGINAL IN-GAME CHARACTER ART").font(.system(size:10,weight:.bold,design:.monospaced)).foregroundStyle(gold)
                }.padding(20).frame(maxWidth:.infinity,maxHeight:.infinity).background(ink).preferredColorScheme(.dark)
            } else if ProcessInfo.processInfo.arguments.contains("--library") {
                NavigationStack { ScrollView { FilmBrowser().padding(20) }.background(ink).navigationTitle("Film library") }.environmentObject(store).preferredColorScheme(.dark)
            } else if ProcessInfo.processInfo.arguments.contains("--notebook") {
                NavigationStack { ScrollView { CustomerNotebook().padding(20) }.background(ink).navigationTitle("Notebook") }.environmentObject(store).preferredColorScheme(.dark)
            } else if ProcessInfo.processInfo.arguments.contains("--equipment") {
                NavigationStack { ScrollView { EquipmentPanel().padding(20) }.background(ink).navigationTitle("Equipment") }.environmentObject(store).preferredColorScheme(.dark)
            } else if ProcessInfo.processInfo.arguments.contains("--covers") {
                ScrollView { VStack(spacing: 14) { Text("NIGHT OWL · VHS COLLECTION").font(.headline).foregroundStyle(mint); LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())],spacing: 12) { ForEach(store.s.movies) { movie in VHSCover(movie: movie).frame(height: 205) } } }.padding(20) }.background(ink).preferredColorScheme(.dark)
            } else if ProcessInfo.processInfo.arguments.contains("--neighborhood") {
                NavigationStack { ScrollView { NeighborhoodPanel().padding(20) }.background(ink).navigationTitle("Maple Street") }.environmentObject(store).preferredColorScheme(.dark)
            } else if ProcessInfo.processInfo.arguments.contains("--chores") {
                NavigationStack { ScrollView { ChoreBench().padding(20) }.background(ink).navigationTitle("Hands-on chores") }.environmentObject(store).preferredColorScheme(.dark)
            } else if ProcessInfo.processInfo.arguments.contains("--slots") {
                SaveSlotsView().environmentObject(store)
            } else if ProcessInfo.processInfo.arguments.contains("--options") {
                NavigationStack { ScrollView { PlayOptions().padding(24) }.background(ink).navigationTitle("Play Options") }.environmentObject(store).preferredColorScheme(.dark)
            } else if ProcessInfo.processInfo.arguments.contains("--styles") {
                NavigationStack { ScrollView { VStack(spacing: 20) { ShopArt(); StyleShop() }.padding(20) }.background(ink).navigationTitle("Your shop") }.environmentObject(store).preferredColorScheme(.dark)
            } else if ProcessInfo.processInfo.arguments.contains("--summary") {
                DayReportView().environmentObject(store)
            } else if ProcessInfo.processInfo.arguments.contains("--tutorial") {
                FlatGameScreen(onMenu: {}).environmentObject(store).preferredColorScheme(.dark)
            } else if ProcessInfo.processInfo.arguments.contains("--menu") {
                StartGameView().environmentObject(store).preferredColorScheme(.dark)
            } else if ProcessInfo.processInfo.arguments.contains("--world") || ProcessInfo.processInfo.arguments.contains("--motion") {
                FlatGameScreen(onMenu: {}).environmentObject(store).preferredColorScheme(.dark)
            } else if ProcessInfo.processInfo.arguments.contains("--characters") || ProcessInfo.processInfo.arguments.contains("--newcharacters") {
                let start = ProcessInfo.processInfo.arguments.contains("--newcharacters") ? 6 : 0
                VStack(spacing: 20) {
                    Text("NIGHT OWL").font(.system(size: 30,weight: .black,design: .rounded)).foregroundStyle(mint)
                    Text(start == 6 ? "MEET THE NEW NEIGHBORS" : "MAPLE STREET REGULARS").font(.system(size: 11,weight: .bold,design: .monospaced)).tracking(2).foregroundStyle(gold)
                    LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())],spacing: 20) {
                        ForEach(start..<(start + 6),id: \.self) { n in
                            VStack(spacing: 6) {
                                Cutout(index: n).scaleEffect(0.95).frame(width: 140,height: 135)
                                Text(Cast.all[n].name.uppercased()).font(.system(size: 12,weight: .black,design: .monospaced)).foregroundStyle(palette[n % 6])
                                Text(Cast.all[n].role).font(.system(size: 8,weight: .medium)).foregroundStyle(.white.opacity(0.6)).multilineTextAlignment(.center)
                            }
                        }
                    }
                    Text("12 ADULT REGULARS · ORIGINAL IN-GAME ART").font(.system(size: 8,weight: .bold,design: .monospaced)).foregroundStyle(.white.opacity(0.4))
                }.padding(20).frame(maxWidth: .infinity,maxHeight: .infinity).background(ink).preferredColorScheme(.dark)
            } else if ProcessInfo.processInfo.arguments.contains("--story") {
                ScrollView { StoryPanel().padding(24) }.background(ink).environmentObject(store).preferredColorScheme(.dark)
            } else {
                GameView().environmentObject(store).preferredColorScheme(.dark)
            }
        }
    }
}
'''
source=source.replace(r'\\.self',r'\.self')
Path('build/CharacterCapture.swift').write_text(source,encoding='utf-8')
