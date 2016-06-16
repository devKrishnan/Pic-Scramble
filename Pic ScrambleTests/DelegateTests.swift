//
//  DelegateTests.swift
//  Pic Scramble
//
//  Created by Radhakrishnan Selvaraj on 16/06/16.
//  Copyright © 2016 Science-Krishnan. All rights reserved.
//

import Foundation
import XCTest
//http://stackoverflow.com/questions/26813268/objc-code-cannot-find-bool-variable-defined-in-swift
class SpyDelegate:NSObject, UICommunication
{
    
   
    override init() {
       
        photoLoadFinish = false
        gameBegan = false
        gameEnded = false
        gameInitatedTimerNotFired = false
        gameReset = false
        
        
        self.photoLoadBegan = false
    }
    // Setting .None is unnecessary, but helps with clarity imho
    var somethingWithDelegateAsyncResult: Bool? = .None
    
     var alertController: UIAlertController?
    internal var message : String!
    internal var imageToIdentify : UIImage!
    
     var photoLoadFinish:Bool
    internal var photoLoadBegan:Bool
    var gameBegan:Bool
    var gameEnded :Bool
    var gameInitatedTimerNotFired:Bool
    var gameReset:Bool
    
    var identificationFailedIndex:NSIndexPath!
    var identificationSucceedIndex:NSIndexPath!
    var timerText:String!
    
    // Async test code needs to fulfill the XCTestExpecation used for the test
    // when all the async operations have been completed. For this reason we need
    // to store a reference to the expectation
    var asyncExpectation: XCTestExpectation?
     func showAlertController(alertController: UIAlertController!, forViewModel viewModel: ScrambleViewModel!) {
        
        self.alertController =  alertController
        
        self.verifyExpectation()
        
    }
     func showMessage(message: String!) {
        
        self.message = message
        self.verifyExpectation()
        
    }
     func didFreshIdentifcationBeginWithImage(image: UIImage!, inViewModel viewModel: ScrambleViewModel!) {
        self.imageToIdentify = image
        self.verifyExpectation()
    }
    
     func didPhotoLoadFinish(viewModel: ScrambleViewModel!) {
        
        self.photoLoadFinish = true
        self.verifyExpectation()
    }
      func didPhotoLoadBegan(viewModel: ScrambleViewModel!) {
        
        self.photoLoadBegan = true
        self.verifyExpectation()
    }
    
      func didGameBegan(viewModel: ScrambleViewModel!) {
        
        self.gameBegan = true
        self.verifyExpectation()
    }
     func didGameEnd(viewModel: ScrambleViewModel!) {
        
        self.gameEnded = true
        self.verifyExpectation()
    }
    
     func didGameInitiatedTimerNotFired(viewModel: ScrambleViewModel!) {
        
        self.gameInitatedTimerNotFired = true
        self.verifyExpectation()
    }
     func didGameReset(viewModel: ScrambleViewModel!) {
        
        self.gameReset = true
        self.verifyExpectation()
    }
    
     func updateTimerText(text: String!) {
        
        self.timerText = text
        self.verifyExpectation()
    }
    
     func didIdentificationFailAtIndexPath(indexPath: NSIndexPath!, inViewModel viewModel: ScrambleViewModel!) {
        
        identificationFailedIndex = indexPath
        self.verifyExpectation()
    }
    
     func didIdentificationSucceedAtIndexPath(indexPath: NSIndexPath!, inViewModel viewModel: ScrambleViewModel!) {
        
        identificationSucceedIndex = indexPath
        self.verifyExpectation()
    }
    
    
     func verifyExpectation(){
        return
        guard let expectation = asyncExpectation else {
            XCTFail("SpyDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        
        expectation.fulfill()
    }

}