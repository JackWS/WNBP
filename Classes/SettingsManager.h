//
//  SettingsManager.h
//  CexiMe
//
//  Created by Julian on 29/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SettingsManager;
@class CXMLDocument;

@protocol SettingsManagerDelegate <NSObject>
-(void)didFinishLoadingSettings:(SettingsManager*)manager;
@end

@interface SettingsManager : NSObject
{
	id<SettingsManagerDelegate>		delegate;		
	
	CXMLDocument*					m_settingsXML;
	NSOperationQueue*				m_operationQueue;
	NSMutableArray*					m_slideShowImages;
	NSString*						m_streamURL;	
	
	int								currentBackgroundIndex;	
	int								backgroundViewIndex;	
	NSMutableData*					urlData;

	CGFloat							streamRefresh;
	CGFloat							slideShowRefresh;
	CGFloat							adRefresh;	
	
	NSMutableDictionary*			m_backgroundImages;
	NSString*						m_requestedImageName;
}

@property (nonatomic, assign) id<SettingsManagerDelegate> 	delegate;	

@property (retain) CXMLDocument*		settingsXML;
@property (retain) NSOperationQueue*	operationQueue;
@property (retain) NSMutableArray*		slideShowImages;
@property (retain) NSString*			streamURL;
@property (retain) NSMutableDictionary*	backgroundImages;


@property (nonatomic, assign) int		currentBackgroundIndex;
	
@property (nonatomic, assign) CGFloat	streamRefresh;	
@property (nonatomic, assign) CGFloat	slideShowRefresh;	
@property (nonatomic, assign) CGFloat	adRefresh;	
	
- (void)loadSettings;
- (void)xmlWasParsed:(CXMLDocument*)xmlDocument;
- (void)initializeTextInView:(UIView*)label fromXPath:(NSString*)xpath;
- (void)initializeImageView:(UIImageView*)view fromXPath:(NSString*)xpath;
- (UIColor*)colorAttributeFromXPath:(NSString*)xpath;
- (void)didReceiveMemoryWarning;
@end
