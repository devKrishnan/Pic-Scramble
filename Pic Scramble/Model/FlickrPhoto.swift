//
//  FlickrPhoto.swift
//  Pic Scramble
//
//  Created by Radhakrishnan Selvaraj on 14/06/16.
//  Copyright © 2016 Science-Krishnan. All rights reserved.
//

import UIKit

public class FlickrPhoto:NSObject {

    var thumbnail : UIImage?
    var largeImage : UIImage?
    let url : String?
    public init (_ dictionary: NSDictionary) {
        
        let media:[String:String] = dictionary["media"] as! [String:String]
        self.url = media["m"]
        
    }
    
}
