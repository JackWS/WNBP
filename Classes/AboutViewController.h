//
//  AboutViewController.h
//  CexiMe
//
//  Created by Julian on 29/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AboutViewController : UIViewController 
{
	UIImageView*	m_backgroundView;
	UITextView*		m_aboutTextView;
	UITextView*		m_creditsTextView;	
	UIView*		m_cexiLabel;
}

@property (nonatomic, retain) IBOutlet UITextView*	aboutTextView;
@property (nonatomic, retain) IBOutlet UITextView*	creditsTextView;
@property (nonatomic, retain) IBOutlet UIImageView*	backgroundView;
@property (nonatomic, retain) IBOutlet UIView*		cexiLabel;

- (IBAction)doneButtonPressed;

@end
