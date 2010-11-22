//
//  TapView.h
//  CexiMe
//
//  Created by Julian on 07/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TapView;

@protocol TapViewDelegate <NSObject>
-(void)handleTap:(UITouch*)touch;
@end

@interface TapView : UIView 
{
	id<TapViewDelegate>	delegate;
}

@property (nonatomic, assign) IBOutlet id<TapViewDelegate> delegate;

@end
