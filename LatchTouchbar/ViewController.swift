//
//  ViewController.swift
//  LatchTouchbar
//
//  Created by lucas fernández on 04/09/2018.
//  Copyright © 2018 lucas fernández. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    let APP_ID = ""
    let APP_SECRET = ""
    var accountId: String!
    var latchInt: LatchInterface!
    @objc dynamic var state: Int = 0
    @IBOutlet weak var latchPosition: NSSegmentedControl!
    @IBOutlet weak var loginView: NSStackView!
    @IBOutlet weak var pairText: NSSecureTextField!
    @IBOutlet weak var pairLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let account = UserDefaults.standard.string(forKey: "app_id") {
            self.accountId = account
            loginView.isHidden = true
            checkStatusLatch()
        } else {
            self.accountId = ""
            latchPosition.isEnabled = false
        }
        latchInt = LatchInterface(accountId: accountId, appId: APP_ID, appSecret: APP_SECRET)
    }

    override var representedObject: Any? { didSet {} }
    @IBAction func latchState(_ sender: Any) {
        changeLock()
    }
    
    func changeLock() {
        print(state)
        if(state == 0) {
            latchInt.unlock()
        } else {
            latchInt.lock()
        }
    }

    func checkStatusLatch() {
        latchInt.checkStatus { (status) in
            print(status)
            print(self.state)
            self.state = (status == "on") ? 0 : 1
        }
    }
    
    func pairNewLatch(account: String) {
        UserDefaults.standard.set(account, forKey: "app_id")
        accountId = account
        latchInt = LatchInterface(accountId: account, appId: APP_ID, appSecret: APP_SECRET)
        loginView.isHidden = true
        checkStatusLatch()
        latchPosition.isEnabled = false
    }
    
    @IBAction func pairLatch(_ sender: Any) {
        latchInt.pairLatch(token: pairText.stringValue) { (account) in
            if (account != "error") {
                self.pairNewLatch(account: account)
            } else {
                self.pairLabel.stringValue = "Error"
            }
        }
    }
    

}

// MARK: - TouchBar Delegate
@available(OSX 10.12.2, *)
extension ViewController: NSTouchBarDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        // create a new touchbar and set the delegate
        let touchbar = NSTouchBar()
        touchbar.delegate = self
        // Set the customization identifier (each touchbar and otuchbaritem need to have unique identifiers)
        touchbar.customizationIdentifier = .travelBar
        // Set the Touch Bar defaul item identifiers
        touchbar.defaultItemIdentifiers = [.flexibleSpace, .latchLabelItem, .latchSegmentedItem, .flexibleSpace]
        // Set the order the items sould be presented
        touchbar.customizationAllowedItemIdentifiers = [.latchLabelItem]
        return touchbar
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItem.Identifier.latchLabelItem:
            let custoViewItem = NSCustomTouchBarItem(identifier: identifier)
            custoViewItem.view = NSTextField(labelWithString: "Latch: ")
            return custoViewItem
        case NSTouchBarItem.Identifier.latchSegmentedItem:
            let customActionItem = NSCustomTouchBarItem(identifier: identifier)
            let segmentedControl = NSSegmentedControl(labels: ["OFF", "ON"], trackingMode: .selectOne, target: self, action: #selector(latchState(_:)))
            segmentedControl.setWidth(40, forSegment: 0)
            segmentedControl.setWidth(40, forSegment: 1)
            customActionItem.view = segmentedControl
            segmentedControl.bind(NSBindingName(rawValue: "selectedTag"), to: self, withKeyPath: #keyPath(state), options: nil)
            return customActionItem
        default:
            return nil
        }
    }
}

