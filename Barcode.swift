//
//  Barcode.swift
//  supplyChainDemo
//
//  Created by Michael Wilkowski on 5/4/18.
//  Copyright © 2018 rifigy. All rights reserved.
//

import Foundation

class Barcode {
    
    let barString: String
    var extraInfo: String
    var scantime: String?
    var creator: String?
    
    init(barString: String, extraInfo: String) {
        self.barString = barString
        self.extraInfo = extraInfo
    }
    
    init(dict: [String:String]){
        self.barString = dict["barcode"]!
        self.extraInfo = dict["condition"]!
        self.scantime = dict["scantime"]!
    }    
}
