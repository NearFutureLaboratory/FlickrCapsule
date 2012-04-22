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

- (void)loadView {
    [super loadView];
    
    CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
    scrollView=[[UIScrollView alloc] initWithFrame:fullScreenRect];
    [scrollView setPagingEnabled:YES];
    
    //scrollView.contentSize=CGSizeMake(320,768);
    
    CGRect topRect=CGRectMake(0, 0, 320, 20);
    
//    lastImage=[[PictureImageView alloc] initWithFrame:fullScreenRect];
    
    firstImage=[[PictureImageView alloc] initWithFrame:topRect];
    [firstImage setBackgroundColor:[UIColor greenColor]];
    
    
//    [scrollView addSubview:lastImage];
///////    [scrollView addSubview:firstImage];
    
    self.view = scrollView;
    [scrollView release];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Do any additional setup after loading the view, typically from a nib.
    
    // if there's already OAuthToken, we want to reauthorize
    /************
    if ([[FCAppDelegate sharedDelegate].flickrContext.OAuthToken length]) {
        [[FCAppDelegate sharedDelegate] setAndStoreFlickrAuthToken:nil secret:nil];
    }
    *************/
    self.flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:[FCAppDelegate sharedDelegate].flickrContext];
    
    self.flickrRequest.delegate = self;
    self.flickrRequest.requestTimeoutInterval = 60.0;
        
    self.flickrRequest.sessionInfo = kFetchRequestTokenStep;
    
    
    [self.flickrRequest fetchOAuthRequestTokenWithCallbackURL:[NSURL URLWithString:SRCallbackURLBaseString]];

    NSLog(@"requesting token %@", self.flickrRequest);

    /*
    [flickrRequest callAPIMethodWithGET:@"flickr.photos.getRecent" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"per_page", nil]];
    
    // swipe recognizer -- adding to controller but also played with adding it to 
    // the view itself (cf. PictureImageView)
   */
    UISwipeGestureRecognizer *horizontal = [[UISwipeGestureRecognizer alloc]
                                            initWithTarget:self action:@selector(reportHorizontalSwipe:)];
    horizontal.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:horizontal];

    [self performSelector:@selector(initFlickrPicturesRequest) withObject:nil afterDelay:1];
    /*    
    NSTimer *timer;
    timer =  [NSTimer scheduledTimerWithTimeInterval: 1
                                              target: self
                                            selector: @selector(timerFireMethod:)
                                            userInfo: nil
                                             repeats: NO];
     */
    
}

- (void)timerFireMethod:(NSTimer*)theTimer
{
    [self initFlickrPicturesRequest];
    
}


-(void)makePictureSubviews
{
    // hopefully, the arrayOfPictureImageViews is populated with, you know..PictureImageViews
    // First..what's the height of all of them stacked end to end?
    NSEnumerator *e = [arrayOfPictureImageViews objectEnumerator];
    PictureImageView *object;
    int _currentHeight = 0;
    int _totalHeight = 0;

    // find the total height we need
    while(object = (PictureImageView *)[e nextObject]) {
        
        CGRect _bounds = [object bounds];
        CGSize _size = [object size];
        NSLog(@"frame %@", (NSStringFromCGRect([object frame])));
        _totalHeight += _bounds.size.height;
    }
 
    scrollView.contentSize=CGSizeMake(800,_totalHeight);

    e = [arrayOfPictureImageViews objectEnumerator];
    
    while(object = (PictureImageView *)[e nextObject]) {
        CGRect _bounds = [object bounds];
        NSLog(@"text %@", ([[object label] text]));
        NSLog(@"currentHeight %d", _currentHeight);
        [object setFrame:CGRectMake(0, _currentHeight, 800, _bounds.size.height)];
//        NSLog(@"bounds %@", (NSStringFromCGRect(_bounds)));
        [object setBackgroundColor:[UIColor blueColor]];
        NSLog(@"frame %@", (NSStringFromCGRect([object frame])));
        [object sizeToFit];
        [scrollView addSubview:object];
        _currentHeight += _bounds.size.height;
    }

}

-(void)buildPicturesArray
{
//    [self getThePicture];
    
    //NSMutableArray * _result = [[NSMutableArray alloc] init ];
    
    NSEnumerator *e = [photos objectEnumerator];
    arrayOfPictureImageViews = [[NSMutableArray alloc] initWithCapacity:10 ];
    id object;
    
    while (object = [e nextObject]) {
    
        NSDictionary *lastPhoto = object;
        NSString *farm = [lastPhoto objectForKey:@"farm"];
        NSString *secret = [lastPhoto objectForKey:@"secret"];
        NSString *server = [lastPhoto objectForKey:@"server"];
        NSString *_id = [lastPhoto objectForKey:@"id"];
        NSString *size = OFFlickrLargeSize;
        NSString *photoURL = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_%@.jpg", farm, server, _id, secret, size];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]]];
 //       PictureImageView *imageView = [[PictureImageView alloc] initWithImage:image];
        CGSize imageSize = [image size];
        PictureImageView *imageView = [[PictureImageView alloc] initWithFrame:(
                                                                    CGRectMake(0, 0, 
                                                                    imageSize.width, imageSize.height ))];
        [imageView setImage:image];
        NSString *title = [lastPhoto objectForKey:@"title"];
        [imageView setLabelText:title];
        [arrayOfPictureImageViews addObject:imageView];
        NSLog(@"photoURL: %@ text: %@", photoURL, title);

        //[imageView dealloc];
    }
    
    [self makePictureSubviews];
    
   // return _result;
    
}

