import SwiftUI

struct StartGameView: View {
    @EnvironmentObject var game: Store
    @StateObject private var backdrop = ShopWorld(preview: true)
    @State private var playing = false
    @State private var showHelp = false
    @State private var confirmNewGame = false
    var body: some View {
        ZStack {
            StoreSceneView(world: backdrop,running: !playing).ignoresSafeArea().blur(radius: 4).allowsHitTesting(false)
            LinearGradient(colors: [ink.opacity(0.3),ink.opacity(0.85),ink],startPoint: .top,endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 18) {
                Spacer()
                Image(systemName: "moon.stars.fill").font(.system(size: 50)).foregroundStyle(gold)
                Text("NIGHT OWL").font(.system(size: 42,weight: .black,design: .rounded)).foregroundStyle(mint).minimumScaleFactor(0.6).lineLimit(1)
                Text("VIDEO STORE · CHIBI EDITION").font(.system(size: 11,weight: .heavy,design: .monospaced)).tracking(2).foregroundStyle(.white)
                Text("A little video store. A whole neighborhood.").font(.subheadline).foregroundStyle(.white.opacity(0.8))
                Spacer()
                VStack(spacing: 12) {
                    if game.hasSavedGame {
                        menuButton("Continue · Day \(game.s.day)",icon: "play.fill",primary: true) { playing = true }
                        menuButton("New Game",icon: "sparkles") { confirmNewGame = true }
                    } else {
                        menuButton("Start Game",icon: "play.fill",primary: true) { game.newGame(); playing = true }
                    }
                    menuButton("How to Play",icon: "questionmark.circle") { showHelp = true }
                }.frame(maxWidth: 390)
                Text("MAPLE STREET · 1994\nBE KIND. REWIND.").font(.system(size: 10,weight: .bold,design: .monospaced)).tracking(2).lineSpacing(6).multilineTextAlignment(.center).foregroundStyle(.white.opacity(0.45)).padding(.top,10)
            }.padding(28).padding(.bottom,12)
        }
        .fullScreenCover(isPresented: $playing) { WorldGameScreen { game.save(); playing = false }.environmentObject(game).preferredColorScheme(.dark) }
        .sheet(isPresented: $showHelp) { NavigationStack { ScrollView { VStack(alignment: .leading,spacing: 20) {
            Text("Welcome to Night Owl").font(.title.bold()).foregroundStyle(mint)
            Text("Tap a floor tile to walk your chibi shopkeeper there. The angled overhead camera follows automatically. The small movement stick is available for fine positioning.")
            Text("Tap a labeled station to walk over and open it, or press USE when you are already nearby. The counter handles rentals and change; the return desk handles scanning, fees and rewinding; the shelves help you choose films. The store PC orders stock, hires staff and decorates.")
            Text("Tap Journal to follow the seven-chapter Maple Street story and meet your twelve adult regulars. Your shop autosaves while you play. Returning to the start screen pauses the shift.")
            Text("Your shopkeeper is marked by a mint ring. New Game asks before replacing an existing save.").foregroundStyle(.secondary)
        }.padding(24) }.background(ink).navigationTitle("How to Play").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showHelp = false } } } } }
        .alert("Start a new shop?",isPresented: $confirmNewGame) { Button("Cancel",role: .cancel) {} ; Button("Start New Game",role: .destructive) { game.newGame(); playing = true } } message: { Text("This replaces your current shop and story progress. Continue keeps your existing save.") }
        .onAppear {
            if ProcessInfo.processInfo.arguments.contains("--smoke-world") { if !game.hasSavedGame { game.newGame() }; playing = true }
        }
    }
    private func menuButton(_ title: String,icon: String,primary: Bool = false,action: @escaping () -> Void) -> some View {
        Button(action: action) { Label(title,systemImage: icon).font(.headline).frame(maxWidth: .infinity).padding(18).foregroundStyle(primary ? ink : .white).background(primary ? mint : .white.opacity(0.09),in: RoundedRectangle(cornerRadius: 15)) }
    }
}

