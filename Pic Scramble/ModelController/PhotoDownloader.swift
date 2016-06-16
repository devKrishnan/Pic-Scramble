//
//  PhotoDownloader.swift
//  Pic Scramble
//
//  Created by Radhakrishnan Selvaraj on 14/06/16.
//  Copyright © 2016 Science-Krishnan. All rights reserved.
//

import UIKit
import SDWebImage
let urlOfFlickerPublicPhotos = "https://api.flickr.com/services/feeds/photos_public.gne?format=json"

typealias PhotoDownloadCompletionBlock = (photo:FlickrPhoto,isLastPhoto:Bool)->Void
typealias PhotoDownloadFailBlock = (errorMessage:NSString)->Void

class PhotoDownloader: NSObject {
    
    func fetchImage(block:PhotoDownloadCompletionBlock,failBlock:PhotoDownloadFailBlock){
        
        let urlObject = NSURL(string:urlOfFlickerPublicPhotos)
        let request = NSURLRequest(URL: urlObject!)
        Async.background { () -> Void in
            
            let urlSession = NSURLSession.sharedSession()
            let task = urlSession.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                
                if let _ = data{
                    
                    do{
                        
                        let finalizedJSONData = self.validJSONData(data!)
                        if finalizedJSONData != nil{
                            
                            let dictionary : NSDictionary? = try NSJSONSerialization.JSONObjectWithData(finalizedJSONData!, options: []) as? NSDictionary
                            
                            if let photoContent = dictionary{
                                
                                let photoListDictionary : [NSDictionary] = photoContent["items"] as! [NSDictionary]
                                if photoListDictionary.count > 0{
                                    
                                    self.fetchImageList(photoListDictionary,block:block)
                                }
                                else{
                                    failBlock(errorMessage: "There are no images found in Public stream")
                                }
                            }else{
                                failBlock(errorMessage: "Failed to Parse Images")
                            }
                        }
                        else{
                            
                            failBlock(errorMessage: "Failed to Fetch Images")
                            
                        }
                        
                    }
                    catch{
                       failBlock(errorMessage: "Failed to Parse Image data from Flicr")
                    }
                
                    
                }
                else if let _ = error{
                    failBlock(errorMessage: (error?.localizedDescription)!)
                }else{
                    failBlock(errorMessage: "Detailed message not completed. Will show the message interpreting the HTTP status")
                }
            }
            task.resume()

        }
        
    }
    
    private func fetchImageList(photoDictionaryList:[NSDictionary],block:PhotoDownloadCompletionBlock){
        
         let manager = SDWebImageManager .sharedManager()
       
        for photoDict in photoDictionaryList{
            
            
            let photoObject = FlickrPhoto(photoDict)
            //let urlSession = NSURLSession.sharedSession()
            let url = NSURL(string: photoObject.url!)
            
            manager.downloadImageWithURL(url, options: SDWebImageOptions.DelayPlaceholder, progress: { (receivedSize:Int,expectedSize: Int) -> Void in
                
                }, completed: { (image: UIImage!, error: NSError!, cacheType:SDImageCacheType,finished: Bool, imageURL:NSURL!) -> Void in
                    photoObject.largeImage = image
                    
                    var isLastObject = false
                    if photoDictionaryList.last == photoDict{
                        isLastObject = true;
                    }
                    block(photo: photoObject,isLastPhoto: isLastObject)
             })
            
            /*
            let task =  urlSession.dataTaskWithURL(url!, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                if let _ = data{
                    photoObject.largeImage = UIImage(data: data!)
                    block(photo: photoObject)
                }else{
                    
                }
            })
            task.resume()
*/
            
        }
    }
    //http://stackoverflow.com/questions/8684667/nsjsonserialization
    func validJSONData(data:NSData)->NSData?{
    
        let extraStringToBeRemoved = "jsonFlickrFeed("
        let jsonString  = NSString(data: data, encoding: NSUTF8StringEncoding)
        if true == jsonString?.containsString(extraStringToBeRemoved){
            
            let tempString = jsonString?.stringByReplacingOccurrencesOfString(extraStringToBeRemoved, withString: "")
            let finalJSON = NSMutableString(string: tempString!)
            let stringLength = finalJSON.length
            var rangeToDelete = NSRange()
            rangeToDelete.length = 1
            rangeToDelete.location = stringLength-1
            finalJSON.deleteCharactersInRange(rangeToDelete)
            let finalEscapedString = finalJSON.stringByReplacingOccurrencesOfString("\\'", withString: "'")
            let data = finalEscapedString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            
            return data
            
        }else{
            return data
        }
    }
    
}
