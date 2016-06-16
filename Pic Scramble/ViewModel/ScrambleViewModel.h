//
//  ScrambleViewModel.h
//  Pic Scramble
//
//  Created by Radhakrishnan Selvaraj on 14/06/16.
//  Copyright © 2016 Science-Krishnan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FlickrPhoto;
@class ScrambleViewModel;

@protocol UICommunication <NSObject>

-(void)showMessage:(NSString*)message;
-(void)didPhotoLoadBegan:(ScrambleViewModel*)viewModel;
-(void)didPhotoLoadFinish:(ScrambleViewModel*)viewModel;
-(void)didGameReset:(ScrambleViewModel*)viewModel;
-(void)didGameInitiatedTimerNotFired:(ScrambleViewModel*)viewModel;
-(void)didGameBegan:(ScrambleViewModel*)viewModel;

-(void)didGameEnd:(ScrambleViewModel*)viewModel;
-(void)showAlertController:(UIAlertController*)alertController forViewModel:(ScrambleViewModel*)viewModel;
-(void)didIdentificationSucceedAtIndexPath:(NSIndexPath*)indexPath inViewModel:(ScrambleViewModel*)viewModel;
-(void)didIdentificationFailAtIndexPath:(NSIndexPath*)indexPath inViewModel:(ScrambleViewModel*)viewModel;

-(void)didFreshIdentifcationBeginWithImage:(UIImage *)image inViewModel :(ScrambleViewModel *)viewModel;
-(void)updateTimerText:(NSString*)text;
@end

typedef void (^ImageLoadingHandler)(FlickrPhoto *photo,NSIndexPath *indexPath);

typedef enum {
    GameNotYetBegan = 0,
    GameInitiatedTimerNotFired,
    GameBegan,
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


@property(nonatomic,readonly)BOOL isAllItemsSelectionMandatoryForGameEnd;
@property(nonatomic,readonly)NSInteger currentlyShownImageIndex;
@property(nonatomic,copy,readonly)NSMutableArray *photoList;
@property(nonatomic,readonly)u_int32_t totalPhotos;
@end
