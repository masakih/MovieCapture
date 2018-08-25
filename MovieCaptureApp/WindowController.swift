//
//  WindowController.swift
//  MovieCapture
//
//  Created by Hori,Masaki on 2018/08/23.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Cocoa

import MovieCapture

class WindowController: NSWindowController {
    
    private var captureFrame: NSRect = NSRect(x: 0, y: 0, width: 100, height: 100)
    
    private var capture: MovieCapture?
    
    override var windowNibName: NSNib.Name? {
        
        return NSNib.Name(String(describing: type(of: self)))
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    
    @IBAction private func set(_: Any) {
        
        if let f = window?.contentView?.frame,
            let frame = window?.convertToScreen(f) {
            
            captureFrame = frame
        }
    }
    
    @IBAction private func start(_: Any) {
        
        do {
            
            try capture = MovieCapture(screenFrame: captureFrame)
            
            try capture?.start()
            
        } catch {
            
            print(error)
        }
    }
    
    @IBAction private func finish(_: Any) {
        
        capture?.stop { url, error in
            
            if let error = error {
                
                print(error)
                return
            }
            
            NSWorkspace.shared.open(url)
        }
    }
}
