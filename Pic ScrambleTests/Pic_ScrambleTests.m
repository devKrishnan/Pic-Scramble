//
//  Pic_ScrambleTests.m
//  Pic ScrambleTests
//
//  Created by Radhakrishnan Selvaraj on 16/06/16.
//  Copyright © 2016 Science-Krishnan. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ScrambleViewModel.h"
#import "Pic_ScrambleTests-Swift.h"

@interface ScrambleViewModel ()
-(void)beginTimer;
@end
@interface Pic_ScrambleTests : XCTestCase<UICommunication>
@property(nonatomic,strong)ScrambleViewModel *viewModel;
@property(nonatomic,strong)SpyDelegate *viewModelDelegate;
@end

@implementation Pic_ScrambleTests
@synthesize viewModel,viewModelDelegate;
- (void) backgroundMethodWithCallback: (void(^)(void)) callback {
    dispatch_queue_t backgroundQueue;
    backgroundQueue = dispatch_queue_create("background.queue", NULL);
    dispatch_async(backgroundQueue, ^(void) {
        callback();
    });
}

- (void)setUp {
    [super setUp];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"get Service Person By ID"];
    self.viewModel = [[ScrambleViewModel alloc]initWithHandler:^(FlickrPhoto *photo, NSIndexPath *indexPath) {
        
        
        
        XCTAssert(viewModel.photoList.count > 0);
        if (viewModel.photoList.count >= viewModel.totalPhotos) {
            self.viewModelDelegate = [[SpyDelegate alloc]init];
            self.viewModel.communicationDelegate = viewModelDelegate;
            [expectation fulfill];
            
        }
        
    }];
    [self waitForExpectationsWithTimeout:20.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
    
    
    
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testScrambleViewModelObject {
    // setup
    
    XCTAssertNotNil(viewModel, @"Cannot find viewModel instance");
    // no teardown needed
}
- (void) testDataLayoutMethods {
    // setup
    //XCTAssertNil(viewModel,@"Method implementation in progress");
    
    NSInteger numberOfItems = [viewModel numberOfItemsInSection:0];
    XCTAssertTrue(numberOfItems>=viewModel.totalPhotos,@"Total number of photos not enough to display for the game");
    
    for (int index = 0; index < viewModel.totalPhotos; index++) {
        UIImage *image = [viewModel imageForItemAtIndex:index];
        XCTAssertNotNil(image, @"Image invalid for index %d",index);
    }
    
    
    
    
    
   
    // no teardown needed
}

- (void)testGameReset {
    
    
    viewModel.gameMode = GameNotYetBegan;
    XCTAssertTrue(viewModelDelegate.gameReset,@"Game reset failed");

}

- (void)testGameInitiate {
    

    viewModel.gameMode = GameInitiatedTimerNotFired;
    [viewModel beginTimer];
    XCTAssertTrue(viewModelDelegate.gameInitatedTimerNotFired,@"Game  Initiation failed");
    
    
}

- (void)testGameBeganAndImage {
    
   
    viewModel.gameMode = GameBegan;
    
    XCTAssertTrue(viewModelDelegate.gameBegan,@"Game began failed");
    XCTAssertNotNil(viewModelDelegate.imageToIdentify, @"Image for identification failed to set");
    
    
}
- (void)testGameEnd {
    
    viewModel.gameMode = GameEnded;
    
    XCTAssertTrue(viewModelDelegate.gameEnded,@"Game Ending failed");

}

- (void)testImageForDifferentState {
    
    UIImage *defaultImage = [UIImage imageNamed:@"Default-Image"];
    UIImage *questionCoinImage = [UIImage imageNamed:@"Question-Coin"];
    
    viewModel.gameMode = GameNotYetBegan;
    UIImage *imageNotYetBegan = [self.viewModel imageForItemAtIndex:0];
    BOOL isImageSame = [self image:defaultImage isEqualTo:imageNotYetBegan];
    XCTAssertTrue(isImageSame,@"GameNotYetBegan Image logic wrong");
    
    viewModel.gameMode = GameBegan;
    UIImage *imageGameBegan = [self.viewModel imageForItemAtIndex:0];
    isImageSame = [self image:questionCoinImage isEqualTo:imageGameBegan];
    XCTAssertTrue(isImageSame,@"GameBegan Image logic wrong");
    
    viewModel.gameMode = GameEnded;
    UIImage *imageGameEnded = [self.viewModel imageForItemAtIndex:0];
    id flickPhotoObject = [self.viewModel.photoList objectAtIndex:0];
    UIImage *flickrPhoto = [flickPhotoObject performSelector:@selector(largeImage)];
    
    isImageSame = [self image:imageGameEnded isEqualTo:flickrPhoto];
    XCTAssertTrue(isImageSame,@"GameEnd Image logic wrong");
    
}


-(void)testImageSelection{
    viewModel.gameMode = GameBegan;
    NSInteger currentRandomImageIndex = viewModel.currentlyShownImageIndex;
    [viewModel didSelectImageAtIndex:currentRandomImageIndex];
    XCTAssertEqual(currentRandomImageIndex, viewModelDelegate.identificationSucceedIndex.row,@"Image selection logic fails");
    
    NSInteger failureIndex = currentRandomImageIndex;
    if (failureIndex == 0) {
        failureIndex = failureIndex + 1;
    }else{
        failureIndex = failureIndex - 1;
    }
    [viewModel didSelectImageAtIndex:failureIndex];
    XCTAssertEqual(failureIndex, viewModelDelegate.identificationFailedIndex.row,@"Image selection Failure case logic is wrong and it fails");
    
}

-(void)testGameOver{
    viewModel.gameMode = GameBegan;
    XCTAssertFalse([viewModel isGameOver],@"Game Over logic wrong");
    for (int index = 0; index  < viewModel.totalPhotos; index++) {
        XCTAssertFalse([viewModel isGameOver],@"Game Over logic wrong");
        NSInteger currentRandomImageIndex = viewModel.currentlyShownImageIndex;
        [viewModel didSelectImageAtIndex:currentRandomImageIndex];
        XCTAssertEqual(currentRandomImageIndex, viewModelDelegate.identificationSucceedIndex.row,@"Image selection logic fails");
        
    }
    XCTAssertTrue([viewModel isGameOver],@"Game Over logic wrong");
    XCTAssertTrue(viewModel.gameMode == GameEnded,@"Game Over logic wrong");
    
}
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
- (BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2
{
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqual:data2];
}
@end


