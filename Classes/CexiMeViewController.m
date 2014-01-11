//
//  CexiMeViewController.m
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

#import "SHK.h"
#import "CexiMeAppDelegate.h"
#import "CexiMeViewController.h"
#import "AudioStreamer.h"
//#import "LevelMeterView.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>
#import "AboutViewController.h"



@implementation CexiMeViewController

@synthesize backgroundImageView0 	= m_backgroundImageView0;
@synthesize backgroundImageView1 	= m_backgroundImageView1;
@synthesize titleLabel				= m_titleLabel;
@synthesize noStreamLabel			= m_noStreamLabel;
@synthesize activityView			= m_activityView;
@synthesize containerView			= m_containerView;


@synthesize controlsView			= m_controlsView;
@synthesize splashView				= m_splashView;
@synthesize streamControlsHost		= m_streamControlsHost;
@synthesize adBackgroundBar			= m_adBackgroundBar;
@synthesize adHost 					= m_adHost;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	
    return YES;// ( (interfaceOrientation == UIInterfaceOrientationLandscapeRight ) );
}

#ifdef BURSTLY
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

	// Bloody ad view has a mind of its own, so let's fade it out while rotating
	[UIView beginAnimations:@"adFadeOut" context:nil];
		self.adHost.alpha = 0.0f;
	[UIView commitAnimations];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[adManager updateView];
	[UIView beginAnimations:@"adFadeUp" context:nil];
		self.adHost.alpha = 1.0f;
	[UIView commitAnimations];	
}
#endif
//
// setButtonImage:
//
// Used to change the image on the playbutton. This method exists for
// the purpose of inter-thread invocation because
// the observeValueForKeyPath:ofObject:change:context: method is invoked
// from secondary threads and UI updates are only permitted on the main thread.
//
// Parameters:
//    image - the image to set on the play button.
//
- (void)setButtonImage:(UIImage *)image
{
	[button.layer removeAllAnimations];
	if (!image)
	{
		[button setImage:[UIImage imageNamed:@"playBtn50.png"] forState:0];
	}
	else
	{
		[button setImage:image forState:0];
	
		if ([button.currentImage isEqual:[UIImage imageNamed:@"loadingBtn50.png"]])
		{
			[UIView beginAnimations:nil context:nil];
			button.alpha = 0.0f;
			[UIView commitAnimations];
			[self.activityView startAnimating];
		}
		else 
		{
			[UIView beginAnimations:nil context:nil];
			button.alpha = 1.0f;
			[UIView commitAnimations];			
			[self.activityView stopAnimating];
		}
	}
}

//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
			removeObserver:self
			name:ASStatusChangedNotification
			object:streamer];
		[self createTimers:NO];
		
		[streamer stop];
		[streamer release];
		streamer = nil;
	}
}

//
// forceUIUpdate
//
// When foregrounded force UI update since we didn't update in the background
//
-(void)forceUIUpdate {
	if (currentArtist)
		metadataArtist.text = currentArtist;
	if (currentTitle)
		metadataTitle.text = currentTitle;
	if (!streamer) 
	{
#if 0
		[levelMeterView updateMeterWithLeftValue:0.0 
									  rightValue:0.0];
#endif									  
		[self setButtonImage:[UIImage imageNamed:@"playBtn50.png"]];
	}
	else 
		[self playbackStateChanged:NULL];
}

//
// createTimers
//
// Creates or destoys the timers
//
-(void)createTimers:(BOOL)create {
	if (create) {
		if (streamer) {
				[self createTimers:NO];
#if 0
				// \todo - not currently using the sliders or level meters
								
				progressUpdateTimer =
				[NSTimer
				 scheduledTimerWithTimeInterval:0.1
				 target:self
				 selector:@selector(updateProgress:)
				 userInfo:nil
				 repeats:YES];
				levelMeterUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:.1 
																		 target:self 
																	   selector:@selector(updateLevelMeters:) 
																	   userInfo:nil 
																		repeats:YES];
#else
				progressUpdateTimer = nil;
				levelMeterUpdateTimer = nil;
#endif																		

		}
	}
	else {
		if (progressUpdateTimer)
		{
			[progressUpdateTimer invalidate];
			progressUpdateTimer = nil;
		}
		if(levelMeterUpdateTimer) {
			[levelMeterUpdateTimer invalidate];
			levelMeterUpdateTimer = nil;
		}
	}
}

