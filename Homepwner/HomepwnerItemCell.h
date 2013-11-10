//
//  HomepwnerItemCell.h
//  Homepwner
//
//  Created by Brian Schick on 4/13/13.
//  Copyright (c) 2013 com.bignerdranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomepwnerItemCell : UITableViewCell
{
    
}


@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *serialNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) id controller;
@property (weak, nonatomic) UITableView *tableView;


- (IBAction)showImage:(id)sender;



@end
