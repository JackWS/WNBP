//
//  CexiMeViewController.h
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

#import <UIKit/UIKit.h>
#import "TapView.h"

#ifdef BURSTLY
#import "OAIAdManager.h"
#import "OAIAdManagerDelegateProtocol.h"
#endif


@class AudioStreamer, LevelMeterView;

@interface CexiMeViewController : UIViewController

// Note if you want to make changes to the xib, you'll need to comment out the ifdef stuff below, or 
// it gets very confused.
	<
	UIGestureRecognizerDelegate,
	TapViewDelegate
#ifdef BURSTLY
	,OAIAdManagerDelegate
	>
{
	OAIAdManager* adManager;
#else
	>
{
#endif

	IBOutlet UITextField *downloadSourceField;
	IBOutlet UIButton *button;
	IBOutlet UIView *volumeSlider;
	IBOutlet UILabel *positionLabel;
	IBOutlet UISlider *progressSlider;
	IBOutlet UITextField *metadataArtist;
	IBOutlet UITextField *metadataTitle;
	AudioStreamer *streamer;
	NSTimer *progressUpdateTimer;
	NSTimer *levelMeterUpdateTimer;
	
//	LevelMeterView *levelMeterView;
	NSString *currentArtist;
	NSString *currentTitle;

	//
	UIView*						m_containerView;
	UIView*						m_controlsView;	
	UIView*						m_splashView;
	UIImageView*				m_backgroundImageView0;
	UIImageView*				m_backgroundImageView1;
	UILabel*					m_titleLabel;
	UILabel*					m_noStreamLabel;
	UIActivityIndicatorView*	m_activityView;
	UIView*						m_streamControlsHost;
	UIView*						m_adBackgroundBar;
	UIView*						m_adHost;
	BOOL						m_pauseCount;
	BOOL						m_wasPlaying;				// used when interruptions occur
	BOOL						showingControls;
}

@property (nonatomic, retain) IBOutlet UIImageView* 				backgroundImageView0;
@property (nonatomic, retain) IBOutlet UIImageView* 				backgroundImageView1;
@property (nonatomic, retain) IBOutlet UILabel*						titleLabel;
@property (nonatomic, retain) IBOutlet UILabel*						noStreamLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView*		activityView;
@property (nonatomic, retain) IBOutlet UIView* 						containerView;
@property (nonatomic, retain) IBOutlet UIView* 						controlsView;
@property (nonatomic, retain) IBOutlet UIView* 						splashView;
@property (nonatomic, retain) IBOutlet UIView* 						streamControlsHost;
@property (nonatomic, retain) IBOutlet UIView* 						adBackgroundBar;
@property (nonatomic, retain) IBOutlet UIView* 						adHost;

- (IBAction)buttonPressed:(id)sender;
- (IBAction)infoButtonPressed:(id)sender;
//- (void)spinButton;
- (void)forceUIUpdate;
- (void)createTimers:(BOOL)create;
- (void)playbackStateChanged:(NSNotification *)aNotification;
- (void)updateProgress:(NSTimer *)updatedTimer;
- (IBAction)sliderMoved:(UISlider *)aSlider;

- (void)applicationWillResignActive:(NSNotification *)notification;
- (void)applicationDidBecomeActive:(NSNotification *)notification;

-(void)didFinishLoadingSettings:(SettingsManager*)settingsManager;
@end

