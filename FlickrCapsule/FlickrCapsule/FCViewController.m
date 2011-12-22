//
//  FCViewController.m
//  FlickrCapsule
//
//  Created by William Carter on 11/27/11.
//  Copyright (c) 2011 Nodesnoop LLC. All rights reserved.
//


//see http://blog.lukhnos.org/post/11275346353/flickr-oauth-support-in-objectiveflickr for auth info
//objective flickr github deal is here https://github.com/lukhnos/objectiveflickr

#import "FCViewController.h"
#import "FCAppDelegate.h"

NSString *kFetchRequestTokenStep = @"kFetchRequestTokenStep";
NSString *kGetUserInfoStep = @"kGetUserInfoStep";
NSString *kSetImagePropertiesStep = @"kSetImagePropertiesStep";
NSString *kUploadImageStep = @"kUploadImageStep";

@implementation FCViewController

@synthesize flickrRequest;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // if there's already OAuthToken, we want to reauthorize
    if ([[FCAppDelegate sharedDelegate].flickrContext.OAuthToken length]) {
        [[FCAppDelegate sharedDelegate] setAndStoreFlickrAuthToken:nil secret:nil];
    }
    
    self.flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:[FCAppDelegate sharedDelegate].flickrContext];
    self.flickrRequest.delegate = self;
    self.flickrRequest.requestTimeoutInterval = 60.0;
        
    self.flickrRequest.sessionInfo = kFetchRequestTokenStep;
    [self.flickrRequest fetchOAuthRequestTokenWithCallbackURL:[NSURL URLWithString:SRCallbackURLBaseString]];

    NSLog(@"requesting token %@", self.flickrRequest);
    
    //[flickrRequest callAPIMethodWithGET:@"flickr.photos.getRecent" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"per_page", nil]];*/
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(IBAction)getLastPicture:(id)sender
{
    NSDate *earlyDate = [NSDate dateWithTimeIntervalSinceNow:-31556926];
    NSDate *laterDate = [NSDate dateWithTimeIntervalSinceNow:(-31556926 + 2629743/2)];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
//    NSString *formattedDateString = [dateFormatter stringFromDate:date];
//    NSLog(@"formattedDateString: %@", formattedDateString);
    
    
    NSString *earlyString = [dateFormatter stringFromDate:earlyDate];
    NSString *laterString = [dateFormatter stringFromDate:laterDate];
//    [flickrRequest callAPIMethodWithGET:@"flickr.people.getPhotos" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"me", @"user_id", nil]];
    
    
    
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:@"me", @"user_id", earlyString,  @"min_taken_date", laterString, @"max_taken_date", nil];

   // NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:@"me", @"user_id", nil];
    
    [flickrRequest callAPIMethodWithGET:@"flickr.people.getPhotos" arguments:args];

}



//FLICKR DELEGATE METHODS
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{    
    NSLog(@"got recent photos %@", inResponseDictionary);
    
    
    NSDictionary *photos = [inResponseDictionary objectForKey:@"photos"];
    NSArray *photo = [photos objectForKey:@"photo"];
    NSNumber *randomNumber = [NSNumber numberWithInt:(arc4random() % [photo count])];
    

    
    NSDictionary *lastPhoto = [photo objectAtIndex:[randomNumber intValue]];
    NSString *farm = [lastPhoto objectForKey:@"farm"];
    NSString *secret = [lastPhoto objectForKey:@"secret"];
    NSString *server = [lastPhoto objectForKey:@"server"];
    NSString *_id = [lastPhoto objectForKey:@"id"];
    NSString *size = @"m";
    NSString *photoURL = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_%@.jpg", farm, server, _id, secret, size];
    NSLog(@"photoURL: %@", photoURL);
    
    //lazy
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]]];
    
    [lastImage setImage:image];
    
}
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
    
}
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest imageUploadSentBytes:(NSUInteger)inSentBytes totalBytes:(NSUInteger)inTotalBytes
{
    
}

//FLICKR OAUTH DELEGATE METHODS

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthRequestToken:(NSString *)inRequestToken secret:(NSString *)inSecret
{
    NSLog(@"getting request token");
    // these two lines are important
    [FCAppDelegate sharedDelegate].flickrContext.OAuthToken = inRequestToken;
    [FCAppDelegate sharedDelegate].flickrContext.OAuthTokenSecret = inSecret;
    
    NSURL *authURL = [[FCAppDelegate sharedDelegate].flickrContext userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrWritePermission];
    [[UIApplication sharedApplication] openURL:authURL];    

}












@end
