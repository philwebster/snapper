import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    var phoneCommunicator: SNPhoneCommunicator?
    
    override init() {
        super.init()
        self.phoneCommunicator = SNPhoneCommunicator.sharedInstance
    }
    
    func applicationDidFinishLaunching() {
        
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
//        self.phoneCommunicator?.stopLiveView()
    }
}

extension ExtensionDelegate: SNPhoneCommunicatorDelegate {
    func phoneCommunicatorDidGetDevice(phoneCommunicator: SNPhoneCommunicator) {
        
    }
    
    func phoneCommunicatorDidGetPreview(phoneCommunicator: SNPhoneCommunicator, image: UIImage) {

    }
}
