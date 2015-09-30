//
//  UIColor+Colour.m
//  TramMeNow
//
//  Created by Laurence Saleh on 29/09/15.
//  Copyright (c) 2015 Laurence Saleh. All rights reserved.
//

#import "UIColor+Colour.h"

@implementation UIColor (Colour)


// -- Create a UIImage from a colour, good for setting a solid colour on the navigation bar rather than a tinted colour
+ (UIImage *)getImageForColor:(UIColor *)color
{
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    colorView.backgroundColor = color;
    colorView.layer.cornerRadius = 4.0f;
    UIGraphicsBeginImageContextWithOptions(colorView.bounds.size, NO, 0);
    
    [colorView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [colorImage resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
}

/* Taken from https://gist.github.com/eiffelqiu/994410 */
// -- Used to create a UIColor from a hex string
+ (UIColor *)colorWithHex:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString length] < 6) return [UIColor grayColor];
    
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString length] != 6) return  [UIColor grayColor];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}



@end
