import UIKit
import AVFoundation

/// 使用ShazamManager封装类的ViewController示例
class ViewControllerWithShazamManager: UIViewController {

    // MARK: - 属性
    private let shazamManager = ShazamManager()
    private var isRecognizing = false

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
        setupShazamManager()
        setupUI()
    }

    // MARK: - 设置
    private func setupShazamManager() {
        shazamManager.onMatchFound = { [weak self] result in
            self?.handleMatchFound(result)
        }
        shazamManager.onMatchNotFound = { [weak self] error in
            self?.clearMusicInfo()
            print("未识别到音乐")
        }
        shazamManager.onStateChanged = { [weak self] state in
            switch state {
            case .idle:
                print("识别状态：空闲")
            case .listening:
                print("识别状态：监听中")
            case .recognizing:
                print("识别状态：识别中")
            case .error(let message):
                print("识别错误：\(message)")
                self?.showAlert(title: "识别错误", message: message)
            }
        }
        shazamManager.onError = { [weak self] error in
            self?.showAlert(title: "错误", message: error.localizedDescription)
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
            shazamManager.stopRecognition()
            stopRippleAnimation()
            actionButton.setTitle("开始识别", for: .normal)
        } else {
            shazamManager.startRecognition()
            startRippleAnimation()
            actionButton.setTitle("停止识别", for: .normal)
        }
        isRecognizing.toggle()
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

    // MARK: - 处理识别结果
    private func handleMatchFound(_ result: MusicRecognitionResult) {
        titleLabel.text = "歌名：\(result.title ?? "-")"
        artistLabel.text = "歌手: \(result.artist ?? "-")"
        albumLabel.text = "专辑：\(result.album ?? "-")"
        genreLabel.text = "风格：\(result.genres.joined(separator: ", "))"
        
        if let releaseDate = result.releaseDate {
            releaseDateLabel.text = "发行时间：" + shazamManager.formatReleaseDate(releaseDate)
        } else {
            releaseDateLabel.text = "发行时间：-"
        }
        
        // 加载专辑封面
        if let artworkURL = result.artworkURL {
            shazamManager.loadArtworkImage(from: artworkURL) { [weak self] image in
                self?.albumImageView.image = image
            }
        } else {
            albumImageView.image = nil
        }
        
        // 显示链接按钮
        webURLButton.isHidden = result.webURL == nil
        webURLButton.accessibilityHint = result.webURL?.absoluteString
        
        appleMusicURLButton.isHidden = result.appleMusicURL == nil
        appleMusicURLButton.accessibilityHint = result.appleMusicURL?.absoluteString
        
        videoURLButton.isHidden = result.videoURL == nil
        videoURLButton.accessibilityHint = result.videoURL?.absoluteString
    }

    // MARK: - 辅助方法
    private func clearMusicInfo() {
        titleLabel.text = "-"
        artistLabel.text = "-"
        albumLabel.text = "-"
        genreLabel.text = "-"
        releaseDateLabel.text = "-"
        albumImageView.image = nil
        webURLButton.isHidden = true
        appleMusicURLButton.isHidden = true
        videoURLButton.isHidden = true
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }

    // MARK: - URL 跳转
    @objc func openWebURL() {
        if let urlString = webURLButton.accessibilityHint, let url = URL(string: urlString) {
            shazamManager.openMusicURL(url)
        }
    }
    
    @objc func openAppleMusicURL() {
        if let urlString = appleMusicURLButton.accessibilityHint, let url = URL(string: urlString) {
            shazamManager.openMusicURL(url)
        }
    }
    
    @objc func openVideoURL() {
        if let urlString = videoURLButton.accessibilityHint, let url = URL(string: urlString) {
            shazamManager.openMusicURL(url)
        }
    }
} 