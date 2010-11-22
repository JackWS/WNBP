//
//  CexiMeAppDelegate.h
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
#import "SettingsManager.h"

@class CexiMeViewController;

@interface CexiMeAppDelegate : NSObject <UIApplicationDelegate,SettingsManagerDelegate,UIAlertViewDelegate> 
{
    UIWindow *window;
    CexiMeViewController *viewController;
	BOOL uiIsVisible;
	SettingsManager*					m_settingsManager;
	BOOL multitaskingSupported;
	BOOL								localAlertShowing;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CexiMeViewController *viewController;
@property (nonatomic) BOOL uiIsVisible;
@property (nonatomic, retain) SettingsManager*	settingsManager;
@property (nonatomic,readonly) BOOL multitaskingSupported;
@property (assign) BOOL localAlertShowing;
@end

