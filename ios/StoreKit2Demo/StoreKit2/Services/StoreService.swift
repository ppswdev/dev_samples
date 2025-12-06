//
//  StoreService.swift
//  StoreKit2
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit

enum StoreKitError: Error {
    case failedVerification
    case unknownError
}

enum PurchaseStatus {
    case success(String)
    case pending
    case cancelled
    case failed(Error)
    case unknown
}

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

class StoreService: ObservableObject {
    // 来自商店的产品
    @Published private(set) var nonConsumables: [Product] = []
    @Published private(set) var consumables: [Product] = []
    @Published private(set) var nonRenewables: [Product] = []
    @Published private(set) var autoRenewables: [Product] = []
    
    // 从商店购买的产品
    @Published private(set) var purchasedNonConsumables: [Product] = []
    @Published private(set) var purchasedNonRenewables: [Product] = []
    @Published private(set) var purchasedAutoRenewables: [Product] = []
    @Published private(set) var subscriptionGroupStatus: RenewalState?
    
    // 用于从商店获取产品的产品ID数组。
    // 通常存储在 plist 或类似文件中。
    private let productsIds = [
        "nonconsumable.lifetime",
        "consumable.week",
        "subscription.yearly",
        "nonrenewable.year"
    ]
    
    
    @Published private(set) var purchaseStatus: PurchaseStatus = .unknown {
        didSet {
            print("--------------------")
            print("Purchase Status: \(purchaseStatus)")
            print("--------------------")
        }
    }

    /// 监听商店更新的后台任务
    private(set) var transactionListener: Task<Void, Error>?
    
    init() {
        transactionListener = transactionStatusStream()
        Task {
            await retrieveProducts()
            await retrievePurchasedProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    /// 从商店获取产品
    @MainActor
    func retrieveProducts() async {
        do {
            let storeProducts = try await Product.products(for: productsIds)
            
            var nonConsumables: [Product] = []
            var consumables: [Product] = []
            var nonRenewables: [Product] = []
            var autoRenewables: [Product] = []
            
            for product in storeProducts {
                switch product.type {
                case .nonConsumable:
                    nonConsumables.append(product)
                case .consumable:
                    consumables.append(product)
                case .nonRenewable:
                    nonRenewables.append(product)
                case .autoRenewable:
                    autoRenewables.append(product)
                default:
                    break
                }
            }
            
            // 按价格排序并更新商店
            self.nonConsumables = sortByPrice(nonConsumables)
            self.consumables = sortByPrice(consumables)
            self.nonRenewables = sortByPrice(nonRenewables)
            self.autoRenewables = sortByPrice(autoRenewables)
            
            print("Store products finished loading.")
        } catch {
            // 无法从 App Store 获取产品
            print("Couldn't load products from the App Store: \(error)")
        }
    }

    /// 获取已购买的产品
    @MainActor
    func retrievePurchasedProducts() async {
        var purchasedNonConsumables: [Product] = []
        var purchasedNonRenewables: [Product] = []
        var purchasedAutoRenewables: [Product] = []
        
        // 遍历用户已购买的产品
        for await verificationResult in Transaction.currentEntitlements {
            do {
                // 验证交易
                let transaction = try verifyPurchase(verificationResult)
                
                print("Retrieved:: \(transaction.productID)")
                                
                // 检查产品类型并分配到正确的数组。
                switch transaction.productType {
                case .nonConsumable:
                    guard let product = nonConsumables.first(where: { $0.id == transaction.productID }) else {
                        // 交易产品不在我们提供的产品列表中。
                        return
                    }
                    purchasedNonConsumables.append(product)
                case .nonRenewable:
                    guard let product = nonRenewables.first(where: { $0.id == transaction.productID }) else {
                        // 交易产品不在我们提供的产品列表中。
                        return
                    }
                    // 关于非续订订阅过期日期的说明（来自 Apple）：
                    /*
                     非续订订阅没有固有的过期日期，因此它们在用户购买后始终包含在 `Transaction.currentEntitlements` 中。
                     此应用将此非续订订阅的过期日期定义为购买后一年。
                     如果当前日期在 `purchaseDate` 的一年内，用户仍然有权使用此产品。
                 */
                    let currentDate = Date()
                    guard let expirationDate = Calendar(identifier: .gregorian).date(
                        byAdding: DateComponents(year: 1),
                        to: transaction.purchaseDate) else {
                        print("Could not determine expiration date.")
                        return
                    }
                    
                    if currentDate < expirationDate {
                        purchasedNonRenewables.append(product)
                    }
                case .autoRenewable:
                    guard let product = autoRenewables.first(where: { $0.id == transaction.productID }) else {
                        // 交易产品不在我们提供的产品列表中。
                        return
                    }
                    purchasedAutoRenewables.append(product)
                default:
                    // 产品类型不属于上述任何类型。
                    break;
                }
            } catch {
                // 交易无效。
                print(error)
            }
        }
        
        // 使用已购买的产品更新商店
        self.purchasedNonConsumables = purchasedNonConsumables
        self.purchasedNonRenewables = purchasedNonRenewables
        self.purchasedAutoRenewables = purchasedAutoRenewables
        
        // 来自 Apple 关于订阅组状态的说明：
        /*
            检查 `subscriptionGroupStatus` 以了解自动续订订阅状态，确定客户是新的（从未订阅）、活跃的或非活跃的（已过期订阅）。
            此应用只有一个订阅组，因此订阅数组中的产品都属于同一组。`product.subscription.status` 返回的状态适用于整个订阅组。
         */
        subscriptionGroupStatus = try? await autoRenewables.first?.subscription?.status.first?.state
    }
    
    /// 进行购买
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                do {
                    let verificationResult = try verifyPurchase(verification)
                    
                    await self.retrievePurchasedProducts()
                    await verificationResult.finish()
                    
                    purchaseStatus = .success(verificationResult.productID)
                } catch {
                    purchaseStatus = .failed(error)
                }
            case .pending:
                purchaseStatus = .pending
            case .userCancelled:
                purchaseStatus = .cancelled
            default:
                purchaseStatus = .failed(StoreKitError.unknownError)
            }
        } catch {
            purchaseStatus = .failed(error)
        }
    }
    
    /// 验证购买
    func verifyPurchase<T>(_ verifcationResult: VerificationResult<T>) throws -> T {
        switch verifcationResult {
        case .unverified(_, let error):
            throw error // 购买成功；但是，交易无法验证，设备已越狱？
        case .verified(let result):
            return result // 验证成功
        }
    }

    private func transactionStatusStream() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.verifyPurchase(result)
                    
                    await self.retrievePurchasedProducts()
                    
                    await transaction.finish()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    private func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { return $0.price < $1.price })
    }
}

