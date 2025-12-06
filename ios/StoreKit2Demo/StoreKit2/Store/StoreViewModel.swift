//
//  StoreViewModel.swift
//  StoreKit2
//
//  Created by Jordan Calhoun on 8/28/23.
//

import Foundation
import StoreKit
import Observation

@Observable
class StoreViewModel: ObservableObject {
    private(set) var nonConsumables: [Product] = []
    private(set) var consumables: [Product] = []
    private(set) var nonRenewables: [Product] = []
    private(set) var autoRenewables: [Product] = []
    
    private(set) var purchasedNonConsumables: [Product] = []
    private(set) var purchasedNonRenewables: [Product] = []
    private(set) var purchasedAutoRenewables: [Product] = []
    
    private(set) var purchaseStatus: PurchaseStatus = .unknown {
        didSet {
            // Alert the user if there is an eror purchasing
            switch purchaseStatus {
            case .failed(let error):
                alertMessage = "There was an error completing your purchase: \(error.localizedDescription)."
                isAlertShowing = true
            default:
                return
            }
        }
    }
    
    var isAlertShowing: Bool = false
    var alertMessage: String = ""
    
    private let storeDataService = StoreService()
    private var subscriberTasks: [Task<Void, Never>] = []
    
    init() {
        self.addSubscribers()
    }
    
    deinit {
        // 取消所有订阅任务，避免内存泄漏
        subscriberTasks.forEach { $0.cancel() }
    }
    
    func addSubscribers() {
        // 监听消耗品产品变化
        subscriberTasks.append(Task {
            for await value in storeDataService.$consumables.values {
                await MainActor.run {
                    self.consumables = value
                }
            }
        })
        
        // 监听非消耗品产品变化
        subscriberTasks.append(Task {
            for await value in storeDataService.$nonConsumables.values {
                await MainActor.run {
                    self.nonConsumables = value
                }
            }
        })
        
        // 监听非续订订阅产品变化
        subscriberTasks.append(Task {
            for await value in storeDataService.$nonRenewables.values {
                await MainActor.run {
                    self.nonRenewables = value
                }
            }
        })
         
        // 监听自动续订订阅产品变化
        subscriberTasks.append(Task {
            for await value in storeDataService.$autoRenewables.values {
                await MainActor.run {
                    self.autoRenewables = value
                }
            }
        })
        
        // 监听已购买的非消耗品变化
        subscriberTasks.append(Task {
            for await value in storeDataService.$purchasedNonConsumables.values {
                await MainActor.run {
                    self.purchasedNonConsumables = value
                }
            }
        })
            
        // 监听已购买的非续订订阅变化
        subscriberTasks.append(Task {
            for await value in storeDataService.$purchasedNonRenewables.values {
                await MainActor.run {
                    self.purchasedNonRenewables = value
                }
            }
        })
            
        // 监听已购买的自动续订订阅变化
        subscriberTasks.append(Task {
            for await value in storeDataService.$purchasedAutoRenewables.values {
                await MainActor.run {
                    self.purchasedAutoRenewables = value
                }
            }
        })
        
        // 监听购买状态变化
        subscriberTasks.append(Task {
            for await value in storeDataService.$purchaseStatus.values {
                await MainActor.run {
                    self.purchaseStatus = value
                }
            }
        })
    }
    
    func purchase(product: Product)  {
        Task {
            await storeDataService.purchase(product)
        }
    }
    
    func isPurchased(_ product: Product) -> Bool {
        switch product.type {
        case .nonConsumable:
            return purchasedNonConsumables.contains(where: { $0.id == product.id })
        case .nonRenewable:
            return purchasedNonRenewables.contains(where: { $0.id == product.id })
        case .autoRenewable:
            return purchasedAutoRenewables.contains(where: { $0.id == product.id })
        default:
            return false
        }
    }
}