//
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//
- (void)createStreamer
{
	if (streamer)
	{
		return;
	}

	[self destroyStreamer];
	

	CexiMeAppDelegate* appDelegate = (CexiMeAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	if ( appDelegate.settingsManager.streamURL == nil )
		return;
	
	NSString *escapedValue =
		[(NSString *)CFURLCreateStringByAddingPercentEscapes(
			nil,
			(CFStringRef)appDelegate.settingsManager.streamURL,	//downloadSourceField.text,
			NULL,
			NULL,
			kCFStringEncodingUTF8)
		autorelease];

	NSURL *url = [NSURL URLWithString:escapedValue];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	
	[self createTimers:YES];

	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(playbackStateChanged:)
		name:ASStatusChangedNotification
		object:streamer];
#ifdef SHOUTCAST_METADATA
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(metadataChanged:)
	 name:ASUpdateMetadataNotification
	 object:streamer];
#endif
}

//
// viewDidLoad
//
// Creates the volume slider, sets the default path for the local file and
// creates the streamer immediately if we already have a file at the local
// location.
//
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	MPVolumeView *volumeView = [[[MPVolumeView alloc] initWithFrame:volumeSlider.bounds] autorelease];
	[volumeSlider addSubview:volumeView];
	[volumeView sizeToFit];
	volumeView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
	
	CGRect frame = volumeView.frame;
	frame.origin.y = floorf( ( volumeSlider.bounds.size.height - frame.size.height ) / 2.0f );
	volumeView.frame = frame;
	
	
	[self setButtonImage:[UIImage imageNamed:@"playBtn50.png"]];
	
//	levelMeterView = [[LevelMeterView alloc] initWithFrame:CGRectMake(10.0, 310.0, 300.0, 60.0)];
//	[self.view addSubview:levelMeterView];

	m_wasPlaying = NO;
	m_pauseCount = 0;

//	UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
//	[self.view addGestureRecognizer:tapGesture];
//	tapGesture.delegate = self;	
//	[tapGesture release];


/*
	UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default.png"]];
	[self.splashView addSubview:imageView];
	[self.splashView bringSubviewToFront:self.activityView];
	[imageView release];
*/

	self.controlsView.alpha = 0.0f;

	showingControls = YES;

#ifdef BURSTLY
	adManager = nil;
	@try 
	{
		adManager = [[OAIAdManager alloc] initWithDelegate:self];
		adManager.view.autoresizingMask = 	UIViewAutoresizingFlexibleLeftMargin |
											UIViewAutoresizingFlexibleRightMargin |
											UIViewAutoresizingFlexibleTopMargin |
											UIViewAutoresizingFlexibleHeight |
											UIViewAutoresizingFlexibleWidth |
											0;
		
		[self.adHost addSubview:adManager.view];
		[adManager requestRefreshAd];	
	}
	@catch (NSException * e) {
		JSLog(@"Exception creating ad manager: %@", e );
	}
//	@finally {
//	}
#endif
}

- (void)showControls:(BOOL)show
{
	[UIView beginAnimations:@"show" context:nil];
		CGRect frame = self.controlsView.frame;

		if ( show )
			frame.origin.y -= frame.size.height;
		else
			frame.origin.y += frame.size.height;

		self.controlsView.frame = frame;
	[UIView commitAnimations];		
	
	showingControls = show;
}
/*
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
//	CGPoint point = [gestureRecognizer locationInView:self.controlsView];
//	
//	return (!( CGRectContainsPoint(self.controlsView.bounds, point) ));

	return ( ![touch.view isDescendantOfView:self.controlsView] );
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer 
{
	// hide or show controls
	[self showControls: !showingControls];
}
*/
-(void)handleTap:(UITouch*)touch
{
	if ( ![touch.view isDescendantOfView:self.controlsView] )
		[self showControls: !showingControls];
	else {
		JSLog(@"tapped control bar");
	}

}


