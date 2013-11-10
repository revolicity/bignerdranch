//
//  ImageViewController.h
//  Homepwner_BS
//
//  Created by Brian Schick on 11/5/13.
//  Copyright (c) 2013 com.bignerdranch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController
{
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIImageView *imageView;
}
@property (nonatomic, strong) UIImage *image;

@end
