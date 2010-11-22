//
//  AboutViewController.m
//  CexiMe
//
//  Created by Julian on 29/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AboutViewController.h"
#import "CexiMeAppDelegate.h"
#import "SettingsManager.h"
#import "TouchXML.h"

@implementation AboutViewController

@synthesize aboutTextView 	= m_aboutTextView;
@synthesize creditsTextView = m_creditsTextView;
@synthesize backgroundView	= m_backgroundView;
@synthesize cexiLabel 		= m_cexiLabel;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;//( (interfaceOrientation == UIInterfaceOrientationLandscapeRight ) );
}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) 
	{
        // Custom initialization
		self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	// Set the about text
	CexiMeAppDelegate* appDelegate = (CexiMeAppDelegate*)[[UIApplication sharedApplication] delegate];
	SettingsManager* settingsManager = appDelegate.settingsManager;
	
	[settingsManager initializeTextInView:self.aboutTextView fromXPath:@"//settings/about/text"];
//	[settingsManager initializeTextInView:self.creditsTextView fromXPath:@"//settings/about/credits"];
//	[settingsManager initializeImageView:self.backgroundView fromXPath:@"//settings/about/background"];
	
/*	
	CEXI.me creates high quality mobile applications for your enjoyment and ours. We currently 
	offer dedicated Internet Radio Station applications that are available for free on the 
	Apple App Store℠ and the Android Marketplace℠.

	Internet Radio broadcasters around the globe are increasing their audience 
	sizes by purchasing our radio application customized just for their station.
*/

	self.cexiLabel.layer.cornerRadius = 10.0f;
	self.cexiLabel.layer.borderWidth = 1.0f;
	self.cexiLabel.layer.borderColor = [UIColor blackColor].CGColor;
}


//SCNetworkReachabilityCreateWithName
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
		
	self.cexiLabel = nil;
	self.aboutTextView = nil;
	self.creditsTextView = nil;
	self.backgroundView = nil;
}


- (void)dealloc 
{
	[m_cexiLabel release];
	[m_aboutTextView release];
	[m_creditsTextView release];
	[m_backgroundView release];
    [super dealloc];
}

- (IBAction)doneButtonPressed
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
