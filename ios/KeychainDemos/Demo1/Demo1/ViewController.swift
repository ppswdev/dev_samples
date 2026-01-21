//
//  ViewController.swift
//  Demo1
//
//  Created by xiaopin on 2026/1/20.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Demo1 - Keychain 演示"
        
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Stack View
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        // Add buttons
        addButton(title: "💾 保存Token", action: #selector(saveTokenTapped))
        addButton(title: "📖 读取Token", action: #selector(getTokenTapped))
        addButton(title: "✅ 检查Token", action: #selector(checkTokenTapped))
        addButton(title: "🗑️  删除Token", action: #selector(deleteTokenTapped))
        addButton(title: "🔑 保存API密钥", action: #selector(saveAPIKeyTapped))
        addButton(title: "📖 读取API密钥", action: #selector(getAPIKeyTapped))
        addButton(title: "🧹 清空所有数据", action: #selector(clearAllTapped))
        addButton(title: "📱 跨应用数据检查", action: #selector(checkSharedDataTapped))
        
        // Add log view
        let logLabel = UILabel()
        logLabel.text = "操作日志"
        logLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        logLabel.textColor = .label
        stackView.addArrangedSubview(logLabel)
        
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        logTextView.layer.borderColor = UIColor.separator.cgColor
        logTextView.layer.borderWidth = 1
        logTextView.layer.cornerRadius = 8
        stackView.addArrangedSubview(logTextView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Stack View
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            // Log Text View
            logTextView.heightAnchor.constraint(equalToConstant: 200),
        ])
    }
    
    private func addButton(title: String, action: Selector) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        stackView.addArrangedSubview(button)
    }
    
    private lazy var logTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 12)
        textView.backgroundColor = .secondarySystemBackground
        textView.textColor = .label
        return textView
    }()
    
    private func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logMessage = "[\(timestamp)] \(message)\n"
        logTextView.text.append(logMessage)
        
        // 自动滚动到底部
        let range = NSRange(location: logTextView.text.count - 1, length: 0)
        logTextView.scrollRangeToVisible(range)
    }
    
    // MARK: - Keychain Operations
    
    @objc private func saveTokenTapped() {
        let token = "token_demo1_\(Date().timeIntervalSince1970)"
        KeychainExample.saveUserToken(token)
        log("✅ Token已保存: \(token)")
    }
    
    @objc private func getTokenTapped() {
        if let token = KeychainExample.getUserToken() {
            log("✅ 获取到Token: \(token)")
        } else {
            log("❌ 未找到Token")
        }
    }
    
    @objc private func checkTokenTapped() {
        if KeychainExample.isTokenExist() {
            log("✅ Token存在")
        } else {
            log("❌ Token不存在")
        }
    }
    
    @objc private func deleteTokenTapped() {
        KeychainExample.deleteUserToken()
        log("✅ Token已删除")
    }
    
    @objc private func saveAPIKeyTapped() {
        let apiKey = "api_key_demo1_\(Date().timeIntervalSince1970)"
        KeychainExample.saveAPIKey(apiKey)
        log("✅ API密钥已保存")
    }
    
    @objc private func getAPIKeyTapped() {
        if let apiKey = KeychainExample.getAPIKey() {
            log("✅ 获取到API密钥: \(apiKey)")
        } else {
            log("❌ 未找到API密钥")
        }
    }
    
    @objc private func clearAllTapped() {
        KeychainExample.clearAllKeychainData()
        log("🧹 所有钥匙串数据已清空")
    }
    
    @objc private func checkSharedDataTapped() {
        // 检查是否有来自Demo2的共享数据
        let sharedKey = "demo2_shared_token"
        if let sharedToken = KeychainManager.shared.read(key: sharedKey) {
            log("📱 检测到来自Demo2的共享Token: \(sharedToken)")
        } else {
            log("📱 未找到来自Demo2的共享数据。请先在Demo2中保存数据。")
        }
        
        // 为Demo2保存一个共享token
        let sharedToken = "Demo1_Shared_\(Date().timeIntervalSince1970)"
        KeychainManager.shared.save(key: "demo1_shared_token", value: sharedToken)
        log("📤 已为Demo2共享Token: \(sharedToken)")
    }

}

