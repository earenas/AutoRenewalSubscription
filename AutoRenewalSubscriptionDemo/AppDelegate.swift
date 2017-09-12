//
//  AppDelegate.swift
//  AutoRenewalSubscriptionDemo
//
//  Created by Eric Arenas on 8/3/17.
//  All Rights Reserved
//// Copyright © 2017 Latin OS Trends -  Eric Arenas
//
// IF YOU WANT TO GET A LICENSE FOR THIS SOURCE CODE, PLEASE DOWNLOAD MY APPLICATION ON THE APP STORE AND SUBSCRIBE.
// BY DOWNLOADING THIS SOURCE CODE, YOU HEREBY AGREE TO DOWNLOAD MY APPLICATION ON THE APP STORE AND SUBSCRIBE TO IT.
// BY USING THIS PORTIONS OR ALL OF THIS SOURCE CODE, YOU HEREBY AGREE TO DOWNLOAD MY APPLICATION ON THE APP STORE AND SUBSCRIBE TO IT.
// 
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
////


// #1 add libraries StoreKit and TPInAppReceipt
import UIKit
import StoreKit
import TPInAppReceipt

@UIApplicationMain

// #2 AppDelegate inherit from SKPaymentTransactionObserver and SKProductsRequestDelegate
class AppDelegate: UIResponder, UIApplicationDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate
{

    var window: UIWindow?
    
    // Subscription Products Identifiers, taken from Itunes Connect from your App
    let basicAccessProduct : String = "AutoRenewalSubscriptionDemoBasic"
    let plusAccessProduct : String = "AutoRenewalSubscriptionDemoPlus"
    let premiumAccessProduct : String = "AutoRenewalSubscriptionDemoPremium"
    
    var skProductArray : [SKProduct]? //skProductArray holds the localized versions of the products
    
    //debug print statements control
    let debugPrintStatements : Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        SKPaymentQueue.default().add(self)
        // Override point for customization after application launch.
        
        self.SKProductsRequestStart()
        //starting the product request
        
