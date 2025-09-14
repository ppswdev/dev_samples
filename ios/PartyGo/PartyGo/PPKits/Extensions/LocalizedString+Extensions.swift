//
//  LocalizedString+Extensions.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/25.
//

import SwiftUI

/*
import SwiftUI

struct LocalizedContentView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var userName = "张三"
    @State private var itemCount = 5
    
    var body: some View {
        VStack(spacing: 20) {
            // 使用扩展方法
            Text("welcome_message".localized)
                .font(.title)
            
            // 带参数
            Text("hello_user".localized(arguments: userName))
            
            // 使用 Text 扩展
            Text(localized: "items_count", arguments: itemCount, "苹果")
            
            // 数字格式化
            Text("数量: \(localizationManager.localizedNumber(NSNumber(value: itemCount)))")
            
            // 日期格式化
            Text("日期: \(localizationManager.localizedDate(Date()))")
            
            // 货币格式化
            Text("价格: \(localizationManager.localizedCurrency(99.99, currencyCode: "CNY"))")
            
            // 语言切换按钮
            Button("切换到英文") {
                localizationManager.switchLanguage(to: Locale(identifier: "en"))
            }
            .buttonStyle(.bordered)
            
            Button("切换到中文") {
                localizationManager.switchLanguage(to: Locale(identifier: "zh-Hans"))
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
*/

/**
 * 本地化字符串扩展
 */
extension String {
    /**
     * 获取本地化字符串
     */
    var localized: String {
        // 使用当前线程的 Bundle 获取本地化字符串
        return NSLocalizedString(self, comment: "")
    }
    
    /**
     * 获取带注释的本地化字符串
     */
    func localized(comment: String) -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
    /**
     * 获取带参数的本地化字符串
     */
    func localized(arguments: CVarArg...) -> String {
        let format = NSLocalizedString(self, comment: "")
        return String(format: format, arguments: arguments)
    }
    
    /**
     * 使用指定语言获取本地化字符串
     */
    func localized(languageCode: String) -> String {
        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return NSLocalizedString(self, bundle: bundle, comment: "")
        }
        return NSLocalizedString(self, comment: "")
    }
    
    /**
     * 使用指定语言获取带参数的本地化字符串
     */
    func localized(languageCode: String, arguments: CVarArg...) -> String {
        let format = localized(languageCode: languageCode)
        return String(format: format, arguments: arguments)
    }
}

/**
 * Text 扩展
 */
extension Text {
    /**
     * 创建本地化文本
     */
    init(localized key: String, comment: String = "") {
        self.init(NSLocalizedString(key, comment: comment))
    }
    
    /**
     * 创建带参数的本地化文本
     */
    init(localized key: String, arguments: CVarArg..., comment: String = "") {
        let format = NSLocalizedString(key, comment: comment)
        self.init(String(format: format, arguments: arguments))
    }
    
    /**
     * 使用指定语言创建本地化文本
     */
    init(localized key: String, languageCode: String, comment: String = "") {
        self.init(key.localized(languageCode: languageCode))
    }
}
