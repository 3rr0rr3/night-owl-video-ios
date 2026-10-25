from pathlib import Path
source = Path('NightOwl/NightOwl.swift').read_text(encoding='utf-8-sig')
a=source.index('@main struct NightOwlApp:')
b=source.index('struct Cutout:')
source=source[:a]+source[b:]
source += '''
@main struct CharacterCaptureApp: App {
    @StateObject var store: Store
    init() {
        let s = Store()
        s.s = Save()
        s.doors()
        s.addGuest()
        s.addGuest()
        _store = StateObject(wrappedValue: s)
    }
    var body: some Scene {
        WindowGroup {
            if ProcessInfo.processInfo.arguments.contains("--characters") {
                VStack(spacing: 25) {
                    Text("NIGHT OWL").font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(mint)
                    Text("MEET YOUR CUSTOMERS").font(.system(size: 11, weight: .bold, design: .monospaced)).tracking(2).foregroundStyle(gold)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 35) {
                        ForEach(0..<6) { n in
                            VStack(spacing: 12) {
                                Cutout(index: n).scaleEffect(1.35).frame(width: 140, height: 140)
                                Text(["MILO", "JULES", "BEA", "OTIS", "NINA", "FRANK"][n]).font(.system(size: 12, weight: .black, design: .monospaced)).foregroundStyle(palette[n])
                            }
                        }
                    }
                    Text("ACTUAL IN-GAME CHARACTER ART").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundStyle(.white.opacity(0.4))
                }.padding(20).frame(maxWidth: .infinity, maxHeight: .infinity).background(ink).preferredColorScheme(.dark)
            } else {
                GameView().environmentObject(store).preferredColorScheme(.dark)
            }
        }
    }
}
'''
Path('build/CharacterCapture.swift').write_text(source,encoding='utf-8')