struct WorldGameScreen: View {
    @EnvironmentObject var game: Store
    @Environment(\.scenePhase) private var phase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var world = ShopWorld()
    @State private var showStation = false
    @State private var stick = CGSize.zero
    let onMenu: () -> Void
    private let timer = Timer.publish(every: 2,on: .main,in: .common).autoconnect()
    var body: some View {
        ZStack {
            StoreSceneView(world: world).ignoresSafeArea()
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading,spacing: 4) { Text("NIGHT OWL · CHIBI").font(.system(size: 15,weight: .black,design: .rounded)).foregroundStyle(mint); Text("DAY \(game.s.day) · \(game.clock) · \(game.s.open ? "OPEN" : "CLOSED")").font(.system(size: 10,weight: .bold,design: .monospaced)).foregroundStyle(.white.opacity(0.8)) }
                    Spacer()
                    Text("$\(game.s.money)").font(.title3.bold()).foregroundStyle(gold)
                    Button { world.stop(); onMenu() } label: { Image(systemName: "pause.fill").padding(10).background(.white.opacity(0.12),in: Circle()) }.accessibilityLabel("Save and return to start screen")
                }.padding(14).background(ink.opacity(0.88),in: RoundedRectangle(cornerRadius: 16))
                HStack(spacing: 10) {
                    Button { open("STORY") } label: { Label("Journal",systemImage: "book.closed.fill") }
                    Spacer()
                    Button { world.resetView(); stick = .zero } label: { Label("Center player",systemImage: "location.north.fill") }
                }.font(.caption.bold()).foregroundStyle(.white).padding(12).background(ink.opacity(0.75),in: Capsule())
                Spacer()
                Text(world.nearby?.title ?? "EXPLORE THE VIDEO STORE").font(.system(size: 12,weight: .black,design: .monospaced)).foregroundStyle(mint).padding(10).background(ink.opacity(0.8),in: Capsule())
                Text(world.hint).font(.caption2).foregroundStyle(.white).padding(8).background(ink.opacity(0.7),in: Capsule())
                HStack(alignment: .bottom) {
                    ZStack {
                        Circle().fill(ink.opacity(0.65)).overlay(Circle().stroke(.white.opacity(0.2),lineWidth: 2)).frame(width: 88,height: 88)
                        Image(systemName: "arrow.up.and.down.and.arrow.left.and.right").font(.system(size: 28)).foregroundStyle(.white.opacity(0.2))
                        Circle().fill(mint.opacity(0.85)).frame(width: 36,height: 36).offset(stick)
                    }.contentShape(Circle()).gesture(DragGesture(minimumDistance: 0).onChanged { value in
                        let distance = max(35,hypot(value.translation.width,value.translation.height))
                        stick = CGSize(width: value.translation.width / distance * 35,height: value.translation.height / distance * 35)
                        world.movement = SIMD2(Float(stick.width / 35),Float(stick.height / 35))
                    }.onEnded { _ in stick = .zero; world.movement = .zero }).accessibilityLabel("Movement stick. Drag in the direction to walk.")
                    Spacer()
                    VStack(spacing: 10) {
                        if !game.s.open && game.s.guests.isEmpty { Button { game.doors() } label: { Label("Open store",systemImage: "door.left.hand.open").padding(12).background(gold,in: Capsule()).foregroundStyle(ink) }.font(.caption.bold()) }
                        Button { world.interact() } label: { Label("USE",systemImage: "hand.tap.fill").font(.headline).frame(width: 95,height: 65).foregroundStyle(world.nearby == nil ? .gray : ink).background(world.nearby == nil ? Color.white.opacity(0.15) : mint,in: RoundedRectangle(cornerRadius: 18)) }.disabled(world.nearby == nil)
                    }
                }.padding(.top,8)
            }.padding(18)
        }
        .sheet(isPresented: $showStation,onDismiss: { world.movement = .zero; stick = .zero; world.start() }) {
            NavigationStack { GameView().environmentObject(game).navigationTitle(game.station == "STORY" ? "Maple Street Journal" : "Night Owl Desk").navigationBarTitleDisplayMode(.inline).toolbar { ToolbarItem(placement: .confirmationAction) { Button("Back to store") { showStation = false } } } }.preferredColorScheme(.dark)
        }
        .onAppear {
            world.reduceMotion = reduceMotion; world.onInteract = { open($0) }; world.sync(game.s.guests,staff: game.s.staff); world.start()
            if ProcessInfo.processInfo.arguments.contains("--smoke-world") {
                precondition(world.scene.rootNode.childNodes.count > 30,"3D store geometry must be built")
                precondition(world.stations.count >= 6,"All task stations must exist")
                precondition(world.camera.camera?.usesOrthographicProjection == true,"Overhead orthographic camera is active")
                precondition(world.player.parent != nil,"Visible chibi player is in the scene")
                print("PASS: overhead camera, visible chibi player, 3D world and task stations initialized")
            }
        }
        .onDisappear { world.stop(); game.save() }
        .onChange(of: game.s.guests.map { $0.id }) { _ in world.sync(game.s.guests,staff: game.s.staff) }
        .onChange(of: game.s.staff) { _ in world.sync(game.s.guests,staff: game.s.staff) }
        .onChange(of: phase) { value in if value == .active && !showStation { world.start() } else { world.stop(); game.save() } }
        .onReceive(timer) { _ in if phase == .active { game.tick() } }
    }
    private func open(_ code: String) { game.station = code; world.stop(); stick = .zero; showStation = true }
}
