//
//  Async.swift
//  Pic Scramble
//
//  Created by Radhakrishnan Selvaraj on 14/06/16.
//  Copyright © 2016 Science-Krishnan. All rights reserved.
//


import Foundation

public class Async:NSObject{
    
    public class func main(block: dispatch_block_t) {
        dispatch_async(dispatch_get_main_queue(), block)
    }
    
    public class func background(block: dispatch_block_t) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), block)
    }
}