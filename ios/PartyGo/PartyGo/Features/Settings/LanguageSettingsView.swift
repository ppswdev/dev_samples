//
//  LanguageSettingsView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/25.
//

import SwiftUI

struct LanguageSettingsView: View {
    @EnvironmentObject var globalState: GlobalStateManager
    
    var body: some View {
        List {
            ForEach(GlobalStateManager.AppLanguage.allCases, id: \.self) { language in
                Button {
                    globalState.switchLanguage(language)
                } label: {
                    HStack {
                        Text(language.displayName)
                        
                        Spacer()
                        
                        if globalState.appLanguage == language {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .navigationTitle("语言设置")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LanguageSettingsView()
}
