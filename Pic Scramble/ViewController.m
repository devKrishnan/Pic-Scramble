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
    self.viewModel = [[ScrambleViewModel alloc]initWithHandler:^(FlickrPhoto *photo, NSIndexPath *indexPath) {
        
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            
    }];
    self.viewModel.communicationDelegate = self;
    self.viewModel.gameMode = GameNotYetBegan;
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(100, 100);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    UIEdgeInsets sectionInsets = UIEdgeInsetsMake(50.0, 20.0, 50.0, 20.0 );
    return sectionInsets;
}
#pragma mark Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [viewModel didSelectImageAtIndex:indexPath.row];
}
#pragma mark Private-Methods
- (void)configureCell:(ImageCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    UIImage *image = [viewModel imageForItemAtIndex:indexPath.row];
    if (viewModel.gameMode == GameNotYetBegan ) {
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
    //[self.tim]
}
-(void)didGameInitiatedTimerNotFired:(ScrambleViewModel*)viewModel{
    self.startButton.enabled = NO;
    self.collectionView.allowsSelection = YES;
    self.timerLabel.hidden = NO;
    [self.collectionView  reloadData];
}
-(void)didGameBegan:(ScrambleViewModel*)viewModel{
    self.timerLabel.hidden = YES;
    [self.collectionView  reloadData];
    
}
-(void)updateTimerText:(NSString*)text{
    self.timerLabel.text =  text;
}
-(void)didGameEnd:(ScrambleViewModel*)viewModel{
    
    
    self.startButton.enabled = YES;
    self.collectionView.allowsSelection = NO;
    self.currentImageView.image = nil;
    [self showMessage:@"Game Ended"];
}
-(void)didPhotoLoadBegan:(ScrambleViewModel*)viewModel{
    startButton.enabled = NO;
}
-(void)didPhotoLoadFinish:(ScrambleViewModel *)viewModel{
    startButton.enabled = YES;
}
-(void)didIdentificationSucceedAtIndex:(NSIndexPath*)indexPath inViewModel:(ScrambleViewModel*)viewModel{

    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        
    }];
    
    
    
}
-(void)showAlertController:(UIAlertController*)alertController forViewModel:(ScrambleViewModel*)viewModel{
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}
-(void)didIdentificationFailAtIndex:(NSInteger)index inViewModel:(ScrambleViewModel*)viewModel{
    [self showMessage:@"Image Identification Failed"];
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


