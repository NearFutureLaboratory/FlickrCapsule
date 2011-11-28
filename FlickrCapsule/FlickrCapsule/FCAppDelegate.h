//
//  FCAppDelegate.h
//  FlickrCapsule
//
//  Created by William Carter on 11/27/11.
//  Copyright (c) 2011 Nodesnoop LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectiveFlickr.h"

extern NSString *SnapAndRunShouldUpdateAuthInfoNotification;
extern NSString *SRCallbackURLBaseString;

@interface FCAppDelegate : UIResponder <UIApplicationDelegate, OFFlickrAPIRequestDelegate>
{
    OFFlickrAPIContext *flickrContext;
    OFFlickrAPIRequest *flickrRequest;
}

@property (nonatomic, readonly) OFFlickrAPIContext *flickrContext;

@property (strong, nonatomic) UIWindow *window;

- (OFFlickrAPIRequest *)flickrRequest;
+ (FCAppDelegate *)sharedDelegate;
- (void)setAndStoreFlickrAuthToken:(NSString *)inAuthToken secret:(NSString *)inSecret;



@end
