import SwiftUI

struct CustomThemeExampleView: View {
    @State private var currentTheme = CustomTheme.light
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("自定义主题示例")
                    .font(.title)
                    .padding()
                
                // 主题选择器
                VStack {
                    Text("主题选择器")
                        .font(.headline)
                    
                    Picker("选择主题", selection: $currentTheme) {
                        ForEach(CustomTheme.allCases, id: \.self) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 主题预览
                VStack {
                    Text("主题预览")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        Text("应用标题")
                            .font(.title)
                            .foregroundColor(currentTheme.primaryColor)
                        
                        HStack(spacing: 15) {
                            Button("主要按钮") { }
                                .buttonStyle(CustomButtonStyle(theme: currentTheme))
                            
                            Button("次要按钮") { }
                                .buttonStyle(CustomSecondaryButtonStyle(theme: currentTheme))
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("卡片标题")
                                .font(.headline)
                                .foregroundColor(currentTheme.textColor)
                            
                            Text("这是一个示例卡片，展示了当前主题的样式。")
                                .font(.body)
                                .foregroundColor(currentTheme.secondaryTextColor)
                        }
                        .padding()
                        .background(currentTheme.cardBackground)
                        .cornerRadius(12)
                        .shadow(color: currentTheme.shadowColor, radius: 5, x: 0, y: 2)
                    }
                }
                .padding()
                .background(currentTheme.background)
                .cornerRadius(15)
                
                // 颜色展示
                VStack {
                    Text("颜色展示")
                        .font(.headline)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ColorCard(name: "主色", color: currentTheme.primaryColor)
                        ColorCard(name: "次色", color: currentTheme.secondaryColor)
                        ColorCard(name: "背景", color: currentTheme.background)
                        ColorCard(name: "卡片", color: currentTheme.cardBackground)
                        ColorCard(name: "文本", color: currentTheme.textColor)
                        ColorCard(name: "阴影", color: currentTheme.shadowColor)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("自定义主题")
        .background(currentTheme.background)
    }
}

// MARK: - 主题定义

enum CustomTheme: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case blue = "blue"
    case green = "green"
    case purple = "purple"
    case orange = "orange"
    
    var displayName: String {
        switch self {
        case .light: return "浅色"
        case .dark: return "深色"
        case .blue: return "蓝色"
        case .green: return "绿色"
        case .purple: return "紫色"
        case .orange: return "橙色"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .light: return .blue
        case .dark: return .white
        case .blue: return .blue
        case .green: return .green
        case .purple: return .purple
        case .orange: return .orange
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .light: return .gray
        case .dark: return .gray
        case .blue: return .cyan
        case .green: return .mint
        case .purple: return .pink
        case .orange: return .yellow
        }
    }
    
    var background: Color {
        switch self {
        case .light: return .white
        case .dark: return .black
        case .blue: return Color.blue.opacity(0.1)
        case .green: return Color.green.opacity(0.1)
        case .purple: return Color.purple.opacity(0.1)
        case .orange: return Color.orange.opacity(0.1)
        }
    }
    
    var cardBackground: Color {
        switch self {
        case .light, .blue, .green, .purple, .orange: return .white
        case .dark: return Color.gray.opacity(0.2)
        }
    }
    
    var textColor: Color {
        switch self {
        case .light, .blue, .green, .purple, .orange: return .black
        case .dark: return .white
        }
    }
    
    var secondaryTextColor: Color {
        switch self {
        case .light, .blue, .green, .purple, .orange: return .gray
        case .dark: return .gray
        }
    }
    
    var shadowColor: Color {
        switch self {
        case .light: return .gray.opacity(0.3)
        case .dark: return .black.opacity(0.5)
        case .blue: return .blue.opacity(0.3)
        case .green: return .green.opacity(0.3)
        case .purple: return .purple.opacity(0.3)
        case .orange: return .orange.opacity(0.3)
        }
    }
}

// MARK: - 自定义样式

struct CustomButtonStyle: ButtonStyle {
    let theme: CustomTheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(theme.primaryColor)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct CustomSecondaryButtonStyle: ButtonStyle {
    let theme: CustomTheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.clear)
            .foregroundColor(theme.primaryColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(theme.primaryColor, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

//struct ColorCard: View {
//    let name: String
//    let color: Color
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            RoundedRectangle(cornerRadius: 8)
//                .fill(color)
//                .frame(height: 40)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                )
//            
//            Text(name)
//                .font(.caption)
//                .foregroundColor(.secondary)
//        }
//    }
//}

#Preview {
    NavigationView {
        CustomThemeExampleView()
    }
}
