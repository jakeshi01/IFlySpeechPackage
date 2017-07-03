//
//  GCDExtension.swift
//  JRFoundationApp
//
//  Created by 王小涛 on 15/8/31.
//  Copyright © 2015年 王小涛. All rights reserved.
//

import Foundation

typealias Task = (_ cancel : Bool) -> Void

@discardableResult
func delay(_ time: TimeInterval, task: @escaping () -> Void) -> Task? {
    
    func dispatch_later(_ block:@escaping () -> Void) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: block)
    }
    
    var closure: (() -> Void)? = task
    var result: Task?
    
    let delayedClosure: Task = { cancel in
        if let internalClosure = closure {
            if (cancel == false) {
                DispatchQueue.main.async(execute: internalClosure)
            }
        }
        closure = nil
        result = nil
    }
    
    result = delayedClosure
    
    dispatch_later {
        if let delayedClosure = result {
            delayedClosure(false)
        }
    }
    
    return result
}

func cancel(_ task:Task?) {
    task?(true)
}




