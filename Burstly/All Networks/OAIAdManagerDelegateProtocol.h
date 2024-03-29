/*
 
 Copyright 2009 App Media Group LLC.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

@class OAIAdManager;
@class OAIAdView;
@class CLLocation;

typedef enum {
	Anchor_Bottom			= 0x1,
	Anchor_Top				= 0x2,
	Anchor_Left				= 0x4,
	Anchor_Right			= 0x8,
	Anchor_Center			= 0xF  // Equal to Anchor_Bottom | Anchor_Top | Anchor_Left | Anchor_Right
} Anchor;

@protocol OAIAdManagerDelegate<NSObject>

@required

- (NSString *)publisherId;
- (NSString*)getZone;
- (UIViewController*)viewControllerForModalPresentation;	/* Required, this must be your top most view controller */

@optional

- (void)adManager:(OAIAdManager*)manager didLoadView:(id)adView;
- (void)adManager:(OAIAdManager*)manager viewDidChangeSize:(CGSize)newSize fromOldSize:(CGSize)oldSize;
- (void)adManager:(OAIAdManager*)manager attemptingToLoad:(NSString*)aNetwork;
- (void)adManager:(OAIAdManager*)manager adNetworkWasClicked:(NSString*)aNetwork;
- (void)adManager:(OAIAdManager*)manager adNetworkControllerPresentFullScreen:(NSString*)aNetwork;
- (void)adManager:(OAIAdManager*)manager adNetworkControllerDismissFullScreen:(NSString*)aNetwork;
- (void)adManager:(OAIAdManager*)manager didLoad:(NSString*)aNetwork;
- (void)adManager:(OAIAdManager*)manager failedToLoad:(NSString*)aNetwork;
- (void)adManager:(OAIAdManager*)manager requestThrottled:(NSNumber*)time;

- (Anchor)anchor;
- (CGPoint)anchorPoint;
- (BOOL)respondsToInterfaceOrientation;	/*	Defaults to YES	*/
- (CGFloat)defaultSessionLife;		/* Default rollover time for Ads (House Image/House Text, Marketplace, 3rd Party, etc */
- (BOOL)runFirstRequestFromCache;		/* Load first request from a local cache, Default NO	*/
- (UIInterfaceOrientation)currentOrientation;	/* Always set the current interface orientation of your view controller, this is queried BEFORE layout of ads */
- (UIModalTransitionStyle)burstlyModalTransitionStyle;	/* Style the modal presentation for burstly ads. UIModalTransitionStyleVertical by default, partial curl not allowed */

// Optional params
- (NSString *)pubTargeting;
- (NSString *)crParms;
- (NSString *)placement;
- (NSArray *)adSizes; // for example: [NSArray arrayWithObjects:@"320x48", @"320x24", @"300x50", @"250x50", nil];
- (NSArray *)category; // array of strings
- (NSArray *)keywords; // array of strings
- (NSString *)debugFlags;
- (NSString *)noTrack;
- (UIColor *)adBackgroundColor;
- (UIColor *)adTextColor;
- (CLLocation *)locationInfo;
- (NSString *)postalCode;
- (NSString *)areaCode;
- (NSDate *)dateOfBirth;
- (NSString *)gender;
- (NSString *)searchString;
- (NSString *)ipAddress;
- (NSString*)referer;
- (NSString*)page;
- (NSString*)acceptLanguage;

@end


//
int PreloadGreystripeWithID(NSString* gsID);	/* returns 0 if called 2+ times, returns 1 on init */
