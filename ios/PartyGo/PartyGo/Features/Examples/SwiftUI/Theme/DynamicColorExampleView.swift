//
//  DynamicColorExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct DynamicColorExampleView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isAnimating = false
    @State private var selectedColor = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("动态颜色示例")
                    .font(.title)
                    .padding()
                
                // 系统动态颜色
                VStack {
                    Text("系统动态颜色")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text("当前模式:")
                            Spacer()
                            Text(colorScheme == .dark ? "深色" : "浅色")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            ColorCard(name: "背景", color: Color(.systemBackground))
                            ColorCard(name: "次要背景", color: Color(.secondarySystemBackground))
                            ColorCard(name: "标签", color: Color(.label))
                            ColorCard(name: "次要标签", color: Color(.secondaryLabel))
                            ColorCard(name: "系统蓝", color: Color(.systemBlue))
                            ColorCard(name: "系统绿", color: Color(.systemGreen))
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 自定义动态颜色
                VStack {
                    Text("自定义动态颜色")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(dynamicPrimaryColor)
                            .frame(height: 80)
                            .overlay(
                                Text("动态主色")
                                    .font(.headline)
                                    .foregroundColor(dynamicTextColor)
                            )
                        
                        RoundedRectangle(cornerRadius: 15)
                            .fill(dynamicSecondaryColor)
                            .frame(height: 80)
                            .overlay(
                                Text("动态次色")
                                    .font(.headline)
                                    .foregroundColor(dynamicTextColor)
                            )
                        
                        RoundedRectangle(cornerRadius: 15)
                            .fill(dynamicAccentColor)
                            .frame(height: 80)
                            .overlay(
                                Text("动态强调色")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            )
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 颜色选择器
                VStack {
                    Text("颜色选择器")
                        .font(.headline)
                    
                    Picker("选择颜色主题", selection: $selectedColor) {
                        Text("主题1").tag(0)
                        Text("主题2").tag(1)
                        Text("主题3").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    VStack(spacing: 15) {
                        HStack {
                            Circle()
                                .fill(selectedDynamicColor)
                                .frame(width: 40, height: 40)
                            
                            VStack(alignment: .leading) {
                                Text("选中颜色")
                                    .font(.headline)
                                Text("根据当前模式自动调整")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 动画颜色
                VStack {
                    Text("动画颜色")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        Circle()
                            .fill(animatedColor)
                            .frame(width: 100, height: 100)
                            .scaleEffect(isAnimating ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                        
                        Button("开始动画") {
                            isAnimating.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 颜色对比
                VStack {
                    Text("颜色对比")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        HStack {
                            VStack {
                                Text("浅色模式")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemBackground))
                                    .frame(height: 60)
                                    .overlay(
                                        Text("背景")
                                            .font(.caption)
                                            .foregroundColor(Color(.label))
                                    )
                            }
                            
                            VStack {
                                Text("深色模式")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemBackground))
                                    .frame(height: 60)
                                    .overlay(
                                        Text("背景")
                                            .font(.caption)
                                            .foregroundColor(Color(.label))
                                    )
                            }
                        }
                        
                        Text("动态颜色会根据系统设置自动调整")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("动态颜色")
        .onAppear {
            isAnimating = true
        }
    }
    
    // MARK: - 动态颜色计算属性
    
    var dynamicPrimaryColor: Color {
        colorScheme == .dark ? Color.blue : Color.blue
    }
    
    var dynamicSecondaryColor: Color {
        colorScheme == .dark ? Color.gray : Color.gray.opacity(0.3)
    }
    
    var dynamicAccentColor: Color {
        colorScheme == .dark ? Color.orange : Color.orange
    }
    
    var dynamicTextColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var selectedDynamicColor: Color {
        switch selectedColor {
        case 0: return colorScheme == .dark ? .purple : .blue
        case 1: return colorScheme == .dark ? .green : .green
        case 2: return colorScheme == .dark ? .orange : .red
        default: return .blue
        }
    }
    
    var animatedColor: Color {
        if isAnimating {
            return colorScheme == .dark ? .purple : .blue
        } else {
            return colorScheme == .dark ? .blue : .purple
        }
    }
}

struct ColorCard: View {
    let name: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Text(name)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationView {
        DynamicColorExampleView()
    }
}
