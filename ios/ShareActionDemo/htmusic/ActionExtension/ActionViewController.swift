//
//  ActionViewController.swift
//  ActionExtension
//
//  Created by xiaopin on 2025/8/14.
//

import UIKit
import UniformTypeIdentifiers

class ActionViewController: UIViewController {
    
    // UI元素
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var openAppButton: UIButton!
    
    // 处理状态
    private var processedCount = 0
    private var totalCount = 0
    private var hasValidFiles = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置初始UI状态
        setupInitialUI()
        
        // 处理传入的文件
        handleIncomingFiles()
    }
    
    func setupInitialUI() {
        // 设置初始状态
        iconImageView.image = UIImage(systemName: "arrow.clockwise")
        iconImageView.tintColor = UIColor.systemBlue
        titleLabel.text = "processing.title".localized
        descriptionLabel.text = "processing.description".localized
        openAppButton.setTitle("button.open.app".localized, for: .normal)
    }
    
    func handleIncomingFiles() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments else {
            showError(message: "error.no.files".localized)
            return
        }

        totalCount = attachments.count
        
        for provider in attachments {
            if provider.hasItemConformingToTypeIdentifier(UTType.audio.identifier) ||
                provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {

                hasValidFiles = true
                provider.loadItem(forTypeIdentifier: UTType.data.identifier, options: nil) { (item, error) in
                    self.processedCount += 1
                    
                    if let url = item as? URL {
                        FileManagerHelper.saveToAppGroup(url: url) { savedURL in
                            NotificationHelper.notifyHostApp()
                        }
                    }
                    
                    // 更新进度
                    DispatchQueue.main.async {
                        self.updateProgress()
                    }
                    
                    // 当所有文件都处理完成后，显示成功界面
                    if self.processedCount >= self.totalCount {
                        DispatchQueue.main.async {
                            self.showSuccess()
                        }
                    }
                }
            } else {
                processedCount += 1
                updateProgress()
                
                if processedCount >= totalCount && !hasValidFiles {
                    DispatchQueue.main.async {
                        self.showError(message: "error.no.audio.video".localized)
                    }
                }
            }
        }
    }
    
    func updateProgress() {
        let progress = Float(processedCount) / Float(totalCount)
        progressView.progress = progress
    }
    
    func showSuccess() {
        updateUIForSuccess()
    }
    
    func showError(message: String) {
        updateUIForError(message: message)
    }
    
    func updateUIForSuccess() {
        progressView.isHidden = true
        iconImageView.image = UIImage(systemName: "checkmark.circle.fill")
        iconImageView.tintColor = UIColor.systemGreen
        titleLabel.text = "success.title".localized
        descriptionLabel.text = "success.description".localized
        openAppButton.isEnabled = true
    }
    
    func updateUIForError(message: String) {
        iconImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        iconImageView.tintColor = UIColor.systemOrange
        titleLabel.text = "error.title".localized
        descriptionLabel.text = message
        openAppButton.isEnabled = false
    }
    
    @objc func openAppButtonTapped() {
        openMainApp()
    }
    
    func openMainApp() {
        // 使用URL Scheme打开主应用
        if let url = URL(string: "htofflinemusic://share") {
            print("ActionExtension: 尝试打开URL: \(url)")
            
            // 在ActionExtension中使用正确的方式打开宿主App
            var responder = self as UIResponder?
            while responder != nil {
                if let application = responder as? UIApplication {
                    print("ActionExtension: 找到UIApplication，执行openURL")
                    application.perform(NSSelectorFromString("openURL:"), with: url)
                    break
                }
                responder = responder?.next
            }
        }
        
        // 延迟完成ActionExtension请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
}

// 本地化字符串扩展
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

// 文件管理助手
struct FileManagerHelper {
    static let appGroupId = "group.com.mobiunity.htmusic.shared"
    
    static func saveToAppGroup(url: URL, completion: @escaping (URL?) -> Void) {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) else {
            completion(nil)
            return
        }
        
        // 创建tracks目录
        let tracksURL = containerURL.appendingPathComponent("tracks")
        do {
            if !FileManager.default.fileExists(atPath: tracksURL.path) {
                try FileManager.default.createDirectory(at: tracksURL, withIntermediateDirectories: true)
            }
        } catch {
            completion(nil)
            return
        }
        
        let destURL = tracksURL.appendingPathComponent(url.lastPathComponent)
        do {
            if FileManager.default.fileExists(atPath: destURL.path) {
                try FileManager.default.removeItem(at: destURL)
            }
            try FileManager.default.copyItem(at: url, to: destURL)
            completion(destURL)
        } catch {
            completion(nil)
        }
    }
}

// 通知助手
struct NotificationHelper {
    static func notifyHostApp() {
        let userDefaults = UserDefaults(suiteName: FileManagerHelper.appGroupId)
        userDefaults?.set(true, forKey: "com.mobiunity.htmusic.shareCompleted")
        userDefaults?.synchronize()
    }
}
