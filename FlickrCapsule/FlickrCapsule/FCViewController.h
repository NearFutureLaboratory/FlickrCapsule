//
//  FCViewController.h
//  FlickrCapsule
//
//  Created by William Carter on 11/27/11.
//  Copyright (c) 2011 Nodesnoop LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectiveFlickr.h"

@interface FCViewController : UIViewController <OFFlickrAPIRequestDelegate>
{
    OFFlickrAPIRequest *flickrRequest;
    IBOutlet UIImageView *lastImage;
}

@property (nonatomic, retain) OFFlickrAPIRequest *flickrRequest;

-(IBAction)getLastPicture:(id)sender;

@end
