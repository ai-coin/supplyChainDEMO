//
//  ChooseViewController.swift
//  supplyChainDemo
//
//  Created by Michael Wilkowski on 5/3/18.
//  Copyright © 2018 rifigy. All rights reserved.
//

import UIKit

class ChooseViewController: UIViewController, passBackData {

    let keychain = KeychainSwift()
    
    @IBOutlet weak var privateKeyTextfield: UITextField!
    

    @IBAction func newAddressTapped(_ sender: Any) {
        
        let uuidString = UUID().uuidString
        let dict:[String:String] = ["uuid":uuidString]
        
        NetworkController.getAccount(param: dict) { (account) in
            
            guard var accountDict = account else {return}
            
            self.keychain.set(uuidString, forKey: "uuidString")

            if let privateKey = accountDict["privateKey"] {
                self.keychain.set(privateKey, forKey: "privateKey")
            }
            if let address = accountDict["address"] {
                self.keychain.set(address, forKey: "address")
            }
            
            self.performSegue(withIdentifier: "accountCreated", sender: accountDict)
        }
    }
    
    @IBAction func restoreTapped(_ sender: Any) {
        if privateKeyTextfield.isHidden {
            privateKeyTextfield.isHidden = false
        } else {
            if !(privateKeyTextfield.text!.isEmpty) {
                let uuidString = privateKeyTextfield.text!
                let dict = ["uuid": uuidString]
                NetworkController.getAccount(param: dict) { (account) in
                    guard var accountDict = account else {return}
                    
                    self.keychain.set(uuidString, forKey: "uuidString")
                    
                    if let privateKey = accountDict["privateKey"] {
                        self.keychain.set(privateKey, forKey: "privateKey")
                    }
                    if let address = accountDict["address"] {
                        self.keychain.set(address, forKey: "address")
                    }
                    self.performSegue(withIdentifier: "accountCreated", sender: accountDict)
                }
            }
        }
    }
    
    func pass(data: String) {
        privateKeyTextfield.text = data
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        privateKeyTextfield.isHidden = true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "accountCreated" {
            if let accountDict = sender as? [String:String] {
                let dVC = segue.destination as! PrivateKeyViewController
                dVC.accountDict = accountDict
            }
        } else if segue.identifier == "toScanPrivate" {
            let vc2 = segue.destination as! QRScannerController
            vc2.delegate = self
            vc2.scannerType = 1
        }
    }
}

protocol passBackData {
    func pass(data: String)  //data: string is an example parameter
}
