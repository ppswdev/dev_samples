# ShazamManager 封装类使用指南

## 概述

`ShazamManager` 是一个对 Apple ShazamKit 的封装类，提供了简单易用的音乐识别功能。它将复杂的音频识别逻辑封装成易于使用的接口，支持权限管理、状态监控、错误处理等功能。

## 主要功能

### 1. 音乐识别
- 实时音频流识别
- 自动权限检查和请求
- 识别状态监控
- 错误处理和恢复

### 2. 结果处理
- 音乐信息提取（歌名、歌手、专辑等）
- 专辑封面加载
- 音乐链接处理（网页、Apple Music、视频）

### 3. 状态管理
- 识别状态枚举（空闲、监听、识别中、错误）
- 状态变化通知
- 错误信息处理

## 文件结构

```
ShazamKitDemo/
├── ShazamManager.swift          # 核心封装类
├── ViewController.swift          # 重构后的主界面
├── ShazamUsageExample.swift     # 使用示例
└── README_ShazamManager.md      # 本说明文档
```

## 核心类说明

### ShazamManager

主要的封装类，提供以下功能：

```swift
class ShazamManager: NSObject {
    weak var delegate: ShazamManagerDelegate?
    
    // 开始识别
    func startRecognition()
    
    // 停止识别
    func stopRecognition()
    
    // 权限检查
    func checkMicrophonePermission(completion: @escaping (Bool) -> Void)
    
    // 状态查询
    var isListening: Bool
    var state: RecognitionState
}
```

### MusicRecognitionResult

音乐识别结果的数据模型：

```swift
struct MusicRecognitionResult {
    let title: String?           // 歌名
    let artist: String?          // 歌手
    let album: String?           // 专辑
    let genres: [String]         // 音乐风格
    let releaseDate: Date?       // 发行时间
    let artworkURL: URL?         // 专辑封面URL
    let webURL: URL?             // 网页链接
    let appleMusicURL: URL?      // Apple Music链接
    let videoURL: URL?           // 视频链接
}
```

### RecognitionState

识别状态枚举：

```swift
enum RecognitionState {
    case idle           // 空闲
    case listening      // 监听中
    case recognizing    // 识别中
    case error(String)  // 错误状态
}
```

## 使用方法

### 1. 基本使用

```swift
class MyViewController: UIViewController, ShazamManagerDelegate {
    
    private let shazamManager = ShazamManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shazamManager.delegate = self
    }
    
    @objc func startRecognition() {
        shazamManager.startRecognition()
    }
    
    @objc func stopRecognition() {
        shazamManager.stopRecognition()
    }
    
    // MARK: - ShazamManagerDelegate
    func shazamManager(_ manager: ShazamManager, didFindMatch result: MusicRecognitionResult) {
        // 处理识别结果
        print("识别到：\(result.title ?? "") - \(result.artist ?? "")")
    }
    
    func shazamManager(_ manager: ShazamManager, didNotFindMatch error: Error?) {
        // 处理识别失败
        print("未识别到音乐")
    }
    
    func shazamManager(_ manager: ShazamManager, didChangeState state: RecognitionState) {
        // 处理状态变化
        switch state {
        case .listening:
            print("正在监听...")
        case .recognizing:
            print("正在识别...")
        case .error(let message):
            print("错误：\(message)")
        default:
            break
        }
    }
    
    func shazamManager(_ manager: ShazamManager, didEncounterError error: Error) {
        // 处理错误
        print("发生错误：\(error.localizedDescription)")
    }
}
```

### 2. 权限检查

```swift
shazamManager.checkMicrophonePermission { granted in
    if granted {
        // 开始识别
        self.shazamManager.startRecognition()
    } else {
        // 显示权限设置引导
        self.showPermissionAlert()
    }
}
```

### 3. 状态监控

```swift
// 检查是否正在监听
if shazamManager.isListening {
    print("正在识别音乐")
}

// 获取当前状态
let currentState = shazamManager.state
switch currentState {
case .idle:
    print("准备就绪")
case .listening:
    print("监听中")
case .recognizing:
    print("识别中")
case .error(let message):
    print("错误：\(message)")
}
```

### 4. 处理识别结果

```swift
func shazamManager(_ manager: ShazamManager, didFindMatch result: MusicRecognitionResult) {
    // 显示音乐信息
    titleLabel.text = result.title
    artistLabel.text = result.artist
    albumLabel.text = result.album
    
    // 加载专辑封面
    if let artworkURL = result.artworkURL {
        manager.loadArtworkImage(from: artworkURL) { image in
            self.albumImageView.image = image
        }
    }
    
    // 处理音乐链接
    if let appleMusicURL = result.appleMusicURL {
        // 显示Apple Music按钮
        appleMusicButton.isHidden = false
        appleMusicButton.accessibilityHint = appleMusicURL.absoluteString
    }
}
```

### 5. 打开音乐链接

```swift
// 打开Apple Music
if let urlString = appleMusicButton.accessibilityHint,
   let url = URL(string: urlString) {
    shazamManager.openMusicURL(url)
}
```

## 高级功能

### 1. 自定义音频会话配置

```swift
// 在ShazamManager中已经配置了基本的音频会话
// 如果需要自定义，可以修改setupAudioSession方法
func setupAudioSession() throws {
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
    try session.setActive(true)
}
```

### 2. 后台识别支持

在 `Info.plist` 中添加后台模式：

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

### 3. 错误处理

```swift
func shazamManager(_ manager: ShazamManager, didEncounterError error: Error) {
    let alert = UIAlertController(title: "错误", message: error.localizedDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "确定", style: .default))
    present(alert, animated: true)
}
```

## 注意事项

1. **权限要求**：使用前需要麦克风权限
2. **网络连接**：识别功能需要网络连接
3. **音频质量**：识别效果受环境噪音影响
4. **iOS版本**：需要iOS 14.0或更高版本
5. **设备兼容性**：某些设备可能不支持ShazamKit

## 常见问题

### Q: 识别失败怎么办？
A: 检查网络连接、麦克风权限，确保环境噪音较小

### Q: 如何提高识别准确率？
A: 在安静环境中使用，确保音乐声音清晰

### Q: 支持哪些音乐平台？
A: 主要支持Apple Music、Spotify等主流平台的音乐

### Q: 可以识别本地音乐吗？
A: ShazamKit主要用于识别在线音乐，本地音乐识别能力有限

## 更新日志

- v1.0.0: 初始版本，基本识别功能
- v1.1.0: 添加状态监控和错误处理
- v1.2.0: 重构为封装类，提高可维护性

## 许可证

本项目遵循MIT许可证。 