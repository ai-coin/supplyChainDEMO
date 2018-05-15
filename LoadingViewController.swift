//
//  LoadingViewController.swift
//  supplyChainDemo
//
//  Created by Michael Wilkowski on 5/11/18.
//  Copyright © 2018 rifigy. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    var addressArray: [String]?
    var testAddress:[String]?
    var barString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scanItem()
    }
    
    func scanItem(){
        guard let barcode = barString else {return}

        let keychain = KeychainSwift()
        if let key = keychain.get("privateKey") {
            let dict = ["privateKey":key, "barCode":barcode, "extraInfo":"good condition"]
            NetworkController.scanP(param: dict) { (success) in
                
                if success {
                    print("SuccessPass")
                    self.showAlert(messageString: "The item has been transfered on the blockchain to your account \n 123345", sender: nil)
                } else {
                    print("BadPass")
                    self.showAlert(messageString: "There was an error transfering the item, please try again", sender: nil)
                }
            }
        }
    }
    
    func getHistory(){
        guard let barcode = barString else {return}
        let dict = ["code":barcode]
        NetworkController.getCodeHistory(param: dict) { (addresses) in
            if let addressArray = addresses {
                self.showAlert(messageString: "Got the item history", sender: addressArray)
            }
        }
    }
    
    func showAlert(messageString: String, sender: Any?){
        if presentedViewController != nil {
            return
        }
        
        let alertPrompt = UIAlertController(title: "Success", message: messageString, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            if let addressArray = sender as? [String] {
                self.performSegue(withIdentifier: "toHistory", sender: sender)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        present(alertPrompt, animated: true, completion: nil)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHistory" {
            guard let addressArray = sender as? [String] else {return}
            let dVC = segue.destination as! HistoryTableViewController
            dVC.addressArray = addressArray
        }
    }

}
