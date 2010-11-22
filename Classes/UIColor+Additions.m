//
//  UIColor+Additions.m
//  CexiMe
//
//  Created by Julian on 05/09/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIColor+Additions.h"

@implementation UIColor (Additions)

+ (UIColor*)colorFromHex:(NSString*)hexString
{
	// Convert string into uppercase
  	NSString *string = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
	
	// Default to something
	if ( string.length != 7 )
		return [UIColor blackColor];
	
	unsigned int r, g, b;
	
	NSRange range;
	range.location = 1;
	range.length = 2;

	[[NSScanner scannerWithString:[string substringWithRange:range]] scanHexInt:&r];

	range.location = 3;
	[[NSScanner scannerWithString:[string substringWithRange:range]] scanHexInt:&g];

	range.location = 5;
	[[NSScanner scannerWithString:[string substringWithRange:range]] scanHexInt:&b];

  	return [UIColor colorWithRed:((float) r / 255.0f)
						   green:((float) g / 255.0f)
							blue:((float) b / 255.0f)
						   alpha:1.0f];
}

@end