- (void)viewDidUnload
{
#ifdef BURSTLY
	[adManager release]; adManager = nil;
#endif
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.backgroundImageView0 = nil;
	self.backgroundImageView1 = nil;
	self.titleLabel = nil;
	self.activityView = nil;
	self.containerView = nil;
	self.controlsView = nil;
	self.splashView = nil;	
	self.noStreamLabel = nil;
	self.streamControlsHost = nil;	
	
	self.adBackgroundBar = nil;
	self.adHost = nil;
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	UIApplication *application = [UIApplication sharedApplication];
	if([application respondsToSelector:@selector(beginReceivingRemoteControlEvents)])
		[application beginReceivingRemoteControlEvents];
	[self becomeFirstResponder]; // this enables listening for events
	// update the UI in case we were in the background
	NSNotification *notification =
	[NSNotification
	 notificationWithName:ASStatusChangedNotification
	 object:self];
	[[NSNotificationCenter defaultCenter]
	 postNotification:notification];
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

//
// spinButton
//
// Shows the spin button when the audio is loading. This is largely irrelevant
// now that the audio is loaded from a local file.
//
/*
- (void)spinButton
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	CGRect frame = [button frame];
	button.layer.anchorPoint = CGPointMake(0.5, 0.5);
	button.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
	[CATransaction commit];

	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
	[CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];

	CABasicAnimation *animation;
	animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.fromValue = [NSNumber numberWithFloat:0.0];
	animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
	animation.delegate = self;
	[button.layer addAnimation:animation forKey:@"rotationAnimation"];

	[CATransaction commit];
}

//
// animationDidStop:finished:
//
// Restarts the spin animation on the button when it ends. Again, this is
// largely irrelevant now that the audio is loaded from a local file.
//
// Parameters:
//    theAnimation - the animation that rotated the button.
//    finished - is the animation finised?
//
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
	if (finished)
	{
		[self spinButton];
	}
}
*/

//
// buttonPressed:
//
// Handles the play/stop button. Creates, observes and starts the
// audio streamer when it is a play button. Stops the audio streamer when
// it isn't.
//
// Parameters:
//    sender - normally, the play/stop button.
//
- (IBAction)buttonPressed:(id)sender
{
	if ([button.currentImage isEqual:[UIImage imageNamed:@"playBtn50.png"]] || [button.currentImage isEqual:[UIImage imageNamed:@"pauseBtn50.png"]])
	{
		[downloadSourceField resignFirstResponder];
		
		[self createStreamer];
		[self setButtonImage:[UIImage imageNamed:@"loadingBtn50.png"]];
		[streamer start];
	}
	else
	{
		[streamer stop];
	}
}




- (void)pauseAudio
{
	if ( m_pauseCount == 0 )
	{
		m_wasPlaying = (![button.currentImage isEqual:[UIImage imageNamed:@"playBtn50.png"]]);
		
		// hack
		if ( m_wasPlaying )
		{
			[self buttonPressed:nil];
		}
	#ifdef BURSTLY
		[adManager setPaused:YES];	
	#endif	
		button.enabled = NO;
	}
	m_pauseCount++;
}

- (void)restartAudio
{
	--m_pauseCount;
	
	if ( m_pauseCount == 0 )
	{
		// hack
		if ( m_wasPlaying )
		{
			[self buttonPressed:nil];
		}
	#ifdef BURSTLY
		[adManager setPaused:YES];	
	#endif		
		button.enabled = YES;
	}
}


- (void)applicationWillResignActive:(NSNotification *)notification
{
// \todo - may need to reintroduce these with phone call interruptions, but consider iOS4.0 multitasking
// Need to test a 3.0 phone.
//	[self pauseAudio];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
//	[self restartAudio];
}


//
// sliderMoved:
//
// Invoked when the user moves the slider
//
// Parameters:
//    aSlider - the slider (assumed to be the progress slider)
//
- (IBAction)sliderMoved:(UISlider *)aSlider
{
	if (streamer.duration)
	{
		double newSeekTime = (aSlider.value / 100.0) * streamer.duration;
		[streamer seekToTime:newSeekTime];
	}
}

//
// playbackStateChanged:
//
// Invoked when the AudioStreamer
// reports that its playback status has changed.
//
- (void)playbackStateChanged:(NSNotification *)aNotification
{
	CexiMeAppDelegate *appDelegate = (CexiMeAppDelegate*)[[UIApplication sharedApplication] delegate];

	if ([streamer isWaiting])
	{
		if (appDelegate.uiIsVisible) 
		{
#if 0		
			[levelMeterView updateMeterWithLeftValue:0.0 
										   rightValue:0.0];
#endif										   
			[streamer setMeteringEnabled:NO];
			[self setButtonImage:[UIImage imageNamed:@"loadingBtn50.png"]];
		}
	}
	else if ([streamer isPlaying])
	{
		if (appDelegate.uiIsVisible) {
			[streamer setMeteringEnabled:YES];
			[self setButtonImage:[UIImage imageNamed:@"stopBtn50.png"]];
		}
	}
	else if ([streamer isPaused]) {
		if (appDelegate.uiIsVisible) {
#if 0		
			[levelMeterView updateMeterWithLeftValue:0.0 
										   rightValue:0.0];
#endif										   
			[streamer setMeteringEnabled:NO];
			[self setButtonImage:[UIImage imageNamed:@"pauseBtn50.png"]];
		}
	}
	else if ([streamer isIdle])
	{
		if (appDelegate.uiIsVisible) {
#if 0		
			[levelMeterView updateMeterWithLeftValue:0.0 
										   rightValue:0.0];
#endif										   
			[self setButtonImage:[UIImage imageNamed:@"playBtn50.png"]];
		}
		[self destroyStreamer];
	}
}

#ifdef SHOUTCAST_METADATA
/** Example metadata
 * 
 StreamTitle='Kim Sozzi / Amuka / Livvi Franc - Secret Love / It's Over / Automatik',
 StreamUrl='&artist=Kim%20Sozzi%20%2F%20Amuka%20%2F%20Livvi%20Franc&title=Secret%20Love%20%2F%20It%27s%20Over%20%2F%20Automatik&album=&duration=1133453&songtype=S&overlay=no&buycd=&website=&picture=',

 Format is generally "Artist hypen Title" although servers may deliver only one. This code assumes 1 field is artist.
 */
- (void)metadataChanged:(NSNotification *)aNotification
{
	NSString *streamArtist;
	NSString *streamTitle;
	NSArray *metaParts = [[[aNotification userInfo] objectForKey:@"metadata"] componentsSeparatedByString:@";"];
	NSString *item;
	NSMutableDictionary *hash = [[NSMutableDictionary alloc] init];
	for (item in metaParts) {
		// split the key/value pair
		NSArray *pair = [item componentsSeparatedByString:@"="];
		// don't bother with bad metadata
		if ([pair count] == 2)
			[hash setObject:[pair objectAtIndex:1] forKey:[pair objectAtIndex:0]];
	}

	// do something with the StreamTitle
	NSString *streamString = [[hash objectForKey:@"StreamTitle"] stringByReplacingOccurrencesOfString:@"'" withString:@""];
	
	NSArray *streamParts = [streamString componentsSeparatedByString:@" - "];
	if ([streamParts count] > 0) {
		streamArtist = [streamParts objectAtIndex:0];
	} else {
		streamArtist = @"";
	}
	// this looks odd but not every server will have all artist hyphen title
	if ([streamParts count] >= 2) {
		streamTitle = [streamParts objectAtIndex:1];
	} else {
		streamTitle = @"";
	}
	NSLog(@"%@ by %@", streamTitle, streamArtist);

	// only update the UI if in foreground
	CexiMeAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	if (appDelegate.uiIsVisible) {
		metadataArtist.text = streamArtist;
		metadataTitle.text = streamTitle;
	}
	currentArtist = streamArtist;
	currentTitle = streamTitle;
}
#endif

//
// updateProgress:
//
// Invoked when the AudioStreamer
// reports that its playback progress has changed.
//
- (void)updateProgress:(NSTimer *)updatedTimer
{
	if (streamer.bitRate != 0.0)
	{
		double progress = streamer.progress;
		double duration = streamer.duration;
		
		if (duration > 0)
		{
			[positionLabel setText:
				[NSString stringWithFormat:@"Time Played: %.1f/%.1f seconds",
					progress,
					duration]];
			[progressSlider setEnabled:YES];
			[progressSlider setValue:100 * progress / duration];
		}
		else
		{
			[progressSlider setEnabled:NO];
		}
	}
	else
	{
		positionLabel.text = @"Time Played:";
	}
}


//
// updateLevelMeters:
//
#if 0
- (void)updateLevelMeters:(NSTimer *)timer {
	CexiMeAppDelegate *appDelegate = (CexiMeAppDelegate *)[[UIApplication sharedApplication] delegate];
	if([streamer isMeteringEnabled] && appDelegate.uiIsVisible) {
		[levelMeterView updateMeterWithLeftValue:[streamer averagePowerForChannel:0] 
									  rightValue:[streamer averagePowerForChannel:([streamer numberOfChannels] > 1 ? 1 : 0)]];
	}
}
#endif


//
// textFieldShouldReturn:
//
// Dismiss the text field when done is pressed
//
// Parameters:
//    sender - the text field
//
// returns YES
//
- (BOOL)textFieldShouldReturn:(UITextField *)sender
{
	[sender resignFirstResponder];
	[self createStreamer];
	return YES;
}


- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// TODO: release anything?
}


