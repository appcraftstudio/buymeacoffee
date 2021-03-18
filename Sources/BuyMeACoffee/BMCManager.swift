//
//  BMCManager.swift
//
//  Created by François Boulais on 30/06/2020.
//  Copyright © 2020 App Craft Studio. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import SafariServices
import StoreKit

public final class BMCManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    public static let shared = BMCManager()
    
    // MARK: - Public properties
    
    /// The view controller used to present donation flow.
    public var presentingViewController: UIViewController?
    
    /// This text is displayed to supporters immediately after they make a payment.
    public var thankYouMessage: String?
    
    // MARK: - Internal properties
    
    internal var product: SKProduct?

    // MARK: - Private properties
    
    private var username = "appcraftstudio"
    private var productsRequest: SKProductsRequest?
    
    private lazy var loadingViewController: UIViewController = {
        let activityIndicatorView: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            activityIndicatorView = UIActivityIndicatorView(style: .large)
        } else {
            activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        }
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.color = BMCColor.default.background
        activityIndicatorView.startAnimating()
        
        let viewController = UIViewController()
        viewController.view.backgroundColor = .white
        viewController.view.addSubview(activityIndicatorView)
        viewController.modalPresentationStyle = .formSheet
        
        if #available(iOS 13.0, *) {
            viewController.isModalInPresentation = true
        }

        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
        ])
        
        return viewController
    }()

    private var url: URL? {
        URL(string: "https://www.buymeacoffee.com/".appending(username))
    }
        
    // MARK: - Public functions
    
    /**
     Configure the manager for future donation requests.
     - parameters:
        - username: The username you've chosen on www.buymeacoffee.com.
     */
    public func configure(username: String) {
        self.username = username

        guard SKPaymentQueue.canMakePayments() else {
            return
        }
        
        if let productIdentifier = Bundle.main.bundleIdentifier?.appending(".buymeacoffee") {
            productsRequest?.cancel()
            productsRequest = SKProductsRequest(productIdentifiers: [productIdentifier])
            productsRequest?.delegate = self
            productsRequest?.start()
        }
    }
    
    /**
     Start the donation flow on presenting view controller.
     */
    @objc public func start() {
        
        guard SKPaymentQueue.canMakePayments(), let product = product else {
            return fallback()
        }
        if #available(iOS 13.0, *) {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        } else {
            guard let presentingViewController = presentingViewController else {
                fatalError("presentingViewController must be set.")
            }
            
            
            presentingViewController.present(loadingViewController, animated: true) {
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().add(payment)
            }
        }
    }
    
    // MARK: - Private functions
    
    private override init() { }
    
    private func fallback() {
        guard let url = url else {
            return
        }
        
        let viewController = SFSafariViewController(url: url)
        viewController.preferredControlTintColor = BMCColor.default.background
        viewController.modalPresentationStyle = .formSheet
        presentingViewController?.present(viewController, animated: true)
    }
    
    private func showPurchasedMessage() {
        let message = thankYouMessage ?? "Thank you for supporting 🎉"
        let alertController = UIAlertController(title: "Buy Me a Coffee", message: message, preferredStyle: .alert)
        
        alertController.addAction(.init(title: "Close", style: .default, handler: { [weak self] _ in
            self?.loadingViewController.dismiss(animated: true)
        }))
        
        alertController.view.tintColor = BMCColor.default.background
        loadingViewController.present(alertController, animated: true)
    }
    
    // MARK: - SKProductsRequestDelegate
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        product = response.products.first
        productsRequest = nil
    }
    
    // MARK: - SKPaymentTransactionObserver
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                showPurchasedMessage()
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                loadingViewController.dismiss(animated: true) { [weak self] in
                    if (transaction.error as? SKError)?.code != .paymentCancelled {
                        self?.fallback()
                    }
                }
            case .restored:
                break
            case .deferred:
                break
            case .purchasing:
                break
            @unknown default:
                break
            }
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        true
    }
}
#endif
