//
//  EnvironmentExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct EnvironmentExampleView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.locale) var locale
    @Environment(\.timeZone) var timeZone
    @Environment(\.calendar) var calendar
    @Environment(\.layoutDirection) var layoutDirection
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("环境值示例")
                    .font(.title)
                    .padding()
                
                // 颜色方案
                ColorSchemeSection(colorScheme: colorScheme)
                
                // 字体大小
                FontSizeSection(sizeCategory: sizeCategory)
                
                // 本地化
                LocalizationSection(locale: locale, timeZone: timeZone, calendar: calendar)
                
                // 布局方向
                LayoutDirectionSection(layoutDirection: layoutDirection)
                
                // 环境值组合
                EnvironmentSummarySection(
                    colorScheme: colorScheme,
                    sizeCategory: sizeCategory,
                    locale: locale,
                    timeZone: timeZone,
                    layoutDirection: layoutDirection
                )
                
                // 自定义环境值
                CustomEnvironmentSection()
            }
            .padding()
        }
        .navigationTitle("环境值")
    }
}

// MARK: - 子视图组件

struct ColorSchemeSection: View {
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack {
            Text("颜色方案")
                .font(.headline)
            
            VStack(spacing: 15) {
                HStack {
                    Text("当前模式:")
                    Spacer()
                    let modeText = colorScheme == .dark ? "深色" : "浅色"
                    Text(modeText)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                
                let backgroundColor = colorScheme == .dark ? Color.white : Color.black
                let textColor = colorScheme == .dark ? Color.black : Color.white
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(backgroundColor)
                    .frame(height: 60)
                    .overlay(
                        Text("当前颜色方案")
                            .foregroundColor(textColor)
                            .font(.headline)
                    )
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct FontSizeSection: View {
    let sizeCategory: ContentSizeCategory
    
    var body: some View {
        VStack {
            Text("字体大小")
                .font(.headline)
            
            VStack(spacing: 15) {
                HStack {
                    Text("当前大小:")
                    Spacer()
                    Text(sizeCategory.description)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("小字体")
                        .font(.caption)
                    
                    Text("正常字体")
                        .font(.body)
                    
                    Text("大字体")
                        .font(.title)
                    
                    Text("超大字体")
                        .font(.largeTitle)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct LocalizationSection: View {
    let locale: Locale
    let timeZone: TimeZone
    let calendar: Calendar
    
    var body: some View {
        VStack {
            Text("本地化")
                .font(.headline)
            
            VStack(spacing: 15) {
                HStack {
                    Text("当前语言:")
                    Spacer()
                    Text(locale.identifier)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("时区:")
                    Spacer()
                    Text(timeZone.identifier)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("日历:")
                    Spacer()
                    Text(calendar.identifier.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                let currentTime = Date().formatted()
                Text("当前时间: \(currentTime)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct LayoutDirectionSection: View {
    let layoutDirection: LayoutDirection
    
    var body: some View {
        VStack {
            Text("布局方向")
                .font(.headline)
            
            VStack(spacing: 15) {
                HStack {
                    Text("当前方向:")
                    Spacer()
                    let directionText = layoutDirection == .leftToRight ? "从左到右" : "从右到左"
                    Text(directionText)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                
                HStack {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.blue)
                    Text("开始")
                        .font(.body)
                    Spacer()
                    Text("结束")
                        .font(.body)
                    Image(systemName: "arrow.right")
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct EnvironmentSummarySection: View {
    let colorScheme: ColorScheme
    let sizeCategory: ContentSizeCategory
    let locale: Locale
    let timeZone: TimeZone
    let layoutDirection: LayoutDirection
    
    var body: some View {
        VStack {
            Text("环境值组合")
                .font(.headline)
            
            VStack(spacing: 15) {
                Text("综合信息")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 8) {
                    let colorSchemeText = colorScheme == .dark ? "深色" : "浅色"
                    Text("• 颜色方案: \(colorSchemeText)")
                    
                    Text("• 字体大小: \(sizeCategory.description)")
                    Text("• 语言: \(locale.identifier)")
                    Text("• 时区: \(timeZone.identifier)")
                    
                    let layoutText = layoutDirection == .leftToRight ? "LTR" : "RTL"
                    Text("• 布局: \(layoutText)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct CustomEnvironmentSection: View {
    var body: some View {
        VStack {
            Text("自定义环境值")
                .font(.headline)
            
            CustomEnvironmentView()
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct CustomEnvironmentView: View {
    @Environment(\.customTheme) var customTheme
    @Environment(\.customSpacing) var customSpacing
    
    var body: some View {
        VStack(spacing: customSpacing) {
            let themeText = "自定义主题: \(customTheme)"
            Text(themeText)
                .font(.headline)
                .foregroundColor(customTheme == "dark" ? .white : .black)
            
            let spacingText = "自定义间距: \(customSpacing)"
            Text(spacingText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(customTheme == "dark" ? Color.black : Color.white)
        .cornerRadius(10)
    }
}

// MARK: - 扩展

extension Calendar.Identifier {
    var displayName: String {
        switch self {
        case .gregorian:
            return "公历"
        case .buddhist:
            return "佛历"
        case .chinese:
            return "农历"
        case .coptic:
            return "科普特历"
        case .ethiopicAmeteMihret:
            return "埃塞俄比亚历"
        case .ethiopicAmeteAlem:
            return "埃塞俄比亚历（世界纪元）"
        case .hebrew:
            return "希伯来历"
        case .indian:
            return "印度历"
        case .islamic:
            return "伊斯兰历"
        case .islamicCivil:
            return "伊斯兰民用历"
        case .islamicTabular:
            return "伊斯兰表格历"
        case .islamicUmmAlQura:
            return "伊斯兰乌姆古拉历"
        case .japanese:
            return "日本历"
        case .persian:
            return "波斯历"
        case .republicOfChina:
            return "民国历"
        case .iso8601:
            return "ISO 8601"
        @unknown default:
            return "Unknown"
        }
    }
}

// MARK: - 自定义环境值

private struct CustomThemeKey: EnvironmentKey {
    static let defaultValue: String = "light"
}

private struct CustomSpacingKey: EnvironmentKey {
    static let defaultValue: CGFloat = 10
}

extension EnvironmentValues {
    var customTheme: String {
        get { self[CustomThemeKey.self] }
        set { self[CustomThemeKey.self] = newValue }
    }
    
    var customSpacing: CGFloat {
        get { self[CustomSpacingKey.self] }
        set { self[CustomSpacingKey.self] = newValue }
    }
}

extension ContentSizeCategory {
    var description: String {
        switch self {
        case .accessibilityExtraExtraExtraLarge: return "超大"
        case .accessibilityExtraExtraLarge: return "特大"
        case .accessibilityExtraLarge: return "很大"
        case .accessibilityLarge: return "大"
        case .accessibilityMedium: return "中"
        case .extraExtraExtraLarge: return "超大"
        case .extraExtraLarge: return "特大"
        case .extraLarge: return "很大"
        case .large: return "大"
        case .medium: return "中"
        case .small: return "小"
        case .extraSmall: return "很小"
        @unknown default: return "未知"
        }
    }
}

#Preview {
    NavigationView {
        EnvironmentExampleView()
            .environment(\.customTheme, "dark")
            .environment(\.customSpacing, 20)
    }
}
