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
}
