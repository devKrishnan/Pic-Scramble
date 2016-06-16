//
//  ViewController.m
//  Pic Scramble
//
//  Created by Radhakrishnan Selvaraj on 14/06/16.
//  Copyright © 2016 Science-Krishnan. All rights reserved.
//

#import "ViewController.h"
#import "ScrambleViewModel.h"
#import "Pic_Scramble-Swift.h"
#import "UIView+Shake.h"

NSString * reuseIdentifier = @"ImageCollectionViewCell";



@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *currentImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *startButton;
@property(nonatomic,strong)ScrambleViewModel *viewModel;

@end

@implementation ViewController
@synthesize viewModel,startButton;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.startButton.enabled = NO;
    self.timerLabel.hidden = YES;
    self.currentImageView.hidden = YES;
    self.viewModel = [[ScrambleViewModel alloc]initWithHandler:^(FlickrPhoto *photo, NSIndexPath *indexPath) {
        
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        if (viewModel.photoList.count >= viewModel.totalPhotos) {
           
            dispatch_time_t timeBlock = dispatch_time(DISPATCH_TIME_NOW, 10*3);
            dispatch_after(timeBlock, dispatch_get_main_queue(), ^{
                self.startButton.enabled = YES;
                self.viewModel.communicationDelegate = self;
                self.viewModel.gameMode = GameNotYetBegan;
            });
        }
    }];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [viewModel numberOfSections];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [viewModel numberOfItemsInSection:section];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}



#pragma mark Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [viewModel didSelectImageAtIndex:indexPath.row];
}
#pragma mark Private-Methods
- (void)configureCell:(ImageCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    UIImage *image = [viewModel imageForItemAtIndex:indexPath.row];
    if (viewModel.gameMode == GameNotYetBegan || viewModel.gameMode == GameInitiatedTimerNotFired) {
        cell.imageView.image = image;
    }else{
        [self flipVerical:cell.imageView withNewImage:image];
    }
    
    
}
-(void)flipVerical:(UIImageView*)imageView withNewImage:(UIImage*)image{
    
  
    
        [UIView animateWithDuration:1.0 animations:^{
            imageView.layer.transform = CATransform3DMakeRotation(M_PI/2,1.0,0.0,0.0);
            
        } completion:^(BOOL finished) {
        
            
            [UIView animateWithDuration:1.0 animations:^{
                imageView.image = image;
                imageView.layer.transform = CATransform3DMakeRotation(4*M_PI,1.0,0.0,0.0);
            } completion:^(BOOL finished) {
                
                
                
            }];
        }];
    

   
}
#pragma mark Event-Handlers
- (IBAction)beginGame:(id)sender {
    startButton.enabled = NO;
    self.viewModel.gameMode = GameInitiatedTimerNotFired;
}

#pragma mark Communication-Delegate
#pragma mark
-(void)didGameReset:(ScrambleViewModel*)viewModel{
    
    self.startButton.enabled = YES;
    self.collectionView.allowsSelection = NO;
    self.currentImageView.image = nil;
    self.timerLabel.hidden = YES;
    [self.collectionView  reloadData];
    //[self.tim]
}
-(void)didGameInitiatedTimerNotFired:(ScrambleViewModel*)viewModel{
    
    [self.collectionView  reloadData];
    self.startButton.enabled = NO;
    self.collectionView.allowsSelection = NO;
    self.timerLabel.hidden = NO;
    
    
}
-(void)didGameBegan:(ScrambleViewModel*)viewModel{
    
    self.currentImageView.hidden = NO;
    self.collectionView.allowsSelection = YES;
    self.timerLabel.hidden = YES;
    [self.collectionView  reloadData];
    
}
-(void)updateTimerText:(NSString*)text{
    self.timerLabel.text =  text;
}
-(void)didGameEnd:(ScrambleViewModel*)viewModel{
    
    self.currentImageView.hidden = YES;
    self.startButton.enabled = YES;
    self.collectionView.allowsSelection = NO;
    self.currentImageView.image = nil;
    [self showMessage:@"Game Ended"];
    
    [NSTimer scheduledTimerWithTimeInterval:3.0
                                     target:self
                                   selector:@selector(resetGame)
                                   userInfo:nil
                                    repeats:NO];
}
-(void)resetGame{
    self.viewModel.gameMode = GameNotYetBegan;
}
-(void)didPhotoLoadBegan:(ScrambleViewModel*)viewModel{
    startButton.enabled = NO;
}
-(void)didPhotoLoadFinish:(ScrambleViewModel *)viewModel{
    startButton.enabled = YES;
}
-(void)didIdentificationSucceedAtIndexPath:(NSIndexPath*)indexPath inViewModel:(ScrambleViewModel*)viewModel{

    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        
    }];
    
}
-(void)didIdentificationFailAtIndexPath:(NSIndexPath*)indexPath inViewModel:(ScrambleViewModel*)viewModel{
    ImageCollectionViewCell *cell = (ImageCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell.imageView shake];
    //[self showMessage:@"Image Identification Failed"];
}
-(void)showAlertController:(UIAlertController*)alertController forViewModel:(ScrambleViewModel*)viewModel{
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

-(void)didFreshIdentifcationBeginWithImage:(UIImage *)image inViewModel :(ScrambleViewModel *)viewModel{
    self.currentImageView.image = image;
}

-(void)showMessage:(NSString*)message
{

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Scramble" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
    
}
@end


