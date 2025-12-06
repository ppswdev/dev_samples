//
//  StoreExampleView.swift
//  StoreKitManager
//
//  Created by xiaopin on 2025/12/6.
//

import SwiftUI
import StoreKit

/// StoreKitManager 使用示例的主视图
struct StoreExampleView: View {
    @StateObject private var viewModel = StoreExampleViewModel()
    
    var body: some View {
        NavigationView {
            List {
                // 已购买状态
                if !viewModel.purchasedProducts.isEmpty {
                    Section("已购买") {
                        ForEach(viewModel.purchasedProducts, id: \.id) { product in
                            PurchasedProductRow(product: product)
                        }
                    }
                }
                
                // 非消耗品
                if !viewModel.nonConsumables.isEmpty {
                    Section("非消耗品") {
                        ForEach(viewModel.nonConsumables, id: \.id) { product in
                            ProductRow(
                                product: product,
                                isPurchased: viewModel.isPurchased(product),
                                onPurchase: { viewModel.purchase(product) }
                            )
                        }
                    }
                }
                
                // 非续订订阅
                if !viewModel.nonRenewables.isEmpty {
                    Section("非续订订阅") {
                        ForEach(viewModel.nonRenewables, id: \.id) { product in
                            ProductRow(
                                product: product,
                                isPurchased: viewModel.isPurchased(product),
                                onPurchase: { viewModel.purchase(product) }
                            )
                        }
                    }
                }
                
                // 自动续订订阅
                if !viewModel.autoRenewables.isEmpty {
                    Section("自动续订订阅") {
                        ForEach(viewModel.autoRenewables, id: \.id) { product in
                            SubscriptionProductRow(
                                viewModel: viewModel,
                                product: product,
                                isPurchased: viewModel.isPurchased(product),
                                onPurchase: { viewModel.purchase(product) },
                                subscriptionInfo: viewModel.subscriptionInfo
                            )
                        }
                    }
                }
                
                // 操作按钮
                Section("操作") {
                    Button("恢复购买") {
                        viewModel.restorePurchases()
                    }
                    
                    Button("刷新购买状态") {
                        Task {
                            await viewModel.refreshPurchases()
                        }
                    }
                    
                    Button("应用内订阅管理") {
                        Task {
                            let success = await viewModel.showManageSubscriptionsSheet()
                            if !success {
                                // 如果应用内界面不可用，使用 URL
                                viewModel.openSubscriptionManagement()
                            }
                            // 注意：showManageSubscriptionsSheet 内部已自动刷新状态
                        }
                    }
                    
                    Button("刷新订阅状态") {
                        Task {
                            await viewModel.refreshSubscriptionStatus()
                        }
                    }
                    
                    Button("打开订阅管理（URL）") {
                        viewModel.openSubscriptionManagement()
                    }
                    
                    NavigationLink("交易历史") {
                        TransactionHistoryView(viewModel: viewModel)
                    }
                }
            }
            .navigationTitle("StoreKit2 示例")
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
            }
            .alert("提示", isPresented: $viewModel.showAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage ?? "")
            }
        }
    }
}

// MARK: - 产品行视图

struct ProductRow: View {
    let product: Product
    let isPurchased: Bool
    let onPurchase: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.displayName)
                    .font(.headline)
                Text(product.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(product.displayPrice)
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            if isPurchased {
                Label("已购买", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
            } else {
                Button("购买") {
                    onPurchase()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 订阅产品行视图

struct SubscriptionProductRow: View {
    @ObservedObject var viewModel: StoreExampleViewModel
    let product: Product
    let isPurchased: Bool
    let onPurchase: () -> Void
    let subscriptionInfo: SubscriptionInfo?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 显示订阅周期
                    if let subscription = product.subscription {
                        Text("周期: \(subscription.subscriptionPeriod.displayName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(product.displayPrice)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                if isPurchased {
                    VStack(spacing: 4) {
                        Label("已订阅", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        
//                        if let info = subscriptionInfo, info.productId == product.id {
//                            if info.isValid {
//                                Text("有效")
//                                    .font(.caption2)
//                                    .foregroundColor(.green)
//                            } else if info.isExpired {
//                                Text("已过期")
//                                    .font(.caption2)
//                                    .foregroundColor(.red)
//                            }
//                        }
                        
                        // 管理订阅按钮
                        Button("管理订阅") {
                            Task {
                                await viewModel.cancelSubscription(for: product.id)
                            }
                        }
                        .buttonStyle(.bordered)
                        .font(.caption2)
                    }
                } else {
                    Button("订阅") {
                        onPurchase()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
            // 显示订阅详细信息
//            if let info = subscriptionInfo, info.productId == product.id {
//                SubscriptionInfoView(info: info)
//            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 已购买产品行视图

struct PurchasedProductRow: View {
    let product: Product
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.displayName)
                    .font(.headline)
                Text(product.displayPrice)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Label("已拥有", systemImage: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 订阅信息视图

struct SubscriptionInfoView: View {
    let info: SubscriptionInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Divider()
            
//            if let renewalDate = info.renewalDate {
//                Text("续订日期: \(renewalDate, style: .date)")
//                    .font(.caption)
//            }
//            
//            if info.isInTrialPeriod {
//                Text("试用期")
//                    .font(.caption)
//                    .foregroundColor(.orange)
//            }
//            
//            if info.isInIntroductoryPricePeriod {
//                Text("优惠价格期")
//                    .font(.caption)
//                    .foregroundColor(.blue)
//            }
//            
//            if info.isCancelled {
//                Text("已取消")
//                    .font(.caption)
//                    .foregroundColor(.orange)
//            }
        }
        .padding(.top, 4)
    }
}

// MARK: - 交易历史视图

struct TransactionHistoryView: View {
    @ObservedObject var viewModel: StoreExampleViewModel
    @State private var transactions: [TransactionHistory] = []
    @State private var isLoading = false
    
    var body: some View {
        List {
            if isLoading {
                ProgressView()
            } else if transactions.isEmpty {
                Text("暂无交易记录")
                    .foregroundColor(.secondary)
            } else {
                ForEach(transactions, id: \.transactionId) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
        }
        .navigationTitle("交易历史")
        .task {
            await loadTransactions()
        }
    }
    
    private func loadTransactions() async {
        isLoading = true
        transactions = await viewModel.getTransactionHistory()
        isLoading = false
    }
}

// MARK: - 交易行视图

struct TransactionRow: View {
    let transaction: TransactionHistory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(transaction.productId)
                .font(.headline)
            
            Text("购买日期: \(transaction.purchaseDate, style: .date)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let expirationDate = transaction.expirationDate {
                Text("过期日期: \(expirationDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if transaction.isRefunded {
                Label("已退款", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            if transaction.isRevoked {
                Label("已撤销", systemImage: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 扩展

extension Product.SubscriptionPeriod {
    var displayName: String {
        switch unit {
        case .day:
            return "\(value) 天"
        case .week:
            return "\(value) 周"
        case .month:
            return "\(value) 月"
        case .year:
            return "\(value) 年"
        @unknown default:
            return "未知"
        }
    }
}

// MARK: - 预览

struct StoreExampleView_Previews: PreviewProvider {
    static var previews: some View {
        StoreExampleView()
    }
}

