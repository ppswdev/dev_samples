//
//  ShopMainView.swift
//  DecibelMeterDemo
//
//  Created by xiaopin on 2025/11/6.
//

import SwiftUI
import StoreKit

struct ShopMainView: View {
    @StateObject private var viewModel = ShopViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // 加载状态
                    if viewModel.isLoading {
                        ProgressView("加载产品中...")
                            .padding()
                    }
                    
                    // 错误提示
                    if let errorMessage = viewModel.errorMessage {
                        errorSection(message: errorMessage)
                    }
                    
                    // 产品列表（按类型分组）
                    productsSection
                    
                    // 恢复购买按钮
                    restoreButton
                }
                .padding()
            }
            .navigationTitle("商店")
            .refreshable {
                viewModel.loadProducts()
            }
        }
    }
    
    // MARK: - Error Section
    
    private func errorSection(message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Products Section
    
    private var productsSection: some View {
        VStack(spacing: 20) {
            // 自动续订订阅
            if let subscriptions = viewModel.productsByType[.autoRenewingSubscription], !subscriptions.isEmpty {
                productGroup(
                    title: "订阅服务",
                    icon: "star.fill",
                    products: subscriptions
                )
            }
            
            // 非自动续订订阅
            if let nonRenewingSubs = viewModel.productsByType[.nonRenewingSubscription], !nonRenewingSubs.isEmpty {
                productGroup(
                    title: "限时订阅",
                    icon: "clock.fill",
                    products: nonRenewingSubs
                )
            }
            
            // 非消耗型产品
            if let nonConsumables = viewModel.productsByType[.nonConsumable], !nonConsumables.isEmpty {
                productGroup(
                    title: "永久购买",
                    icon: "crown.fill",
                    products: nonConsumables
                )
            }
            
            // 消耗型产品
            if let consumables = viewModel.productsByType[.consumable], !consumables.isEmpty {
                productGroup(
                    title: "消耗品",
                    icon: "bag.fill",
                    products: consumables
                )
            }
        }
    }
    
    /// 产品组视图
    private func productGroup(title: String, icon: String, products: [ShopViewModel.ProductInfo]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
            }
            .padding(.horizontal)
            
            ForEach(products) { productInfo in
                ProductCardView(
                    productInfo: productInfo,
                    buttonText: viewModel.getButtonText(for: productInfo.productID),
                    canPurchase: viewModel.canPurchase(productID: productInfo.productID),
                    onPurchase: {
                        viewModel.purchaseProduct(productID: productInfo.productID)
                    }
                )
            }
        }
    }
    
    // MARK: - Restore Button
    
    private var restoreButton: some View {
        Button(action: {
            viewModel.restorePurchases()
        }) {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text("恢复购买")
            }
            .font(.headline)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Product Card View

private struct ProductCardView: View {
    let productInfo: ShopViewModel.ProductInfo
    let buttonText: String
    let canPurchase: Bool
    let onPurchase: () -> Void
    
    @State private var isPurchasing = false
    
    var body: some View {
        HStack(spacing: 16) {
            // 产品信息
            VStack(alignment: .leading, spacing: 8) {
                // 产品标题（从 Product 对象获取，支持国际化）
                if let product = productInfo.product {
                    Text(product.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                } else {
                    // 如果产品信息还未加载，显示产品ID
                    Text(productInfo.productID)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                
                // 产品描述
                if let product = productInfo.product, !product.description.isEmpty {
                    Text(product.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // 产品价格
                HStack(spacing: 4) {
                    if let product = productInfo.product {
                        Text(product.displayPrice)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    } else {
                        Text("加载中...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // 购买按钮
            Button(action: {
                isPurchasing = true
                onPurchase()
                // 延迟重置状态（实际应该通过事件回调更新）
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isPurchasing = false
                }
            }) {
                if isPurchasing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(width: 100, height: 44)
                } else {
                    Text(buttonText)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 100, height: 44)
                }
            }
            .background(canPurchase ? Color.blue : Color.gray)
            .cornerRadius(8)
            .disabled(!canPurchase || isPurchasing)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    ShopMainView()
}
