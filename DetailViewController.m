//
//  DetailViewController.m
//  Homepwner
//
//  Created by Brian Schick on 3/18/13.
//  Copyright (c) 2013 com.bignerdranch. All rights reserved.
//

#import "DetailViewController.h"
#import "BNRItem.h"
#import "BNRImageStore.h"
#import "BNRItemStore.h"

@implementation DetailViewController

@synthesize dismissBlock;
@synthesize item;

- (id)initForNewItem:(BOOL)isNew
{
    self = [super initWithNibName:@"DetailViewController" bundle:nil];
    
    if (self)
    {
        if(isNew)
        {
            UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                     target:self
                                     action:@selector(save:)];
        
            [[self navigationItem] setRightBarButtonItem:doneItem];
        
            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                       target:self
                                       action:@selector(cancel:)];
            [[self navigationItem] setLeftBarButtonItem:cancelItem];
        }
        
    }
    
    return self;
}

// throw an exception if the default initializer is called
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    @throw [NSException exceptionWithName:@"Wrong Initializer"
                                    reason:@"Use initForNewItem"
                                    userInfo:nil];
    return nil;
}

- (void)save:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES
                                                        completion:dismissBlock];
}

- (void)cancel:(id)sender
{
    
    [[BNRItemStore sharedStore] removeItem:item];
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:dismissBlock];
}

// REMEMBER ON MY READING LIGHT APP, CHECK FOR THE LED/CAMERA OR WHATEVER BEFORE TRYING TO USE IT
- (void) takePicture:(id)sender
{
    if([imagePickerPopover isPopoverVisible])
    {
        // if the popover is already up, get rid of it
        [imagePickerPopover dismissPopoverAnimated:YES];
        imagePickerPopover = nil;
        return;
    }
    
    UIImagePickerController *imagePicker =
    [[UIImagePickerController alloc] init];
    
    //if our device has a camera, we want to take a pic, otherwise choose from library
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [imagePicker setDelegate:self];
    
    // select a picture for either iPad or iPhone
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        //create the popover
        imagePickerPopover = [[UIPopoverController alloc]
                              initWithContentViewController:imagePicker];
        
        [imagePickerPopover setDelegate:self];
        
        //display popover controller
        [imagePickerPopover presentPopoverFromBarButtonItem:sender
                                   permittedArrowDirections:UIPopoverArrowDirectionAny
                                                   animated:YES];
    }
    else    // Display for iphone
    {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    NSLog(@"User Dismissed popover");
    imagePickerPopover = nil;
}

- (void)backgroundTapped:(id)sender
{
    [[self view] endEditing:YES];
}



- (void) imagePickerController:(UIImagePickerController *)picker
 didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //delete the old image before setting the new one
    NSString *oldKey = [item imageKey];
    if(oldKey)
    {
        [[BNRImageStore sharedStore] deleteImageForKey:oldKey];
    }
    
    // get picked image from info dictionary
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [item setThumbnailDataFromImage:image];
    
    // create a GUID
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    
    // now create a string from this
    CFStringRef newUniqueIDString =
        CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    
    // use that unique ID to set our item's imagekey
    NSString *key = (__bridge NSString *)newUniqueIDString;
    [item setImageKey:key];
    
    // store image in BNRImageStore with this key
    [[BNRImageStore sharedStore] setImage:image
                                   forKey:[item imageKey]];
    
    // release the core foundation objects
    CFRelease(newUniqueIDString);
    CFRelease(newUniqueID);
    
    // put that image onto the screen in our image view
    [imageView setImage:image];
    
    // for iPad or iPhone
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        //remove the image picker
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        //remove the image picker
        [imagePickerPopover dismissPopoverAnimated:YES];
        imagePickerPopover = nil;
    }
}

// Do something wiht

// when we switch to this view, we populate the fields with the data set by items view controller
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [nameField setText:[item itemName]];
    [serialNumberField setText:[item serialNumber]];
    [valueField setText:[NSString stringWithFormat:@"%d", [item valueInDollars]]];
    
    //creawte a nsdateformatter that will turn the date into a date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle ];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    //use filtered NSDate object for label
    [dateLabel setText:[dateFormatter stringFromDate:[item dateCreated]]];
    
    // ok update the image stuff
    NSString *imageKey = [item imageKey];
    
    if(imageKey)
    {
        UIImage *imageToDisplay =
        [[BNRImageStore sharedStore] imageForKey:imageKey];
        
        //put it on the screen
        [imageView setImage:imageToDisplay];
    }
    else
    {
        //clear the imageView
        [imageView setImage:nil];
    }
}

// when we go away from this view, we need use the new data to set things back in item store or itemsviewcontroller
- (void) viewWillDisappear:(BOOL)animated
{
    // call the super/inherited
    [super viewWillDisappear:animated];
    
    // clear the first responder?
    [[self view] endEditing:YES];
    
    //save the changes to the item
    [item setItemName:[nameField text]];
    [item setSerialNumber:[serialNumberField text]];
    [item setValueInDollars:[[valueField text] intValue]];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIColor *clr = nil;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        clr = [UIColor colorWithRed:0.875 green:0.88 blue:0.91 alpha:1];
    }
    else
    {
        clr = [UIColor groupTableViewBackgroundColor];
    }
    [[self view] setBackgroundColor:clr];
    
}

- (void)setItem:(BNRItem *)i
{
    item = i;
    [[self navigationItem] setTitle:[item itemName]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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

- (IBAction)valueTextChanged:(id)sender {
    NSString *local = [valueField text];
    float value = [local floatValue];
    
    // look at the value extracted from the sting
    if (0.0 == value)  {
        valueField.textColor  = [UIColor blackColor];
    }
    else if (50.0 >= value) {
        valueField.textColor  = [UIColor greenColor];
    }
    else    {
        valueField.textColor  = [UIColor redColor];
    }
        
    
    
    // if its bigger, than 50 change the text color
    
    // if its less, change it
    
    // if not a value, make it black
}
@end
