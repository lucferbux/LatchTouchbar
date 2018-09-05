//
//  WindowController.swift
//  LatchTouchbar
//
//  Created by lucas fernández on 05/09/2018.
//  Copyright © 2018 lucas fernández. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        guard let viewController = contentViewController as? ViewController else {
            return nil
        }
        return viewController.makeTouchBar()
    }

}
