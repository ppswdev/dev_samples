import UIKit

/// ShazamManager 使用示例
class ShazamUsageExample: UIViewController, ShazamManagerDelegate {
    
    // MARK: - 属性
    private let shazamManager = ShazamManager()
    private let statusLabel = UILabel()
    private let resultTextView = UITextView()
    private let startButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupShazamManager()
    }
    
    // MARK: - 设置
    private func setupShazamManager() {
        shazamManager.delegate = self
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 状态标签
        statusLabel.text = "准备就绪"
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        // 结果文本视图
        resultTextView.isEditable = false
        resultTextView.font = UIFont.systemFont(ofSize: 14)
        resultTextView.layer.borderColor = UIColor.systemGray4.cgColor
        resultTextView.layer.borderWidth = 1
        resultTextView.layer.cornerRadius = 8
        resultTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultTextView)
        
        // 开始按钮
        startButton.setTitle("开始识别", for: .normal)
        startButton.backgroundColor = .systemBlue
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 8
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.addTarget(self, action: #selector(toggleRecognition), for: .touchUpInside)
        view.addSubview(startButton)
        
        // 约束
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            resultTextView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            resultTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resultTextView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -20),
            
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 120),
            startButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func toggleRecognition() {
        if shazamManager.isListening {
            shazamManager.stopRecognition()
            startButton.setTitle("开始识别", for: .normal)
            startButton.backgroundColor = .systemBlue
        } else {
            shazamManager.startRecognition()
            startButton.setTitle("停止识别", for: .normal)
            startButton.backgroundColor = .systemRed
        }
    }
    
    // MARK: - ShazamManagerDelegate
    func shazamManager(_ manager: ShazamManager, didFindMatch result: MusicRecognitionResult) {
        let resultText = """
        识别成功！
        
        歌名：\(result.title ?? "未知")
        歌手：\(result.artist ?? "未知")
        专辑：\(result.album ?? "未知")
        风格：\(result.genres.joined(separator: ", "))
        发行时间：\(result.releaseDate != nil ? shazamManager.formatReleaseDate(result.releaseDate!) : "未知")
        
        链接：
        - 网页：\(result.webURL?.absoluteString ?? "无")
        - Apple Music：\(result.appleMusicURL?.absoluteString ?? "无")
        - 视频：\(result.videoURL?.absoluteString ?? "无")
        """
        
        resultTextView.text = resultText
        statusLabel.text = "识别成功"
        statusLabel.textColor = .systemGreen
    }
    
    func shazamManager(_ manager: ShazamManager, didNotFindMatch error: Error?) {
        resultTextView.text = "未识别到音乐\n错误信息：\(error?.localizedDescription ?? "无")"
        statusLabel.text = "识别失败"
        statusLabel.textColor = .systemRed
    }
    
    func shazamManager(_ manager: ShazamManager, didChangeState state: RecognitionState) {
        switch state {
        case .idle:
            statusLabel.text = "准备就绪"
            statusLabel.textColor = .systemBlue
        case .listening:
            statusLabel.text = "正在监听..."
            statusLabel.textColor = .systemOrange
        case .recognizing:
            statusLabel.text = "正在识别..."
            statusLabel.textColor = .systemYellow
        case .error(let message):
            statusLabel.text = "错误：\(message)"
            statusLabel.textColor = .systemRed
        }
    }
    
    func shazamManager(_ manager: ShazamManager, didEncounterError error: Error) {
        let alert = UIAlertController(title: "错误", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - 高级使用示例
class AdvancedShazamExample {
    
    private let shazamManager = ShazamManager()
    
    init() {
        setupManager()
    }
    
    private func setupManager() {
        shazamManager.delegate = self
    }
    
    /// 检查权限并开始识别
    func startRecognitionWithPermissionCheck() {
        shazamManager.checkMicrophonePermission { [weak self] granted in
            if granted {
                self?.shazamManager.startRecognition()
            } else {
                print("麦克风权限被拒绝")
                // 可以在这里显示权限设置引导
            }
        }
    }
    
    /// 获取当前识别状态
    func getCurrentState() -> RecognitionState {
        return shazamManager.state
    }
    
    /// 检查是否正在监听
    func isCurrentlyListening() -> Bool {
        return shazamManager.isListening
    }
}

// MARK: - 高级示例的代理实现
extension AdvancedShazamExample: ShazamManagerDelegate {
    func shazamManager(_ manager: ShazamManager, didFindMatch result: MusicRecognitionResult) {
        print("识别到音乐：\(result.title ?? "未知") - \(result.artist ?? "未知")")
        
        // 自动打开Apple Music链接
        if let appleMusicURL = result.appleMusicURL {
            manager.openMusicURL(appleMusicURL)
        }
        
        // 加载专辑封面
        if let artworkURL = result.artworkURL {
            manager.loadArtworkImage(from: artworkURL) { image in
                if let image = image {
                    print("成功加载专辑封面")
                    // 在这里处理封面图片
                }
            }
        }
    }
    
    func shazamManager(_ manager: ShazamManager, didNotFindMatch error: Error?) {
        print("未识别到音乐")
    }
    
    func shazamManager(_ manager: ShazamManager, didChangeState state: RecognitionState) {
        print("识别状态变化：\(state)")
    }
    
    func shazamManager(_ manager: ShazamManager, didEncounterError error: Error) {
        print("识别错误：\(error.localizedDescription)")
    }
} 