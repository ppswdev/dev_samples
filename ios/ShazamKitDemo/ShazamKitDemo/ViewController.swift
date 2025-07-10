import UIKit
import ShazamKit
import AVFoundation

/// 流式实时识别
class ViewController: UIViewController, SHSessionDelegate {

    let audioEngine = AVAudioEngine()
    let session = SHSession()
    var isRecognizing = false

    // 水波纹动画层
    var rippleLayer: CAShapeLayer?
    // 开始/停止按钮
    let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("开始识别", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        btn.backgroundColor = UIColor.systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // 歌曲信息UI
    let albumImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = UIColor(white: 0.2, alpha: 1)
        return iv
    }()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let artistLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let albumLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let genreLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let webURLButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("网页地址", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isHidden = true
        return btn
    }()
    let appleMusicURLButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Apple Music", for: .normal)
        btn.setTitleColor(.systemPink, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isHidden = true
        return btn
    }()
    let videoURLButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("MV/视频", for: .normal)
        btn.setTitleColor(.systemRed, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isHidden = true
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioSession()
        session.delegate = self
        setupUI()
    }

    func setupAudioSession() {
        /*
        支持后台识别
        <key>UIBackgroundModes</key>
        <array>
            <string>audio</string>
        </array>
        */
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
        } catch {
            print("音频会话配置失败: \(error)")
        }
    }

    func setupUI() {
        view.backgroundColor = .black
        view.addSubview(albumImageView)
        view.addSubview(titleLabel)
        view.addSubview(artistLabel)
        view.addSubview(albumLabel)
        view.addSubview(genreLabel)
        view.addSubview(releaseDateLabel)
        view.addSubview(webURLButton)
        view.addSubview(appleMusicURLButton)
        view.addSubview(videoURLButton)
        view.addSubview(actionButton)
        NSLayoutConstraint.activate([
            albumImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            albumImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            albumImageView.widthAnchor.constraint(equalToConstant: 180),
            albumImageView.heightAnchor.constraint(equalToConstant: 180),
            titleLabel.topAnchor.constraint(equalTo: albumImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            artistLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            artistLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            albumLabel.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 8),
            albumLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            albumLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            genreLabel.topAnchor.constraint(equalTo: albumLabel.bottomAnchor, constant: 8),
            genreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            genreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            releaseDateLabel.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 8),
            releaseDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            releaseDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            webURLButton.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 12),
            webURLButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleMusicURLButton.topAnchor.constraint(equalTo: webURLButton.bottomAnchor, constant: 8),
            appleMusicURLButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            videoURLButton.topAnchor.constraint(equalTo: appleMusicURLButton.bottomAnchor, constant: 8),
            videoURLButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            actionButton.widthAnchor.constraint(equalToConstant: 180),
            actionButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        actionButton.addTarget(self, action: #selector(toggleRecognition), for: .touchUpInside)
        webURLButton.addTarget(self, action: #selector(openWebURL), for: .touchUpInside)
        appleMusicURLButton.addTarget(self, action: #selector(openAppleMusicURL), for: .touchUpInside)
        videoURLButton.addTarget(self, action: #selector(openVideoURL), for: .touchUpInside)
    }

    @objc func toggleRecognition() {
        if isRecognizing {
            stopListening()
            stopRippleAnimation()
            actionButton.setTitle("开始识别", for: .normal)
        } else {
            startListening()
            startRippleAnimation()
            actionButton.setTitle("停止识别", for: .normal)
        }
        isRecognizing.toggle()
    }

    func startListening() {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, time in
            self.session.matchStreamingBuffer(buffer, at: nil)
        }
        audioEngine.prepare()
        try? audioEngine.start()
    }

    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }

    // MARK: - 水波纹动画
    func startRippleAnimation() {
        if rippleLayer != nil { return }
        let layer = CAShapeLayer()
        let center = view.center
        let initialRadius: CGFloat = 60
        let finalRadius: CGFloat = max(view.bounds.width, view.bounds.height)
        let path = UIBezierPath(arcCenter: center, radius: initialRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        layer.path = path.cgPath
        layer.fillColor = UIColor.systemBlue.withAlphaComponent(0.2).cgColor
        view.layer.insertSublayer(layer, below: actionButton.layer)
        rippleLayer = layer

        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = path.cgPath
        let finalPath = UIBezierPath(arcCenter: center, radius: finalRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        animation.toValue = finalPath.cgPath
        animation.duration = 1.2
        animation.repeatCount = .infinity
        animation.autoreverses = true
        layer.add(animation, forKey: "ripple")
    }

    func stopRippleAnimation() {
        rippleLayer?.removeAllAnimations()
        rippleLayer?.removeFromSuperlayer()
        rippleLayer = nil
    }

    // MARK: - SHSessionDelegate
    func session(_ session: SHSession, didFind match: SHMatch) {
        guard let mediaItem = match.mediaItems.first else { return }
        DispatchQueue.main.async {
            self.titleLabel.text = "歌名：\(mediaItem.title ?? "-")"
            self.artistLabel.text = "歌手: \(mediaItem.artist ?? "-")"
            if let albumName = mediaItem[SHMediaItemProperty(rawValue: "sh_albumName")] as? String {
                self.albumLabel.text = "专辑：\(albumName)"
            }else{
                self.albumLabel.text = "专辑：-"
            }
           
            self.genreLabel.text = "风格：\(mediaItem.genres)"
            if let releaseDate =  mediaItem[SHMediaItemProperty(rawValue: "sh_releaseDate")] as? Date {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                self.releaseDateLabel.text = "发行时间：" + formatter.string(from: releaseDate)
            } else {
                self.releaseDateLabel.text = "发行时间：-"
            }
            if let artworkURL = mediaItem.artworkURL {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: artworkURL), let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.albumImageView.image = image
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.albumImageView.image = nil
                        }
                    }
                }
            } else {
                self.albumImageView.image = nil
            }
            // 网页地址
            if let webURL = mediaItem.webURL {
                self.webURLButton.isHidden = false
                self.webURLButton.accessibilityHint = webURL.absoluteString
            } else {
                self.webURLButton.isHidden = true
            }
            // Apple Music
            if let appleMusicURL = mediaItem.appleMusicURL {
                self.appleMusicURLButton.isHidden = false
                self.appleMusicURLButton.accessibilityHint = appleMusicURL.absoluteString
            } else {
                self.appleMusicURLButton.isHidden = true
            }
            // 视频
            if let videoURL = mediaItem.videoURL {
                self.videoURLButton.isHidden = false
                self.videoURLButton.accessibilityHint = videoURL.absoluteString
            } else {
                self.videoURLButton.isHidden = true
            }
        }
    }

    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        DispatchQueue.main.async {
            self.titleLabel.text = "-"
            self.artistLabel.text = "-"
            self.albumLabel.text = "-"
            self.genreLabel.text = "-"
            self.releaseDateLabel.text = "-"
            self.albumImageView.image = nil
            self.webURLButton.isHidden = true
            self.appleMusicURLButton.isHidden = true
            self.videoURLButton.isHidden = true
        }
        print("未识别到音乐")
    }

    // MARK: - URL 跳转
    @objc func openWebURL() {
        if let urlString = webURLButton.accessibilityHint, let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    @objc func openAppleMusicURL() {
        if let urlString = appleMusicURLButton.accessibilityHint, let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    @objc func openVideoURL() {
        if let urlString = videoURLButton.accessibilityHint, let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
