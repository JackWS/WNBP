//
//  TapView.m
//  CexiMe
//
//  Created by Julian on 07/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TapView.h"


@implementation TapView

@synthesize delegate;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = [touches anyObject];
	
	if ( touch.tapCount == 1 )
	{
		[self.delegate handleTap:touch];
	}
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
