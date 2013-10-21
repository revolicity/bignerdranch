//
//  BNRItem.h
//  RandomPossessions
//
//  Created by Brian Schick on 1/5/13.
//  Copyright (c) 2013 Brian Schick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BNRItem : NSObject <NSCoding>
{
    NSString *itemName;
    NSString *serialNumber;
    int valueInDollars;
    NSDate *dateCreated;
    BNRItem *containedItem;
    __weak BNRItem *container;
}

+ (id)randomItem;

- (id)initWithItemName:(NSString *)name
        valueInDollars:(int)value
           serialNumer:(NSString *)sNumber;



@property (nonatomic, strong) BNRItem *containedItem;
@property (nonatomic, weak) BNRItem *container;

@property (nonatomic, copy) NSString *itemName;
@property (nonatomic, copy) NSString *serialNumber;
@property (nonatomic) int valueInDollars;
@property (nonatomic, readonly) NSDate *dateCreated;

@property (nonatomic, copy) NSString *imageKey;

@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSData *thumbnailData;

- (void)setThumbnailDataFromImage:(UIImage *)image;

@end
