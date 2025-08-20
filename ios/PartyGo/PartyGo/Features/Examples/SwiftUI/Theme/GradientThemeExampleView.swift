import SwiftUI

struct GradientThemeExampleView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // 标题区域
                VStack(spacing: 15) {
                    Text("弥散光渐变主题")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("MyGradientPrimary"), Color("MyGradientSecondary")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("梦幻柔和的光效设计")
                        .font(.subheadline)
                        .foregroundColor(Color("MyGradientText"))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color("MyGradientBackground"),
                                    Color("MyGradientOverlay")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color("MyGradientGlow"), radius: 20, x: 0, y: 10)
                )
                
                // 渐变色彩展示
                VStack(spacing: 20) {
                    Text("渐变色彩系统")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("MyGradientText"))
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        GradientColorCard(
                            title: "主渐变",
                            gradient: AnyShapeStyle(LinearGradient(
                                colors: [Color("MyGradientPrimary"), Color("MyGradientSecondary")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                        )
                        
                        GradientColorCard(
                            title: "强调渐变",
                            gradient: AnyShapeStyle(LinearGradient(
                                colors: [Color("MyGradientAccent"), Color("MyGradientPrimary")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                        )
                        
                        GradientColorCard(
                            title: "光晕效果",
                            gradient: AnyShapeStyle(RadialGradient(
                                colors: [Color("MyGradientGlow"), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            ))
                        )
                        
                        GradientColorCard(
                            title: "背景渐变",
                            gradient: AnyShapeStyle(LinearGradient(
                                colors: [Color("MyGradientBackground"), Color("MyGradientOverlay")],
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                        )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("MyGradientCard"))
                        .shadow(color: Color("MyGradientGlow"), radius: 15, x: 0, y: 8)
                )
                
                // 实际应用示例
                VStack(spacing: 20) {
                    Text("应用示例")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("MyGradientText"))
                    
                    // 渐变卡片
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color("MyGradientPrimary"), Color("MyGradientAccent")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text("梦幻卡片")
                                .font(.headline)
                                .foregroundColor(Color("MyGradientText"))
                            
                            Spacer()
                            
                            Text("NEW")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    LinearGradient(
                                        colors: [Color("MyGradientAccent"), Color("MyGradientPrimary")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                        
                        Text("这是一个使用弥散光渐变主题的示例卡片，展现了梦幻柔和的光效设计。")
                            .font(.body)
                            .foregroundColor(Color("MyGradientText"))
                            .opacity(0.8)
                        
                        HStack(spacing: 15) {
                            Button("主要操作") {
                                // 主要操作
                            }
                            .buttonStyle(GradientPrimaryButtonStyle())
                            
                            Button("次要操作") {
                                // 次要操作
                            }
                            .buttonStyle(GradientSecondaryButtonStyle())
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color("MyGradientCard"),
                                        Color("MyGradientOverlay")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [Color("MyGradientPrimary"), Color("MyGradientSecondary")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color("MyGradientGlow"), radius: 20, x: 0, y: 10)
                }
                
                // 光效元素
                VStack(spacing: 20) {
                    Text("光效元素")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("MyGradientText"))
                    
                    HStack(spacing: 30) {
                        GlowElement(icon: "star.fill", title: "星光")
                        GlowElement(icon: "moon.fill", title: "月光")
                        GlowElement(icon: "sun.max.fill", title: "阳光")
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("MyGradientCard"))
                        .shadow(color: Color("MyGradientGlow"), radius: 15, x: 0, y: 8)
                )
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [Color("MyGradientBackground"), Color("MyGradientOverlay")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .navigationTitle("弥散光渐变主题")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - 辅助视图

struct GradientColorCard: View {
    let title: String
    let gradient: AnyShapeStyle
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(gradient)
                .frame(height: 60)
                .shadow(color: Color("MyGradientGlow"), radius: 10, x: 0, y: 5)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Color("MyGradientText"))
        }
    }
}

struct GlowElement: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color("MyGradientPrimary"), Color("MyGradientAccent")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color("MyGradientGlow"), radius: 15, x: 0, y: 0)
            
            Text(title)
                .font(.caption)
                .foregroundColor(Color("MyGradientText"))
        }
    }
}

// MARK: - 渐变按钮样式

struct GradientPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [Color("MyGradientPrimary"), Color("MyGradientSecondary")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: Color("MyGradientGlow"), radius: 10, x: 0, y: 5)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct GradientSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(Color("MyGradientPrimary"))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [Color("MyGradientPrimary"), Color("MyGradientSecondary")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    NavigationView {
        GradientThemeExampleView()
    }
}
