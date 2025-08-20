//
//  ScrollViewExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct ScrollViewExampleView: View {
    @State private var scrollPosition: CGPoint = .zero
    @State private var showingScrollInfo = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("ScrollView 示例")
                    .font(.title)
                    .padding()
                
                // 基础ScrollView
                VStack {
                    Text("基础滚动视图")
                        .font(.headline)
                    
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(1...10, id: \.self) { index in
                                HStack {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text("\(index)")
                                                .foregroundColor(.white)
                                                .fontWeight(.bold)
                                        )
                                    
                                    VStack(alignment: .leading) {
                                        Text("项目 \(index)")
                                            .font(.headline)
                                        Text("这是第 \(index) 个项目的详细描述")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
                            }
                        }
                        .padding()
                    }
                    .frame(height: 300)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 水平ScrollView
                VStack {
                    Text("水平滚动视图")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(1...8, id: \.self) { index in
                                VStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green)
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.white)
                                                .font(.title)
                                        )
                                    
                                    Text("卡片 \(index)")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 150)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 网格ScrollView
                VStack {
                    Text("网格滚动视图")
                        .font(.headline)
                    
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            ForEach(1...12, id: \.self) { index in
                                VStack {
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Text("\(index)")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                        )
                                    
                                    Text("网格 \(index)")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
                            }
                        }
                        .padding()
                    }
                    .frame(height: 400)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 滚动信息
                VStack {
                    Text("滚动信息")
                        .font(.headline)
                    
                    VStack(spacing: 10) {
                        HStack {
                            Text("滚动位置:")
                            Spacer()
                            Text("X: \(Int(scrollPosition.x)), Y: \(Int(scrollPosition.y))")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        Button("显示滚动提示") {
                            showingScrollInfo = true
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 占位内容
                VStack(spacing: 15) {
                    ForEach(1...5, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.purple.opacity(0.3))
                            .frame(height: 80)
                            .overlay(
                                Text("占位内容 \(index)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            )
                    }
                }
                .padding()
            }
            .padding()
        }
        .navigationTitle("ScrollView")
        .alert("滚动视图提示", isPresented: $showingScrollInfo) {
            Button("确定") { }
        } message: {
            Text("ScrollView 支持垂直和水平滚动，可以包含任意内容。使用 LazyVStack 和 LazyHStack 可以提高性能。")
        }
    }
}

#Preview {
    NavigationView {
        ScrollViewExampleView()
    }
}
