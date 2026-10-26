import SwiftUI

struct StartGameView: View {
    @EnvironmentObject var game: Store
    @State private var playing = false
    @State private var showHelp = false
    @State private var showOptions = false
    @State private var confirmNewGame = false
    var body: some View {
        ZStack {
            ink.ignoresSafeArea()
            ShopArt().environmentObject(game).padding(20).opacity(0.25).blur(radius: 3).allowsHitTesting(false)
            LinearGradient(colors: [ink.opacity(0.3),ink.opacity(0.85),ink],startPoint: .top,endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 18) {
                Spacer()
                Image(systemName: "moon.stars.fill").font(.system(size: 50)).foregroundStyle(gold)
                Text("NIGHT OWL").font(.system(size: 42,weight: .black,design: .rounded)).foregroundStyle(mint).minimumScaleFactor(0.6).lineLimit(1)
                Text("VIDEO STORE SIMULATOR").font(.system(size: 11,weight: .heavy,design: .monospaced)).tracking(2).foregroundStyle(.white)
                Text("A little video store. A whole neighborhood.").font(.subheadline).foregroundStyle(.white.opacity(0.8))
                Spacer()
                VStack(spacing: 12) {
                    if game.hasSavedGame {
                        menuButton("Continue · Day \(game.s.day)",icon: "play.fill",primary: true) { playing = true }
                        menuButton("New Game",icon: "sparkles") { confirmNewGame = true }
                    } else {
                        menuButton("Start Game",icon: "play.fill",primary: true) { game.newGame(); playing = true }
                    }
                    menuButton("Play Options",icon: "slider.horizontal.3") { showOptions = true }
                    menuButton("How to Play",icon: "questionmark.circle") { showHelp = true }
                }.frame(maxWidth: 390)
                Text("MAPLE STREET · 1994\nBE KIND. REWIND.").font(.system(size: 10,weight: .bold,design: .monospaced)).tracking(2).lineSpacing(6).multilineTextAlignment(.center).foregroundStyle(.white.opacity(0.45)).padding(.top,10)
            }.padding(28).padding(.bottom,12)
        }
        .fullScreenCover(isPresented: $playing) { FlatGameScreen { game.save(); playing = false }.environmentObject(game).preferredColorScheme(.dark) }
        .sheet(isPresented: $showHelp) { NavigationStack { ScrollView { VStack(alignment: .leading,spacing: 20) {
            Text("Welcome to Night Owl").font(.title.bold()).foregroundStyle(mint)
            Text("Use the Counter, Returns, Shelves, Story and Store PC tabs below the illustrated shop. Scroll down to see the actions for your selected station.")
            Text("Tap a station tab to open its tasks. The counter handles rentals and change; the return desk handles scanning, fees and rewinding; the shelves help you choose films. The store PC orders stock, hires staff and decorates.")
            Text("Open Story to follow the seven-chapter Maple Street story and meet your twelve adult regulars. Your shop autosaves while you play. Returning to the start screen pauses the shift.")
            Text("Tap Menu to save and pause. New Game asks before replacing an existing save.").foregroundStyle(.secondary)
        }.padding(24) }.background(ink).navigationTitle("How to Play").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showHelp = false } } } } }
        .sheet(isPresented: $showOptions) { NavigationStack { ScrollView { PlayOptions().padding(24) }.background(ink).navigationTitle("Play Options").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showOptions = false } } } } }
        .alert("Start a new shop?",isPresented: $confirmNewGame) { Button("Cancel",role: .cancel) {} ; Button("Start New Game",role: .destructive) { game.newGame(); playing = true } } message: { Text("This replaces your current shop and story progress. Continue keeps your existing save.") }
        .onAppear {
            if ProcessInfo.processInfo.arguments.contains("--smoke-store") { if !game.hasSavedGame { game.newGame() }; playing = true }
        }
    }
    private func menuButton(_ title: String,icon: String,primary: Bool = false,action: @escaping () -> Void) -> some View {
        Button(action: action) { Label(title,systemImage: icon).font(.headline).frame(maxWidth: .infinity).padding(18).foregroundStyle(primary ? ink : .white).background(primary ? mint : .white.opacity(0.09),in: RoundedRectangle(cornerRadius: 15)) }
    }
}

struct FlatGameScreen: View {
    @EnvironmentObject var game: Store
    @Environment(\.scenePhase) private var phase
    let onMenu: () -> Void
    private let timer = Timer.publish(every: 2,on: .main,in: .common).autoconnect()
    var body: some View {
        NavigationStack {
            GameView().environmentObject(game)
                .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Menu") { game.save(); onMenu() }.accessibilityLabel("Save and pause game") } }
                .navigationBarTitleDisplayMode(.inline)
        }
        .onReceive(timer) { _ in if phase == .active { game.tick() } }
        .onChange(of: phase) { _ in game.save() }
        .onDisappear { game.save() }
    }
}
