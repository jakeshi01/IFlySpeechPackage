//
//  Timer+Weak.swift
//  JRFramework
//
//  Created by 王小涛 on 16/5/11.
//  Copyright © 2016年 王小涛. All rights reserved.
//

import UIKit

private class WeakTimerProxy: AnyObject {
    
    fileprivate weak var target: AnyObject?
    fileprivate let block: (Timer) -> Void
    
    init(target: AnyObject, block: @escaping (Timer) -> Void) {
        self.target = target
        self.block = block
    }
    
    @objc func timerDidfire(_ timer: Timer) {
        
        if let _ = target {
            block(timer)
        } else {
            timer.invalidate()
        }
    }
}

extension Timer {
    
    fileprivate class func weakTimerWithTimeInterval(timeInterval ti: TimeInterval, target: AnyObject, block: @escaping (Timer) -> Void, userInfo: AnyObject?, repeats: Bool) -> Timer {
        
        let proxy = WeakTimerProxy(target: target, block: block)
        let timer = Timer(timeInterval: ti, target: proxy, selector:#selector(WeakTimerProxy.timerDidfire(_:)), userInfo: userInfo, repeats: repeats)
        return timer
    }
    
    @discardableResult
    public class func after(_ interval: TimeInterval, target: AnyObject, _ block: @escaping (_ sender: Timer) -> Void) -> Timer {
        
        let timer = Timer.weakTimerWithTimeInterval(timeInterval: interval, target: target, block: block, userInfo: nil, repeats: false)
        timer.start()
        return timer
    }
    
    @discardableResult
    public class func every(_ interval: TimeInterval, target: AnyObject, _ block: @escaping (_ sender: Timer) -> Void) -> Timer {
        
        let timer = Timer.weakTimerWithTimeInterval(timeInterval: interval, target: target, block: block, userInfo: nil, repeats: true)
        timer.start(modes: RunLoopMode.commonModes.rawValue)
        return timer
    }
    
    /// Schedule this timer on the run loop
    ///
    /// By default, the timer is scheduled on the current run loop for the default mode.
    /// Specify `runLoop` or `modes` to override these defaults.
    
    fileprivate func start(runLoop: RunLoop = RunLoop.current, modes: String...) {
        
        // Common Modes包含default modes,modal modes,event Tracking modes.
        let modes = modes.isEmpty ? [RunLoopMode.defaultRunLoopMode.rawValue] : modes
        
        for mode in modes {
            runLoop.add(self, forMode: RunLoopMode(rawValue: mode))
        }
    }
}
