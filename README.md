# EasyIAP

An ios package for in app purchase integration.

# Integration

1. Xcode -> File -> Swift Packages -> Add Package Dependencies
2. put `https://github.com/nitanta/EasyIAP.git` and follow the prompts.

# Usage

1. Determine product identifiers used in your app and create enum value for them using `IAPProductIdentifiable` protocol.
    ``` Swift
        enum IAPIdentifiers: IAPProductIdentifiable, CaseIterable {
        case yearly
        case monthly
        
        var term: PaymentTerm {
            switch self {
            case .yearly: return .yearly
            case .monthly: return .monthly
            }
        }
        
        var identifier: String {
            switch self {
            case .yearly: return "YEARLY_SUBSCRIPTION_IDENTIFIER"
            case .monthly: return "MONTHLY_SUBSCRIPTION_IDENTIFIER"
            }
        }
    }
    ```
2. Listen for the product info.
    ``` Swift
        // listen for products fetch result
        EasyIAP.shared.products.receive(on: RunLoop.main).sink { [weak self] products in
            guard let self = self else { return }
            // STORE FOR YOUR USAGE WITHIN APP, These are the instance of IAPProduct
        }.store(in: &bag)
    ```
3. Pass the identifiers to IAP class so that their details are retrieved from appstore and the result are listened from step 2.
    ``` Swift
        EasyIAP.shared.setProducts(availableProducts: Constant.IAPIdentifiers.allCases)
    ```
3. For purchasing
    ``` Swift
        EasyIAP.shared.purchase(product: /*IAPProduct*/)
    ```
4. Listen for the purchasing states
    ``` Swift
        // states when purchase is in progress
        EasyIAP.shared.productPurchaseState.receive(on: RunLoop.main).sink { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .failed(let error):
                /// handle errors properly
            case .purchased(let inAppPurchase):
                /// The purchase info is received here if completed
            default: break
            }
        }.store(in: &viewModel.bag)
    ``` 
5. Validating and other logic are handled by server. We can fetch latest receipt to be able to restore in server using following method from IAP.
    ``` Swift
        public func fetchLatestReceipt(force: Bool = false, completion: @escaping (_ receiptData: Data?, _ error: ReceiptError?) -> Void)
    ```
