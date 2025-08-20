import SwiftUI

struct MyThemeColorsExampleView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("My 主题配色系统")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("MyTextPrimary"))
                    .padding()
                
                // 主色调系列
                ColorSectionView(
                    title: "主色调系列",
                    colors: [
                        ("MyPrimary", "主色调", Color("MyPrimary")),
                        ("MySecondary", "次色调", Color("MySecondary")),
                        ("MyTertiary", "三级色", Color("MyTertiary")),
                        ("MyQuaternary", "四级色", Color("MyQuaternary"))
                    ]
                )
                
                // 背景色系列
                ColorSectionView(
                    title: "背景色系列",
                    colors: [
                        ("MyBackground", "背景色", Color("MyBackground")),
                        ("MyCardBackground", "卡片背景", Color("MyCardBackground"))
                    ]
                )
                
                // 文本色系列
                ColorSectionView(
                    title: "文本色系列",
                    colors: [
                        ("MyTextPrimary", "主要文本", Color("MyTextPrimary")),
                        ("MyTextSecondary", "次要文本", Color("MyTextSecondary")),
                        ("MyTextTertiary", "三级文本", Color("MyTextTertiary")),
                        ("MyPlaceholder", "占位符", Color("MyPlaceholder"))
                    ]
                )
                
                // 功能色系列
                ColorSectionView(
                    title: "功能色系列",
                    colors: [
                        ("MySuccess", "成功色", Color("MySuccess")),
                        ("MyWarning", "警告色", Color("MyWarning")),
                        ("MyError", "错误色", Color("MyError")),
                        ("MyInfo", "信息色", Color("MyInfo"))
                    ]
                )
                
                // 装饰色系列
                ColorSectionView(
                    title: "装饰色系列",
                    colors: [
                        ("MyBorder", "边框色", Color("MyBorder")),
                        ("MySeparator", "分割线", Color("MySeparator")),
                        ("MyShadow", "阴影色", Color("MyShadow"))
                    ]
                )
                
                // 实际应用示例
                VStack(spacing: 20) {
                    Text("实际应用示例")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("MyTextPrimary"))
                    
                    // 卡片示例
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color("MyPrimary"))
                            Text("示例卡片")
                                .font(.headline)
                                .foregroundColor(Color("MyTextPrimary"))
                            Spacer()
                            Text("NEW")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color("MySuccess"))
                                .cornerRadius(8)
                        }
                        
                        Text("这是一个使用 My 主题配色的示例卡片，展示了各种颜色的实际应用效果。")
                            .font(.body)
                            .foregroundColor(Color("MyTextSecondary"))
                        
                        HStack {
                            Button("主要操作") {
                                // 主要操作
                            }
                            .buttonStyle(MyPrimaryButtonStyle())
                            
                            Button("次要操作") {
                                // 次要操作
                            }
                            .buttonStyle(MySecondaryButtonStyle())
                        }
                    }
                    .padding()
                    .background(Color("MyCardBackground"))
                    .cornerRadius(12)
                    .shadow(color: Color("MyShadow"), radius: 8, x: 0, y: 4)
                }
                .padding()
                .background(Color("MyBackground"))
                .cornerRadius(16)
                
                // 状态指示器
                VStack(spacing: 15) {
                    Text("状态指示器")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("MyTextPrimary"))
                    
                    HStack(spacing: 20) {
                        StatusIndicator(title: "成功", color: Color("MySuccess"), icon: "checkmark.circle.fill")
                        StatusIndicator(title: "警告", color: Color("MyWarning"), icon: "exclamationmark.triangle.fill")
                        StatusIndicator(title: "错误", color: Color("MyError"), icon: "xmark.circle.fill")
                        StatusIndicator(title: "信息", color: Color("MyInfo"), icon: "info.circle.fill")
                    }
                }
                .padding()
                .background(Color("MyCardBackground"))
                .cornerRadius(12)
            }
            .padding()
        }
        .background(Color("MyBackground"))
        .navigationTitle("My 主题配色")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - 辅助视图

struct ColorSectionView: View {
    let title: String
    let colors: [(name: String, description: String, color: Color)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color("MyTextPrimary"))
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(colors, id: \.name) { colorInfo in
                    ColorCardView(
                        name: colorInfo.name,
                        description: colorInfo.description,
                        color: colorInfo.color
                    )
                }
            }
        }
        .padding()
        .background(Color("MyCardBackground"))
        .cornerRadius(12)
    }
}

struct ColorCardView: View {
    let name: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("MyBorder"), lineWidth: 1)
                )
            
            VStack(spacing: 2) {
                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color("MyTextPrimary"))
                
                Text(description)
                    .font(.caption2)
                    .foregroundColor(Color("MyTextSecondary"))
            }
        }
    }
}

struct StatusIndicator: View {
    let title: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(Color("MyTextSecondary"))
        }
    }
}

// MARK: - 自定义按钮样式

struct MyPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color("MyPrimary"))
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct MySecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(Color("MyPrimary"))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color("MyPrimary"), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    NavigationView {
        MyThemeColorsExampleView()
    }
}
