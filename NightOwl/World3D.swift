import SwiftUI
import SceneKit
import UIKit

struct ShopStation: Equatable {
    let code: String
    let title: String
    let x: Float
    let z: Float
}

@MainActor final class ShopWorld: NSObject, ObservableObject {
    let scene = SCNScene()
    let camera = SCNNode()
    let player = SCNNode()
    private var route: [FloorPoint] = []
    private var pendingStation: String? = nil
    @Published var nearby: ShopStation? = nil
    @Published var hint = "Tap a floor tile or a station to walk there"
    var onInteract: ((String) -> Void)?
    var movement = SIMD2<Float>.zero
    var reduceMotion = false
    var preview = false
    private var displayLink: CADisplayLink?
    private var lastTime: CFTimeInterval = 0
    private var yaw: Float = 0
    private var pitch: Float = -0.08
    private var people: [UUID: SCNNode] = [:]
    private var focusFrame = 0
    private weak var surface: SCNView?
    let stations = [
        ShopStation(code: "COUNTER", title: "RENTAL COUNTER", x: 3, z: -3.8),
        ShopStation(code: "RETURNS", title: "RETURNS & REWIND", x: -4, z: 4.6),
        ShopStation(code: "SHELVES", title: "MOVIE SHELVES", x: -2.5, z: -1.1),
        ShopStation(code: "SHELVES", title: "NEW RELEASES", x: 0, z: -1.1),
        ShopStation(code: "STORE PC", title: "STORE COMPUTER", x: 4.3, z: -5.3),
        ShopStation(code: "STORY", title: "MAPLE STREET BOARD", x: -4.5, z: -4.9),
        ShopStation(code: "STORE PC", title: "SNACKS & SUPPLIES", x: 4.6, z: 2.5)
    ]
    init(preview: Bool = false) {
        self.preview = preview
        super.init()
        buildStore()
        camera.camera = SCNCamera()
        camera.camera?.usesOrthographicProjection = true
        camera.camera?.orthographicScale = preview ? 12.3 : 11.4
        camera.camera?.zNear = 0.05
        camera.camera?.zFar = 60
        scene.rootNode.addChildNode(camera)
        player.position = SCNVector3(WorldLayout.spawn.x,0,WorldLayout.spawn.z)
        player.name = "player"
        player.addChildNode(person(0))
        let marker = SCNTorus(ringRadius: 0.32,pipeRadius: 0.025); marker.materials = [material(.systemMint,glow: true)]
        let ring = SCNNode(geometry: marker); ring.position.y = 0.025; player.addChildNode(ring)
        scene.rootNode.addChildNode(player)
        updateCamera(immediate: true)
    }
    private func updateCamera(immediate: Bool = false) {
        let focusX: Float = preview ? 0 : min(1.3,max(-1.3,player.position.x * 0.25))
        let focusZ: Float = preview ? 0 : min(1.5,max(-1.5,(player.position.z - 4.7) * 0.35))
        camera.position = SCNVector3(focusX,14,12 + focusZ)
        camera.look(at: SCNVector3(focusX,0,focusZ))
    }

