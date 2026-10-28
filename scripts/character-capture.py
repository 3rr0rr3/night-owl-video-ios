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
            s.s.guests = []
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                s.s.guests = [6,7,8].map { Guest(name:Cast.all[$0].name,genre:Cast.all[$0].genre,snack:$0 == 6) }
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                s.recommend(2)
                try? await Task.sleep(nanoseconds: 3_500_000_000)
                s.scan()
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                s.payment()
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                s.change = 3; s.checkout()
                try? await Task.sleep(nanoseconds: 4_500_000_000)
                s.talk()
            }
        }
        s.experience = Experience(); s.experience.tutorialDone = true
        if ProcessInfo.processInfo.arguments.contains("--tutorial") { s.experience.tutorialDone = false; s.s.guests = []; s.s.open = false }
        if ProcessInfo.processInfo.arguments.contains("--styles") { s.s.served = 10; s.s.money = 200; for id in ["poster-space","shelf-walnut","counter-gold"] { s.selectStyle(ShopStyle.all.first { $0.id == id }!) } }
        if ProcessInfo.processInfo.arguments.contains("--summary") { s.experience.report = DayReport(day: 1,revenue: 47,bonus: 30,purchases: 12,bills: 15,customers: 8,returns: 4,grant: 0,tomorrow: "Day 2: 8 returns expected. Check stock, process returns, and continue your Story goals.") }
        s.neighborhood = Neighborhood()
        if ProcessInfo.processInfo.arguments.contains("--neighborhood") { s.neighborhood.rare = [0,1,3]; s.neighborhood.reputation = 30; s.neighborhood.friendship = ["0":3,"6":6] }
        s.expansion = ExpansionProgress()
        s.expandCatalog()
        s.prepareUsedOffer(); s.inspectUsedTape()
        s.expansion.weeklyGoal = "friends"; s.expansion.weeklyFriends = 5
        s.expansion.articles = [TownArticle(day:1,title:"A new chapter for Night Owl",body:"The movie club is preparing its first double bill. Neighbors can now bring used tapes to the shop.")]
        if ProcessInfo.processInfo.arguments.contains("--gazette") { s.s.day = 15; s.syncExpansionWeek() }
        if ProcessInfo.processInfo.arguments.contains("--floorplan") { s.arrange("counter",at:4); s.arrange("snacks",at:6) }
        _store = StateObject(wrappedValue: s)
    }
    var body: some Scene {
        WindowGroup {
            if ProcessInfo.processInfo.arguments.contains("--floorplan") {
                NavigationStack { ScrollView { VStack(spacing:20) { FloorPlanScene(editing:true); StaffAssignmentPanel() }.padding(20) }.background(ink).navigationTitle("Your shop layout") }.environmentObject(store).preferredColorScheme(.dark)
            } else if ProcessInfo.processInfo.arguments.contains("--usedtapes") {
                NavigationStack { ScrollView { UsedTapeDesk().padding(20) }.background(ink).navigationTitle("Used-tape trading") }.environmentObject(store).preferredColorScheme(.dark)
            } else if ProcessInfo.processInfo.arguments.contains("--movieclub") {
                NavigationStack { ScrollView { MovieClubPanel().padding(20) }.background(ink).navigationTitle("Movie club") }.environmentObject(store).preferredColorScheme(.dark)
            } else if ProcessInfo.processInfo.arguments.contains("--gazette") {
                NavigationStack { ScrollView { TownNewspaper().padding(20) }.background(ink).navigationTitle("The Gazette") }.environmentObject(store).preferredColorScheme(.dark)
            } else if ProcessInfo.processInfo.arguments.contains("--forecast") {
                NavigationStack { ScrollView { VStack(spacing:20) { ForecastCard(); WeeklyProjectPanel() }.padding(20) }.background(ink).navigationTitle("Plan your week") }.environmentObject(store).preferredColorScheme(.dark)
            } else if ProcessInfo.processInfo.arguments.contains("--gestures") {
                VStack(spacing:20) {
                    Text("FRANK · CONNECTED GESTURES").font(.headline).foregroundStyle(mint)
                    Text("Matching sleeves · two arms · wristwatch").font(.caption).foregroundStyle(gold)
                    LifeClock { time in
                        LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible())],spacing:24) {
                            ForEach(["idle","waiting","talk","happy"],id:\.self) { mood in
                                VStack(spacing:8) {
                                    CustomerGesture(index:5,mood:mood,time:time).scaleEffect(1.5).frame(width:130,height:200)
                                    Text(mood.uppercased()).font(.caption.bold()).foregroundStyle(mint)
                                }
                            }
                        }
                    }
                }.padding(20).frame(maxWidth:.infinity,maxHeight:.infinity).background(ink).preferredColorScheme(.dark)
            } else if ProcessInfo.processInfo.arguments.contains("--life") {
                ScrollView {
                    VStack(spacing:12) {
                        Text("NIGHT OWL · LIVING SHOP").font(.headline).foregroundStyle(mint)
                        ShopArt(); BrowsingScene()
                        LifeClock { time in HStack { CustomerGesture(index:6,mood:"talk",time:time); CustomerGesture(index:5,mood:"waiting",time:time); CustomerGesture(index:5,mood:"happy",time:time) } }
                        ShopActionScene(); CelebrationBanner()
                    }.padding(14)
                }.background(ink).environmentObject(store).preferredColorScheme(.dark)
                    .task {
                        store.s.day = 3; store.shopAction(.opening,"Opening · lights on, shutters up")
                        try? await Task.sleep(nanoseconds:4_000_000_000)
                        store.shopAction(.returnDrop,"Return drops into the bin",movie:0)
                        try? await Task.sleep(nanoseconds:4_000_000_000)
                        store.shopAction(.rewindDone,"Rewinder clicks to a stop",movie:0)
                        try? await Task.sleep(nanoseconds:4_000_000_000)
                        store.shopAction(.restock,"Restocking the shelves",movie:2)
                        try? await Task.sleep(nanoseconds:4_000_000_000)
                        store.neighborhood.friendship["6"] = 2; store.befriend(6)
                        try? await Task.sleep(nanoseconds:4_000_000_000)
                        store.discoverRare(3)
                        try? await Task.sleep(nanoseconds:4_000_000_000)
                        store.s.open = false; store.shopAction(.closing,"Closing · shutters down, lights out")
                    }
            } else if ProcessInfo.processInfo.arguments.contains("--portrait") {
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
