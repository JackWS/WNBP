//
//  ParseXMLBackgroundOperation.h
//  CexiMe
//
//  Created by Julian on 29/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SettingsManager;

@interface ParseXMLBackgroundOperation : NSOperation 
{
	SettingsManager*	m_settingsManager;
}

@property (nonatomic, retain) SettingsManager* settingsManager;

- (id)initWithManager:(SettingsManager*)manager;

@end
