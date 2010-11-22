//
//  SettingsManager.m
//  CexiMe
//
//  Created by Julian on 29/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingsManager.h"
#import "ParseXMLBackgroundOperation.h"
#import "TouchXML.h"
#import "UIColor+Additions.h"
#import "CexiMeViewController.h"
#import "CexiMeAppDelegate.h"

@interface SettingsManager ()
- (void)saveSettings;
- (void)updateBackgroundImageCallback:(UIImage*)image;
@end

@implementation SettingsManager

@synthesize delegate;

@synthesize settingsXML		= m_settingsXML;
@synthesize operationQueue	= m_operationQueue;
@synthesize slideShowImages = m_slideShowImages;
@synthesize streamURL		= m_streamURL;
@synthesize backgroundImages = m_backgroundImages;
@synthesize currentBackgroundIndex;
@synthesize streamRefresh;
@synthesize adRefresh;
@synthesize slideShowRefresh;

- (void)dealloc
{
	self.operationQueue	= nil;
	self.slideShowImages = nil;
	self.streamURL = nil;
	[m_backgroundImages release]; m_backgroundImages = nil;
	[super dealloc];
}

- (id)init
{
	if ( self = [super init] )
	{
		m_operationQueue 	= [[NSOperationQueue alloc] init];		
		m_backgroundImages 	= [[NSMutableDictionary alloc] initWithCapacity:10]; 
		self.operationQueue.maxConcurrentOperationCount = 1;
		self.currentBackgroundIndex = 0;
		backgroundViewIndex = 0;
	}
	return self;
}

- (void)loadSettings
{
	// Let a background operation deal with this
	ParseXMLBackgroundOperation* op = [[ParseXMLBackgroundOperation alloc] initWithManager:self];	
	[self.operationQueue addOperation:op];
	[op release];
}

- (void)xmlWasParsed:(CXMLDocument*)xmlDocument
{
	self.settingsXML = xmlDocument;

	NSArray* imageElements 	= [xmlDocument nodesForXPath:@"//settings/slideshow/img" error:nil];
	self.slideShowImages 	= [imageElements mutableCopy];
	
	CXMLElement* streamURLElement = [[xmlDocument nodesForXPath:@"//settings/stream" error:nil] objectAtIndex:0];
//	self.streamURL = [streamURLElement stringValue];
//	
//	JSLog( @"stream url = %@", self.streamURL );

	// Get refresh values	
	streamRefresh = [[[streamURLElement attributeForName:@"refresh"] stringValue] floatValue];	
	
	CXMLElement* slideShowElement = [[xmlDocument nodesForXPath:@"//settings/slideshow" error:nil] objectAtIndex:0];
	slideShowRefresh = [[[slideShowElement attributeForName:@"refresh"] stringValue] floatValue];	
	
	CXMLElement* adsElement = [[xmlDocument nodesForXPath:@"//settings/ads" error:nil] objectAtIndex:0];
	adRefresh = [[[adsElement attributeForName:@"refresh"] stringValue] floatValue];	
	
	[self.delegate didFinishLoadingSettings:self];	
}

- (UIColor*)colorAttributeFromXPath:(NSString*)xpath
{
	CXMLElement* urlElement = [[self.settingsXML nodesForXPath:xpath error:nil] objectAtIndex:0];
	return [UIColor colorFromHex:[[urlElement attributeForName:@"color"] stringValue]];
}

- (void)initializeTextInView:(UIView*)view fromXPath:(NSString*)xpath
{
// Format like 	<title color="#0000ff" size="20" font="Helvetica">Funky Radio Station</title>

	CXMLElement* urlElement = [[self.settingsXML nodesForXPath:xpath error:nil] objectAtIndex:0];
	
	if ( [view respondsToSelector:@selector(setText:)] )
	{
		[view performSelector:@selector(setText:) withObject:[urlElement stringValue]];
	}
		
	if ( [view respondsToSelector:@selector(setFont:)] )
	{
		[view performSelector:@selector(setFont:) withObject:[UIFont fontWithName:[[urlElement attributeForName:@"font"] stringValue]
																			 size:[[[urlElement attributeForName:@"size"] stringValue] floatValue]]];
	}																			
	
	if ( [view respondsToSelector:@selector(setTextColor:)] )
	{
		[view performSelector:@selector(setTextColor:) withObject:[UIColor colorFromHex:[[urlElement attributeForName:@"color"] stringValue]]];
	}
}	

- (void)initializeImageView:(UIImageView*)view fromXPath:(NSString*)xpath
{
	CXMLElement* urlElement = [[self.settingsXML nodesForXPath:xpath error:nil] objectAtIndex:0];
	view.image = [UIImage imageNamed:[urlElement stringValue]];
}


