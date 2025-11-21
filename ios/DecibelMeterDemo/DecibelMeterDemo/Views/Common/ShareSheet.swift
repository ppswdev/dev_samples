//
//  ShareSheet.swift
//  DecibelMeterDemo
//
//  通用分享面板组件
//  用于在 SwiftUI 中显示 iOS 原生的分享界面（UIActivityViewController）
//

import SwiftUI
import UIKit

/// UIActivityViewController 的 SwiftUI 包装器
///
/// 用于在 SwiftUI 中展示系统原生的分享界面，支持分享文件、图片、文本等内容
///
/// **使用方式**：
/// ```swift
/// @State private var showShareSheet = false
/// @State private var shareItems: [Any] = []
///
/// .sheet(isPresented: $showShareSheet) {
///     ShareSheet(activityItems: shareItems)
/// }
/// ```
///
/// **功能特点**：
/// - 支持 AirDrop、邮件、消息等系统分享方式
/// - 自动适配 iPhone 和 iPad（iPad 上显示为 Popover）
/// - 支持自定义分享活动
///
/// **参数说明**：
/// - `activityItems`: 要分享的内容数组，可以是 URL、UIImage、String 等
/// - `applicationActivities`: 自定义的分享活动（可选）
/// - `excludedActivityTypes`: 要排除的分享类型（可选）
struct ShareSheet: UIViewControllerRepresentable {
    /// 要分享的内容数组
    let activityItems: [Any]
    
    /// 自定义的分享活动（可选）
    var applicationActivities: [UIActivity]? = nil
    
    /// 要排除的分享类型（可选）
    /// 例如：[.addToReadingList, .assignToContact]
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        
        // 设置排除的活动类型
        controller.excludedActivityTypes = excludedActivityTypes
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // 不需要更新
    }
}

// MARK: - 便利初始化方法

extension ShareSheet {
    /// 分享单个文件
    ///
    /// - Parameter fileURL: 文件 URL
    init(fileURL: URL, excludedActivityTypes: [UIActivity.ActivityType]? = nil) {
        self.activityItems = [fileURL]
        self.excludedActivityTypes = excludedActivityTypes
    }
    
    /// 分享文本
    ///
    /// - Parameter text: 要分享的文本
    init(text: String, excludedActivityTypes: [UIActivity.ActivityType]? = nil) {
        self.activityItems = [text]
        self.excludedActivityTypes = excludedActivityTypes
    }
    
    /// 分享图片
    ///
    /// - Parameter image: 要分享的图片
    init(image: UIImage, excludedActivityTypes: [UIActivity.ActivityType]? = nil) {
        self.activityItems = [image]
        self.excludedActivityTypes = excludedActivityTypes
    }
}

