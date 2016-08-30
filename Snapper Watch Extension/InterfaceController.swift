import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var connectionLabel: WKInterfaceLabel!
    @IBOutlet var snapButton: WKInterfaceButton!
    @IBOutlet var previewImageView: WKInterfaceImage!
    
    let phoneCommunicator = SNPhoneCommunicator.sharedInstance
    var startedLiveView = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.phoneCommunicator.delegate = self
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.phoneCommunicator.delegate = self

        self.phoneCommunicator.getCamera()
        self.connectionLabel.setText("Connecting")
        self.snapButton.setHidden(true)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func snapPressed() {
        self.phoneCommunicator.sendTakePhotoCommand()
    }
}

extension InterfaceController: SNPhoneCommunicatorDelegate {
    
    func phoneCommunicatorDidGetDevice(phoneCommunicator: SNPhoneCommunicator) {
        DispatchQueue.main.async {
            
            if !self.startedLiveView {
                self.startedLiveView = true
                self.phoneCommunicator.startRecMode()
                self.phoneCommunicator.startLiveView()
            }
        }
    }
    
    func phoneCommunicatorDidGetPreview(phoneCommunicator: SNPhoneCommunicator, image: UIImage) {
        DispatchQueue.main.async {
            self.connectionLabel.setText("Connected")
            self.snapButton.setHidden(false)

            self.previewImageView.setImage(image)
        }
    }
}
