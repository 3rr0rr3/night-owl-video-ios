import AVFoundation

@MainActor final class ShopAudio {
    static let shared = ShopAudio()
    private var effect: AVAudioPlayer?
    private var music: AVAudioPlayer?
    private var rainy = false
    private func wave(seconds: Double, sample: (Double) -> Double) -> Data {
        let rate = 22050; let count = Int(seconds * Double(rate))
        var pcm = Data(capacity: count * 2)
        for n in 0..<count { var value = Int16(max(-1,min(1,sample(Double(n) / Double(rate)))) * 16000).littleEndian; withUnsafeBytes(of: &value) { pcm.append(contentsOf: $0) } }
        var data = Data("RIFF".utf8)
        func u32(_ n: Int) { var v = UInt32(n).littleEndian; withUnsafeBytes(of: &v) { data.append(contentsOf: $0) } }
        func u16(_ n: Int) { var v = UInt16(n).littleEndian; withUnsafeBytes(of: &v) { data.append(contentsOf: $0) } }
        u32(36 + pcm.count); data.append(Data("WAVEfmt ".utf8)); u32(16); u16(1); u16(1); u32(rate); u32(rate * 2); u16(2); u16(16); data.append(Data("data".utf8)); u32(pcm.count); data.append(pcm)
        return data
    }
    func cue(_ name: String) {
        try? AVAudioSession.sharedInstance().setCategory(.ambient,options: .mixWithOthers)
        let duration = name == "rewind" ? 0.65 : 0.3
        let data = wave(seconds: duration) { t in
            let envelope = max(0,1 - t / duration)
            switch name {
            case "scan": return sin(t * 2 * .pi * 1480) * envelope * 0.3
            case "cash": return (sin(t * 2 * .pi * 880) + sin(t * 2 * .pi * 1320)) * envelope * 0.2
            case "rewind": return sin(t * 2 * .pi * (160 + t * 100)) * sin(t * 80) * envelope * 0.2
            default: return sin(t * 2 * .pi * 440) * envelope * 0.15
            }
        }
        effect = try? AVAudioPlayer(data: data); effect?.volume = 0.45; effect?.play()
    }
    func ambience(enabled: Bool,rain: Bool) {
        guard enabled else { music?.stop(); music = nil; return }
        if music?.isPlaying == true && rainy == rain { return }
        rainy = rain
        try? AVAudioSession.sharedInstance().setCategory(.ambient,options: .mixWithOthers)
        let melody: [Double] = [261.63,329.63,392,523.25,440,392,329.63,293.66,261.63,392,440,523.25,493.88,392,329.63,293.66]
        var seed: UInt32 = 34191
        let data = wave(seconds: 8) { t in
            let phase = t.truncatingRemainder(dividingBy: 0.5)
            let frequency = melody[min(15,Int(t * 2))]
            let note = sin(2 * .pi * frequency * phase) * exp(-phase * 8) * 0.16
            seed = 1664525 &* seed &+ 1013904223
            let noise = (Double(seed % 65536) / 32768 - 1) * (rain ? 0.07 : 0)
            return note + noise
        }
        music = try? AVAudioPlayer(data: data); music?.numberOfLoops = -1; music?.volume = 0.28; music?.play()
    }
    func stop() { effect?.stop(); music?.stop(); music = nil }
    func validate() -> Bool {
        let data = wave(seconds: 0.1) { t in sin(t * 880 * .pi) * 0.1 }
        return (try? AVAudioPlayer(data: data)) != nil
    }
}
