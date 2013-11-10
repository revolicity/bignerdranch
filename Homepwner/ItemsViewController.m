//
//  ItemsViewController.m
//  Homepwner
//
//  Created by Brian Schick on 3/3/13.
//  Copyright (c) 2013 com.bignerdranch. All rights reserved.
//

#import "ItemsViewController.h"
#import "BNRItemStore.h"
#import "BNRItem.h"
#import "HomepwnerItemCell.h"
#import "BNRImageStore.h"
#import "ImageViewController.h"

@implementation ItemsViewController

- (void)showImage:(id)sender atIndexPath:(NSIndexPath *)ip
{
    NSLog(@"Going to show the image for %@", ip);
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)    {
        // Get the item for the index path
        BNRItem *i = [[[BNRItemStore sharedStore] allItems] objectAtIndex:[ip row]];
        
        NSString *imageKey = [i imageKey];
        
        // If there is no image, we don;t need to display anything
        UIImage *img = [[BNRImageStore sharedStore] imageForKey:imageKey];
        if(!img)
            return;
        
        // make a rectangle that the frame of the btton relative to
        // our table view
        CGRect rect = [[self view] convertRect:[sender bounds] fromView:sender];
        
        // create a new iamgeviewcontroller and set its iamge
        ImageViewController *ivc = [[ImageViewController alloc] init];
        [ivc setImage:img];
        
        // present the popover!
        imagePopover = [[UIPopoverController alloc]initWithContentViewController:ivc];
        [imagePopover setDelegate:self];
        [imagePopover setPopoverContentSize:CGSizeMake(600,600)];
        [imagePopover presentPopoverFromRect:rect
                                      inView:[self view]
                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                    animated:YES];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [imagePopover dismissPopoverAnimated:YES];
    imagePopover = nil;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailViewController *dvc = [[DetailViewController alloc] initForNewItem:NO];
    
    NSArray *items = [[BNRItemStore sharedStore] allItems];
    BNRItem *selectedItem = [items objectAtIndex:[indexPath row]];
    
    // give detail view controller a pointer to the item obejct in row
    [dvc setItem:selectedItem];
    
    //push onto the top of the navigation controller stack
    [[self navigationController] pushViewController:dvc animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // load the nib file
    UINib *nib = [UINib nibWithNibName:@"HomepwnerItemCell" bundle:nil];
    
    [[self tableView] registerNib:nib
           forCellReuseIdentifier:@"HomepwnerItemCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
}

// look at how this works!!! great example
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Please don't delete me!";
}

- (id)init
{
    // call the superclass initializer
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if(self)
    {
        // set a title
        UINavigationItem *n = [self navigationItem];
        [n setTitle:@"Homepwner"];
        
        // create a button bar instead of the table buttons
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                target:self
                                 action:@selector(addNewItem:)];
        
        // set this bar button item as the right item in the naviagtionItem
        [[self navigationItem] setRightBarButtonItem:bbi];
        
        // add the edit button
        [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
        
    }

    return self;

}

- (IBAction)addNewItem:(id)sender
{
    //make a new BNR item
    BNRItem *newItem = [[BNRItemStore sharedStore] createItem];
    
    // make a new item for the 0th selection, last row
    //int lastRow = [[[BNRItemStore sharedStore] allItems] indexOfObject:newItem];
    //NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
    
    //insert into table
    //[[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:ip]
    //                        withRowAnimation:UITableViewRowAnimationTop];

    DetailViewController *dvc =
    [[DetailViewController alloc] initForNewItem:YES];
    
    [dvc setItem:newItem];
    
    [dvc setDismissBlock:^{
        [[self tableView] reloadData];
    }];
    
    UINavigationController *nc = [[UINavigationController alloc]
                                  initWithRootViewController:dvc];

    [nc setModalPresentationStyle:UIModalPresentationFormSheet];
    
    [nc setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    [self presentViewController: nc animated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //set the text on the cell with the description of the itmem
    //that is at the nth index of items, where n= row this cell will appear in on the tableView
    BNRItem *p = [[[BNRItemStore sharedStore] allItems]
                  objectAtIndex:[indexPath row]];
    
    // get the new or recycled cell
    HomepwnerItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomepwnerItemCell"];
    
    [cell setController:self];
    [cell setTableView:tableView];
    
    //configure the cell wiht the BNRItem
    [[cell nameLabel] setText:[p itemName]];
    [[cell serialNumberLabel] setText:[p serialNumber]];
    [[cell valueLabel] setText:[NSString stringWithFormat:@"$%d", [p valueInDollars]]];
    
    [[cell thumbnailView] setImage:[p thumbnail]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return[[[BNRItemStore sharedStore] allItems] count];
}

// move row
- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[BNRItemStore sharedStore] moveItemAtIndex:[sourceIndexPath row]
                                   toIndex:[destinationIndexPath row ]];
      
}

// delete row
- (void)tableView:(UITableView *)myTableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {        
        
        BNRItemStore *ps = [BNRItemStore sharedStore];
        NSArray *items = [ps allItems];
        BNRItem *p = [items objectAtIndex:[indexPath row]];
        [ps removeItem:p];
        
        //also remove the row with animation
        [myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)io
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        return YES;
    }
    else
    {
        return (io == UIInterfaceOrientationPortrait);
    }
}

@end
