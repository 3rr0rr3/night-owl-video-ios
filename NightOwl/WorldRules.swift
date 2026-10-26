import Foundation

struct FloorPoint: Equatable {
    var x: Float
    var z: Float
}
struct FloorBlock {
    let x: Float
    let z: Float
    let width: Float
    let depth: Float
    func contains(_ point: FloorPoint, radius: Float = 0.24) -> Bool {
        abs(point.x - x) < width / 2 + radius && abs(point.z - z) < depth / 2 + radius
    }
}
enum WorldLayout {
    static let blocks = [
        FloorBlock(x: -2.5, z: -1.1, width: 1, depth: 3.4),
        FloorBlock(x: 0, z: -1.1, width: 1, depth: 3.4),
        FloorBlock(x: 3, z: -3.8, width: 3, depth: 1.1),
        FloorBlock(x: 4.3, z: -5.3, width: 1.5, depth: 0.7),
        FloorBlock(x: -4, z: 4.6, width: 1, depth: 0.8),
        FloorBlock(x: 4.6, z: 2.5, width: 1, depth: 0.9)
    ]
    static let spawn = FloorPoint(x: -1.2, z: 4.7)
    static func move(from point: FloorPoint, side: Float, forward: Float, yaw: Float, seconds: Float, extra: [FloorBlock] = []) -> FloorPoint {
        let length = max(1, sqrt(side * side + forward * forward))
        let stride = min(max(seconds, 0), 0.1) * 2.2
        let dx = (cos(yaw) * side - sin(yaw) * forward) / length * stride
        let dz = (-sin(yaw) * side - cos(yaw) * forward) / length * stride
        let obstacles = blocks + extra
        var result = point
        let xStep = FloorPoint(x: min(5.15, max(-5.15, point.x + dx)), z: point.z)
        if !obstacles.contains(where: { $0.contains(xStep) }) { result.x = xStep.x }
        let zStep = FloorPoint(x: result.x, z: min(6.15, max(-6.15, point.z + dz)))
        if !obstacles.contains(where: { $0.contains(zStep) }) { result.z = zStep.z }
        return result
    }
    private struct Tile: Hashable { let x: Int; let z: Int }
    static func path(from start: FloorPoint,to goal: FloorPoint,extra: [FloorBlock] = []) -> [FloorPoint] {
        let obstacles = blocks + extra
        func point(_ tile: Tile) -> FloorPoint { FloorPoint(x: Float(tile.x) * 0.5,z: Float(tile.z) * 0.5) }
        func free(_ tile: Tile) -> Bool { abs(tile.x) <= 10 && abs(tile.z) <= 12 && !obstacles.contains { $0.contains(point(tile)) } }
        func squared(_ a: FloorPoint,_ b: FloorPoint) -> Float { let x = a.x - b.x; let z = a.z - b.z; return x * x + z * z }
        let tiles = (-10...10).flatMap { x in (-12...12).map { Tile(x: x,z: $0) } }.filter(free)
        guard let first = tiles.min(by: { squared(point($0),start) < squared(point($1),start) }) else { return [] }
        var queue = [first]; var visited: Set<Tile> = [first]; var parents: [Tile: Tile] = [:]; var head = 0
        while head < queue.count {
            let tile = queue[head]; head += 1
            for next in [Tile(x: tile.x,z: tile.z - 1),Tile(x: tile.x + 1,z: tile.z),Tile(x: tile.x,z: tile.z + 1),Tile(x: tile.x - 1,z: tile.z)] {
                if free(next) && visited.insert(next).inserted { parents[next] = tile; queue.append(next) }
            }
        }
        guard var current = queue.min(by: { squared(point($0),goal) < squared(point($1),goal) }) else { return [] }
        var result = [point(current)]
        while let parent = parents[current] { result.append(point(parent)); current = parent }
        return Array(result.reversed())
    }

}
