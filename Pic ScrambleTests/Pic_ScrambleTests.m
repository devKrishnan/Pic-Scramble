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
@interface Pic_ScrambleTests : XCTestCase<UICommunication>
@property(nonatomic,strong)ScrambleViewModel *viewModel;
@end

@implementation Pic_ScrambleTests
@synthesize viewModel;
- (void)setUp {
    [super setUp];
    
    self.viewModel = [[ScrambleViewModel alloc]initWithHandler:^(FlickrPhoto *photo, NSIndexPath *indexPath) {
        
        
        
    }];
    
viewModel.gameMode = GameNotYetBegan;
    
    
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

- (void)testGameBegin {
    
    SpyDelegate *delegate = [[SpyDelegate alloc]init];
    self.viewModel.communicationDelegate = delegate;
    
    XCTestExpectation *getServicePersonExpectation = [self expectationWithDescription:@"get Service Person By ID"];
    delegate.asyncExpectation = getServicePersonExpectation;
    
    
    
    
    //XCTAssertTrue(delegate.gameBegan ,@"Game begin failed");
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
#pragma mark Communication-Delegate
#pragma mark
-(void)showMessage:(NSString*)message{
    
}
-(void)didPhotoLoadBegan:(ScrambleViewModel*)viewModel{
    
}
-(void)didPhotoLoadFinish:(ScrambleViewModel*)viewModel{
    
}
-(void)didGameReset:(ScrambleViewModel*)viewModel{
    
}
-(void)didGameInitiatedTimerNotFired:(ScrambleViewModel*)viewModel{
    
}
-(void)didGameBegan:(ScrambleViewModel*)viewModel{
    
}
-(void)didGameEnd:(ScrambleViewModel*)viewModel{
    
}
-(void)showAlertController:(UIAlertController*)alertController forViewModel:(ScrambleViewModel*)viewModel{
    
}
-(void)didIdentificationSucceedAtIndex:(NSIndexPath*)indexPath inViewModel:(ScrambleViewModel*)viewModel{
    
}
-(void)didIdentificationFailAtIndex:(NSInteger)index inViewModel:(ScrambleViewModel*)viewModel{
    
}

-(void)didFreshIdentifcationBeginWithImage:(UIImage *)image inViewModel :(ScrambleViewModel *)viewModel{
    
}
-(void)updateTimerText:(NSString*)text{
    
}
@end
