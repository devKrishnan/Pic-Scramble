//
//  ScrambleViewModel.h
//  Pic Scramble
//
//  Created by Radhakrishnan Selvaraj on 14/06/16.
//  Copyright © 2016 Science-Krishnan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pic_Scramble-Swift.h"

@class ScrambleViewModel;

@protocol UICommunication <NSObject>

-(void)showMessage:(NSString*)message;
-(void)didPhotoLoadBegan:(ScrambleViewModel*)viewModel;
-(void)didPhotoLoadFinish:(ScrambleViewModel*)viewModel;
-(void)didGameReset:(ScrambleViewModel*)viewModel;
-(void)didGameBegan:(ScrambleViewModel*)viewModel;
-(void)didGameEnd:(ScrambleViewModel*)viewModel;

-(void)didIdentificationSucceedAtIndex:(NSInteger)index inViewModel:(ScrambleViewModel*)viewModel;
-(void)didIdentificationFailAtIndex:(NSInteger)index inViewModel:(ScrambleViewModel*)viewModel;

-(void)didFreshIdentifcationBeginWithImage:(UIImage *)image inViewModel :(ScrambleViewModel *)viewModel;
@end

typedef void (^ImageLoadingHandler)(FlickrPhoto *photo,NSIndexPath *indexPath);

typedef enum {
    GameNotYetBegan = 0,
    GameInProgress,
    GameEnded
}GameMode;

@interface ScrambleViewModel : NSObject

@property(nonatomic,weak)id<UICommunication> communicationDelegate;
@property(nonatomic)GameMode gameMode;



-(id)initWithHandler:(ImageLoadingHandler)handler;
-(BOOL)isGameOver;
-(void)didSelectImageAtIndex:(NSInteger)selectedIndex;
-(NSInteger)numberOfSections;
-(NSInteger)numberOfItemsInSection:(NSInteger)section;
-(UIImage*)imageForItemAtIndex:(NSInteger)index;
@end
