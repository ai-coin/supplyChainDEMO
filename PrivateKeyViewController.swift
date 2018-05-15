//
//  PrivateKeyViewController.swift
//  supplyChainDemo
//
//  Created by Michael Wilkowski on 5/4/18.
//  Copyright © 2018 rifigy. All rights reserved.
//

import UIKit

class PrivateKeyViewController: UIViewController {

    var accountDict:[String:String]?
    
    var qrcodeImage: CIImage!
    
    var new: Bool = true
    
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var privateKey: UILabel!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var balanceOutlet: UILabel!
    @IBOutlet weak var QRimageview: UIImageView!
    
    @IBOutlet weak var dismissOutlet: UIButton!
    @IBAction func dismissButtonTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: false, completion: nil)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        let keychain = KeychainSwift()
        
        keychain.delete("privateKey")
        keychain.delete("address")
        keychain.delete("uuidString")
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if new {
            newAccount()
        } else {
            viewAccount()
            
            let keychain = KeychainSwift()
            if let uuid = keychain.get("uuidString") {
                let dict = ["uuid":uuid]
                NetworkController.checkBalance(param: dict) { (balance) in
                    if let accountBalance = balance {
                        self.UI {
                            self.balance.text = accountBalance
                        }
                    }
                }
            }
        }
        createQR(address: self.address.text!)
    }
    
    private func newAccount(){
        balance.isHidden = true
        balanceOutlet.isHidden = true
        guard let account = accountDict else {return}
        guard let address = account["address"], let privateKey = account["privateKey"] else {return}
        self.address.text = address
        self.privateKey.text = privateKey
    }
    
    private func viewAccount(){
        dismissOutlet.isHidden = true
        let keychain = KeychainSwift()
        if let privateKey = keychain.get("privateKey"), let address = keychain.get("address") {
            self.privateKey.text = privateKey
            self.address.text = address
        }
    }
    
    
    func createQR(address: String){
        if qrcodeImage == nil {
            
            let data = address.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
            
            let filter = CIFilter(name: "CIQRCodeGenerator")
            
            filter?.setValue(data, forKey: "inputMessage")
            filter?.setValue("Q", forKey: "inputCorrectionLevel")
            
            qrcodeImage = filter?.outputImage
            
            displayQRCodeImage()
        }
    }

    func displayQRCodeImage() {
        let scaleX = QRimageview.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = QRimageview.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        QRimageview.image = UIImage(ciImage: transformedImage)
        
        
    }
    
    func UI(_ block: @escaping ()->Void) {
        DispatchQueue.main.async(execute: block)
    }

}
