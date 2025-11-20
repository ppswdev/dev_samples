//
//  SwiftUISampleView.swift
//  DecibelMeterDemo
//
//  使用 SwiftUI 的购买示例
//  演示如何在 SwiftUI 中使用 PurchaseHelper
//

import SwiftUI
import StoreKit

struct SwiftUISampleView: View {
    
    @ObservedObject private var purchaseHelper = PurchaseHelper.shared
    @State private var eventLogs: [String] = []
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 状态显示
                    statusSection
                    
                    // 产品列表
                    if purchaseHelper.isLoadingProducts {
                        ProgressView("加载产品中...")
                            .padding()
                    } else {
                        productsSection
                    }
                    
                    // 恢复购买按钮
                    restoreButton
                    
                    // 事件日志
                    eventLogSection
                }
                .padding()
            }
            .navigationTitle("订阅管理")
            .onAppear {
                setupPurchaseHelper()
                loadProducts()
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Status Section
    
    private var statusSection: some View {
        VStack(spacing: 8) {
            Text("状态")
                .font(.headline)
            Text(statusText)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var statusText: String {
        if purchaseHelper.isLoadingProducts {
            return "正在加载产品信息..."
        } else if purchaseHelper.isPurchasing {
            return "正在购买..."
        } else {
            return "就绪"
        }
    }
    
    // MARK: - Products Section
    
    private var productsSection: some View {
        VStack(spacing: 16) {
            ForEach(Array(PurchaseConfig.allProductIDs.sorted()), id: \.self) { productID in
                ProductCardView(
                    productID: productID,
                    product: purchaseHelper.getProduct(productID: productID),
                    isPurchased: purchaseHelper.isPurchased(productID: productID),
                    isPurchasing: purchaseHelper.isPurchasing,
                    onPurchase: {
                        purchaseProduct(productID: productID)
                    }
                )
            }
        }
    }
    
    // MARK: - Restore Button
    
    private var restoreButton: some View {
        Button(action: {
            restorePurchases()
        }) {
            Text("恢复购买")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
        }
    }
    
    // MARK: - Event Log Section
    
    private var eventLogSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("事件日志")
                .font(.headline)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(eventLogs, id: \.self) { log in
                        Text(log)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 200)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Setup
    
    private func setupPurchaseHelper() {
        // 配置产品ID和类型映射
        let productTypeMap = buildProductTypeMap()
        purchaseHelper.configure(
            productIDs: PurchaseConfig.allProductIDs,
            productTypeMap: productTypeMap
        )
        
        // 统一事件回调 - 记录所有事件
        purchaseHelper.onEvent = { event in
            DispatchQueue.main.async {
                appendEventLog(event.description)
            }
        }
    }
    
    private func loadProducts() {
        Task {
            do {
                try await purchaseHelper.loadProducts()
            } catch {
                showAlert(title: "错误", message: "加载产品失败: \(error.localizedDescription)")
            }
        }
    }
    
    private func purchaseProduct(productID: String) {
        Task {
            do {
                try await purchaseHelper.purchase(productID: productID)
                showAlert(title: "成功", message: "购买成功！")
            } catch {
                if let purchaseError = error as? PurchaseError,
                   purchaseError == .userCancelled {
                    // 用户取消，不显示错误
                } else {
                    showAlert(title: "失败", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func restorePurchases() {
        Task {
            do {
                try await purchaseHelper.restorePurchases()
                showAlert(title: "成功", message: "已恢复购买")
            } catch {
                showAlert(title: "失败", message: error.localizedDescription)
            }
        }
    }
    
    private func appendEventLog(_ text: String) {
        let timestamp = DateFormatter.logFormatter.string(from: Date())
        let logText = "[\(timestamp)] \(text)"
        eventLogs.append(logText)
        
        // 限制日志数量
        if eventLogs.count > 100 {
            eventLogs.removeFirst()
        }
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
    
    /// 构建产品类型映射
    private func buildProductTypeMap() -> [String: ProductType] {
        var typeMap: [String: ProductType] = [:]
        
        // 消耗型产品
        for productID in PurchaseConfig.consumableProductIDs {
            typeMap[productID] = .consumable
        }
        
        // 非消耗型产品
        for productID in PurchaseConfig.nonConsumableProductIDs {
            typeMap[productID] = .nonConsumable
        }
        
        // 非自动续订订阅
        for productID in PurchaseConfig.nonRenewingSubscriptionProductIDs {
            typeMap[productID] = .nonRenewingSubscription
        }
        
        // 自动续订订阅
        for productID in PurchaseConfig.autoRenewingSubscriptionProductIDs {
            typeMap[productID] = .autoRenewingSubscription
        }
        
        return typeMap
    }
}

// MARK: - Product Card View

private struct ProductCardView: View {
    let productID: String
    let product: Product?
    let isPurchased: Bool
    let isPurchasing: Bool
    let onPurchase: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                // 使用 Product 对象的 displayName（支持国际化）
                Text(product?.displayName ?? productID)
                    .font(.headline)
                
                if let product = product {
                    Text(product.displayPrice)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                } else {
                    Text("加载中...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if isPurchased {
                Text("已购买")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
            } else {
                Button(action: onPurchase) {
                    if isPurchasing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(width: 80, height: 44)
                    } else {
                        Text("购买")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 44)
                    }
                }
                .background(isPurchasing ? Color.gray : Color.blue)
                .cornerRadius(8)
                .disabled(isPurchasing)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Preview

struct SwiftUISampleView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUISampleView()
    }
}