    func material(_ color: UIColor, glow: Bool = false) -> SCNMaterial {
        let m = SCNMaterial(); m.diffuse.contents = color; m.roughness.contents = 0.85; m.emission.contents = color.withAlphaComponent(0.18); m.emission.intensity = 0.22
        if glow { m.emission.contents = color; m.lightingModel = .constant }
        return m
    }
    @discardableResult func box(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat, at position: SCNVector3, color: UIColor, parent: SCNNode? = nil, name: String? = nil, bevel: CGFloat = 0.02) -> SCNNode {
        let g = SCNBox(width: x, height: y, length: z, chamferRadius: min(bevel,min(x,min(y,z)) * 0.45))
        g.materials = [material(color)]
        let n = SCNNode(geometry: g); n.position = position; n.name = name
        (parent ?? scene.rootNode).addChildNode(n); return n
    }
    @discardableResult func ball(_ radius: CGFloat, at position: SCNVector3, color: UIColor, scale: SCNVector3 = SCNVector3(1,1,1), parent: SCNNode) -> SCNNode {
        let g = SCNSphere(radius: radius); g.segmentCount = 12; g.materials = [material(color)]
        let n = SCNNode(geometry: g); n.position = position; n.scale = scale; parent.addChildNode(n); return n
    }
    func label(_ text: String, at position: SCNVector3, width: CGFloat, color: UIColor = .white, parent: SCNNode? = nil, billboard: Bool = false, name: String? = nil) {
        let format = UIGraphicsImageRendererFormat(); format.scale = 1
        let image = UIGraphicsImageRenderer(size: CGSize(width: 768, height: 160), format: format).image { _ in
            UIColor(red: 0.08,green: 0.10,blue: 0.18,alpha: 0.88).setFill()
            UIBezierPath(roundedRect: CGRect(x: 5,y: 18,width: 758,height: 128),cornerRadius: 24).fill()
            let style = NSMutableParagraphStyle(); style.alignment = .center
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.monospacedSystemFont(ofSize: 46, weight: .heavy), .foregroundColor: color, .paragraphStyle: style]
            (text as NSString).draw(in: CGRect(x: 8,y: 35,width: 752,height: 120),withAttributes: attributes)
        }
        let g = SCNPlane(width: width, height: width * 160 / 768)
        let m = SCNMaterial(); m.diffuse.contents = image; m.lightingModel = .constant; m.isDoubleSided = true
        g.materials = [m]
        let n = SCNNode(geometry: g); n.position = position; n.name = name
        if billboard { let c = SCNBillboardConstraint(); c.freeAxes = .all; n.constraints = [c] }
        (parent ?? scene.rootNode).addChildNode(n)
    }
    private func buildStore() {
        let navy = UIColor(red: 0.08,green: 0.09,blue: 0.17,alpha: 1)
        let mint = UIColor(red: 0.51,green: 0.94,blue: 0.74,alpha: 1)
        let coral = UIColor(red: 1,green: 0.46,blue: 0.40,alpha: 1)
        let purple = UIColor(red: 0.77,green: 0.69,blue: 0.60,alpha: 1)
        scene.background.contents = UIColor(red: 0.68,green: 0.80,blue: 0.82,alpha: 1); scene.fogStartDistance = 35; scene.fogEndDistance = 60
        box(11,0.12,13,at: SCNVector3(0,-0.07,0),color: purple,name: "floor",bevel: 0)
        for x in -5...5 { box(0.015,0.008,13,at: SCNVector3(Float(x),0.001,0),color: UIColor(red: 0.63,green: 0.55,blue: 0.48,alpha: 1),bevel: 0) }
        for z in -6...6 { box(11,0.008,0.015,at: SCNVector3(0,0.002,Float(z)),color: UIColor(red: 0.63,green: 0.55,blue: 0.48,alpha: 1),bevel: 0) }
        box(11,1.15,0.16,at: SCNVector3(0,0.575,-6.5),color: UIColor(red: 0.89,green: 0.85,blue: 0.74,alpha: 1))
        box(0.16,0.75,13,at: SCNVector3(-5.5,0.375,0),color: UIColor(red: 0.82,green: 0.88,blue: 0.76,alpha: 1))
        box(0.16,0.75,13,at: SCNVector3(5.5,0.375,0),color: UIColor(red: 0.82,green: 0.88,blue: 0.76,alpha: 1))
        box(11,0.09,0.12,at: SCNVector3(0,1.1,-6.35),color: coral)
        box(0.12,0.09,13,at: SCNVector3(-5.35,0.7,0),color: mint)
        box(0.12,0.09,13,at: SCNVector3(5.35,0.7,0),color: coral)
        label("NIGHT OWL",at: SCNVector3(0,1.45,-6.1),width: 2.7,color: mint,billboard: true)

        for x in [Float]([-4,-2,0,2,4]) {
            let l = SCNLight(); l.type = .omni; l.intensity = 200; l.color = UIColor(red: 1,green: 0.88,blue: 0.74,alpha: 1)
            l.attenuationStartDistance = 1; l.attenuationEndDistance = 9
            let n = SCNNode(); n.light = l; n.position = SCNVector3(x,3,0); scene.rootNode.addChildNode(n)

        }
        let ambient = SCNNode(); ambient.light = SCNLight(); ambient.light?.type = .ambient; ambient.light?.intensity = 750; ambient.light?.color = UIColor(red: 0.72,green: 0.78,blue: 1,alpha: 1); scene.rootNode.addChildNode(ambient)
        for (index,x) in [Float]([-2.5,0]).enumerated() {
            let shelf = SCNNode(); shelf.name = "station:SHELVES"; shelf.position = SCNVector3(x,0,-1.1); scene.rootNode.addChildNode(shelf); shelf.scale.y = 0.65
            box(1,1.55,0.15,at: SCNVector3(0,0.78,0),color: navy,parent: shelf)
            for y in [Float]([0.12,0.55,0.98,1.41]) { box(1.05,0.07,3.4,at: SCNVector3(0,y,0),color: UIColor(red: 0.38,green: 0.29,blue: 0.30,alpha: 1),parent: shelf) }
            for row in 0..<3 { for side in [Float]([-1,1]) { for slot in 0..<12 {
                let colors: [UIColor] = [mint,coral,.systemYellow,.systemCyan,.systemPurple,.systemPink]
                let tape = box(0.12,0.32,0.20,at: SCNVector3(side * 0.39,Float(row) * 0.43 + 0.34,Float(slot) * 0.25 - 1.38),color: colors[(row + slot + index) % colors.count],parent: shelf,bevel: 0.008)
                box(0.125,0.07,0.205,at: SCNVector3(0,-0.08,0),color: navy,parent: tape,bevel: 0.002)
            } } }
            for slot in 0..<10 {
                let colors: [UIColor] = [mint,coral,.systemYellow,.systemCyan,.systemPurple]
                let cover = box(0.70,0.055,0.24,at: SCNVector3(0,1.49,Float(slot) * 0.30 - 1.35),color: colors[(slot + index) % colors.count],parent: shelf)
                box(0.38,0.008,0.045,at: SCNVector3(0,0.032,0),color: .white,parent: cover,bevel: 0)
            }
            label(index == 0 ? "CLASSICS" : "NEW",at: SCNVector3(0,1.9,1.6),width: 1.3,color: .systemYellow,parent: shelf,billboard: true,name: "station:SHELVES")
        }
        let counter = box(3,1.05,1.1,at: SCNVector3(3,0.525,-3.8),color: coral,name: "station:COUNTER")
        box(3.15,0.08,1.22,at: SCNVector3(0,0.56,0),color: navy,parent: counter)
        box(0.6,0.12,0.4,at: SCNVector3(-0.35,0.67,0),color: .darkGray,parent: counter)
        box(0.45,0.32,0.1,at: SCNVector3(-0.35,0.87,-0.1),color: navy,parent: counter)
        label("$4 / TWO NIGHTS",at: SCNVector3(0,0,0.56),width: 2.0,color: .white,parent: counter,name: "station:COUNTER")
        label("COUNTER",at: SCNVector3(3,1.95,-3.8),width: 1.7,color: mint,billboard: true,name: "station:COUNTER")
        let returns = box(1,0.85,0.8,at: SCNVector3(-4,0.425,4.6),color: mint,name: "station:RETURNS")
        box(0.65,0.10,0.12,at: SCNVector3(0,0.2,0.41),color: navy,parent: returns)
        label("RETURNS",at: SCNVector3(-4,1.4,4.6),width: 1.9,color: mint,billboard: true,name: "station:RETURNS")
        box(0.68,0.15,0.5,at: SCNVector3(-4,0.96,4.6),color: navy,name: "station:RETURNS")
        for x in [Float]([-4.2,-3.8]) { let reel = SCNTorus(ringRadius: 0.10, pipeRadius: 0.022); reel.materials = [material(.systemGray)]; let n = SCNNode(geometry: reel); n.position = SCNVector3(x,1.05,4.6); scene.rootNode.addChildNode(n) }
        box(1.5,0.8,0.7,at: SCNVector3(4.3,0.4,-5.3),color: purple,name: "station:STORE PC")
        let crt = box(0.65,0.50,0.48,at: SCNVector3(4.3,1.1,-5.3),color: .lightGray,name: "station:STORE PC")
        box(0.5,0.35,0.015,at: SCNVector3(0,0,0.25),color: navy,parent: crt)
        label("OWL OS 94",at: SCNVector3(0,0,0.27),width: 0.43,color: mint,parent: crt)
        label("STORE PC",at: SCNVector3(4.3,1.75,-5.3),width: 1.9,color: mint,billboard: true,name: "station:STORE PC")
        box(1.5,1.1,0.12,at: SCNVector3(-4.5,1.5,-4.9),color: UIColor(red: 0.47,green: 0.32,blue: 0.20,alpha: 1),name: "station:STORY")
        label("MAPLE STREET",at: SCNVector3(-4.5,1.7,-4.8),width: 1.4,color: .systemYellow,name: "station:STORY")
        label("OUR MOVIE NIGHT",at: SCNVector3(-4.5,1.3,-4.8),width: 1.4,color: .white,name: "station:STORY")
        let snacks = box(1,1.7,0.9,at: SCNVector3(4.6,0.85,2.5),color: .systemYellow,name: "station:STORE PC")
        box(0.8,0.75,0.05,at: SCNVector3(0,0.2,0.48),color: navy,parent: snacks)
        label("POPCORN",at: SCNVector3(4.6,1.95,2.5),width: 1.8,color: .systemYellow,billboard: true,name: "station:STORE PC")

    }
    private func person(_ index: Int) -> SCNNode {
        let root = SCNNode(); let v = index % 6
        let dark = UIColor(red: 0.08,green: 0.09,blue: 0.16,alpha: 1)
        let skins = [UIColor(red: 0.89,green: 0.68,blue: 0.49,alpha: 1),UIColor(red: 0.64,green: 0.41,blue: 0.28,alpha: 1),UIColor(red: 0.95,green: 0.74,blue: 0.63,alpha: 1)]
        let skin = skins[v % 3]
        let colors: [UIColor] = [.systemTeal,.systemOrange,.systemYellow,.systemBlue,.systemPink,.systemPurple,.systemTeal,.systemOrange,.systemGreen,.systemPurple,.systemBlue,.systemBrown]
        let coat = colors[index % colors.count].withAlphaComponent(1)
        let hair = v == 5 ? UIColor.gray : (v == 2 ? UIColor.brown : dark)
        for x in [Float]([-0.105,0.105]) {
            box(0.15,0.60,0.19,at: SCNVector3(x,0.37,0),color: UIColor(red: 0.17,green: 0.23,blue: 0.30,alpha: 1),parent: root)
            box(0.18,0.10,0.31,at: SCNVector3(x,0.06,0.045),color: dark,parent: root)
        }
        let torso = box(0.44,0.53,0.25,at: SCNVector3(0,0.94,0),color: coat,parent: root,bevel: 0.05)
        box(0.13,0.14,0.12,at: SCNVector3(0,1.255,0),color: skin,parent: root)
        for x in [Float]([-0.29,0.29]) {
            box(0.12,0.48,0.15,at: SCNVector3(x,0.94,0),color: coat,parent: root,bevel: 0.05)
            ball(0.065,at: SCNVector3(x,0.65,0.01),color: skin,scale: SCNVector3(0.8,1.2,0.75),parent: root)
        }
        ball(0.17,at: SCNVector3(0,1.47,0),color: skin,scale: SCNVector3(1,1.05,0.9),parent: root)
        for x in [Float]([-0.16,0.16]) { ball(0.04,at: SCNVector3(x,1.47,0),color: skin,scale: SCNVector3(0.6,1,0.6),parent: root) }
        if index != 8 {
            ball(0.17,at: SCNVector3(0,1.56,-0.025),color: hair,scale: SCNVector3(1.04,0.72,0.94),parent: root)
            if [2,4,6,10,11].contains(index) { ball(0.17,at: SCNVector3(0,1.46,-0.13),color: hair,scale: SCNVector3(1.04,1.10,0.55),parent: root) }
            if index == 6 || index == 11 { ball(0.085,at: SCNVector3(0.13,1.6,-0.15),color: hair,parent: root) }
        }
        if index == 0 || index == 3 || index == 9 { box(0.23,0.095,0.05,at: SCNVector3(0,1.36,0.125),color: hair,parent: root,bevel: 0.025) }
        let eyes = SCNNode(); root.addChildNode(eyes)
        for x in [Float]([-0.065,0.065]) {
            ball(0.043,at: SCNVector3(x,1.50,0.139),color: .white,scale: SCNVector3(1,0.72,0.35),parent: eyes)
            ball(0.020,at: SCNVector3(x,1.50,0.163),color: dark,scale: SCNVector3(0.8,1,0.4),parent: eyes)
            box(0.075,0.012,0.008,at: SCNVector3(x,1.55,0.14),color: hair,parent: root,bevel: 0.003)
        }
        ball(0.026,at: SCNVector3(0,1.445,0.15),color: skin,scale: SCNVector3(0.7,1.1,1),parent: root)
        box(0.085,0.008,0.012,at: SCNVector3(0,1.39,0.146),color: dark,parent: root,bevel: 0.004)
        if [1,5,7,11].contains(index) {
            for x in [Float]([-0.065,0.065]) { let g = SCNTorus(ringRadius: 0.047,pipeRadius: 0.006); g.materials = [material(dark)]; let n = SCNNode(geometry: g); n.position = SCNVector3(x,1.5,0.164); n.eulerAngles.x = .pi / 2; root.addChildNode(n) }
            box(0.04,0.008,0.008,at: SCNVector3(0,1.5,0.164),color: dark,parent: root)
        }
        if index == 7 { box(0.29,0.40,0.025,at: SCNVector3(0,0.91,0.14),color: .init(red: 0.91,green: 0.86,blue: 0.72,alpha: 1),parent: root) }
        if index == 6 { box(0.08,0.11,0.025,at: SCNVector3(0.12,1.05,0.14),color: .white,parent: root) }
        if index == 8 || index == 10 { box(0.43,0.07,0.28,at: SCNVector3(0,0.72,0),color: .brown,parent: root) }
        if index == 9 { for x in [Float]([-0.175,0.175]) { box(0.055,0.13,0.12,at: SCNVector3(x,1.49,0),color: dark,parent: root,bevel: 0.025) } }
        if !reduceMotion {
            torso.runAction(.repeatForever(.sequence([.scale(by: 1.015,duration: 1.1),.scale(by: 1 / 1.015,duration: 1.1)])),forKey: "breathe")
            eyes.runAction(.repeatForever(.sequence([.wait(duration: 2.5 + Double(index % 4) * 0.4),.fadeOut(duration: 0.07),.wait(duration: 0.08),.fadeIn(duration: 0.07)])),forKey: "blink")
        }
        let head = SCNNode(); head.position.y = 1.03
        for node in Array(root.childNodes) {
            let isFace = node === eyes || node.position.y >= 1.23
            if isFace {
                node.removeFromParentNode()
                if node === eyes { node.position.y = -1.47 * 1.6 }
                else { node.position = SCNVector3(node.position.x * 1.6,(node.position.y - 1.47) * 1.6,node.position.z * 1.6) }
                node.scale = SCNVector3(node.scale.x * 1.6,node.scale.y * 1.6,node.scale.z * 1.6)
                head.addChildNode(node)
            } else {
                node.position = SCNVector3(node.position.x * 0.8,node.position.y * 0.63,node.position.z * 0.8)
                node.scale = SCNVector3(node.scale.x * 0.8,node.scale.y * 0.63,node.scale.z * 0.8)
            }
        }
        root.addChildNode(head)
        return root
    }
    func sync(_ guests: [Guest], staff: Bool) {
        let current = Set(guests.map { $0.id })
        for id in Array(people.keys) where !current.contains(id) {
            guard let n = people.removeValue(forKey: id) else { continue }
            n.runAction(.sequence([.move(to: SCNVector3(-1.2,0,6),duration: reduceMotion ? 0 : 1.3),.removeFromParentNode()]))
        }
        for (index,guest) in guests.enumerated() {
            let target = SCNVector3(2.8,0,-2.4 + Float(index) * 1.05)
            if let n = people[guest.id] { if abs(n.position.z - target.z) > 0.01 { n.runAction(.move(to: target,duration: reduceMotion ? 0 : 0.65),forKey: "queue") } }
            else {
                let n = person(guest.characterIndex); n.name = "customer"; n.position = preview ? target : SCNVector3(-1.2,0,5.8); n.eulerAngles.y = .pi
                scene.rootNode.addChildNode(n); people[guest.id] = n
                n.runAction(.move(to: target,duration: reduceMotion || preview ? 0 : 2.3),forKey: "queue")
            }
        }
        if staff && scene.rootNode.childNode(withName: "bea-employee",recursively: false) == nil {
            let bea = person(2); bea.name = "bea-employee"; bea.position = SCNVector3(2.3,0,-5); scene.rootNode.addChildNode(bea)
        }
    }
    func attach(_ view: SCNView) {
        surface = view
        if !preview { view.addGestureRecognizer(UITapGestureRecognizer(target: self,action: #selector(tapped(_:)))) }
    }
    func start() { guard displayLink == nil, !preview else { return }; let link = CADisplayLink(target: self,selector: #selector(step(_:))); link.preferredFramesPerSecond = 30; link.add(to: .main,forMode: .common); displayLink = link; lastTime = 0 }
    func stop() { movement = .zero; route = []; pendingStation = nil; displayLink?.invalidate(); displayLink = nil; lastTime = 0 }
    func interact() { guard let station = nearby else { hint = "Walk closer to a labeled station"; return }; movement = .zero; route = []; pendingStation = nil; onInteract?(station.code) }
    func resetView() { route = []; pendingStation = nil; movement = .zero; updateCamera(immediate: true) }
    @objc private func tapped(_ tap: UITapGestureRecognizer) {
        guard let view = surface else { return }
        let hits = view.hitTest(tap.location(in: view),options: [.searchMode: SCNHitTestSearchMode.all.rawValue])
        for hit in hits {
            var node: SCNNode? = hit.node
            while let n = node {
                if let name = n.name, name.hasPrefix("station:") {
                    let code = String(name.dropFirst(8))
                    guard let station = stations.filter({ $0.code == code }).min(by: { distance($0) < distance($1) }) else { return }
                    if distance(station) < 2.4 { movement = .zero; route = []; pendingStation = nil; onInteract?(code) }
                    else { walk(to: FloorPoint(x: station.x,z: station.z),station: code) }
                    return
                }
                node = n.parent
            }
        }
        if let hit = hits.first(where: { $0.node.name == "floor" }) { walk(to: FloorPoint(x: hit.worldCoordinates.x,z: hit.worldCoordinates.z),station: nil) }
    }
    private func walk(to target: FloorPoint,station: String?) {
        let blockers = people.values.map { FloorBlock(x: $0.presentation.position.x,z: $0.presentation.position.z,width: 0.4,depth: 0.3) }
        route = WorldLayout.path(from: FloorPoint(x: player.position.x,z: player.position.z),to: target,extra: blockers)
        pendingStation = station; hint = station == nil ? "Walking to that tileâ€¦" : "Walking to the stationâ€¦"
    }
    private func distance(_ s: ShopStation) -> Float { hypot(player.position.x - s.x,player.position.z - s.z) }
    @objc private func step(_ link: CADisplayLink) {
        let dt = lastTime == 0 ? Float(1.0 / 30.0) : Float(link.timestamp - lastTime); lastTime = link.timestamp
        let old = FloorPoint(x: player.position.x,z: player.position.z)
        let blockers = people.values.map { FloorBlock(x: $0.presentation.position.x,z: $0.presentation.position.z,width: 0.4,depth: 0.3) }
        var direction = movement
        if abs(movement.x) + abs(movement.y) > 0.05 { route = []; pendingStation = nil }
        else if let next = route.first {
            let x = next.x - old.x; let z = next.z - old.z; let d = hypot(x,z)
            if d < 0.09 { route.removeFirst() } else { direction = SIMD2(x / d,z / d) }
        }
        let result = WorldLayout.move(from: old,side: direction.x,forward: -direction.y,yaw: 0,seconds: dt,extra: blockers)
        player.position.x = result.x; player.position.z = result.z
        if hypot(result.x - old.x,result.z - old.z) > 0.001 {
            player.eulerAngles.y = atan2(direction.x,direction.y)
            if !reduceMotion { player.position.y = Float(abs(sin(link.timestamp * 9))) * 0.035 }
        } else {
            player.position.y = 0
            if !route.isEmpty && abs(direction.x) + abs(direction.y) > 0.1 { route = []; pendingStation = nil; hint = "Path blocked. Tap another tile or use the stick." }
        }
        updateCamera()
        for node in people.values {
            let dx = player.position.x - node.position.x; let dz = player.position.z - node.position.z
            if hypot(dx,dz) < 2.5 { node.eulerAngles.y = atan2(dx,dz) }
        }
        focusFrame += 1
        if focusFrame % 5 == 0 {
            let closest = stations.min { distance($0) < distance($1) }
            let next = closest.flatMap { distance($0) < 2.4 ? $0 : nil }
            if nearby != next { nearby = next; if route.isEmpty { hint = next == nil ? "Tap a floor tile or a station to walk there" : "Tap USE to open this station" } }
            if route.isEmpty, let code = pendingStation { pendingStation = nil; if stations.contains(where: { $0.code == code && distance($0) < 2.4 }) { onInteract?(code) } }
        }
    }
}

struct StoreSceneView: UIViewRepresentable {
    let world: ShopWorld
    var running = true
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView(); view.scene = world.scene; view.pointOfView = world.camera; view.backgroundColor = .black
        view.preferredFramesPerSecond = 30; view.antialiasingMode = .multisampling2X; view.autoenablesDefaultLighting = false; view.isPlaying = running
        view.accessibilityLabel = "Overhead 3D shop. Tap the floor to move your chibi character. Tap a station to walk over and use it."
        world.attach(view); return view
    }
    func updateUIView(_ uiView: SCNView,context: Context) { uiView.pointOfView = world.camera; uiView.isPlaying = running }
}