        return true
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    // SKPaymentTransactionObserver methods/functions
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        // checking what type of transaction is...
        for transaction in transactions
        {
            //checking for errors, like "Cannot connect to iTunes Store" before proceeding
            
            if transaction.error != nil
            {
                if debugPrintStatements
                { print("Auto Renewal Subscription Demo - An error was detected when processing the transaction. Please see more details here: \(transaction.error!.localizedDescription)")}
                
                // We could alert the user if needed
                NotificationCenter.default.post(name: Notification.Name("paymentFailed"), object: nil, userInfo: ["error":transaction.error!.localizedDescription])
            }
            
                switch transaction.transactionState
                {
                    case .purchasing:
                        purchasingState (for: transaction, in: queue)
                    case .purchased:
                        purchasedState (for: transaction, in: queue)
                    case .restored:
                        restoredState (for: transaction, in: queue)
                    case .failed:
                        failedState (for: transaction, in: queue)
                    case .deferred:
                        deferredState (for: transaction, in: queue)
                }
            }
            
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error)
    {
        //this queue is used when there are errors while restoring the previous purchases
        
        if debugPrintStatements
        { print("Auto Renewal Subscription Demo - User tried to restore a subscription but there were errors")}
        
        NotificationCenter.default.post(name: Notification.Name("RestoreFailed"), object: nil, userInfo: ["error":error.localizedDescription])
    }
    
    func purchasingState (for transaction : SKPaymentTransaction , in queue : SKPaymentQueue)
    {
        // not much to do here, other than logging it and letting it go...
        if debugPrintStatements
        { print("Auto Renewal Subscription Demo - User is Purchasing a subscription with transaction \(transaction) ")}
        
    }
    
    func purchasedState (for transaction : SKPaymentTransaction , in queue : SKPaymentQueue)
    {
        if debugPrintStatements
        { print("Auto Renewal Subscription Demo - User sucessfully purchased a subscription with transaction \(transaction) and productID: \(transaction.payment.productIdentifier)") }
        
        // Always complete the transaction, otherwise these transactions remain on the queue forever.
        queue.finishTransaction(transaction)
        
        let subscriptionProducts : [String] = [basicAccessProduct,plusAccessProduct,premiumAccessProduct]
        
        for product in subscriptionProducts
        {
            if verifyReceipt(productToVerify:product)
            {
                // In order to enable the subscription, we send a notification that the payment was successful
                NotificationCenter.default.post(name: Notification.Name("paymentCompleted"), object: nil, userInfo:nil )
                
            
                
                break
            }
        }
        
    }
    
    func restoredState (for transaction : SKPaymentTransaction , in queue : SKPaymentQueue)
    {
        
        if debugPrintStatements
        { print("Auto Renewal Subscription Demo - User restored an already purchased a subscription with transaction \(transaction) ") }
        
        queue.finishTransaction(transaction)
        
        if transaction.error == nil
        {
            // In order to enable subscription, we send a notification that the restore was successful, assuming there are no errors
            NotificationCenter.default.post(name: Notification.Name("paymentRestored"), object: nil, userInfo: nil)
        }
        else
        {
            if debugPrintStatements
            { print("Auto Renewal Subscription Demo - Trying to restore previous purchases but there are errors. For more details please see:\n \(transaction.error!.localizedDescription)")}
        }
        
    }
    
    func failedState (for transaction : SKPaymentTransaction , in queue : SKPaymentQueue)
    {
        if debugPrintStatements
        { print("Auto Renewal Subscription Demo - Failed to purchase a subscription with transaction \(transaction) ")}
        //you need to complete the transaction otherwise, they remain in the queue... forever
        
        queue.finishTransaction(transaction)
    }
    
    func deferredState (for transaction : SKPaymentTransaction , in queue : SKPaymentQueue)
    {
        if debugPrintStatements
        { print("Auto Renewal Subscription Demo - Deferred a subscription with transaction \(transaction) ")}
        
        //you need to complete the transaction otherwise, they remain in the queue... forever
        queue.finishTransaction(transaction)
    }
    
    func isStringEmptyOrNil(paramString : String?) -> Bool
    { //returns true if the paramString is empty or NIL, false otherwise
        if paramString == nil {return true}
        else if paramString!.characters.count == 0 {return true}
        else {return false}
    }
    
    func verifyReceipt(productToVerify:String) -> Bool
    {
        //This method verifies the receipt and checks if there is any valid subscription.
        // requires import TPInAppReceipt
        // gets Subscription Products in productToVerify parameter
        
        // Setting Date Formatter
        // ISO8601 Date Formatter
        let dformatterString = DateFormatter()
        dformatterString.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        dformatterString.calendar = Calendar(identifier: .iso8601)
        dformatterString.locale = Locale(identifier: "en_US_POSIX")
        dformatterString.timeZone = TimeZone(secondsFromGMT:0)
        
        if debugPrintStatements
        { print("Auto Renewal Subscription Demo - verifyReceipt - Check Active Auto Renewable Subscriptions for \(productToVerify) Purchases using today's date")}
        
        do
        {
            let receipt = try InAppReceiptManager.shared.receipt()
            //verify receipt
            
            do
            {
                try receipt.verify()
            }
            catch
            {
                if debugPrintStatements
                { print("Auto Renewal Subscription Demo - verifyReceipt - There was an error when verifying the receipt, with error:\(error)")}
                return false
            }
            let todayDate : Date = Date()
            
            //getting all subscriptions active as of today
            let currentSubs : InAppPurchase? = receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: productToVerify, forDate: todayDate)
            if currentSubs == nil
            {
                if debugPrintStatements
                { print("Auto Renewal Subscription Demo - verifyReceipt - There were no \(productToVerify) subscriptions found")}
                return false
            }
            else
            {
                let expirationDateSubscription : Date = currentSubs!.subscriptionExpirationDate
                
                if expirationDateSubscription <= todayDate
                {
                    if debugPrintStatements
                    { print("Auto Renewal Subscription Demo - verifyReceipt - The \(productToVerify) subscription has been expired, with a expiration date of \(expirationDateSubscription)")}
                    return false
                }
                else
                {
                    // expirationDateSubscription > todayDate
                    
                    //need to check cancel date, if it exists
                    if isStringEmptyOrNil(paramString: currentSubs!.cancellationDateString)
                    {
                        //valid subscription not yet cancel and not expired
                        if debugPrintStatements
                        { print("Auto Renewal Subscription Demo - verifyReceipt - The \(productToVerify) subscription is valid, and will expire on: \(expirationDateSubscription)")}
                        return true
                    }
                    else
                    {
                        //currentSubs!.cancellationDateString is not null or empty, need to compare dates
                        
                        let cancelDateSubscription : Date = dformatterString.date(from: currentSubs!.cancellationDateString!)!
                        // cancelDateSubscription cannot be nil
                        
                        if cancelDateSubscription >= todayDate
                        {
                            if debugPrintStatements
                            { print("Auto Renewal Subscription Demo - verifyReceipt - The \(productToVerify) subscription has been cancelled, with a cancel date of \(cancelDateSubscription)")}
                            return false
                        }
                        else
                        {
                            //subscription valid but cancelled for a future date
                            if debugPrintStatements
                            { print("Auto Renewal Subscription Demo - The \(productToVerify) subscription has been cancelled but it is still valid. The future cancel date is:  \(cancelDateSubscription)")}
                            return true
                        }
                    } //end of else //currentSubs!.cancellationDateString is not null, need to compare dates
                    
                } //end of else // expirationDateSubscription > todayDate
            } //end of else // currentSubs != nil
            
        } //end of do at the start of this func
        catch
        {
            if debugPrintStatements
            { print("Auto Renewal Subscription Demo - verifyReceipt - There was an error with error code : \(error) ")}
            return false
        }
    } // end of func verifyReceipt()
    
    //SKProductsRequestDelegate methods/funcs
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse)
    {
        //An SKProductsRequest object is used to retrieve localized information about a list of products from the Apple App Store. Your application uses this request to present localized prices and other information to the user without having to maintain that list itself. (from Apple Documentation)
        
        //in this app, we stored the pricing and product names (localized) in the skProductArray
        skProductArray = response.products
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error)
    {
        if request is SKProductsRequest
        {
            if debugPrintStatements
            { print("Auto Renewal Subscription Demo - Error - Auto Renewal Subscription. Description of error: \(error.localizedDescription)")}
        }
    }
    
    func SKProductsRequestStart() -> Void
    {
        let products = Set([basicAccessProduct,plusAccessProduct,premiumAccessProduct])
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
    }
    
    func purchase(productParam : SKProduct)
    {
        if skProductArray != nil
        {
            if (skProductArray?.count)! > 0
            {
                let payment = SKPayment(product: productParam)
                SKPaymentQueue.default().add(payment)
                // purchasing the product in productParam
            }
            else
            {
                if debugPrintStatements
                { print("Auto Renewal Subscription Demo - Error in the purchase function. Products not loaded from Apple Store correctly")}
            }
        }
        else
        {
            if debugPrintStatements
            { print("Auto Renewal Subscription Demo - Error in the purchase function. Products array is empty. Products were not loaded from Apple Store correctly")}
        }
        
    }
    
    func restorePurchases()
    {
        // this is how we restore purchases
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func getProducts() -> [SKProduct]?
    {
        return self.skProductArray
    }
    
    
}

