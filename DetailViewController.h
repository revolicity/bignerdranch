//
//  DetailViewController.h
//  Homepwner
//
//  Created by Brian Schick on 3/18/13.
//  Copyright (c) 2013 com.bignerdranch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BNRItem;

@interface DetailViewController : UIViewController
    <UINavigationControllerDelegate, UIImagePickerControllerDelegate,
        UITextFieldDelegate, UIPopoverControllerDelegate>
{
    
    __weak IBOutlet UITextField *nameField;
    __weak IBOutlet UITextField *serialNumberField;
    __weak IBOutlet UITextField *valueField;
    __weak IBOutlet UILabel *dateLabel;
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UIToolbar *takePicture;
    __weak IBOutlet UIButton *assetTypeButton;
    
    UIPopoverController *imagePickerPopover;
}

@property (nonatomic, strong) BNRItem *item;
@property (nonatomic, copy) void (^dismissBlock)(void);

- (id)initForNewItem:(BOOL)isNew;

- (IBAction)showAssetTypePicker:(id)sender;
- (IBAction)takePicture:(id)sender;
- (IBAction)backgroundTapped:(id)sender;

@end
