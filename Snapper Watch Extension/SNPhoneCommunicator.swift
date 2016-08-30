import UIKit
import WatchConnectivity

protocol SNPhoneCommunicatorDelegate {
    func phoneCommunicatorDidGetDevice(phoneCommunicator: SNPhoneCommunicator)
    func phoneCommunicatorDidGetPreview(phoneCommunicator: SNPhoneCommunicator, image: UIImage)
}

class SNPhoneCommunicator: NSObject {
    static let sharedInstance = SNPhoneCommunicator()
    
    var session: WCSession?
    var delegate: SNPhoneCommunicatorDelegate?
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            self.session = WCSession.default()
            self.session?.delegate = self
            self.session?.activate()
        }
    }
    
    func sendTakePhotoCommand() {
        self.session?.sendMessage(["takePhoto": "takePhoto"], replyHandler: { replyDict in
            print(replyDict)
            }, errorHandler: { error in
                print(error)
        })
    }
    
    func getCamera() {
        self.session?.sendMessage(["getCamera": "getCamera"], replyHandler: { replyDict in
            print(replyDict)
            self.delegate?.phoneCommunicatorDidGetDevice(phoneCommunicator: self)
            self.startLiveView()
            }, errorHandler: { error in
                print(error)
        })
    }
    
    func startLiveView() {
        self.session?.sendMessage(["getPreview": "getPreview"], replyHandler:nil)
    }
    
    func stopLiveView() {
        self.session?.sendMessage(["stopLiveView": "stopLiveView"], replyHandler: nil)
    }
    
    func startRecMode() {
        self.session?.sendMessage(["startRecMode": "startRecMode"], replyHandler: nil, errorHandler: nil)
    }
}

extension SNPhoneCommunicator: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let key = message.first?.key else {
            return
        }
        
        switch key {
        case "gotCamera":
            self.delegate?.phoneCommunicatorDidGetDevice(phoneCommunicator: self)
        case "image":
            self.delegate?.phoneCommunicatorDidGetPreview(phoneCommunicator: self, image: UIImage(data:message["image"] as! Data)!)
        default: break
        }
    }
}
