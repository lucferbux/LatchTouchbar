//
//  ExfiltrationReader.swift
//  LatchTest
//
//  Created by lucas fernández on 22/01/2018.
//  Copyright © 2018 lucas fernández. All rights reserved.
//

import Foundation

class LatchExfiltrationReader: LatchExfiltration {
    
    override init(accountId: String, appId: String, appSecret: String) {
        super.init(accountId: accountId, appId: appId, appSecret: appSecret)
    }
        
    /// Get the exfiltrated byte of latch an convert it into its ascii representation
    ///
    /// - Parameters:
    ///   - operation: Name of the operation
    ///   - ascii: String with the message to append
    ///   - dictConveted: Dictionary with the operations
    ///   - completion: Closure to return the character and bit representation
    func readExfiltratedByte(operation: Int, ascii:String, dictConveted: [String:String], completion: @escaping ((String, String)) -> Void){
        let latchOperation = dictConveted[String(operation)]
        self.latch.checkStatus(operationId: latchOperation!, completion: { (response) in
            let asciiNew = ascii + (response == "on" ? "0" : "1")
            if asciiNew.count == 8 {
                let byteConverted = self.byteToString(byte: asciiNew)
                //self.latch.unlock(operationId: dictConveted["control"]!)
                completion((asciiNew, byteConverted))
            } else {
                self.readExfiltratedByte(operation: operation + 1, ascii: asciiNew, dictConveted: dictConveted, completion: completion)
            }
        })
        
    }
    
    
    
    
}
