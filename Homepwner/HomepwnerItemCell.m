//
//  HomepwnerItemCell.m
//  Homepwner
//
//  Created by Brian Schick on 4/13/13.
//  Copyright (c) 2013 com.bignerdranch. All rights reserved.
//


// I don't want to do this here...
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
// how do we prevent the selector 

#import "HomepwnerItemCell.h"

@implementation HomepwnerItemCell

@synthesize valueLabel;
@synthesize thumbnailView;
@synthesize serialNumberLabel;
@synthesize nameLabel;

@synthesize tableView;
@synthesize controller;


- (IBAction)showImage:(id)sender
{
    // Get this name of this method, "showImage:"
    NSString *selector = NSStringFromSelector(_cmd);
    // selector is now "showImage:atImagePath:"
    selector = [selector stringByAppendingString:@"atIndexPath:"];
    
    SEL newSelector = NSSelectorFromString(selector);
    
    //NSSelectorFromString(selector);
    
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:self];
    
    if (indexPath)
    {
        if ([[self controller] respondsToSelector:newSelector])
        {
            // Ignore Warning
            [[self controller] performSelector:newSelector
                                    withObject:sender
                                    withObject:indexPath];
        }
    }
}

@end
