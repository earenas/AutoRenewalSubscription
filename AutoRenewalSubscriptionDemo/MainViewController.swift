//
//  MainViewController.swift
//  AutoRenewalSubscriptionTutorial
//
//  Created by Eric Arenas on 8/3/17.
//  All Rights Reserved
//// Copyright © 2017 Latin OS Trends -  Eric Arenas
//
// IF YOU WANT TO GET A LICENSE FOR THIS SOURCE CODE, PLEASE DOWNLOAD MY APPLICATION ON THE APP STORE AND SUBSCRIBE.
// BY DOWNLOADING THIS SOURCE CODE, YOU HEREBY AGREE TO DOWNLOAD MY APPLICATION ON THE APP STORE AND SUBSCRIBE TO IT.
// BY USING THIS SOURCE CODE, OR PORTIONS OF IT, YOU HEREBY AGREE TO DOWNLOAD MY APPLICATION ON THE APP STORE AND SUBSCRIBE TO IT.
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

import UIKit


class MainViewController: UIViewController
{

//Storyboard elements
    @IBOutlet weak var statusUILabel: UILabel!
    
    @IBOutlet weak var descriptionUILabel: UILabel!

    @IBOutlet weak var basicUIButton: UIButton!
    
    @IBOutlet weak var plusUIButton: UIButton!
    
    @IBOutlet weak var premiumUIButton: UIButton!
    
    @IBOutlet weak var restoreUIButton: UIButton!
    
    @IBOutlet weak var helpUIButton: UIButton!
    
//Class variables
    // Subscription Products, taken from Itunes Connect from your App
    let basicAccessProduct : String = "AutoRenewalSubscriptionDemoBasic"
    let plusAccessProduct : String = "AutoRenewalSubscriptionDemoPlus"
    let premiumAccessProduct : String = "AutoRenewalSubscriptionDemoPremium"
    
    //appDelegate for handling the Store Kit Payments and others
    let myAppDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
override func viewDidLoad()
{
    self.initialSetup()
    super.viewDidLoad()
    
    //adding notification observers
    NotificationCenter.default.addObserver(self, selector: #selector(self.paymentRestoreNotification), name: Notification.Name("paymentRestored"), object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.paymentCompletedNotification), name: Notification.Name("paymentCompleted"), object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.paymentFailedNotification), name: Notification.Name("paymentFailed"), object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.restoreFailedNotification), name: Notification.Name("RestoreFailed"), object: nil)
    
    
    //Verify that we have a valid subscription
    self.verifyValidSubscription()    
    
}

deinit
{
    NotificationCenter.default.removeObserver(self)
    //removing notification observers
}
    
func initialSetup()
{
    statusUILabel.layer.borderWidth = 0
    statusUILabel.layer.cornerRadius = 0
    statusUILabel.layer.borderColor = UIColor.black.cgColor
    
    descriptionUILabel.layer.borderWidth = 1.0
    descriptionUILabel.layer.cornerRadius = 8
    descriptionUILabel.layer.borderColor = UIColor.black.cgColor
    
    basicUIButton.layer.borderWidth = 1.0
    basicUIButton.layer.cornerRadius = 8
    basicUIButton.layer.borderColor = UIColor.black.cgColor
    
    plusUIButton.layer.borderWidth = 1.0
    plusUIButton.layer.cornerRadius = 8
    plusUIButton.layer.borderColor = UIColor.black.cgColor
    
    premiumUIButton.layer.borderWidth = 1.0
    premiumUIButton.layer.cornerRadius = 8
    premiumUIButton.layer.borderColor = UIColor.black.cgColor
    
    restoreUIButton.layer.borderWidth = 1.0
    restoreUIButton.layer.cornerRadius = 8
    restoreUIButton.layer.borderColor = UIColor.black.cgColor
    
    helpUIButton.layer.borderWidth = 0
    helpUIButton.layer.cornerRadius = 0
    helpUIButton.layer.borderColor = UIColor.black.cgColor
}

override func didReceiveMemoryWarning()
{
    super.didReceiveMemoryWarning()
}


func paymentCompletedNotification() -> Void
{
    // this method is called by the notification observer
    // and in this case, we are just validating the subscription
    self.verifyValidSubscription()
}

func paymentRestoreNotification() -> Void
{
    // this method is called by the notification observer
    
    // and in this case, we are just validating the subscription
    self.verifyValidSubscription()
    
    //and closing the alert explaining the restore process
    NotificationCenter.default.post(name: Notification.Name("RestoreCompletedHideAlert"), object: nil, userInfo: nil)
    
}
    
func paymentFailedNotification(_ notification: NSNotification) -> Void
{
    // this method is called by the notification observer when there is an error in processing the payments
    
    //feel free to comment the alert function if you do not want to display the alert to the user
    if let errorMessage = notification.userInfo?["error"] as? String
    {
        let alertFailed = UIAlertController(title: "Auto Renewal Subscription Demo", message: "An error was detected when processing the subscription transaction. Please see more details here:\n \(errorMessage)", preferredStyle: .alert)
        alertFailed.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertFailed, animated: true, completion: nil)
    }
}
    
func restoreFailedNotification(_ notification: NSNotification) -> Void
{
    // this method is called by the notification observer when there is an error in processing the restore payments
    
    // closing the alert explaining the restore process
    self.hideRestoreInProgressAlert()
    
    if let errorMessage = notification.userInfo?["error"] as? String
    {
        let alertRestoreFailed = UIAlertController(title: "Auto Renewal Subscription Demo", message: "An error was detected when restoring the previous purchases. Please see more details here:\n \(errorMessage)", preferredStyle: .alert)
        alertRestoreFailed.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertRestoreFailed, animated: true, completion: nil)
    }
}
    

