//
//  BaseViewModel.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/18.
//

import SwiftUI
import SwiftData

// Swift6 新的ViewModel基类
@MainActor
class BaseViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Swift6 改进的错误处理
    func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        isLoading = false
    }
    
    // Swift6 新的异步任务处理
    func performAsyncTask<T: Sendable>(_ task: @escaping () async throws -> T) async -> T? {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await task()
            isLoading = false
            return result
        } catch {
            handleError(error)
            return nil
        }
    }
}
