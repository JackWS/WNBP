    //
//  SplashViewController.m
//  iPhoneStreamingPlayer
//
//  Created by Julian on 29/09/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SplashViewController.h"


@implementation SplashViewController
/*
-(UIInterfaceOrientation)interfaceOrientation
{
	return [[UIDevice currentDevice] orientation];
}*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return ( (interfaceOrientation == UIInterfaceOrientationLandscapeRight ) );
}


@end
