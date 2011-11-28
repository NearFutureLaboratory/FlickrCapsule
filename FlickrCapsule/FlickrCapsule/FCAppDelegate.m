//
//  FCAppDelegate.m
//  FlickrCapsule
//
//  Created by William Carter on 11/27/11.
//  Copyright (c) 2011 Nodesnoop LLC. All rights reserved.
//

#import "FCAppDelegate.h"

NSString *SnapAndRunShouldUpdateAuthInfoNotification = @"SnapAndRunShouldUpdateAuthInfoNotification";

// preferably, the auth token is stored in the keychain, but since working with keychain is a pain, we use the simpler default system
NSString *kStoredAuthTokenKeyName = @"FlickrOAuthToken";
NSString *kStoredAuthTokenSecretKeyName = @"FlickrOAuthTokenSecret";

NSString *kGetAccessTokenStep = @"kGetAccessTokenStep";
NSString *kCheckTokenStep = @"kCheckTokenStep";

NSString *SRCallbackURLBaseString = @"flickrcapsule://auth";


@implementation FCAppDelegate

@synthesize window = _window;
@synthesize flickrContext;

- (void)dealloc
{
    [flickrContext release];
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    if ([self.flickrContext.OAuthToken length]) {
		[self flickrRequest].sessionInfo = kCheckTokenStep;
		[flickrRequest callAPIMethodWithGET:@"flickr.test.login" arguments:nil];

	}
    
    return YES;
}


+ (FCAppDelegate *)sharedDelegate
{
    return (FCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)setAndStoreFlickrAuthToken:(NSString *)inAuthToken secret:(NSString *)inSecret
{
	if (![inAuthToken length] || ![inSecret length]) {
		self.flickrContext.OAuthToken = nil;
        self.flickrContext.OAuthTokenSecret = nil;        
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kStoredAuthTokenKeyName];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kStoredAuthTokenSecretKeyName];
        
	}
	else {
		self.flickrContext.OAuthToken = inAuthToken;
        self.flickrContext.OAuthTokenSecret = inSecret;
		[[NSUserDefaults standardUserDefaults] setObject:inAuthToken forKey:kStoredAuthTokenKeyName];
		[[NSUserDefaults standardUserDefaults] setObject:inSecret forKey:kStoredAuthTokenSecretKeyName];
	}
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([self flickrRequest].sessionInfo) {
        // already running some other request
        NSLog(@"Already running some other request");
    }
    else {
        NSString *token = nil;
        NSString *verifier = nil;
        BOOL result = OFExtractOAuthCallback(url, [NSURL URLWithString:SRCallbackURLBaseString], &token, &verifier);
        
        if (!result) {
            NSLog(@"Cannot obtain token/secret from URL: %@", [url absoluteString]);
            return NO;
        }
        
        [self flickrRequest].sessionInfo = kGetAccessTokenStep;
        [flickrRequest fetchOAuthAccessTokenWithRequestToken:token verifier:verifier];
    }
	
    return YES;
}


- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{    
    if (inRequest.sessionInfo == kCheckTokenStep) {
		//self.flickrUserName = [inResponseDictionary valueForKeyPath:@"user.username._text"];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:SnapAndRunShouldUpdateAuthInfoNotification object:self];
    [self flickrRequest].sessionInfo = nil;    
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
	if (inRequest.sessionInfo == kGetAccessTokenStep) {
	}
	else if (inRequest.sessionInfo == kCheckTokenStep) {
		[self setAndStoreFlickrAuthToken:nil secret:nil];
	}
	    
	[[[[UIAlertView alloc] initWithTitle:@"API Failed" message:[inError description] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease] show];
	[[NSNotificationCenter defaultCenter] postNotificationName:SnapAndRunShouldUpdateAuthInfoNotification object:self];
}


#pragma mark OFFlickrAPIRequest delegate methods
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthAccessToken:(NSString *)inAccessToken secret:(NSString *)inSecret userFullName:(NSString *)inFullName userName:(NSString *)inUserName userNSID:(NSString *)inNSID
{
    [self setAndStoreFlickrAuthToken:inAccessToken secret:inSecret];

	[[NSNotificationCenter defaultCenter] postNotificationName:SnapAndRunShouldUpdateAuthInfoNotification object:self];
    [self flickrRequest].sessionInfo = nil;
}

- (OFFlickrAPIRequest *)flickrRequest
{
	if (!flickrRequest) {
		flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:self.flickrContext];
		flickrRequest.delegate = self;		
	}
	
	return flickrRequest;
}

- (OFFlickrAPIContext *)flickrContext
{
    if (!flickrContext) {
        flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:@"9eec6dfe83bd089da045b2cf74b0fd1c" sharedSecret:@"1fc84293af4b9227"];
        
        NSString *authToken = [[NSUserDefaults standardUserDefaults] objectForKey:kStoredAuthTokenKeyName];
        NSString *authTokenSecret = [[NSUserDefaults standardUserDefaults] objectForKey:kStoredAuthTokenSecretKeyName];
        
        if (([authToken length] > 0) && ([authTokenSecret length] > 0)) {
            flickrContext.OAuthToken = authToken;
            flickrContext.OAuthTokenSecret = authTokenSecret;
        }
    }
    
    return flickrContext;
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
