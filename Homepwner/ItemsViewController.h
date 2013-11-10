//
//  ItemsViewController.h
//  Homepwner
//
//  Created by Brian Schick on 3/3/13.
//  Copyright (c) 2013 com.bignerdranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailViewController.h"

@interface ItemsViewController : UITableViewController
    <UIPopoverControllerDelegate>
{
    UIPopoverController *imagePopover;
}

- (IBAction)addNewItem:(id)sender;

@end
