//
//  ScrambleViewModel.m
//  Pic Scramble
//
//  Created by Radhakrishnan Selvaraj on 14/06/16.
//  Copyright © 2016 Science-Krishnan. All rights reserved.
//

#import "Pic_Scramble-Swift.h"
#import "ScrambleViewModel.h"


CGFloat totalSecondsBeforIdentificationbegins = 10.0;

@interface ScrambleViewModel ()
@property(nonatomic)BOOL didTimerForIdentificationBegin;
@property (weak) NSTimer *repeatingTimer;
@property(nonatomic)NSInteger timeInSeconds;
@property(nonatomic)u_int32_t totalPhotos;
@property(nonatomic,copy)ImageLoadingHandler handler;
@property(nonatomic,strong)PhotoDownloader *downloader;
@property(nonatomic,copy)NSMutableArray *photoList;
@property(nonatomic)BOOL isAllItemsSelectionMandatoryForGameEnd;
@property(nonatomic)NSInteger currentlyShownImageIndex;
@property(nonatomic,strong)NSMutableSet *identifiedPhotoIndexes;

@property(nonatomic)BOOL isAllPhotosFetchedFromServer;
@end

@implementation ScrambleViewModel
@synthesize totalPhotos,downloader,photoList;
@synthesize identifiedPhotoIndexes,currentlyShownImageIndex;
@synthesize timeInSeconds,didTimerForIdentificationBegin;
@synthesize isAllItemsSelectionMandatoryForGameEnd;
-(id)initWithHandler:(ImageLoadingHandler)object{
    
    if (object == nil){
        return nil;
    }
    if (self = [super init]) {
        _handler = object;
        totalPhotos = 9;
        timeInSeconds = (NSInteger)totalSecondsBeforIdentificationbegins+1;
        photoList = [[NSMutableArray alloc]initWithCapacity:totalPhotos];
        downloader = [[PhotoDownloader alloc]init];
        identifiedPhotoIndexes = [[NSMutableSet alloc]initWithCapacity:totalPhotos];
        didTimerForIdentificationBegin = NO;
        isAllItemsSelectionMandatoryForGameEnd = NO;
        
    }
    
    [self fetchPhotos];
    
    return self;
}
-(id)init{
    return [self initWithHandler:nil];
}
#pragma mark Game-Mode-handler
#pragma mark
-(void)setGameMode:(GameMode)gameMode{
    _gameMode = gameMode;
    [self updateViewBasedOnGameMode];
}
-(void)updateViewBasedOnGameMode{
    if (self.gameMode == GameNotYetBegan) {
        [self resetGameView];
    }else if (self.gameMode == GameInitiatedTimerNotFired){
        [self didGameInitiatedTimerNotFired];
    }
    else if (self.gameMode == GameBegan){
        [self didGameBegin];
    }else{
        [self didGameEnd];
    }
}
-(void)resetGameView{
    [identifiedPhotoIndexes removeAllObjects];
    [self shufflePhotos];
    [self.communicationDelegate didGameReset:self];
}
-(void)didGameInitiatedTimerNotFired{
    
    
    NSString *message = [[NSString alloc]initWithFormat:@"You will be given %d seconds to remember the Pictures",(int)totalSecondsBeforIdentificationbegins];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Scramble" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        didTimerForIdentificationBegin = YES;
        [self beginTimer];
    }];
    [alertController addAction:okAction];
    [self.communicationDelegate showAlertController:alertController forViewModel:self];
    
    
}
-(void)beginTimer{
    
    
    [NSTimer scheduledTimerWithTimeInterval:totalSecondsBeforIdentificationbegins
                                     target:self
                                   selector:@selector(timerFired:)
                                   userInfo:nil
                                    repeats:NO];
    
    [self.communicationDelegate didGameInitiatedTimerNotFired:self];
    
    [self startRepeatingTimer];
}
-(void)timerFired:(NSTimer*)timer{
    self.gameMode = GameBegan;
}
-(void)didGameBegin{
    [self.communicationDelegate didGameBegan:self];
    [self updateRandomImageForIdentification];
}
-(void)didGameEnd{
    
    [self stopRepeatingTimer];
    
    [self.communicationDelegate didGameEnd:self];
    
}

