//
//  Exfiltration.swift
//  LatchTest
//
//  Created by lucas fernández on 22/01/2018.
//  Copyright © 2018 lucas fernández. All rights reserved.
//

import Foundation

class LatchExfiltration {
    
    private var _latches = ["1", "2", "3", "4", "5", "6", "7", "8", "control", "reader", "end"]
    let latch: LatchInterface
    let accountId: String
    
    init(accountId: String, appId: String, appSecret: String) {
        self.accountId = accountId
        self.latch = LatchInterface(accountId: accountId, appId: appId, appSecret: appSecret)
    }
    
    /// Start the process of exfiltration, currently it doesn't support the setup of the latches,
    /// they must be created before starting the exfiltration (see python script)
    ///
    /// - Parameter completion: Closure that returns the dictionary with the latch operations
    func startExfiltration(completion: @escaping ([String:String]) -> Void){
        latch.getOperations(completion: { (response) in
            let dictConverted = self.convertDict(dict: response)
            DispatchQueue.global(qos: .userInitiated).async {
                self.latch.unlockAll(operations: dictConverted)
            }
            completion(dictConverted)
        })
    }
    
    /// Tramsform the operations sent by latch to the format used in the Exfiltration [name:operationId]
    ///
    /// - Parameter dict: Latch response with all the operations
    /// - Returns: Dictionary with the operations in Exfiltration format
    func convertDict(dict: [String:Any]) -> [String:String] {
        var finalDictionary = [String:String]()
        for (key, value) in dict {
            guard let valueDict = value as? [String:Any],
                let name = valueDict["name"] as? String else {
                    print("Error conversion failed")
                    return ["Error" : "Conversion Failed"]
            }
            finalDictionary[name] = key
        }
        return finalDictionary
    }
    
    /// Transform a string into an array of bits
    ///
    /// - Parameter message: Message to exfiltrate
    /// - Returns: Array with bit representation of the message
    func readStringToByte(message: String) -> [String] {
        let buf: [UInt8] = Array(message.utf8)
        let bufstr: [String] = buf.map() {pad(string: String($0, radix:2), toSize: 8)}
        return bufstr
    }
    
    /// Add extra bits if the conversion gives less than 8
    ///
    /// - Parameters:
    ///   - string: The bit representation
    ///   - toSize: The size that might be
    /// - Returns: The right amount of bits
    func pad(string : String, toSize: Int) -> String {
        var padded = string
        for _ in 0..<(toSize - string.count) {
            padded = "0" + padded
        }
        return padded
    }
    
    /// Transform a bnit representation of a character intro an Ascii character
    ///
    /// - Parameter byte: String representation in bist
    /// - Returns: Ascii Character
    func byteToString(byte: String) -> String {
        return String(UnicodeScalar(UInt8(byte, radix: 2)!))
    }
    
    

    

    
    
    
    
    
}




