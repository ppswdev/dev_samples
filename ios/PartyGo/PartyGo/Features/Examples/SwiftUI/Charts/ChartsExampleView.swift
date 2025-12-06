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
    
    // 预处理折线图数据（计算属性，避免在闭包中计算）
    private var processedLineData: [LineDataPoint] {
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    titleView
                    pieChartSection
                    barChartSection
                    lineChartSection
                    combinedChartSection
                }
                .padding()
            }
            .navigationTitle("Charts 示例")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - 子视图
    
    private var titleView: some View {
        Text("SwiftUI Charts 示例")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding()
    }
    
    private var pieChartSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("饼图示例")
                .font(.title2)
                .fontWeight(.semibold)
            
            pieChart
            
            pieChartLegend
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var pieChart: some View {
        Chart(pieChartData) { data in
            SectorMark(
                angle: .value("数值", data.value),
                innerRadius: .ratio(0.5),
                outerRadius: .ratio(0.8),
                angularInset: 1
            )
            .foregroundStyle(data.color)
            .annotation(position: .overlay) {
                if data.value > 20 {
                    Text("\(Int(data.value))%")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(height: 250)
    }
    
    private var pieChartLegend: some View {
        HStack(spacing: 10) {
            ForEach(pieChartData) { data in
                HStack {
                    Circle()
                        .fill(data.color)
                        .frame(width: 12, height: 12)
                    Text(data.name)
                        .font(.caption)
                }
            }
        }
    }
    
    private var barChartSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("柱状图示例")
                .font(.title2)
                .fontWeight(.semibold)
            
            barChart
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var barChart: some View {
        Chart(barChartData) { data in
            BarMark(
                x: .value("名称", data.name),
                y: .value("数值", data.value)
            )
            .foregroundStyle(data.color)
            .cornerRadius(4)
        }
        .frame(height: 300)
    }
    
    private var lineChartSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("折线图示例")
                .font(.title2)
                .fontWeight(.semibold)
            
            lineChart
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var lineChart: some View {
        Chart {
            ForEach(processedLineData) { item in
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
    
    private var combinedChartSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("组合图表示例")
                .font(.title2)
                .fontWeight(.semibold)
            
            combinedChart
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var combinedChart: some View {
        Chart {
            ForEach(barChartData) { data in
                BarMark(
                    x: .value("名称", data.name),
                    y: .value("数值", data.value)
                )
                .foregroundStyle(data.color.opacity(0.6))
            }
            
            ForEach(barChartData) { data in
                LineMark(
                    x: .value("名称", data.name),
                    y: .value("数值", data.value * 1.2)
                )
                .foregroundStyle(Color.black)
                .symbolSize(10)
            }
        }
        .frame(height: 300)
    }
}

// MARK: - 辅助结构体

private struct LineDataPoint: Identifiable {
    let id: UUID
    let month: String
    let value: Double
    let type: String
    let color: Color
}

#Preview {
    ChartsExampleView()
}
