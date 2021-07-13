import StoreKit

public enum IAPState {
    case setProductIds
    case disabled
    case restored(SKPaymentTransaction?)
    case purchased(SKProduct?, SKPaymentTransaction)
    case productList([SKProduct])
    case emptyProducts
    case receiptDownload(String)
    
    var message: String{
        switch self {
        case .setProductIds: return "Product ids not set, call setProductIds method!"
        case .disabled: return "Purchases are disabled in your device!"
        case .restored: return "You've successfully restored your purchase!"
        case .purchased: return "You've successfully bought this purchase!"
        case .emptyProducts: return "There are no products listed."
        default: return ""
        }
    }
    
    public var gochatKey: String {
        switch self {
        case .purchased: return "new_purchase"
        case .restored: return "restore"
        default: return ""
        }
    }
}


public class EasyIAP: NSObject {
    
    public override init() { }
    
    fileprivate var productIds = [String]()
    fileprivate var productID = ""
    fileprivate var productsRequest = SKProductsRequest()
    
    fileprivate var productToPurchase: SKProduct?
    
    public var productListCompletion: ((IAPState)->Void)?
    public var purchaseCompletion: ((IAPState)->Void)?
    public var restoreCompletion: ((IAPState)->Void)?
    public var receiptCompletion: ((IAPState)->Void)?
    
    var isLogEnabled: Bool = true
    
    public func setProductIds(ids: [String]) {
        self.productIds = ids
    }

    private func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    public func purchase(product: SKProduct, completion: @escaping ((IAPState)->Void)) {
        self.purchaseCompletion = completion
        self.productToPurchase = product
        
        if self.canMakePurchases() {
            
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            productID = product.productIdentifier
            
        } else {
            completion(IAPState.disabled)
        }
    }
    
    public func restorePurchase(completion: @escaping ((IAPState)->Void)) {
        self.restoreCompletion = completion
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
    public func fetchAvailableProducts(completion: @escaping ((IAPState)->Void)){
        self.productListCompletion = completion
        if self.productIds.isEmpty {
            fatalError(IAPState.setProductIds.message)
        } else {
            productsRequest = SKProductsRequest(productIdentifiers: Set(self.productIds))
            productsRequest.delegate = self
            productsRequest.start()
        }
    }
    
    public func getPurchaseReceipt(completion: @escaping ((IAPState)->Void)) {
        self.receiptCompletion = completion
        if let receiptData = self.loadReceiptData() {
            completion(IAPState.receiptDownload(receiptData))
        } else {
            self.requestReceipt()
        }
    }
    
    private func loadReceiptData() -> String? {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
                return nil
        }
        do {
            let rawReceiptData = try Data(contentsOf: appStoreReceiptURL)
            let receiptData = rawReceiptData.base64EncodedString(options: .endLineWithCarriageReturn)
            return receiptData
        } catch {
            return nil
        }
    }
    
    private func requestReceipt() {
        let request = SKReceiptRefreshRequest()
        request.delegate = self
        request.start()
    }
}

extension EasyIAP: SKProductsRequestDelegate, SKPaymentTransactionObserver, SKRequestDelegate {
    
    public func requestDidFinish(_ request: SKRequest) {
        if request is SKReceiptRefreshRequest, let receiptData = self.loadReceiptData() {
            receiptCompletion?(IAPState.receiptDownload(receiptData))
        }
    }
    
    // REQUEST IAP PRODUCTS
    public func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        if (response.products.count > 0) {
            productListCompletion?(IAPState.productList(response.products))
        } else {
            productListCompletion?(IAPState.emptyProducts)
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        if request is SKReceiptRefreshRequest {
            
        }
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        restoreCompletion?(IAPState.restored(nil))
    }
    
    // IAP PAYMENT QUEUE
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    purchaseCompletion?(IAPState.purchased(self.productToPurchase, trans))
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    purchaseCompletion?(IAPState.restored(trans))
                default: break
                }
            }
        }
    }
    
}

extension SKProduct {
    public var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
    
    public func dateString() -> String {
        let period:String = {
            switch self.subscriptionPeriod?.unit {
            case .day: return "day"
            case .week: return "week"
            case .month: return "month"
            case .year: return "year"
            case .none: return ""
            case .some(_): return ""
            }
        }()
        
        let numUnits = self.subscriptionPeriod?.numberOfUnits ?? 0
        let plural = numUnits > 1 ? "s" : ""
        return String(format: "%d %@%@", arguments: [numUnits, period, plural])
    }
}
