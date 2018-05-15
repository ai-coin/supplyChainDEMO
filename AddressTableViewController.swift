//
//  AddressTableViewController.swift
//  supplyChainDemo
//
//  Created by Michael Wilkowski on 5/4/18.
//  Copyright © 2018 rifigy. All rights reserved.
//

import UIKit

class AddressTableViewController: UITableViewController {

    
    var barcodeItems:[Barcode]?
    
    
    @IBOutlet weak var balanceOutlet: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = .green
        tableView.rowHeight = 80
    }
    
    @IBAction func accountTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toAccount", sender: nil)
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = self.barcodeItems {
            return items.count
        }
        else {
            return 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! BarcodeItemTableViewCell
        
        if let items = self.barcodeItems {
            let item = items[indexPath.row]
            cell.title.text = item.barString
            cell.info.text = item.extraInfo
            cell.timeStamp.text = item.scantime
        } else {
            cell.title.text = "No Items"
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAccount" {
            let dVC = segue.destination as! PrivateKeyViewController
            dVC.new = false
        } else if segue.identifier == "toHistory" {
            guard let addressArray = sender as? [String] else {return}
            let dVC = segue.destination as! HistoryTableViewController
            dVC.addressArray = addressArray
        }
    }
}
