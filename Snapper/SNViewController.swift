import UIKit
import Foundation

class SNViewController: UIViewController {

    let instructionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Connect to the camera's wifi network. Once connected, there's no need to open this app."
        return label
    }()
    
    let connectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Not connected"
        return label
    }()
    
    let searchDevicesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Search for camera", for: UIControlState.normal)
        return button
    }()
    
    let searchingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        indicator.hidesWhenStopped = true
        indicator.isHidden = true
        return indicator
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.searchDevicesButton.addTarget(self, action: #selector(SNViewController.searchPressed), for: UIControlEvents.touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        for v in [self.instructionLabel, self.connectionLabel, self.searchDevicesButton, self.searchingIndicator] {
            v.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(v)
        }
        
        NSLayoutConstraint.activate([
            self.instructionLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.instructionLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.instructionLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8, constant: 0),
            
            self.searchingIndicator.centerXAnchor.constraint(equalTo: self.connectionLabel.centerXAnchor),
            self.searchingIndicator.centerYAnchor.constraint(equalTo: self.connectionLabel.centerYAnchor),
            
            self.connectionLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.connectionLabel.bottomAnchor.constraint(equalTo: self.searchDevicesButton.topAnchor, constant: -10),
            
            self.searchDevicesButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.searchDevicesButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20),
            ])
        
        self.searchPressed()
    }
    
    func searchPressed() {
        self.connectionLabel.isHidden = true
        self.searchingIndicator.startAnimating()
        
        let discoverer = SampleDeviceDiscovery()
        discoverer.performSelector(inBackground: #selector(SampleDeviceDiscovery.discover(_:)), with: self)
    }
}

extension SNViewController: HttpAsynchronousRequestParserDelegate {
    
    func parseMessage(_ response: Data!, apiName: String!) {
        do {
            _ = try JSONSerialization.jsonObject(with: response, options: .init(rawValue: 0))
        } catch {
            
        }
    }
}

extension SNViewController: SampleDeviceDiscoveryDelegate {
    
    func didReceiveDeviceList(_ isReceived: Bool) {
        
        DispatchQueue.main.async {
            let firstDevice = DeviceList.allDevices().firstObject as? DeviceInfo
            let connectionText: String
            
            if let firstDevice = firstDevice {
                connectionText = "Connected to: " + firstDevice.getFriendlyName()

                DeviceList.selectDevice(at: 0)
                SampleCameraApi.startRecMode(self, isSync: false)
            }
            else {
                connectionText = "Unable to find a camera"
            }
            
            self.connectionLabel.text = connectionText
            self.connectionLabel.isHidden = false
            self.searchingIndicator.stopAnimating()
        }
    }
}
