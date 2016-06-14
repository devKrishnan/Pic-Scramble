//
//  ScrambleViewModel.m
//  Pic Scramble
//
//  Created by Radhakrishnan Selvaraj on 14/06/16.
//  Copyright © 2016 Science-Krishnan. All rights reserved.
//

#import "ScrambleViewModel.h"

@interface ScrambleViewModel ()
@property(nonatomic)u_int32_t totalPhotos;
@property(nonatomic,copy)ImageLoadingHandler handler;
@property(nonatomic,strong)PhotoDownloader *downloader;
@property(nonatomic,copy)NSMutableArray *photoList;

@property(nonatomic)NSInteger currentlyShownImageIndex;
@property(nonatomic,strong)NSMutableSet *identifiedPhotoIndexes;
@end

@implementation ScrambleViewModel
@synthesize totalPhotos,downloader,photoList;
@synthesize identifiedPhotoIndexes,currentlyShownImageIndex;
-(id)initWithHandler:(ImageLoadingHandler)object{
    
    if (object == nil){
        return nil;
    }
    if (self = [super init]) {
        _handler = object;
        totalPhotos = 9;
        photoList = [[NSMutableArray alloc]initWithCapacity:totalPhotos];
        downloader = [[PhotoDownloader alloc]init];
        identifiedPhotoIndexes = [[NSMutableSet alloc]initWithCapacity:totalPhotos];
        
        
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
    }else if (self.gameMode == GameInProgress){
        [self didGameBegin];
    }else{
        [self didGameEnd];
    }
}
-(void)resetGameView{
    [self.communicationDelegate didGameReset:self];
}
-(void)didGameBegin{
    [self.communicationDelegate didGameBegan:self];
    [self updateRandomImageForIdentification];
}
-(void)didGameEnd{
    
    [identifiedPhotoIndexes removeAllObjects];
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
        
        if (self.photoList.count > index) {
            
            FlickrPhoto * photo = [self.photoList objectAtIndex:index];
            return photo.largeImage;
        }
        else{
            UIImage *defaultImage = [UIImage imageNamed:@"Default-Image"];
            return defaultImage;
            
        }
        
    }else{
        
        FlickrPhoto * photo = [self.photoList objectAtIndex:index];
        return photo.largeImage;
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
    if (didSucceed) {
        [identifiedPhotoIndexes addObject:[NSNumber numberWithInteger:selectedIndex ]];
        [self.communicationDelegate didIdentificationSucceedAtIndex:selectedIndex inViewModel:self];
        [self updateRandomImageForIdentification];
    }
    else{
        [self.communicationDelegate didIdentificationFailAtIndex:selectedIndex inViewModel:self];
    }
}
#pragma mark Photo-Fetch
-(void)fetchPhotos{
    [self.communicationDelegate didPhotoLoadBegan:self];
    [Async background:^{
        
        [downloader fetchImage:^(FlickrPhoto *photo) {
            
            
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
-(BOOL)isPhotoIdentifiedWithIndex:(NSInteger)selectedIndex{
    if (selectedIndex == currentlyShownImageIndex) {
        return YES;
    }
    return NO;
}
-(BOOL)isGameOver{
     if (identifiedPhotoIndexes.count < totalPhotos) {
         return NO;
     }else{
         return YES;
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
@end