func verifyValidSubscription() -> Void
{
    let subscriptionProducts : [String] = [basicAccessProduct,plusAccessProduct,premiumAccessProduct]
    
    var validSubscription : Bool = false
    var validProduct : String = ""
    
    for product in subscriptionProducts
    {
        if self.myAppDelegate.verifyReceipt(productToVerify: product)
        {
            //enable subscription for product
            validSubscription = true
            validProduct = product
            break
        }
    }
    
    if validSubscription
    {
        self.enableSubscriptionForProduct(productParam: validProduct)
    }
    else
    {
        self.displayFreeContent() // if no valid subscription was found, display free content.
    }
    
    
}

func enableSubscriptionForProduct(productParam:String) -> Void
{
    self.descriptionUILabel.text = "Thank you for your subscription.\nYou are subscribed to our product: \(productParam)"
    //you could enable downloading the subscription content or other methods here...
}

func displayFreeContent() -> Void
{
    //if there was no valid subscription found,  you still need to let your users use your app, ideally displaying free content
    self.descriptionUILabel.text = "No subscription found.\nThanks for trying our App.\nPlease consider upgrading your app experience with our premium products below."
    
}


func processPurchase(productParam:String) -> Void
{
    //This function process the purchase for the product "productParam"
    
    //getting the products from AppDelegate
    let skproducts = myAppDelegate.getProducts()
    if skproducts != nil
    {
        if skproducts!.count > 0
        {
            // there are localized products downloaded from the Apple Store
            
            for skproduct in skproducts!
            {
                if skproduct.productIdentifier == productParam
                {
                    self.myAppDelegate.purchase(productParam: skproduct)
                    break
                }
                else
                {
                    //for informational purposes, feel free to delete this else section
                    if myAppDelegate.debugPrintStatements
                    {print("Trying to purchase \(productParam) but found \(skproduct.productIdentifier)")}
                }
            }
        }
    }
}

func showRestoreInProgressAlert()
{
    let alertRestore = UIAlertController(title: "Auto Renewal Subscription Demo - Restoring Purchase", message: "Restoring your previous purchases. This message will close automatically when the restore process is complete", preferredStyle: .alert)
    
    present(alertRestore, animated: false, completion: nil)
        
    // adding notification to remove the alertRestore once the process is complete
    NotificationCenter.default.addObserver(self, selector: #selector(hideRestoreInProgressAlert), name: Notification.Name("RestoreCompletedHideAlert"), object: nil)
    
    //validate the Subscription are valid
    
}

func hideRestoreInProgressAlert()
{
    dismiss(animated: false, completion: nil)
    //this is called by the Notification once the restore process is complete
}

//UI functions
    
@IBAction func onBasicSubscription(_ sender: UIButton)
{
    self.processPurchase(productParam: self.basicAccessProduct)
}

@IBAction func onPlusSubscription(_ sender: UIButton)
{
    self.processPurchase(productParam: self.plusAccessProduct)
}

@IBAction func onPremiumSubscription(_ sender: UIButton)
{
    self.processPurchase(productParam: self.premiumAccessProduct)
}

@IBAction func onRestorePurchases(_ sender: UIButton)
{
    self.myAppDelegate.restorePurchases()
    self.showRestoreInProgressAlert()
}

@IBAction func onHelp(_ sender:UIButton)
{
    //display an alert with name and link to help
    let alertHelp = UIAlertController(title: "Auto Renewal Subscription Demo - About", message: "This application has been brought to you by Eric Arenas\nFor more information, please go to http://www.latinostrends.com/apps/ \n\nLatin OS Trends", preferredStyle: .alert)
    
    alertHelp.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    
    self.present(alertHelp, animated: true, completion: nil)
}

 

    
}


