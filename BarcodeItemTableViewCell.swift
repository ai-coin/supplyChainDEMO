//
//  BarcodeItemTableViewCell.swift
//  supplyChainDemo
//
//  Created by Michael Wilkowski on 5/4/18.
//  Copyright © 2018 rifigy. All rights reserved.
//

import UIKit

class BarcodeItemTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var info: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
