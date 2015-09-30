//
//  UIViewController+ViewController.m
//  TramMeNow
//
//  Created by Laurence Saleh on 29/09/15.
//  Copyright (c) 2015 Laurence Saleh. All rights reserved.
//

#import "UIViewController+ViewController.h"
#import "UIColor+Colour.h"
@implementation UIViewController (ViewController)


// -- Style the navigation bar and setup a title
// -- Ease of access when used in a category, every viewcontroller can maintain a 'house' style easily

- (void)setupNavigationBarWithTitle:(NSString *)title
{
    [self createTitleLabel];
    
    self.title = title;
    ((UILabel *) self.navigationItem.titleView).text = title;
    
    self.navigationController.view.layer.cornerRadius = 0;

    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] )
    {
        UIImage * navigationBarImage = [UIColor getImageForColor:[UIColor colorWithHex:@"00a5dc"]];
        [self.navigationController.navigationBar setBackgroundImage:navigationBarImage forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        self.navigationController.navigationBar.backgroundColor = [UIColor blueColor];
    }
}

- (void)createTitleLabel
{
    if(![self.navigationItem.titleView isKindOfClass:[UILabel class]])
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 32)];
        titleLabel.font = [UIFont fontWithName:@"Bullpen3D" size:20];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        self.navigationItem.titleView = titleLabel;
    }
}

@end