#pragma mark DataSource
#pragma mark
-(NSInteger)numberOfSections{
    return 1;
}
-(NSInteger)numberOfItemsInSection:(NSInteger)section{
    return totalPhotos;
}
-(UIImage*)imageForItemAtIndex:(NSInteger)index{
    
    if (self.gameMode == GameNotYetBegan) {
        
        
            UIImage *defaultImage = [UIImage imageNamed:@"Default-Image"];
            return defaultImage;
            
        
        
    }else if (self.gameMode == GameInitiatedTimerNotFired){
        
    
        if (didTimerForIdentificationBegin == YES) {
            
            FlickrPhoto * photo = [self.photoList objectAtIndex:index];
            return photo.largeImage;

        }else{
            UIImage *defaultImage = [UIImage imageNamed:@"Default-Image"];
            return defaultImage;
        }
        
        
        
    }
    else if (self.gameMode == GameEnded){
       
        FlickrPhoto * photo = [self.photoList objectAtIndex:index];
        return photo.largeImage;
    }else{
        
        
        if (YES == [self isImageIndexAlreadyIdentified:index] ){
            
            FlickrPhoto * photo = [self.photoList objectAtIndex:index];
            return photo.largeImage;
            
        }else{
            UIImage *defaultImage = [UIImage imageNamed:@"Question-Coin"];
            return defaultImage;
        }
        
    }
    
}
-(void)updateRandomImageForIdentification{
    
    if ([self isGameOver] == NO) {
        NSInteger identificationIndex = [self updatedImageIndexForIdentification];
        currentlyShownImageIndex = identificationIndex;
        FlickrPhoto *photo = [self.photoList objectAtIndex:identificationIndex];
        [self.communicationDelegate didFreshIdentifcationBeginWithImage:photo.largeImage inViewModel:self];
    }else{
        self.gameMode = GameEnded;
    }
}
-(void)didSelectImageAtIndex:(NSInteger)selectedIndex{
    
    BOOL didSucceed = [self isPhotoIdentifiedWithIndex:selectedIndex];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:selectedIndex inSection:0];
    if (didSucceed) {
        [identifiedPhotoIndexes addObject:[NSNumber numberWithInteger:selectedIndex ]];
        
        [self.communicationDelegate didIdentificationSucceedAtIndexPath:indexPath inViewModel:self];
        [self updateRandomImageForIdentification];
    }
    else{
        [self.communicationDelegate didIdentificationFailAtIndexPath:indexPath inViewModel:self];
    }
}
#pragma mark Photo-Fetch
-(void)fetchPhotos{
    
    [self.communicationDelegate didPhotoLoadBegan:self];
    [Async background:^{
        
        [downloader fetchImage:^(FlickrPhoto * photo, BOOL isLastObject) {
            
            self.isAllPhotosFetchedFromServer = isLastObject;
            [photoList addObject:photo];
            NSInteger index = photoList.count-1;
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            if (photoList.count <= totalPhotos) {
                [Async main:^{
                    _handler(photo,indexPath);
                    
                }];
                if (photoList.count == totalPhotos) {
                    [self.communicationDelegate didPhotoLoadFinish:self];
                }
            }
            
        } failBlock:^(NSString * errorMessage) {
            
            [self.communicationDelegate showMessage:errorMessage];
            [photoList removeAllObjects];
        }];
       
        
    }];
}

#pragma mark Game-Logic
#pragma mark
-(BOOL)isImageIndexAlreadyIdentified:(NSInteger)index{
    
    NSNumber *currentIndex = [[NSNumber alloc] initWithInteger: index];
    if (YES == [identifiedPhotoIndexes containsObject:currentIndex]) {
        return YES;
    }else{
        return NO;
    }
    
}
-(BOOL)isPhotoIdentifiedWithIndex:(NSInteger)selectedIndex{
    if (selectedIndex == currentlyShownImageIndex) {
        return YES;
    }
    return NO;
}
-(BOOL)isGameOver{
    
    if (isAllItemsSelectionMandatoryForGameEnd == YES) {
        
        if (identifiedPhotoIndexes.count < totalPhotos) {
            return NO;
        }else{
            return YES;
        }
        
    }else{
        
        if (identifiedPhotoIndexes.count < totalPhotos-1) {
            return NO;
        }else{
            return YES;
        }
    }
    
}
-(NSInteger)updatedImageIndexForIdentification{
    
    NSMutableSet *wholeSet = [[NSMutableSet alloc]initWithCapacity:totalPhotos];
    for (NSInteger index = 0; index < totalPhotos; index++) {
        [wholeSet addObject:[[NSNumber alloc] initWithInteger: index]];
    }
    [wholeSet minusSet:identifiedPhotoIndexes];
    NSArray *listOfRemainingIndexes = [wholeSet allObjects];
    u_int32_t index = arc4random_uniform((u_int32_t)listOfRemainingIndexes.count);
    NSNumber *selectedIndex = [listOfRemainingIndexes objectAtIndex:index];
    return selectedIndex.integerValue;
}
#pragma mark Timer
#pragma mark
- (IBAction)startRepeatingTimer {
    
    [self updateTimerLabel:_repeatingTimer];
    // Cancel a preexisting timer.
    [self.repeatingTimer invalidate];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self selector:@selector(updateTimerLabel:)
                                                    userInfo:nil repeats:YES];
    self.repeatingTimer = timer;
}

-(void)updateTimerLabel:(NSTimer*)timer{
    timeInSeconds = timeInSeconds - 1;
    NSString *text = [[NSString alloc]initWithFormat:@"%ld seconds",(long)timeInSeconds];
    [self.communicationDelegate updateTimerText:text];
}
- (void)stopRepeatingTimer {
    
    self.timeInSeconds = (NSInteger)totalSecondsBeforIdentificationbegins+1;
    [self.repeatingTimer invalidate];
    self.repeatingTimer = nil;
}
#pragma mark Shuffle
#pragma mark
-(void)shufflePhotos{
    
    if (true == self.isAllPhotosFetchedFromServer && self.photoList.count > 0) {
        
        NSSet *allPhotos = [[NSSet alloc]initWithArray:self.photoList];
        NSMutableArray *mutablePhotoList = [[NSMutableArray alloc]initWithArray:[allPhotos allObjects]];
        self.photoList = [mutablePhotoList mutableCopy];
    }
}
@end

