//
//  UIKitSampleViewController.swift
//  DecibelMeterDemo
//
//  使用 UIKit 的购买示例
//  演示如何在 UIKit 中使用 PurchaseHelper
//

import UIKit
import StoreKit

class UIKitSampleViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "订阅管理"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "状态: 未加载"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let productsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let restoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("恢复购买", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let eventLogTextView: UITextView = {
        let textView = UITextView()
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.backgroundColor = .systemGray6
        textView.isEditable = false
        textView.layer.cornerRadius = 8
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // MARK: - Properties
    
    private var productViews: [String: ProductView] = [:]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupPurchaseHelper()
        loadProducts()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(loadingIndicator)
        contentView.addSubview(productsStackView)
        contentView.addSubview(restoreButton)
        contentView.addSubview(eventLogTextView)
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Status Label
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            
            // Products Stack View
            productsStackView.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 24),
            productsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            productsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Restore Button
            restoreButton.topAnchor.constraint(equalTo: productsStackView.bottomAnchor, constant: 24),
            restoreButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            restoreButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Event Log
            eventLogTextView.topAnchor.constraint(equalTo: restoreButton.bottomAnchor, constant: 24),
            eventLogTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            eventLogTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            eventLogTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            eventLogTextView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        restoreButton.addTarget(self, action: #selector(restoreButtonTapped), for: .touchUpInside)
    }
    
    private func setupPurchaseHelper() {
        let helper = PurchaseHelper.shared
        
        // 配置产品ID和类型映射
        let productTypeMap = buildProductTypeMap()
        helper.configure(
            productIDs: PurchaseConfig.allProductIDs,
            productTypeMap: productTypeMap
        )
        
        // 统一事件回调 - 处理所有购买相关事件
        helper.onEvent = { [weak self] event in
            DispatchQueue.main.async {
                // 记录事件日志
                self?.appendEventLog(event.description)
                
                // 根据事件类型处理UI更新
                switch event {
                case .productsLoadStarted:
                    self?.loadingIndicator.startAnimating()
                    self?.updateStatus("正在加载产品信息...")
                    
                case .productsLoadSuccess:
                    self?.loadingIndicator.stopAnimating()
                    self?.updateStatus("产品加载成功")
                    self?.updateProductsUI()
                    
                case .productsLoadFailed:
                    self?.loadingIndicator.stopAnimating()
                    
                case .productInfoRetrieved:
                    // 产品信息更新时刷新UI
                    self?.updateProductsUI()
                    
                case .purchaseStatusUpdated, .purchaseStatusRefreshed:
                    // 购买状态更新时刷新UI
                    self?.updateProductsUI()
                    
                case .purchaseStarted:
                    self?.updateStatus("正在购买...")
                    
                case .purchaseSuccess(let productID, _):
                    self?.updateStatus("购买成功")
                    self?.updateProductsUI()
                    self?.showAlert(title: "购买成功", message: "已成功购买 \(productID)")
                    
                case .purchaseFailed(let productID, let error):
                    if let purchaseError = error as? PurchaseError,
                       purchaseError == .userCancelled {
                        self?.updateStatus("用户取消购买")
                        // 用户取消，不显示错误
                    } else {
                        self?.updateStatus("购买失败")
                        self?.showAlert(title: "购买失败", message: error.localizedDescription)
                    }
                    
                case .purchaseCancelled:
                    self?.updateStatus("用户取消购买")
                    
                case .restoreStarted:
                    self?.updateStatus("正在恢复购买...")
                    
                case .restoreSuccess:
                    self?.updateStatus("恢复购买成功")
                    self?.updateProductsUI()
                    self?.showAlert(title: "成功", message: "已恢复购买")
                    
                case .restoreFailed(let error):
                    self?.updateStatus("恢复购买失败")
                    self?.showAlert(title: "失败", message: error.localizedDescription)
                    
                default:
                    // 其他事件（如交易监听等）只记录日志
                    break
                }
            }
        }
    }
    
    private func loadProducts() {
        updateStatus("正在加载产品信息...")
        
        Task {
            do {
                try await PurchaseHelper.shared.loadProducts()
                updateStatus("产品加载成功")
            } catch {
                updateStatus("产品加载失败: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - UI Updates
    
    private func updateStatus(_ text: String) {
        statusLabel.text = "状态: \(text)"
    }
    
    private func updateProductsUI() {
        let helper = PurchaseHelper.shared
        
        // 清除现有视图
        productsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        productViews.removeAll()
        
        // 创建产品视图
        for productID in PurchaseConfig.allProductIDs.sorted() {
            let product = helper.getProduct(productID: productID)
            let isPurchased = helper.isPurchased(productID: productID)
            
            let productView = ProductView(
                productID: productID,
                product: product,
                isPurchased: isPurchased,
                onPurchase: { [weak self] productID in
                    self?.purchaseProduct(productID: productID)
                }
            )
            
            productViews[productID] = productView
            productsStackView.addArrangedSubview(productView)
        }
    }
    
    private func appendEventLog(_ text: String) {
        let timestamp = DateFormatter.logFormatter.string(from: Date())
        let logText = "[\(timestamp)] \(text)\n"
        
        eventLogTextView.text += logText
        
        // 自动滚动到底部
        let bottom = NSRange(location: eventLogTextView.text.count - 1, length: 1)
        eventLogTextView.scrollRangeToVisible(bottom)
    }
    
    // MARK: - Actions
    
    @objc private func restoreButtonTapped() {
        updateStatus("正在恢复购买...")
        
        Task {
            do {
                try await PurchaseHelper.shared.restorePurchases()
                updateStatus("恢复购买成功")
                showAlert(title: "成功", message: "已恢复购买")
            } catch {
                updateStatus("恢复购买失败: \(error.localizedDescription)")
                showAlert(title: "失败", message: error.localizedDescription)
            }
        }
    }
    
    private func purchaseProduct(productID: String) {
        updateStatus("正在购买 \(productID)...")
        
        Task {
            do {
                try await PurchaseHelper.shared.purchase(productID: productID)
                updateStatus("购买成功")
            } catch {
                if let purchaseError = error as? PurchaseError,
                   purchaseError == .userCancelled {
                    updateStatus("用户取消购买")
                } else {
                    updateStatus("购买失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
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

// MARK: - ProductView

private class ProductView: UIView {
    
    private let productID: String
    private let onPurchase: (String) -> Void
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let purchaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("购买", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(productID: String, product: Product?, isPurchased: Bool, onPurchase: @escaping (String) -> Void) {
        self.productID = productID
        self.onPurchase = onPurchase
        super.init(frame: .zero)
        
        setupUI()
        updateContent(product: product, isPurchased: isPurchased)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(statusLabel)
        containerView.addSubview(purchaseButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            statusLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: purchaseButton.leadingAnchor, constant: -16),
            
            purchaseButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            purchaseButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            purchaseButton.widthAnchor.constraint(equalToConstant: 80),
            purchaseButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        purchaseButton.addTarget(self, action: #selector(purchaseButtonTapped), for: .touchUpInside)
    }
    
    private func updateContent(product: Product?, isPurchased: Bool) {
        // 使用 Product 对象的 displayName（支持国际化）
        titleLabel.text = product?.displayName ?? productID
        
        if let product = product {
            priceLabel.text = product.displayPrice
        } else {
            priceLabel.text = "加载中..."
        }
        
        if isPurchased {
            statusLabel.text = "已购买"
            statusLabel.isHidden = false
            purchaseButton.isHidden = true
        } else {
            statusLabel.isHidden = true
            purchaseButton.isHidden = false
        }
    }
    
    @objc private func purchaseButtonTapped() {
        onPurchase(productID)
    }
}