- (void)updateBackgroundImage
{
	if ( currentBackgroundIndex >= m_slideShowImages.count )
		currentBackgroundIndex = 0;
		
	CXMLElement* slideImage = [m_slideShowImages objectAtIndex:currentBackgroundIndex];
	
	NSString* imageName = [slideImage stringValue];
	UIImage* image = [UIImage imageNamed:imageName];
	
	if ( !image )
	{
#if 0	
		// Look in the caches directory
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString* cachesDir = [paths objectAtIndex:0];

//		stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@2x.%@", 
//										[[path lastPathComponent] stringByDeletingPathExtension], 
//										[path pathExtension]]];

		NSString* filePath = [cachesDir stringByAppendingPathComponent:imageName];

        if ( [[NSFileManager defaultManager] fileExistsAtPath:filePath] )
		{
			image = [UIImage imageWithContentsOfFile:filePath];
		}
#else
		// We're going to grab images at each boot, but only once
		image = (UIImage*)[self.backgroundImages valueForKey:imageName];
#endif		
	}

	if ( !image )
	{
		// \todo grab from URL and save to caches.			
		// fetch an image from the users photos directory
		
		// <img url="http://s3.digitaldeckhands.com">slideshow1.png</img>
		NSString* httpString = [[slideImage attributeForName:@"url"] stringValue];
		NSString* urlPath = [httpString stringByAppendingPathComponent:imageName];

/*
\todo fix up url requests with context parameter (so we can look for 2x, and if that fails look for 1x)

		if ( [[UIScreen mainScreen] scale] == 2.0f )
		{
			NSString* extension = [imageName pathExtension];
			urlPath = [urlPath stringByDeletingPathExtension];
			urlPath = [urlPath stringByAppendingFormat:@"@2x.%@", extension];
		}
*/	
		BOOL urlRequested = NO;
		
		if ( urlPath )
		{
			NSURL* url = [NSURL URLWithString:urlPath];
			NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];	// default http method is GET
										
			NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:self];
			
			if ( connection )
			{
				urlRequested = YES;
				m_requestedImageName = [imageName retain];
			}
		}

		if ( urlRequested == NO )
		{
			// Hmm something failed here, so remove this 
			[m_slideShowImages removeObjectAtIndex:currentBackgroundIndex];
			[self performSelector:@selector(updateBackgroundImage) withObject:nil afterDelay:3.0f];
		}
	}
	else
	{
		[self updateBackgroundImageCallback:image];
	}
	
	currentBackgroundIndex++;		
}

#pragma mark NSURLConnectionDelegate
	
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
//	JSLog(@"didReceiveResponse: %@", response);
//	JSLog(@"headers = %@", [(NSHTTPURLResponse*)response allHeaderFields] );
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if ( !urlData )
		urlData = [[NSMutableData alloc] init];
	
	[urlData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[m_requestedImageName release]; m_requestedImageName = nil;
	// Fail!	
	// We could retry if the @2x doesn't exist, but that's just a nicety at present.
	[self updateBackgroundImageCallback:nil];
}
	
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	UIImage* image = [UIImage imageWithData:urlData];
	
	[self.backgroundImages setValue:image forKey:m_requestedImageName];

	[m_requestedImageName release]; m_requestedImageName = nil;	
	[self updateBackgroundImageCallback:image];
}



	
- (void)updateBackgroundImageCallback:(UIImage*)image
{
	CexiMeAppDelegate* appDelegate = (CexiMeAppDelegate*)[[UIApplication sharedApplication] delegate];
	CexiMeViewController* playerVC = appDelegate.viewController;

	if ( urlData )
	{
		[urlData release];
		urlData = nil;
	}
	
	// Here we have been given a UIImage, and need to swap over our background images
	if ( image )
	{
		backgroundViewIndex = !backgroundViewIndex;
		
		UIImageView* from 	= playerVC.backgroundImageView0;
		UIImageView* to 	= playerVC.backgroundImageView1;
		
		if ( backgroundViewIndex )
		{
			to 		= playerVC.backgroundImageView0;
			from 	= playerVC.backgroundImageView1;			
		}
		
		to.image = image;
		
#if 0	
		// We'll need this if/when we add the frame around the image
		CGSize 	imageSize 	= image.size;
		CGFloat imageRatio	= imageSize.width / imageSize.height;
		
		CGSize hostSize  	= playerVC.containerView.bounds.size;
		CGFloat hostRatio	= hostSize.width / hostSize.height;
	
		CGRect newViewFrame;
		if ( hostRatio > imageRatio )
		{
			newViewFrame.size.height 	= hostSize.height;
			newViewFrame.size.width		= newViewFrame.size.height * imageRatio;
			newViewFrame.origin.x		= ( hostSize.width - newViewFrame.size.width ) / 2.0f;
			newViewFrame.origin.y		= 0.0f;
		}
		else 
		{
			newViewFrame.size.width	 	= hostSize.width;
			newViewFrame.size.height 	= newViewFrame.size.width / imageRatio;	
			newViewFrame.origin.x 		= 0.0f;
			newViewFrame.origin.y		= ( hostSize.height - newViewFrame.size.height ) / 2.0f;
		}

		to.frame = newViewFrame;		
#endif
		// Animate the transition	
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:1.0f];
			to.alpha 	= 1.0f;
			from.alpha 	= 0.0f;
			[playerVC.containerView	bringSubviewToFront:to];	
		[UIView commitAnimations];
	}
		
	// Now trigger a new background images swap a little later
	// WARNING - retain count prob here...
	[self performSelector:@selector(updateBackgroundImage) withObject:nil afterDelay:self.slideShowRefresh];
}

-(void)saveSettings
{
}

- (void)didReceiveMemoryWarning
{
	// TODO: clear settings xml
	// Get rid of background images
	[self.backgroundImages removeAllObjects];
}

@end
