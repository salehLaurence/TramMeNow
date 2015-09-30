//
//  UIColor+Colour.h
//  TramMeNow
//
//  Created by Laurence Saleh on 29/09/15.
//  Copyright (c) 2015 Laurence Saleh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Colour)


+ (UIImage *)getImageForColor:(UIColor *)color;
+ (UIColor *)colorWithHex:(NSString*)hex;


@end