//
// dealloc
//
// Releases instance memory.
//
- (void)dealloc
{
	
#ifdef BURSTLY
	[adManager release]; adManager = nil;
#endif

	[m_adBackgroundBar release]; m_adBackgroundBar = nil;
	[m_adHost release]; m_adHost = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self destroyStreamer];
	
	// \todo replace by release - not mutators
	self.backgroundImageView0 = nil;
	self.backgroundImageView1 = nil;
	self.titleLabel = nil;
	self.activityView = nil;
	self.containerView = nil;
	self.controlsView = nil;
	self.splashView = nil;
	self.noStreamLabel = nil;
	self.streamControlsHost = nil;

	[self createTimers:NO];
#if 0	
	[levelMeterView release];
#endif	
	[super dealloc];
}

#pragma mark Remote Control Events
/* The iPod controls will send these events when the app is in the background */
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
	switch (event.subtype) {
		case UIEventSubtypeRemoteControlTogglePlayPause:
			[streamer pause];
			break;
		case UIEventSubtypeRemoteControlPlay:
			[streamer start];
			break;
		case UIEventSubtypeRemoteControlPause:
			[streamer pause];
			break;
		case UIEventSubtypeRemoteControlStop:
			[streamer stop];
			break;
		default:
			break;
	}
}


