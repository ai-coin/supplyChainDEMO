//
//  AuthViewController.swift
//  supplyChainDemo
//
//  Created by Michael Wilkowski on 5/4/18.
//  Copyright © 2018 rifigy. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthViewController: UIViewController {
    
    var context = LAContext()
    private var privateKey: String?
    private var address: String?
    private var uuidString: String?

    
    @IBOutlet weak var authButtonOutlet: UIButton!

    @IBAction func authButtonTapped(_ sender: Any) {
        checkPolicy()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundButtons()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkKeychain()
    }
    
    func roundButtons(){
        authButtonOutlet.layer.borderWidth = 1.75
        authButtonOutlet.layer.cornerRadius = 5.0
        authButtonOutlet.layer.borderColor = UIColor.green.cgColor
    }
    
    private func checkKeychain(){
        let keychain = KeychainSwift()
        if let privateKey = keychain.get("privateKey"), let address = keychain.get("address"), let uuidString = keychain.get("uuidString") {
            print(uuidString+"\n"+privateKey+"/n"+address)
            self.privateKey = privateKey
            self.address = address
            self.uuidString = uuidString
        }
        else {
            self.performSegue(withIdentifier: "toChoose", sender: nil)
        }
    }
    
    private func checkPolicy() {
        let policy: LAPolicy = .deviceOwnerAuthentication
        var err: NSError?
        
        guard context.canEvaluatePolicy(policy, error: &err) else {
            self.showErrorMessage(messageString: "To protect your account and assets it is highly suggested to create a device passcode")
            
            
            guard let address = self.address else {return}
            
            let addressDict = ["address":address]
            NetworkController.getInfo(param: addressDict, completion: { (barcodes) in
                if let barcodes = barcodes {
                    self.performSegue(withIdentifier: "authenticated", sender: barcodes)
                }
            })
            
            return
        }
        loginProcess(policy: policy)
    }
    
    private func loginProcess(policy: LAPolicy) {
        
        let reason = "Device Account Login!"
        context.evaluatePolicy(policy, localizedReason: reason, reply: { (success, error) in
            
            guard success else {
                // if Auth wasnt successful
                guard let error = error else { self.showErrorMessage(messageString: "An Unexpected error has occured"); return }
                
                switch(error) {
                // show message based on error
                case LAError.authenticationFailed:
                    self.showErrorMessage(messageString: "There was a problem verifying your identity.")
                case LAError.userCancel:
                    self.showErrorMessage(messageString: "Authentication was canceled by user.")
                case LAError.userFallback:
                    self.showErrorMessage(messageString: "The user tapped the fallback button")
                case LAError.systemCancel:
                    self.showErrorMessage(messageString: "Authentication was canceled by system.")
                case LAError.passcodeNotSet:
                    self.showErrorMessage(messageString: "It is recommended you set a device password for your device.")
                case LAError.biometryNotAvailable:
                    self.showErrorMessage(messageString: "Touch ID is not available on the device.")
                case LAError.biometryNotEnrolled:
                    self.showErrorMessage(messageString: "Touch ID has no enrolled fingers.")
                case LAError.biometryLockout:
                    self.showErrorMessage(messageString: "There were too many failed authentications attempts and the app is now locked.")
                default:
                    self.showErrorMessage(messageString: "Biometric ID may not be configured")
                    break
                }
                return
            }
            
            guard let address = self.address else {return}
            
            let addressDict = ["address":address]
            NetworkController.getInfo(param: addressDict, completion: { (barcodes) in
                if let barcodes = barcodes {
                    self.performSegue(withIdentifier: "authenticated", sender: barcodes)
                }
            })
        })
    }
    
    
    // Login Error Message
    private func showErrorMessage(messageString: String) {
        let ac = UIAlertController(title: "Error", message: messageString, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(ac, animated: true)
    }

    
    
    // SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "authenticated" {
            let dNC = segue.destination as! UINavigationController
            let dVC = dNC.topViewController as! AddressTableViewController
            if let barcodes = sender as? [Barcode]{
                dVC.barcodeItems = barcodes
            }
        }
    }
}
