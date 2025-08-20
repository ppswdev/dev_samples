//
//  SliderExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct SliderExampleView: View {
    @State private var value = 50.0
    @State private var volume = 0.5
    @State private var brightness = 0.8
    
    var body: some View {
        VStack(spacing: 20) {
            // 基础滑块
            VStack {
                Text("基础滑块: \(Int(value))")
                Slider(value: $value, in: 0...100, step: 1)
            }
            
            // 音量滑块
            VStack {
                HStack {
                    Image(systemName: "speaker.fill")
                    Slider(value: $volume, in: 0...1)
                    Image(systemName: "speaker.wave.3.fill")
                }
                Text("音量: \(Int(volume * 100))%")
            }
            
            // 亮度滑块
            VStack {
                HStack {
                    Image(systemName: "sun.min.fill")
                    Slider(value: $brightness, in: 0...1)
                    Image(systemName: "sun.max.fill")
                }
                Text("亮度: \(Int(brightness * 100))%")
            }
            
            // 自定义滑块
            VStack {
                Text("自定义滑块: \(Int(value))")
                Slider(value: $value, in: 0...100) {
                    Text("自定义滑块")
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("100")
                }
                .accentColor(.blue)
            }
        }
        .padding()
    }
}

#Preview {
    SliderExampleView()
}