// -------------------------------------------------------------------------------------------------

- (IBAction)infoButtonPressed:(id)sender
{
	AboutViewController* aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
	[self presentModalViewController:aboutViewController animated:YES];
	[aboutViewController release];
}

-(void)didFinishLoadingSettings:(SettingsManager*)settingsManager
{
	[self setButtonImage:[UIImage imageNamed:@"playBtn50.png"]];
	
	[settingsManager initializeTextInView:self.titleLabel fromXPath:@"//settings/title"];

	// An initial image
	[settingsManager initializeImageView:self.backgroundImageView0 fromXPath:@"//settings/background"];
	self.backgroundImageView1.image = self.backgroundImageView0.image;
	
	// window color
	CexiMeAppDelegate* appDelegate = (CexiMeAppDelegate*)[[UIApplication sharedApplication] delegate];
	appDelegate.window.backgroundColor = [settingsManager colorAttributeFromXPath:@"//settings/background"];
		
	// Trigger background image view
	[settingsManager performSelector:@selector(updateBackgroundImage) withObject:nil afterDelay:0];//settingsManager.slideShowRefresh];
	
	// Now things are properly set up, register our observers
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(applicationWillResignActive:)
												 name:UIApplicationWillResignActiveNotification 
											   object:nil]; 

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(applicationDidBecomeActive:)
												 name:UIApplicationDidBecomeActiveNotification 
											   object:nil]; 

	// If the above doesn't work, we'll need to look at CTCallCenter											   

	if ( settingsManager.streamURL == nil )
	{
		self.streamControlsHost.hidden = YES;
		self.noStreamLabel.hidden = NO;
		
		// \todo recheck network
	}
	
	// Get rid of the splash screen
	[UIView beginAnimations:nil context:nil];
	self.splashView.alpha = 0.0f;
	self.controlsView.alpha = 1.0f;
	[UIView commitAnimations];	
	

	
	
}

