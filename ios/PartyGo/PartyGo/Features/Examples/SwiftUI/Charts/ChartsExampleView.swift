//
//  ChartsExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/28.
//

import SwiftUI
import Charts // 导入官方Charts框架

struct ChartData: Identifiable {
    let id = UUID()
    let name: String
    let value: Double
    let color: Color
}

struct ChartsExampleView: View {
    // 示例数据
    let pieChartData = [
        ChartData(name: "一月", value: 30, color: .red),
        ChartData(name: "二月", value: 20, color: .blue),
        ChartData(name: "三月", value: 25, color: .green),
        ChartData(name: "四月", value: 15, color: .orange),
        ChartData(name: "五月", value: 35, color: .purple)
    ]
    
    let barChartData = [
        ChartData(name: "产品A", value: 45, color: .blue),
        ChartData(name: "产品B", value: 60, color: .green),
        ChartData(name: "产品C", value: 30, color: .orange),
        ChartData(name: "产品D", value: 75, color: .red),
        ChartData(name: "产品E", value: 50, color: .purple)
    ]
    
    // 生成折线图数据（包含多条线）
    let lineChartData: [(String, [Double])] = [
        ("温度", [22, 24, 23, 25, 27, 26, 28, 27, 29, 30, 28, 26]),
        ("湿度", [60, 65, 70, 65, 75, 80, 75, 70, 65, 60, 65, 70]),
        ("气压", [1013, 1012, 1015, 1014, 1016, 1017, 1015, 1014, 1012, 1013, 1014, 1015])
    ]
    
    let months = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    Text("SwiftUI Charts 示例")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    // 1. 饼图示例
                    VStack(alignment: .leading, spacing: 15) {
                        Text("饼图示例")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Chart(pieChartData) {
                            SectorMark(
                                angle: .value("数值", $0.value),
                                innerRadius: .ratio(0.5),
                                outerRadius: .ratio(0.8),
                                cornerRadius: 5,
                                angularInset: 1
                            )
                            .foregroundStyle($0.color)
                            .annotation(position: .overlay) {
                                if $0.value > 20 {
                                    Text("\(Int($0.value))%")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .aspectRatio(1, contentMode: .fit)
                        .frame(height: 250)
                        
                        // 图例
                        HStack(spacing: 10) {
                            ForEach(pieChartData) {
                                HStack {
                                    Circle()
                                        .fill($0.color)
                                        .frame(width: 12, height: 12)
                                    Text($0.name)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // 2. 柱状图示例
                    VStack(alignment: .leading, spacing: 15) {
                        Text("柱状图示例")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Chart(barChartData) {
                            BarMark(
                                x: .value("名称", $0.name),
                                y: .value("数值", $0.value)
                            )
                            .foregroundStyle($0.color)
                            .cornerRadius(4)
                        }
                        .frame(height: 300)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                   // 3. 折线图示例
                    VStack(alignment: .leading, spacing: 15) {
                        Text("折线图示例")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        // 修复：将复杂的折线图表达式分解为更简单的结构
                        Chart {
                            // 预处理数据，创建更简单的数据结构
                            ForEach(preprocessedLineData(), id: \.id) { item in
                                LineMark(
                                    x: .value("月份", item.month),
                                    y: .value(item.type, item.value)
                                )
                                .foregroundStyle(item.color)
                                .symbol(by: .value("类型", item.type))
                            }
                        }
                        .frame(height: 300)
                        .chartXAxis {
                            AxisMarks(values: .stride(by: 2))
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // 4. 组合图表示例
                    VStack(alignment: .leading, spacing: 15) {
                        Text("组合图表示例")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Chart {
                            // 柱状图部分
                            ForEach(barChartData) {
                                BarMark(
                                    x: .value("名称", $0.name),
                                    y: .value("数值", $0.value)
                                )
                                .foregroundStyle($0.color.opacity(0.6))
                            }
                            
                            // 折线图部分
                            ForEach(barChartData) {
                                LineMark(
                                    x: .value("名称", $0.name),
                                    y: .value("数值", $0.value * 1.2)
                                )
                                .foregroundStyle(Color.black)
                                .symbolSize(10)
                            }
                        }
                        .frame(height: 300)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Charts 示例")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // 在ChartsExampleView结构体内部添加
    private func preprocessedLineData() -> [LineDataPoint] {
        let colors: [Color] = [.red, .blue, .green]
        var result = [LineDataPoint]()
        
        for dataIndex in 0..<lineChartData.count {
            let data = lineChartData[dataIndex]
            let color = colors[dataIndex % colors.count]
            
            for monthIndex in 0..<months.count {
                result.append(
                    LineDataPoint(
                        id: UUID(),
                        month: months[monthIndex],
                        value: data.1[monthIndex],
                        type: data.0,
                        color: color
                    )
                )
            }
        }
        
        return result
    }

    // 添加一个新的辅助结构体
    private struct LineDataPoint: Identifiable {
        let id: UUID
        let month: String
        let value: Double
        let type: String
        let color: Color
    }
}

#Preview {
    ChartsExampleView()
}