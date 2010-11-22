//
//  CexiMeAppDelegate.m
//  CexiMe
//
//  Created by Matt Gallagher on 28/10/08.
//  Copyright Matt Gallagher 2008. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "CexiMeAppDelegate.h"
#import "CexiMeViewController.h"
#import "AudioStreamer.h"

@implementation CexiMeAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize settingsManager			= m_settingsManager;
@synthesize localAlertShowing		= m_localAlertShowing;
@synthesize uiIsVisible;
@synthesize multitaskingSupported;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{

#ifdef DEBUG
	for ( NSString* family in [UIFont familyNames] )
	{		
		NSLog(@"Available Fonts for Family: %@", family);			
		NSLog(@"fonts=%@", [UIFont fontNamesForFamilyName:family]);
	}
#endif





	UIDevice* device = [UIDevice currentDevice];
	multitaskingSupported = NO;
	
	if ([device respondsToSelector:@selector(isMultitaskingSupported)])
		multitaskingSupported = device.multitaskingSupported;


	self.uiIsVisible = YES;
		NSDictionary *credentialStorage =
			[[NSURLCredentialStorage sharedCredentialStorage] allCredentials];
		NSLog(@"Credentials: %@", credentialStorage);
	[viewController createTimers:YES];
	[viewController forceUIUpdate];
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(presentAlertWithTitle:)
	 name:ASPresentAlertWithTitleNotification
	 object:nil];

	// Load our settings
	m_settingsManager = [[SettingsManager alloc] init];
	self.settingsManager.delegate = self;
	
	[self.settingsManager loadSettings];	

}


- (void)dealloc {

	self.settingsManager = nil;

    [viewController release];
    [window release];
    [super dealloc];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[self.settingsManager didReceiveMemoryWarning];
}





- (void)presentAlertWithTitle:(NSNotification *)notification
{
	NSString *title = [[notification userInfo] objectForKey:@"title"];
	NSString *message = [[notification userInfo] objectForKey:@"message"];
	if (!uiIsVisible) {
#ifdef TARGET_OS_IPHONE
		// \todo - check how these version numbers are being generated. This is probably not 
		// the best way to check
		if(kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_4_0) {
			UILocalNotification *localNotif = [[UILocalNotification alloc] init];	
			localNotif.alertBody = message;
			localNotif.alertAction = NSLocalizedString(@"Open", @"");
			[[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
			[localNotif release];
		}
#endif
	}
	else {
#ifdef TARGET_OS_IPHONE
		if ( self.localAlertShowing == NO ) // This is a workaround to deal with a bug with multiple notifications being received. 
		{
			UIAlertView *alert = [
								  [[UIAlertView alloc]
								   initWithTitle:title
								   message:message
								   delegate:self
								   cancelButtonTitle:NSLocalizedString(@"OK", @"")
								   otherButtonTitles: nil]
								  autorelease];
			
			if ( alert )
			{
				self.localAlertShowing = YES;
				[alert
				 performSelector:@selector(show)
				 onThread:[NSThread mainThread]
				 withObject:nil
				 waitUntilDone:NO];
			}
		}
#else
		NSAlert *alert =
		[NSAlert
		 alertWithMessageText:title
		 defaultButton:NSLocalizedString(@"OK", @"")
		 alternateButton:nil
		 otherButton:nil
		 informativeTextWithFormat:message];
		[alert
		 performSelector:@selector(runModal)
		 onThread:[NSThread mainThread]
		 withObject:nil
		 waitUntilDone:NO];
#endif
	}
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	self.uiIsVisible = NO;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	self.uiIsVisible = NO;
	[viewController createTimers:NO];
	[NSObject cancelPreviousPerformRequestsWithTarget:self.settingsManager];	
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	self.uiIsVisible = YES;
	[viewController createTimers:YES];
	[viewController forceUIUpdate];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(presentAlertWithTitle:)
	 name:ASPresentAlertWithTitleNotification
	 object:nil];
	 
 	[self.settingsManager performSelector:@selector(updateBackgroundImage) withObject:nil afterDelay:self.settingsManager.slideShowRefresh];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	self.uiIsVisible = YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	self.uiIsVisible = NO;
	[[NSNotificationCenter defaultCenter]
	 removeObserver:self
	 name:ASPresentAlertWithTitleNotification
	 object:nil];
}

// MARK: SettingsManagerDelegate

-(void)didFinishLoadingSettings:(SettingsManager*)manager 
{
	[viewController didFinishLoadingSettings:(SettingsManager*)manager];

	// Get rid of the splash screen
	[UIView beginAnimations:nil context:nil];
	viewController.splashView.alpha = 0.0f;
	[UIView commitAnimations];
}

// MARK: UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	self.localAlertShowing = NO;	
}


@end