#pragma mark Burstly delegate methods
#ifdef BURSTLY
- (NSString *)publisherId 
{
	return @"YYRL-lH1ZkeLeoLRMIHTqA";
}

- (NSString *)getZone 
{
	return @"0558167679162204599";
}

- (UIViewController *)viewControllerForModalPresentation 
{
	return self;
}

- (CGFloat)defaultSessionLife 
{
	CexiMeAppDelegate* appDelegate = (CexiMeAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	CGFloat sessionLife = appDelegate.settingsManager.adRefresh;
	
	return sessionLife ? sessionLife : 20.0f; // default
}

- (CGPoint)anchorPoint 
{
// \todo - define for orientation?
	return CGPointMake(self.adHost.frame.size.width/2, self.adHost.frame.size.height);
}

- (Anchor)anchor 
{
	return Anchor_Bottom;
}

- (void)adManager:(OAIAdManager*)manager viewDidChangeSize:(CGSize)newSize fromOldSize:(CGSize)oldSize
{
	// resize the container view
	CGRect bounds = self.view.bounds;
	bounds.size.height -= newSize.height;
	
	// Calc new frame for adBackgroundBar
	CGRect adFrame = self.adBackgroundBar.frame;
	if ( newSize.height > 0 && (adFrame.origin.y >= bounds.size.height))
		adFrame.origin.y -= adFrame.size.height;
	else
		adFrame.origin.y += adFrame.size.height;
	
	[UIView beginAnimations:nil context:nil];
		self.containerView.frame = bounds;
		self.adBackgroundBar.frame = adFrame;
	[UIView commitAnimations];		
}

// When the ad goes full screen we should stop any audio
- (void)adManager:(OAIAdManager*)manager adNetworkControllerPresentFullScreen:(NSString*)aNetwork
{
	[self pauseAudio];
}

- (void)adManager:(OAIAdManager*)manager adNetworkControllerDismissFullScreen:(NSString*)aNetwork
{
	[self restartAudio];
}


#endif

// MARK:Share
- (IBAction)share
{
	// Create the item to share (in this example, a url)
	CexiMeAppDelegate* appDelegate = (CexiMeAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	NSString* shareURL = [appDelegate.settingsManager textFromXPath:@"//settings/sharing/url"];
	NSString* shareTitle = [appDelegate.settingsManager textFromXPath:@"//settings/sharing/text"];
		
	NSURL *url = [NSURL URLWithString:shareURL];
	SHKItem *item = [SHKItem URL:url title:shareTitle];

	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];

	// Display the action sheet
	[actionSheet showFromRect:self.controlsView.frame inView:self.view animated:YES];
//	[actionSheet showFromToolbar:navigationController.toolbar];
}

@end
