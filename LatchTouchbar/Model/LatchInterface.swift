//
//  LatchInterface.swift
//  LatchTest
//
//  Created by lucas fernández on 20/01/2018.
//  Copyright © 2018 lucas fernández. All rights reserved.
//

import Foundation

class LatchInterface {
    private var _accountId: String!
    private var _webhookChanges: String!
    private var _latchAuth: LatchAuth
    // Latch Connection Api
    
    /// Interface in latch to use it in Swift
    ///
    /// - Parameters:
    ///   - accountId: String given after pairing the app with the service
    ///   - appId: The App Id of the application
    ///   - appSecret: The Secret of the applications
    init(accountId: String, appId: String, appSecret: String) {
        self._accountId = accountId
        self._latchAuth = LatchAuth(appId: appId, appSecret: appSecret)
    }
    
    func pairLatch(token: String, completion: @escaping (String) -> Void) {
        let url = _latchAuth.API_PAIR_URL + "/" + token
        _latchAuth.http(method: "GET", url: url) { (response) in
            guard let data = response["data"] as? [String:Any],
                let accountId = data["accountId"] else {
                    print("Response malformed")
                    completion("error")
                    return
            }
            print(accountId)
            if let accountIdReturn = accountId as? String{
                completion(accountIdReturn)
            } else {
               completion("error")
            }
            
        }
    }
    
    func unPairLatch(){
        let url = _latchAuth.API_UNPAIR_URL + "/" + self._accountId
        _latchAuth.http(method: "GET", url: url) { (response) in
            print(response)
        }
    }
    
    func checkStatus(completion: @escaping (String) -> Void) {
        let url = _latchAuth.API_CHECK_STATUS_URL + "/" + self._accountId
        _latchAuth.http(method: "GET", url: url) { (response) in
            let latchStatus = self.parseResponseStatus(response: response)
            completion(latchStatus)
        }
    }
    
    func checkStatus(operationId:String, completion: @escaping (String) -> Void) {
        let url = _latchAuth.API_CHECK_STATUS_URL + "/" + self._accountId + "/op/" + operationId
        _latchAuth.http(method: "GET", url: url) { (response) in
            let latchStatus = self.parseResponseStatus(response: response)
            completion(latchStatus)
        }
    }
    
    func parseResponseStatus(response: [String:Any]) -> String {
        guard let data = response["data"] as? [String:Any],
            let operations = data["operations"] as? [String:Any],
            let status = Array(operations)[0].value as? [String:String],
            let latchStatus = status["status"] else {
                print("Response malformed")
                return "Error"
        }
        return latchStatus
    }
    
    func getLatchOperationId(completion: @escaping (String) -> Void) {
        let url = _latchAuth.API_CHECK_STATUS_URL + "/" + self._accountId
        _latchAuth.http(method: "GET", url: url) { (response) in
            guard let data = response["data"] as? [String:Any],
                let operations = data["operations"] as? [String:Any] else {
                    print("Response malformed")
                    return
            }
            let operationId = Array(operations.keys)[0]
            print(operationId)
            completion(operationId)
        }
    }
    
    func lock() {
        let url = _latchAuth.API_LOCK_URL + "/" + self._accountId
        _latchAuth.http(method: "POST", url: url) { (response) in
            print(response)
        }
    }
    
    func lock(operationId: String) {
        let url = _latchAuth.API_LOCK_URL + "/" + self._accountId + "/op/" + operationId
        _latchAuth.http(method: "POST", url: url) { (response) in
            print(response)
        }
    }
    
    func unlock() {
        let url = _latchAuth.API_UNLOCK_URL + "/" + self._accountId
        _latchAuth.http(method: "POST", url: url) { (response) in
            print(response)
        }
    }
    
    func unlock(operationId: String) {
        let url = _latchAuth.API_UNLOCK_URL + "/" + self._accountId + "/op/" + operationId
        _latchAuth.http(method: "POST", url: url) { (response) in
            print(response)
        }
    }
    
    func unlock(operationId: String, completion: @escaping () -> Void){
        let url = _latchAuth.API_UNLOCK_URL + "/" + self._accountId + "/op/" + operationId
        _latchAuth.http(method: "POST", url: url) { (response) in
            print(response)
            completion()
        }
    }
    
    func unlockAll(operations: [String: String]){
        for (_, operationId) in operations {
            DispatchQueue.global(qos: .userInitiated).async {
                self.unlock(operationId: operationId)
            }
        }
    }
    
    func getOperations(completion: @escaping ([String:Any]) -> Void) {
        let url = _latchAuth.API_OPERATION_URL
        _latchAuth.http(method: "GET", url: url) { (response) in
            print(response)
            let operations = self.parseResponseOperationId(response: response)
            print(operations)
            completion(operations)
        }
    }
    
    func getOperations(operationId: String, completion: @escaping ([String:Any]) -> Void) {
        let url = _latchAuth.API_OPERATION_URL + "/" + operationId
        _latchAuth.http(method: "GET", url: url) { (response) in
            let operations = self.parseResponseOperationId(response: response)
            print(operations)
            completion(operations)
        }
    }
    
    func parseResponseOperationId(response: [String:Any]) -> [String:Any] {
        guard let data = response["data"] as? [String:Any],
            let operations = data["operations"] as? [String:Any] else {
                print("Response malformed")
                return ["Error":"Error in data"]
        }
        return operations
    }
    
    
    
}
