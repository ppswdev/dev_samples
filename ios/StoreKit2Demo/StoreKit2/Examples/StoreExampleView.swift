//
//  StoreExampleView.swift
//  StoreKit2Manager
//
//  Created by xiaopin on 2025/12/6.
//

import SwiftUI
import StoreKit

/// StoreKit2Manager 使用示例的主视图
struct StoreExampleView: View {
    @StateObject private var viewModel = StoreExampleViewModel()
    
    var body: some View {
        NavigationView {
            List {
                // 已购买状态
                if !viewModel.purchasedTransactions.isEmpty {
                    Section("已购买") {
                        ForEach(viewModel.purchasedTransactions, id: \.id) { transaction in
                            PurchasedTransactionRow(transaction: transaction, viewModel: viewModel)
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
                    Button("应用评价") {
                        viewModel.requestReview()
                    }
                   
                    if #available(iOS 16.0, *) {
                        Button {
                            Task {
                                await viewModel.presentOfferCodeRedeemSheet()
                            }
                        } label: {
                            Text("优惠代码兑换")
                        }
                    }
                    
                    Button("恢复购买") {
                        viewModel.restorePurchases()
                    }
                    
                    Button("刷新已购买记录") {
                        Task {
                            await viewModel.refreshPurchases()
                            await viewModel.loadSubscriptionInfo()
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
                    
                    
                    Button("打开订阅管理（URL）") {
                        viewModel.openSubscriptionManagement()
                    }
                    
                    NavigationLink("所有交易历史") {
                        TransactionHistoryView(viewModel: viewModel)
                    }

                    NavigationLink("当前有效交易记录") {
                        EffectiveTransactionHistoryView(viewModel: viewModel)
                    }

                     NavigationLink("最新产品交易记录（每个产品最新一笔交易）") {
                        LatestProductTransactionHistoryView(viewModel: viewModel)
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
                        
                        // 管理订阅按钮
                        Button("管理订阅") {
                            Task {
                                await viewModel.showSubscriptionManagement()
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
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 已购买交易行视图

struct PurchasedTransactionRow: View {
    let transaction: Transaction
    @ObservedObject var viewModel: StoreExampleViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let product = viewModel.products.first(where: { $0.id == transaction.productID }) {
                    Text(product.displayName)
                        .font(.headline)
                    Text(product.displayPrice)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text(transaction.productID)
                        .font(.headline)
                }
                
                // 显示过期日期（如果是订阅）
                if let expirationDate = transaction.expirationDate {
                    Text("过期: \(expirationDate, style: .date)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Label("已拥有", systemImage: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
        .padding(.vertical, 4)
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
        .navigationTitle("所有交易历史")
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

// MARK: - 当前有效交易记录视图

struct EffectiveTransactionHistoryView: View {
    @ObservedObject var viewModel: StoreExampleViewModel
    
    var body: some View {
        List {
            if viewModel.purchasedTransactions.isEmpty {
                Text("暂无有效交易记录")
                    .foregroundColor(.secondary)
            } else {
                Section {
                    Text("共 \(viewModel.purchasedTransactions.count) 条有效交易记录")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ForEach(viewModel.purchasedTransactions, id: \.id) { transaction in
                    EffectiveTransactionRow(transaction: transaction, viewModel: viewModel)
                }
            }
        }
        .navigationTitle("当前有效交易")
        .refreshable {
            await viewModel.refreshPurchases()
        }
    }
}

// MARK: - 最新产品交易记录视图

struct LatestProductTransactionHistoryView: View {
    @ObservedObject var viewModel: StoreExampleViewModel
    
    var body: some View {
        List {
            if viewModel.latestTransactions.isEmpty {
                Text("暂无最新交易记录")
                    .foregroundColor(.secondary)
            } else {
                Section {
                    Text("共 \(viewModel.latestTransactions.count) 个产品的最新交易")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ForEach(viewModel.latestTransactions, id: \.id) { transaction in
                    LatestTransactionRow(transaction: transaction, viewModel: viewModel)
                }
            }
        }
        .navigationTitle("最新产品交易")
        .refreshable {
            await viewModel.refreshPurchases()
        }
    }
}

// MARK: - 交易行视图

struct TransactionRow: View {
    let transaction: TransactionHistory
    @State private var isExpanded = false
    
    private var txn: StoreKit.Transaction {
        transaction.transaction
    }
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            // 详细信息
            transactionDetails
        } label: {
            // 摘要信息
            transactionSummary
        }
    }
    
    // MARK: - 摘要视图
    private var transactionSummary: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                // 产品名称或ID
                if let product = transaction.product {
                    Text(product.displayName)
                        .font(.headline)
                } else {
                    Text(transaction.productId)
                        .font(.headline)
                }
                
                Spacer()
                
                // 状态标签
                statusBadges
            }
            
            HStack(spacing: 12) {
                // 产品类型
                productTypeBadge
                
                // 价格
                if let price = txn.price {
                    Text("¥\(price)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                // 购买日期
                Text("购买: \(transaction.purchaseDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - 详细信息视图
    @ViewBuilder
    private var transactionDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            
            // 基本信息
            detailRow("产品ID", transaction.productId)
            detailRow("交易ID", "\(txn.id)")
            detailRow("产品类型", productTypeName)
            detailRow("所有权", ownershipTypeName)
            
            // 日期信息
            detailRow("购买日期", formatDateTime(transaction.purchaseDate))
            detailRow("原始购买日期", formatDateTime(txn.originalPurchaseDate))
            
            if let expirationDate = transaction.expirationDate {
                detailRow("过期日期", formatDateTime(expirationDate))
            }
            
            if let revocationDate = txn.revocationDate {
                detailRow("撤销日期", formatDateTime(revocationDate), color: .red)
            }
            
            // 交易信息
            if let price = txn.price {
                detailRow("价格", "¥\(price)")
            }
            
            if let currency = txn.currency {
                detailRow("货币", currency.identifier)
            }
            
            detailRow("购买数量", "\(txn.purchasedQuantity)")
            detailRow("是否升级", txn.isUpgraded ? "是" : "否")
            
            if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                detailRow("购买原因", purchaseReasonName)
            }
            
            // 订阅信息
            if transaction.product?.type == .autoRenewable || transaction.product?.type == .nonRenewable {
                if let subscriptionGroupID = txn.subscriptionGroupID {
                    detailRow("订阅组ID", subscriptionGroupID)
                }
            }
            
            // 撤销信息
            if transaction.isRefunded || transaction.isRevoked {
                if let revocationReason = txn.revocationReason {
                    detailRow("撤销原因", revocationReasonName(revocationReason), color: .red)
                }
            }
            
            // 环境信息
            detailRow("环境", environmentName)
            
            // 原始交易信息
            if txn.originalID != txn.id {
                detailRow("原始交易ID", "\(txn.originalID)")
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - 辅助视图
    
    @ViewBuilder
    private var statusBadges: some View {
        HStack(spacing: 4) {
            if transaction.isRefunded {
                Label("已退款", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption2)
                    .foregroundColor(.red)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(4)
            }
            
            if transaction.isRevoked {
                Label("已撤销", systemImage: "xmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(4)
            }
            
            if let expirationDate = transaction.expirationDate {
                let isExpired = expirationDate < Date()
                Label(isExpired ? "已过期" : "有效", systemImage: isExpired ? "clock.fill" : "checkmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(isExpired ? .red : .green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background((isExpired ? Color.red : Color.green).opacity(0.1))
                    .cornerRadius(4)
            }
        }
    }
    
    private var productTypeBadge: some View {
        Text(productTypeName)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(4)
    }
    
    private func detailRow(_ label: String, _ value: String, color: Color = .primary) -> some View {
        HStack {
            Text(label + ":")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            Text(value)
                .font(.caption)
                .foregroundColor(color)
            Spacer()
        }
    }
    
    // MARK: - 格式化方法
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
    // MARK: - 属性名称
    
    private var productTypeName: String {
        switch txn.productType {
        case .consumable:
            return "消耗品"
        case .nonConsumable:
            return "非消耗品"
        case .nonRenewable:
            return "非续订订阅"
        case .autoRenewable:
            return "自动续订订阅"
        default:
            return "未知"
        }
    }
    
    private var ownershipTypeName: String {
        switch transaction.ownershipType {
        case .purchased:
            return "用户购买"
        case .familyShared:
            return "家庭共享"
        default:
            return "未知"
        }
    }
    
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    private var purchaseReasonName: String {
        switch txn.reason {
        case .purchase:
            return "购买"
        case .renewal:
            return "续订"
        default:
            return "未知"
        }
    }
    
    private func revocationReasonName(_ reason: StoreKit.Transaction.RevocationReason) -> String {
        switch reason {
        case .developerIssue:
            return "开发者问题"
        case .other:
            return "其他原因"
        default:
            return "未知原因"
        }
    }
    
    private var environmentName: String {
        switch txn.environment {
        case .production:
            return "生产环境"
        case .sandbox:
            return "沙盒环境"
        case .xcode:
            return "Xcode 测试"
        default:
            return "未知"
        }
    }
}

// MARK: - 有效交易行视图

struct EffectiveTransactionRow: View {
    let transaction: Transaction
    @ObservedObject var viewModel: StoreExampleViewModel
    @State private var isExpanded = false
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            // 详细信息
            effectiveTransactionDetails
        } label: {
            // 摘要信息
            effectiveTransactionSummary
        }
    }
    
    // MARK: - 摘要视图
    private var effectiveTransactionSummary: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                // 产品名称或ID
                if let product = viewModel.products.first(where: { $0.id == transaction.productID }) {
                    Text(product.displayName)
                        .font(.headline)
                } else {
                    Text(transaction.productID)
                        .font(.headline)
                }
                
                Spacer()
                
                // 状态标签
                effectiveStatusBadges
            }
            
            HStack(spacing: 12) {
                // 产品类型
                effectiveProductTypeBadge
                
                // 价格
                if let price = transaction.price {
                    Text("¥\(price)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                // 购买日期
                Text("购买: \(transaction.purchaseDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - 详细信息视图
    @ViewBuilder
    private var effectiveTransactionDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            
            // 基本信息
            effectiveDetailRow("产品ID", transaction.productID)
            effectiveDetailRow("交易ID", "\(transaction.id)")
            effectiveDetailRow("产品类型", effectiveProductTypeName)
            effectiveDetailRow("所有权", effectiveOwnershipTypeName)
            
            // 日期信息
            effectiveDetailRow("购买日期", effectiveFormatDateTime(transaction.purchaseDate))
            effectiveDetailRow("原始购买日期", effectiveFormatDateTime(transaction.originalPurchaseDate))
            
            if let expirationDate = transaction.expirationDate {
                let isExpired = expirationDate < Date()
                effectiveDetailRow("过期日期", effectiveFormatDateTime(expirationDate), color: isExpired ? .red : .green)
            }
            
            // 交易信息
            if let price = transaction.price {
                effectiveDetailRow("价格", "¥\(price)")
            }
            
            if let currency = transaction.currency {
                effectiveDetailRow("货币", currency.identifier)
            }
            
            effectiveDetailRow("购买数量", "\(transaction.purchasedQuantity)")
            effectiveDetailRow("是否升级", transaction.isUpgraded ? "是" : "否")
            
            if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                effectiveDetailRow("购买原因", effectivePurchaseReasonName)
            }
            
            // 订阅信息
            if let product = viewModel.products.first(where: { $0.id == transaction.productID }),
               product.type == .autoRenewable || product.type == .nonRenewable {
                if let subscriptionGroupID = transaction.subscriptionGroupID {
                    effectiveDetailRow("订阅组ID", subscriptionGroupID)
                }
            }
            
            // 环境信息
            effectiveDetailRow("环境", effectiveEnvironmentName)
            
            // 原始交易信息
            if transaction.originalID != transaction.id {
                effectiveDetailRow("原始交易ID", "\(transaction.originalID)")
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - 辅助视图
    
    @ViewBuilder
    private var effectiveStatusBadges: some View {
        HStack(spacing: 4) {
            if let expirationDate = transaction.expirationDate {
                let isExpired = expirationDate < Date()
                Label(isExpired ? "已过期" : "有效", systemImage: isExpired ? "clock.fill" : "checkmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(isExpired ? .red : .green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background((isExpired ? Color.red : Color.green).opacity(0.1))
                    .cornerRadius(4)
            } else {
                Label("永久有效", systemImage: "checkmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(4)
            }
        }
    }
    
    private var effectiveProductTypeBadge: some View {
        Text(effectiveProductTypeName)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(4)
    }
    
    private func effectiveDetailRow(_ label: String, _ value: String, color: Color = .primary) -> some View {
        HStack {
            Text(label + ":")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            Text(value)
                .font(.caption)
                .foregroundColor(color)
            Spacer()
        }
    }
    
    // MARK: - 格式化方法
    
    private func effectiveFormatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
    // MARK: - 属性名称
    
    private var effectiveProductTypeName: String {
        switch transaction.productType {
        case .consumable:
            return "消耗品"
        case .nonConsumable:
            return "非消耗品"
        case .nonRenewable:
            return "非续订订阅"
        case .autoRenewable:
            return "自动续订订阅"
        default:
            return "未知"
        }
    }
    
    private var effectiveOwnershipTypeName: String {
        switch transaction.ownershipType {
        case .purchased:
            return "用户购买"
        case .familyShared:
            return "家庭共享"
        default:
            return "未知"
        }
    }
    
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    private var effectivePurchaseReasonName: String {
        switch transaction.reason {
        case .purchase:
            return "购买"
        case .renewal:
            return "续订"
        default:
            return "未知"
        }
    }
    
    private var effectiveEnvironmentName: String {
        switch transaction.environment {
        case .production:
            return "生产环境"
        case .sandbox:
            return "沙盒环境"
        case .xcode:
            return "Xcode 测试"
        default:
            return "未知"
        }
    }
}

// MARK: - 最新交易行视图

struct LatestTransactionRow: View {
    let transaction: Transaction
    @ObservedObject var viewModel: StoreExampleViewModel
    @State private var isExpanded = false
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            // 详细信息
            latestTransactionDetails
        } label: {
            // 摘要信息
            latestTransactionSummary
        }
    }
    
    // MARK: - 摘要视图
    private var latestTransactionSummary: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                // 产品名称或ID
                if let product = viewModel.products.first(where: { $0.id == transaction.productID }) {
                    Text(product.displayName)
                        .font(.headline)
                } else {
                    Text(transaction.productID)
                        .font(.headline)
                }
                
                Spacer()
                
                // 状态标签
                latestStatusBadges
            }
            
            HStack(spacing: 12) {
                // 产品类型
                latestProductTypeBadge
                
                // 价格
                if let price = transaction.price {
                    Text("¥\(price)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                // 购买日期
                Text("购买: \(transaction.purchaseDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - 详细信息视图
    @ViewBuilder
    private var latestTransactionDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            
            // 基本信息
            latestDetailRow("产品ID", transaction.productID)
            latestDetailRow("交易ID", "\(transaction.id)")
            latestDetailRow("产品类型", latestProductTypeName)
            latestDetailRow("所有权", latestOwnershipTypeName)
            
            // 日期信息
            latestDetailRow("购买日期", latestFormatDateTime(transaction.purchaseDate))
            latestDetailRow("原始购买日期", latestFormatDateTime(transaction.originalPurchaseDate))
            
            if let expirationDate = transaction.expirationDate {
                let isExpired = expirationDate < Date()
                latestDetailRow("过期日期", latestFormatDateTime(expirationDate), color: isExpired ? .red : .green)
            }
            
            // 交易信息
            if let price = transaction.price {
                latestDetailRow("价格", "¥\(price)")
            }
            
            if let currency = transaction.currency {
                latestDetailRow("货币", currency.identifier)
            }
            
            latestDetailRow("购买数量", "\(transaction.purchasedQuantity)")
            latestDetailRow("是否升级", transaction.isUpgraded ? "是" : "否")
            
            if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                latestDetailRow("购买原因", latestPurchaseReasonName)
            }
            
            // 订阅信息
            if let product = viewModel.products.first(where: { $0.id == transaction.productID }),
               product.type == .autoRenewable || product.type == .nonRenewable {
                if let subscriptionGroupID = transaction.subscriptionGroupID {
                    latestDetailRow("订阅组ID", subscriptionGroupID)
                }
            }
            
            // 环境信息
            latestDetailRow("环境", latestEnvironmentName)
            
            // 原始交易信息
            if transaction.originalID != transaction.id {
                latestDetailRow("原始交易ID", "\(transaction.originalID)")
            }
            
            // 是否在当前有效交易中
            let isInPurchased = viewModel.purchasedTransactions.contains(where: { $0.id == transaction.id })
            latestDetailRow("是否有效", isInPurchased ? "是（当前有效）" : "否（已过期或无效）", color: isInPurchased ? .green : .red)
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - 辅助视图
    
    @ViewBuilder
    private var latestStatusBadges: some View {
        HStack(spacing: 4) {
            // 检查是否在当前有效交易中
            let isInPurchased = viewModel.purchasedTransactions.contains(where: { $0.id == transaction.id })
            
            if isInPurchased {
                Label("当前有效", systemImage: "checkmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(4)
            } else {
                Label("已失效", systemImage: "clock.fill")
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(4)
            }
            
            if let expirationDate = transaction.expirationDate {
                let isExpired = expirationDate < Date()
                Label(isExpired ? "已过期" : "未过期", systemImage: isExpired ? "clock.fill" : "checkmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(isExpired ? .red : .green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background((isExpired ? Color.red : Color.green).opacity(0.1))
                    .cornerRadius(4)
            }
        }
    }
    
    private var latestProductTypeBadge: some View {
        Text(latestProductTypeName)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(4)
    }
    
    private func latestDetailRow(_ label: String, _ value: String, color: Color = .primary) -> some View {
        HStack {
            Text(label + ":")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            Text(value)
                .font(.caption)
                .foregroundColor(color)
            Spacer()
        }
    }
    
    // MARK: - 格式化方法
    
    private func latestFormatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
    // MARK: - 属性名称
    
    private var latestProductTypeName: String {
        switch transaction.productType {
        case .consumable:
            return "消耗品"
        case .nonConsumable:
            return "非消耗品"
        case .nonRenewable:
            return "非续订订阅"
        case .autoRenewable:
            return "自动续订订阅"
        default:
            return "未知"
        }
    }
    
    private var latestOwnershipTypeName: String {
        switch transaction.ownershipType {
        case .purchased:
            return "用户购买"
        case .familyShared:
            return "家庭共享"
        default:
            return "未知"
        }
    }
    
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    private var latestPurchaseReasonName: String {
        switch transaction.reason {
        case .purchase:
            return "购买"
        case .renewal:
            return "续订"
        default:
            return "未知"
        }
    }
    
    private var latestEnvironmentName: String {
        switch transaction.environment {
        case .production:
            return "生产环境"
        case .sandbox:
            return "沙盒环境"
        case .xcode:
            return "Xcode 测试"
        default:
            return "未知"
        }
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

