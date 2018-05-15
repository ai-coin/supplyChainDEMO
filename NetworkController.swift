//
//  NetworkController.swift
//  supplyChainDemo
//
//  Created by Michael Wilkowski on 5/1/18.
//  Copyright © 2018 rifigy. All rights reserved.
//


import Foundation

class NetworkController {
    
    static var rootString = "http://10.0.0.108:8080"
    
    private static func buildRequest(endpoint: String, method: String, bodyData: [String:Any]?)->URLRequest{
        let url = URL(string: rootString + endpoint)!
        
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let data = bodyData {
            let jsonData = try? JSONSerialization.data(withJSONObject: data)
            request.httpBody = jsonData
        }
        
        return request
    }
    
    static func getInfo(param: [String:String], completion:@escaping(_ result: [Barcode]?)->Void){
        
        let request = buildRequest(endpoint: "/getInfo", method: "POST", bodyData: param)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(nil)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseDict = responseJSON as? [[String:String]] {
                var allBarcodes: [Barcode] = []
                for barcodeDict in responseDict {
                    let barcode = Barcode(dict: barcodeDict)
                    allBarcodes.append(barcode)
                }
                completion(allBarcodes)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    static func scanTest(param: [String:String], completion:@escaping(_ result: [String:Any]?)->Void){
        
        let request = buildRequest(endpoint: "/scantest", method: "POST", bodyData: param)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(nil)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseDict = responseJSON as? [String:Any] {
                completion(responseDict)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    static func scanP(param: [String:String], completion:@escaping(_ result: Bool)->Void){
        
        let request = buildRequest(endpoint: "/scan", method: "POST", bodyData: param)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(false)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseDict = responseJSON {
                print(responseDict)
                completion(true)
            } else {
                completion(false)
            }
        }
        task.resume()
    }
    
    static func getAccount(param: [String:String], completion:@escaping(_ result: [String:String]?)->Void){
        
        let request = buildRequest(endpoint: "/getAccount", method: "POST", bodyData: param)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(nil)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseDict = responseJSON as? [String:String] {
                completion(responseDict)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    static func getCodeHistory(param: [String:String], completion:@escaping(_ result: [String]?)->Void){
        
        let request = buildRequest(endpoint: "/getBarcode", method: "POST", bodyData: param)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(nil)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseArray = responseJSON as? [String] {
                completion(responseArray)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    static func checkBalance(param: [String:String], completion:@escaping(_ result: String?)->Void){
        
        let request = buildRequest(endpoint: "/getBalance", method: "POST", bodyData: param)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(nil)
                return
            }
            if let balance = String(data: data, encoding: .utf8){
                completion(balance)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}
