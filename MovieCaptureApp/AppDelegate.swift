//
//  AppDelegate.swift
//  MovieCapture
//
//  Created by Hori,Masaki on 2018/08/23.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    private var controller = WindowController()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        
        controller.showWindow(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

