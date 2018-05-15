//
//  QRScannerController.swift
//  supplyChainDemo
//
//  Created by Michael Wilkowski on 5/4/18.
//  Copyright © 2018 rifigy. All rights reserved.
//

import UIKit
import AVFoundation

class QRScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var topBar: UIView!
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    var delegate: passBackData?
    var uuid: String?
    var scannerType = 0 // 0 is item scanner 1 is privateKey
    
    override func viewDidLoad() {
        super.viewDidLoad()
        discoverVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if delegate != nil {
            guard let uuid = uuid else {return}
            delegate!.pass(data: uuid)
        }
        
    }

    func discoverVideo(){
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        let captureSession:AVCaptureSession = AVCaptureSession()

        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession.startRunning()
            
            view.bringSubview(toFront: messageLabel)
            view.bringSubview(toFront: topBar)
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel.text = "QR Found!"
                parseQR(stringValue: metadataObj.stringValue!)
                
            }
        }
    }
    
    func parseQR(stringValue: String){
        guard let barcodeDict = convertToDictionary(text: stringValue) else {return}
        
        if let privateKey = barcodeDict["privateKey"] as? String, let uuid = barcodeDict["uuidString"] as? String{
            
            if scannerType == 1 {
                self.uuid = uuid
                showAlert(barcodeString: nil, addresses: nil, messageString: "This is the private key to be restored: \n \(privateKey)")
                
            } else {
                showAlert(barcodeString: nil, addresses: nil, messageString: "The QR scanned is a private key not an item")
            }
        } else if let barString = barcodeDict["barString"] {
            if scannerType == 1 {
                showAlert(barcodeString: nil, addresses: nil, messageString: "The QR scanned is an item not a private key")
            } else {
                let barcodeTitleDict = ["code":barString]
                NetworkController.getCodeHistory(param: barcodeTitleDict) { (addresses) in
                    if let addressArray = addresses {
                        self.showAlert(barcodeString: barString, addresses: addressArray, messageString: "Accept the item into your inventory")
                    }
                }
            }
        }
        
    }
    
    func convertToDictionary(text: String) -> [String: String]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
    func showAlert(barcodeString: String?, addresses: Any?, messageString: String){
        if presentedViewController != nil {
            return
        }
        
        let alertPrompt = UIAlertController(title: "Confirm Item", message: messageString, preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            if self.scannerType == 0 {
                guard let code = barcodeString else {return}
                self.acceptItem(barcode: code, owners: addresses as! [String])
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
    
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        present(alertPrompt, animated: true, completion: nil)

        
    }
    
    private func acceptItem(barcode: String, owners: [String]){
        self.performSegue(withIdentifier: "toLoading", sender: barcode)
    }
    
    
    func randomStringWithLength(len: Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in 1...len{
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        
        return randomString
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLoading" {
//            guard let addressArray = sender as? [String] else {return}
//            let dVC = segue.destination as! LoadingViewController
//            dVC.addressArray = addressArray
            guard let barcode = sender as? String else {return}
            let dVC = segue.destination as! LoadingViewController
            dVC.barString = barcode
        }
    }

}
