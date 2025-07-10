import UIKit
import ShazamKit
import AVFoundation

/// 分段采集识别
class ViewController2: UIViewController, SHSessionDelegate {
    var audioEngine = AVAudioEngine()
    var session = SHSession()
    var matcher = SHSignatureGenerator()

    let titleLabel = UILabel()
    let artistLabel = UILabel()
    let albumImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupUI()
        session.delegate = self
        startListening()
    }

    func setupUI() {
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        artistLabel.font = .systemFont(ofSize: 16)
        artistLabel.textAlignment = .center
        artistLabel.translatesAutoresizingMaskIntoConstraints = false

        albumImageView.contentMode = .scaleAspectFit
        albumImageView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(artistLabel)
        view.addSubview(albumImageView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            artistLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            artistLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            albumImageView.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 30),
            albumImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            albumImageView.widthAnchor.constraint(equalToConstant: 200),
            albumImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    func startListening() {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            (buffer, _) in
            do {
                try self.matcher.append(buffer, at: nil)
            } catch {
                print("❌ Append error: \(error)")
            }

            if let signature = try? self.matcher.signature() {
                self.session.match(signature)
            }
        }

        do {
            try audioEngine.start()
            print("🎧 Listening...")
        } catch {
            print("❌ Audio engine error: \(error)")
        }
    }

    func session(_ session: SHSession, didFind match: SHMatch) {
        guard let item = match.mediaItems.first else { return }
        DispatchQueue.main.async {
            self.titleLabel.text = "🎵 \(item.title ?? "Unknown")"
            self.artistLabel.text = "🎤 \(item.artist ?? "Unknown")"
            if let url = item.artworkURL, let data = try? Data(contentsOf: url) {
                self.albumImageView.image = UIImage(data: data)
            }
            self.audioEngine.stop()
            self.audioEngine.inputNode.removeTap(onBus: 0)
        }
    }

    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        print("⚠️ No match found")
    }
}
