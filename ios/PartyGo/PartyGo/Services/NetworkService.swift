//
//  NetworkService.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/18.
//

import Foundation

// Swift6 新的并发模型
@MainActor
class NetworkService: ObservableObject {
    static let shared = NetworkService()
    
    private init() {}
    
    // Swift6 改进的错误处理
    func fetchData<T: Codable>(from url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// Swift6 新的错误定义
enum NetworkError: LocalizedError {
    case invalidResponse
    case decodingError
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "无效的响应"
        case .decodingError:
            return "数据解析错误"
        case .networkError:
            return "网络连接错误"
        }
    }
}
