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
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                s.recommend(2); s.scan(); s.payment(); s.change = 3; s.checkout()
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                s.talk()
            }
        }
        _store = StateObject(wrappedValue: s)
    }
    var body: some Scene {
        WindowGroup {
            if ProcessInfo.processInfo.arguments.contains("--characters") || ProcessInfo.processInfo.arguments.contains("--newcharacters") {
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
