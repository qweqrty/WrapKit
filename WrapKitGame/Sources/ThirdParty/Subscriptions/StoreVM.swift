import StoreKit
import Combine
import SwiftUI // For ObservableObject

// Typealias for clarity
public typealias RenewalState = SKPaymentTransactionState // Using SKPaymentTransactionState as a proxy for renewal state

public class StoreVM: NSObject, ObservableObject {
    @Published public private(set) var subscriptions: [SKProduct] = []
    @Published public private(set) var purchasedSubscriptions: [SKProduct] = []
    @Published public private(set) var subscriptionGroupStatus: RenewalState?

    private let productIds: Set<String> = ["subscription.ads"]
    private var productsRequest: SKProductsRequest?
    private var transactionObserver: PaymentTransactionObserver?

    public override init() {
        super.init() // Required for NSObject initialization
        // Start observing transactions as early as possible
        transactionObserver = PaymentTransactionObserver(storeVM: self)
        SKPaymentQueue.default().add(transactionObserver!)

        // Request products
        Task {
            await requestProducts()
        }
    }

    deinit {
        // Clean up
        SKPaymentQueue.default().remove(transactionObserver!)
        productsRequest?.cancel()
    }

    // Request products from the App Store
    @MainActor
    func requestProducts() async {
        do {
            let products = try await fetchProducts()
            subscriptions = products.sorted { $0.price.doubleValue < $1.price.doubleValue } // Sort by price
            print("Fetched products: \(subscriptions.map { $0.productIdentifier })")
            await updateCustomerProductStatus()
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }

    private func fetchProducts() async throws -> [SKProduct] {
        try await withCheckedThrowingContinuation { continuation in
            let request = SKProductsRequest(productIdentifiers: productIds)
            request.delegate = self
            self.productsRequest = request
            // Store the continuation using associated object
            request.setContinuation(continuation)
            request.start()
        }
    }

    // Purchase a product
    public func purchase(_ product: SKProduct) async throws {
        guard SKPaymentQueue.canMakePayments() else {
            throw StoreError.paymentNotAllowed
        }

        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    @MainActor
    public func restorePurchases() async throws {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    // Update customer product status
    @MainActor
    func updateCustomerProductStatus() async {
        purchasedSubscriptions.removeAll()
        SKPaymentQueue.default().restoreCompletedTransactions()
        // Note: Actual entitlement checking requires server-side receipt validation
    }

    // Handle transaction updates (called by PaymentTransactionObserver)
    func handleTransaction(_ transaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            switch transaction.transactionState {
            case .purchased, .restored:
                if let product = self.subscriptions.first(where: { $0.productIdentifier == transaction.payment.productIdentifier }) {
                    self.purchasedSubscriptions.append(product)
                    self.subscriptionGroupStatus = .purchased
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                print("Transaction failed: \(String(describing: transaction.error))")
                SKPaymentQueue.default().finishTransaction(transaction)
                self.subscriptionGroupStatus = .failed
            case .purchasing, .deferred:
                break
            @unknown default:
                break
            }
        }
    }
}

// MARK: - SKProductsRequestDelegate
extension StoreVM: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        Task {
            await MainActor.run {
                if let continuation = request.getContinuation() {
                    continuation.resume(returning: response.products)
                }
                self.productsRequest = nil
            }
        }
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        Task {
            await MainActor.run {
                if let continuation = (request as? SKProductsRequest)?.getContinuation() {
                    continuation.resume(throwing: error)
                }
                self.productsRequest = nil
            }
        }
    }
}

// MARK: - Payment Transaction Observer
private class PaymentTransactionObserver: NSObject, SKPaymentTransactionObserver {
    weak var storeVM: StoreVM?

    init(storeVM: StoreVM) {
        self.storeVM = storeVM
        super.init()
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            storeVM?.handleTransaction(transaction)
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoredTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            storeVM?.handleTransaction(transaction)
        }
    }
}

// MARK: - Store Error
public enum StoreError: Error {
    case failedVerification
    case paymentNotAllowed
    case productNotFound
}

extension SKProduct: @retroactive Identifiable {
    
}

// MARK: - SKProductsRequest Continuation Support
private extension SKProductsRequest {
    private static var continuationKey: UInt8 = 0

    func setContinuation(_ continuation: CheckedContinuation<[SKProduct], Error>?) {
        objc_setAssociatedObject(self, &Self.continuationKey, continuation, .OBJC_ASSOCIATION_RETAIN)
    }

    func getContinuation() -> CheckedContinuation<[SKProduct], Error>? {
        objc_getAssociatedObject(self, &Self.continuationKey) as? CheckedContinuation<[SKProduct], Error>
    }
}
