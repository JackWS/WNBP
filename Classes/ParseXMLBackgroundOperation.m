//
//  ParseXMLBackgroundOperation.m
//  CexiMe
//
//  Created by Julian on 29/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ParseXMLBackgroundOperation.h"
#import "SettingsManager.h"
#import "TouchXML.h"

@interface ParseXMLBackgroundOperation ()
- (NSString*)fetchStreamURLFromPLS:(NSString*)plsURL;
@end


@implementation ParseXMLBackgroundOperation
@synthesize settingsManager = m_settingsManager;

- (void)dealloc
{
	self.settingsManager = nil;
	[super dealloc];
}

- (id)initWithManager:(SettingsManager*)manager
{
	if ( self = [super init] )
	{
		self.settingsManager = manager;
	}
	return self;
}

- (void)main
{
	NSString* pathToXML = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"xml"];
    JSAssert(pathToXML);
    
	NSData* data = [NSData dataWithContentsOfFile:pathToXML];

	CXMLDocument* settingsDoc = [[[CXMLDocument alloc] initWithData:data options:0 error:nil] autorelease];

	// \todo handle PLS/M3U properly.
	// For the moment quickly 

	CXMLElement* streamURLElement = [[settingsDoc nodesForXPath:@"//settings/stream" error:nil] objectAtIndex:0];
	NSString* streamURL = [streamURLElement stringValue];
	
	if ( [[[streamURL pathExtension] lowercaseString] isEqualToString:@"pls"] )
	{
		self.settingsManager.streamURL = [self fetchStreamURLFromPLS:streamURL];
	}
	else 
	{
		self.settingsManager.streamURL = streamURL;	
	}

	[self.settingsManager performSelectorOnMainThread:@selector(xmlWasParsed:) withObject:settingsDoc waitUntilDone:YES];
}


- (NSString*)fetchStreamURLFromPLS:(NSString*)plsURL
{
	NSString *responseString = nil;
	
	// \todo make generic network operation.
	NSURL *url = [NSURL URLWithString:plsURL];
	
	if (url == nil) 
	{
		JSLog(@"nil PLS");
	}
	else 
	{
		// Prepare the URL request
		NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
		[req setHTTPShouldHandleCookies:YES];

		NSHTTPURLResponse *response = NULL;
		NSError * error = NULL;
		
		// Send the request
		NSData* data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];		
		
		// Get the request's status code
		int statusCode = [response statusCode];
		

		if (statusCode == 200) 
		{
			// Request succeeded, get the response
			responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
			
			// PLS Format is: http://en.wikipedia.org/wiki/PLS_(file_format)
			/*
			[playlist]
			NumberOfEntries=1

			File1=http://streamexample.com:80
			Title1=My Favorite Online Radio
			Length1=-1

			Version=2
			*/
			
			// As a short cut, we'll just look for File1 for the moment
			NSArray* lines = [responseString componentsSeparatedByString:@"\n"];
			for ( NSString* line in lines )
			{
				if ( [[line lowercaseString] hasPrefix:@"file1"] )
				{
					NSArray* components = [line componentsSeparatedByString:@"="];
					if ( components.count == 2 )
					{
						responseString = [[components objectAtIndex:1] stringByTrimmingCharactersInSet:
			                                  [NSCharacterSet whitespaceAndNewlineCharacterSet]];
						return responseString;
					}
				}
			}	
			
			responseString = nil;
		}
	}
	
	return responseString;
}

@end