- (void)reportHorizontalSwipe:(UIGestureRecognizer *)recognizer {
    //[self foo];
   // [self getAPicture];
    [self showNextImage];
    //[lastImage setLabelText:@"Swipe Horizontal L->R"];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [lastImage woopsRotated];
    
}


-(void)initFlickrPicturesRequest {
    NSDate *earlyDate = [NSDate dateWithTimeIntervalSinceNow:-31556926];
    NSDate *laterDate = [NSDate dateWithTimeIntervalSinceNow:(-31556926 + 2629743/2)];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    //    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    //    NSLog(@"formattedDateString: %@", formattedDateString);
    
    
    NSString *earlyString = [dateFormatter stringFromDate:earlyDate];
    NSString *laterString = [dateFormatter stringFromDate:laterDate];
    //    [flickrRequest callAPIMethodWithGET:@"flickr.people.getPhotos" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"me", @"user_id", nil]];
    
    
   // NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:@"35034348999@N01", @"user_id", earlyString,  @"min_taken_date", laterString, @"max_taken_date", nil];
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:@"66854529@N00", @"user_id", earlyString,  @"min_taken_date", laterString, @"max_taken_date", @"10", @"per_page", nil];
    //NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:@"me", @"user_id", earlyString,  @"min_taken_date", laterString, @"max_taken_date", nil];
    
    // NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:@"me", @"user_id", nil];
    
    [flickrRequest callAPIMethodWithGET:@"flickr.people.getPhotos" arguments:args];

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
    
    
    //NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:@"35034348999@N01", @"user_id", earlyString,  @"min_taken_date", laterString, @"max_taken_date", nil];
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:@"66854529@N00", @"user_id", earlyString,  @"min_taken_date", laterString, @"max_taken_date", nil];
    //NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:@"me", @"user_id", earlyString,  @"min_taken_date", laterString, @"max_taken_date", nil];

   // NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:@"me", @"user_id", nil];
    
    [flickrRequest callAPIMethodWithGET:@"flickr.people.getPhotos" arguments:args];

}

/**
- (void)showNextImage
{
    photoIndex++;
    if (photoIndex >= [photos count]) {
        photoIndex = 0;
    }
    NSDictionary *lastPhoto = [photos objectAtIndex:photoIndex];
    NSString *farm = [lastPhoto objectForKey:@"farm"];
    NSString *secret = [lastPhoto objectForKey:@"secret"];
    NSString *server = [lastPhoto objectForKey:@"server"];
    NSString *_id = [lastPhoto objectForKey:@"id"];
    NSString *size = OFFlickrSmallSize;
    NSString *photoURL = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_%@.jpg", farm, server, _id, secret, size];
    NSLog(@"photoURL: %@", photoURL);
    
    //lazy
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]]];
    [lastImage setImage:image];
    NSString *title = [lastPhoto objectForKey:@"title"];
    [lastImage setLabelText:title];
   

}
**/


//FLICKR DELEGATE METHODS
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{    
    NSLog(@"got recent photos %@", inResponseDictionary);
    
    //photosResponse = [inResponseDictionary copy];
    
    NSDictionary *photoDictionary = [inResponseDictionary objectForKey:@"photos"];
    photos = [[NSArray alloc] initWithArray:[photoDictionary objectForKey:@"photo"]];
    
/*
    NSNumber *randomNumber = [NSNumber numberWithInt:(arc4random() % [photos count])];
    photoIndex = [randomNumber intValue];

    
    NSDictionary *lastPhoto = [photos objectAtIndex:[randomNumber intValue]];
    NSString *farm = [lastPhoto objectForKey:@"farm"];
    NSString *secret = [lastPhoto objectForKey:@"secret"];
    NSString *server = [lastPhoto objectForKey:@"server"];
    NSString *_id = [lastPhoto objectForKey:@"id"];
    NSString *size = @"z";
    NSString *photoURL = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_%@.jpg", farm, server, _id, secret, size];
    NSLog(@"photoURL: %@", photoURL);
    
    //lazy
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]]];
    [lastImage setImage:image];
 */   
    [self buildPicturesArray];
}
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
    NSLog(@"Flickr API Request Error %@", [inError localizedDescription]);
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



- (IBAction)imageTapped:(id)sender {
   
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






- (void)dealloc {
    [super dealloc];
}
@end
