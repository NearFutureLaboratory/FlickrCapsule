//
//  FCViewController.h
//  FlickrCapsule
//
//  Created by William Carter on 11/27/11.
//  Copyright (c) 2011 Nodesnoop LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectiveFlickr.h"
#import "PictureImageView.h"
@interface FCViewController : UIViewController <OFFlickrAPIRequestDelegate>
{
    OFFlickrAPIRequest *flickrRequest;
    //IBOutlet UIImageView *lastImage;
    IBOutlet PictureImageView *lastImage;
    PictureImageView *firstImage;
    //NSDictionary *photosResponse;
    NSArray *photos;
    int photoIndex;
    UIScrollView *scrollView;
    
    //NSMutableArray *arrayOfPictureImageViews;
    NSMutableArray *arrayOfPictureImageViews;
}

@property (nonatomic, retain) OFFlickrAPIRequest *flickrRequest;

-(IBAction)getLastPicture:(id)sender;
-(void)initFlickrPicturesRequest;
//-(void)showNextImage;
-(void)buildPicturesArray;
-(void)makePictureSubviews;

//-(IBAction)imageTapped:(id)sender;

@end
