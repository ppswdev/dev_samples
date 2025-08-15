//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by xiaopin on 2025/8/14.
//

import UIKit
import Social
import UniformTypeIdentifiers

// 本地化字符串扩展
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

class ShareViewController: UIViewController {
    
    // 存储UI元素的引用
    private var iconImageView: UIImageView!
    private var titleLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var openAppButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置背景色
        view.backgroundColor = UIColor.systemBackground
        
        // 创建UI界面
        setupUI()
        
        // 处理传入的文件
        handleIncomingFiles()
    }
    
    func setupUI() {
        // 创建主容器视图
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // 创建图标
        iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = UIColor.systemBlue
        // 使用系统图标
        iconImageView.image = UIImage(systemName: "arrow.clockwise")
        containerView.addSubview(iconImageView)
        
        // 创建标题标签
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "processing.title".localized
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.label
        containerView.addSubview(titleLabel)
        
        // 创建描述标签
        descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "processing.description".localized
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = UIColor.secondaryLabel
        descriptionLabel.numberOfLines = 0
        containerView.addSubview(descriptionLabel)
        
        // 创建打开应用按钮
        openAppButton = UIButton(type: .system)
        openAppButton.translatesAutoresizingMaskIntoConstraints = false
        openAppButton.setTitle("button.open.app".localized, for: .normal)
        openAppButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        openAppButton.backgroundColor = UIColor.systemBlue
        openAppButton.setTitleColor(UIColor.white, for: .normal)
        openAppButton.layer.cornerRadius = 12
        openAppButton.addTarget(self, action: #selector(openAppButtonTapped), for: .touchUpInside)
        containerView.addSubview(openAppButton)
        
        // 设置约束
        NSLayoutConstraint.activate([
            // 容器视图约束
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // 图标约束
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),
            
            // 标题约束
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // 描述约束
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // 按钮约束
            openAppButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            openAppButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            openAppButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            openAppButton.heightAnchor.constraint(equalToConstant: 50),
            openAppButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    @objc func openAppButtonTapped() {
        openMainApp()
    }

    func handleIncomingFiles() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments else {
            // 如果没有附件，显示错误信息
            showError(message: "error.no.files".localized)
            return
        }

        var processedCount = 0
        let totalCount = attachments.count
        var hasValidFiles = false
        
        for provider in attachments {
            if provider.hasItemConformingToTypeIdentifier(UTType.audio.identifier) ||
                provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {

                hasValidFiles = true
                provider.loadItem(forTypeIdentifier: UTType.data.identifier, options: nil) { (item, error) in
                    processedCount += 1
                    
                    if let url = item as? URL {
                        FileManagerHelper.saveToAppGroup(url: url) { savedURL in
                            NotificationHelper.notifyHostApp()
                        }
                    }
                    
                    // 当所有文件都处理完成后，显示成功界面
                    if processedCount >= totalCount {
                        DispatchQueue.main.async {
                            self.showSuccess()
                        }
                    }
                }
            } else {
                processedCount += 1
                if processedCount >= totalCount && !hasValidFiles {
                    DispatchQueue.main.async {
                        self.showError(message: "error.no.audio.video".localized)
                    }
                }
            }
        }
    }
    
    func showSuccess() {
        print("showSuccess被调用")
        // 更新UI显示成功状态
        updateUIForSuccess()
    }
    
    func showError(message: String) {
        // 更新UI显示错误状态
        updateUIForError(message: message)
    }
    
    func updateUIForSuccess() {
        print("updateUIForSuccess被调用")
        // 使用本地化字符串更新UI
        updateUIElements(
            iconName: "checkmark.circle.fill",
            iconColor: UIColor.systemGreen,
            title: "success.title".localized,
            description: "success.description".localized
        )
    }
    
    func updateUIForError(message: String) {
        // 使用本地化字符串更新UI
        updateUIElements(
            iconName: "exclamationmark.triangle.fill",
            iconColor: UIColor.systemOrange,
            title: "error.title".localized,
            description: message
        )
    }
    
    func updateUIElements(iconName: String, iconColor: UIColor, title: String, description: String) {
        // 确保在主线程执行UI更新
        DispatchQueue.main.async {
            print("开始更新UI: \(title) - \(description)")
            
            // 直接使用属性引用更新UI
            self.iconImageView.image = UIImage(systemName: iconName)
            self.iconImageView.tintColor = iconColor
            self.titleLabel.text = title
            self.descriptionLabel.text = description
            
            // 根据内容设置颜色
            if description.contains("失败") {
                self.descriptionLabel.textColor = UIColor.systemOrange
            } else {
                self.descriptionLabel.textColor = UIColor.secondaryLabel
            }
            
            // 强制刷新布局
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            
            // 添加动画效果
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func openMainApp() {
        // 使用URL Scheme打开主应用htofflinemusic://share
        if let url = URL(string: "htofflinemusic://share") {
            print("ShareExtension: 尝试打开URL: \(url)")
            
            // 在ShareExtension中使用正确的方式打开宿主App
            var responder = self as UIResponder?
            while responder != nil {
                if let application = responder as? UIApplication {
                    print("ShareExtension: 找到UIApplication，执行openURL")
                    application.perform(NSSelectorFromString("openURL:"), with: url)
                    break
                }
                responder = responder?.next
            }
        }
        
        // 延迟完成ShareExtension请求，给用户时间看到成功界面
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
}

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

struct NotificationHelper {
    static func notifyHostApp() {
        let userDefaults = UserDefaults(suiteName: FileManagerHelper.appGroupId)
        userDefaults?.set(true, forKey: "com.mobiunity.htmusic.shareCompleted")
        userDefaults?.synchronize()
    }
}


// class ShareViewController: SLComposeServiceViewController {

//    override func isContentValid() -> Bool {
//        // Do validation of contentText and/or NSExtensionContext attachments here
//        return true
//    }

//    override func didSelectPost() {
//        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
//         handleIncomingFiles()
//        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
//        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
//    }

//    override func configurationItems() -> [Any]! {
//        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
//        return []
//    }

//    func handleIncomingFiles() {
//         guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
//               let attachments = extensionItem.attachments else { return }

//         for provider in attachments {
//             if provider.hasItemConformingToTypeIdentifier(kUTTypeAudio as String) ||
//                 provider.hasItemConformingToTypeIdentifier(kUTTypeMovie as String) {

//                 provider.loadItem(forTypeIdentifier: kUTTypeData as String, options: nil) { (item, error) in
//                     if let url = item as? URL {
//                         FileManagerHelper.saveToAppGroup(url: url) { savedURL in
//                             NotificationHelper.notifyHostApp()
//                             // 跳转到主应用
//                             self.openMainApp()
//                             self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
//                         }
//                     }
//                 }
//             }
//         }
//     }
    
//     func openMainApp() {
//         // 使用URL Scheme打开主应用
//         if let url = URL(string: "htofflinemusic://share") {
//             print("ShareExtension: 尝试打开URL: \(url)")
            
//             // 在ShareExtension中使用正确的方式打开宿主App
//             var responder = self as UIResponder?
//             while responder != nil {
//                 if let application = responder as? UIApplication {
//                     print("ShareExtension: 找到UIApplication，执行openURL")
//                     application.perform(NSSelectorFromString("openURL:"), with: url)
//                     break
//                 }
//                 responder = responder?.next
//             }
            
//             // 备用方法：使用extensionContext
//             print("ShareExtension: 尝试备用方法")
//             extensionContext?.completeRequest(returningItems: [], completionHandler: { _ in
//                 // 在完成请求后尝试打开宿主App
//                 DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                     if let url = URL(string: "htofflinemusic://share") {
//                         var responder = self as UIResponder?
//                         while responder != nil {
//                             if let application = responder as? UIApplication {
//                                 application.perform(NSSelectorFromString("openURL:"), with: url)
//                                 break
//                             }
//                             responder = responder?.next
//                         }
//                     }
//                 }
//             })
//         }
//     }

// }
