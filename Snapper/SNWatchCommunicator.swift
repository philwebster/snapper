import UIKit
import WatchConnectivity

class SNWatchCommunicator: NSObject {

    var session: WCSession?
    var streamingDataManager = SampleStreamingDataManager()
    var lastLiveViewUpdate = Date()
    
    override init() {
        super.init()

        if WCSession.isSupported() {
            self.session = WCSession.default()
            self.session?.delegate = self
            self.session?.activate()
        }
    }
}

extension SNWatchCommunicator: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let key = message.first?.key else {
            return
        }
        
        switch key {
        case "getCamera":
            let discoverer = SampleDeviceDiscovery()
            discoverer.discover(self)
        case "takePhoto":
            SampleCameraApi.actTakePicture(self)
        case "getPreview":
            SampleCameraApi.startLiveview(self)
        case "stopLiveView":
            SampleCameraApi.stopLiveview(self)
        case "startRecMode":
            SampleCameraApi.startRecMode(self, isSync: true)
        default: break
        }
    }
}

extension SNWatchCommunicator: HttpAsynchronousRequestParserDelegate {
    func parseMessage(_ response: Data!, apiName: String!) {
        let responseDict: [String: Any]?
        do {
            responseDict = try JSONSerialization.jsonObject(with: response, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
        } catch {
            return
        }

        guard let result = responseDict?["result"] as? [String] else {
            return
        }
        
        if apiName == API_CAMERA_startLiveview {
            self.streamingDataManager.start(result.first, viewDelegate: self)
        }
        if apiName == API_CAMERA_stopLiveview {
            self.streamingDataManager.stop()
        }
    }
}

extension SNWatchCommunicator: SampleDeviceDiscoveryDelegate {
    func didReceiveDeviceList(_ isReceived: Bool) {
        let firstDevice = DeviceList.allDevices().firstObject as? DeviceInfo
        DeviceList.selectDevice(at: 0)
        self.session?.sendMessage(["gotCamera": "gotCamera"], replyHandler: nil, errorHandler: nil)
    }
}

extension SNWatchCommunicator: SampleStreamingDataDelegate {
    func didFetch(_ image: UIImage!) {
        if (-lastLiveViewUpdate.timeIntervalSinceNow > 2) {
            let resizedImage = self.imageWithImage(image: image, scaledToSize: CGSize(width: 100, height: 100))
            guard let imageData = UIImageJPEGRepresentation(resizedImage, 0.2) else {
                return
            }
            
            self.session?.sendMessage(["image": imageData], replyHandler: nil, errorHandler: nil)
            lastLiveViewUpdate = Date()
        }
    }
    
    func didStreamingStopped() {
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
