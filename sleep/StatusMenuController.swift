//
//  StatusMenuController.swift
//  sleep
//
//  Created by artemeff on 20/04/16.
//  Copyright © 2016 artemeff. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    let defaultScheduleLabel = "Schedule disabled"
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    var delay = 0
    var countDown = NSTimer()
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var scheduleStatusMenuItem: NSMenuItem!
    
    override func awakeFromNib() {
        let icon = NSImage(named: "StatusIcon")
        icon?.template = true // best for light/dark mode
        
        statusItem.image = icon
        statusItem.menu = statusMenu
    }

    @IBAction func sleepFifteenMinutes(sender: NSMenuItem) {
        cancelTimer()
        schedule(15)
    }
    
    @IBAction func sleepThirdtyMinutes(sender: NSMenuItem) {
        cancelTimer()
        schedule(30)
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    @IBAction func cancelTimerClicked(sender: NSMenuItem) {
        cancelTimer()
    }
    
    private func schedule(minutes: Int) {
        delay = minutesToSeconds(minutes)
        
        countDown = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(countDownAction), userInfo: nil, repeats: true)
        
        NSRunLoop.currentRunLoop().addTimer(countDown, forMode: NSRunLoopCommonModes)
    }
    
    @objc private func countDownAction() {
        delay -= 1
        
        if delay > 0 {
            scheduleStatusMenuItem.title = "Sleep after \(formatSeconds(delay))"
        } else {
            cancelTimer()
            sleepNow()
        }
    }

    private func sleepNow() {
        let task = NSTask()
        task.launchPath = "/usr/bin/pmset"
        task.arguments = ["sleepnow"]
        task.launch()
    }
    
    private func cancelTimer() {
        delay = 0
        scheduleStatusMenuItem.title = defaultScheduleLabel
        countDown.invalidate()
    }
    
    private func minutesToSeconds(min: Int) -> Int {
        return min * 60
    }
    
    private func formatSeconds(seconds: Int) -> String {
        if seconds > 60 {
            let min = String(format: "%.2d", seconds / 60)
            let sec = String(format: "%.2d", seconds % 60)
            
            return "\(min):\(sec)"
        } else {
            let sec = String(format: "%.2d", seconds)
            
            return "\(sec) seconds"
        }
    }
}
