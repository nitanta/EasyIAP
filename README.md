# EasyIAP

An ios package for in app purchase integration.

# Integration

1. Xcode -> File -> Swift Packages -> Add Package Dependencies
2. put `https://github.com/nitanta/EasyIAP.git` and follow the prompts.

# Usage

1. Set the product ids for fetching data
    ``` Swift
        //Set the product ids before fetching it
        public func setProductIds(ids: [String]) 
    ```
    
2. Purchase a prudct
    ``` Swift
        //Purchase the selected SKProduct
        public func purchase(product: SKProduct, completion: @escaping ((IAPState)->Void))
    ```
    
3. The IAP states during transaction
    ``` Swift
      //Different states for the IAP purchase transaction
        case setProductIds
        case disabled
        case restored(SKPaymentTransaction?)
        case purchased(SKProduct?, SKPaymentTransaction)
        case productList([SKProduct])
        case emptyProducts
        case receiptDownload(String)
    ```
    
4. Restore the IAP purchase
    ``` Swift
        //Restore the IAP purchase
        public func restorePurchase(completion: @escaping ((IAPState)->Void))
    ```
    
5. Fetch available prouducts in the store
    ``` Swift
        //Get the available products in the store
        public func fetchAvailableProducts(completion: @escaping ((IAPState)->Void))
    ```
    
6. Get the purchase receipt
    ``` Swift
        //Get the purchase receipt
        public func getPurchaseReceipt(completion: @escaping ((IAPState)->Void))
    ```
