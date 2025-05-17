import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    
    private var backgroundPlayer: AVAudioPlayer?
    private var effectPlayer: AVAudioPlayer?
    
    private init() {}

    // MARK: - Background Music

    func playMusic(named name: String, loop: Bool = true) {
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
            print("⚠️ Music file not found: \(name)")
            return
        }
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.numberOfLoops = loop ? -1 : 0
            backgroundPlayer?.volume = 0.5
            backgroundPlayer?.prepareToPlay()
            backgroundPlayer?.play()
        } catch {
            print("❌ Error playing music: \(error)")
        }
    }
    
    func stopMusic() {
        backgroundPlayer?.stop()
        backgroundPlayer = nil
    }

    // MARK: - Sound Effects

    func playEffect(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
            print("⚠️ Effect file not found: \(name)")
            return
        }
        do {
            effectPlayer = try AVAudioPlayer(contentsOf: url)
            effectPlayer?.volume = 1.0
            effectPlayer?.play()
        } catch {
            print("❌ Error playing sound effect: \(error)")
        }
    }
}
