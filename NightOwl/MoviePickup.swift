import Foundation

struct MoviePickup: Identifiable {
    let id = UUID()
    let guestID: UUID
    let movie: Int
}
enum ClerkPickupStage { case waiting, toShelf, collecting, returning }
enum ClerkPickupMotion {
    static let walkDuration = 1.3
    static let collectDuration = 0.5
    static func progress(_ time: Double) -> Double { min(1,max(0,time / walkDuration)) }
    static func depth(stage: ClerkPickupStage,time: Double) -> Double {
        switch stage {
        case .toShelf: return progress(time)
        case .collecting: return 1
        case .returning: return 1 - progress(time)
        case .waiting: return 0
        }
    }
}
extension Store {
    func restorePendingPickup() {
        if let guest = s.guests.first, let movie = guest.movie, !guest.scanned { moviePickup = MoviePickup(guestID:guest.id,movie:movie) }
        else { moviePickup = nil }
    }
    func finishPickup(_ request: MoviePickup) {
        guard moviePickup?.id == request.id else { return }
        moviePickup = nil
    }
}
