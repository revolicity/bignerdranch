//
//  BNRItem.m
//  RandomPossessions
//
//  Created by Brian Schick on 1/5/13.
//  Copyright (c) 2013 Brian Schick. All rights reserved.
//

#import "BNRItem.h"

@implementation BNRItem
@synthesize imageKey;
@synthesize itemName;   //remember what they said in stanford... don't use the same global variable as synthesize
@synthesize containedItem, container, serialNumber, valueInDollars, dateCreated;
@synthesize thumbnail, thumbnailData;

- (UIImage *)thumbnail
{
    // if there is no thumbnail data, I have no thumbanail to return
    if(!thumbnailData)
    {
        return nil;
    }
    
    if (!thumbnail)
    {
        // create the image from the data
        thumbnail = [UIImage imageWithData:thumbnailData];
    }
    return thumbnail;
}

- (void)setThumbnailDataFromImage:(UIImage *)image
{
    
    // NEED TO LEARN ABOUT GRAPHICS CONTEXTS!!!
    CGSize origImageSize = [image size];
    
    // rectangle of the thumbnail
    CGRect newRect = CGRectMake(0, 0, 40, 40);
    
    // figure out a scaling ratio to make sure we maintain it in the thumbnail
    float ratio = MAX(newRect.size.width / origImageSize.width,
                      newRect.size.height / origImageSize.height);
    
    // Create a transparent bitmap context with a scaling factor
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    
    // create a path that is a rounded rectangle
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect
                                                    cornerRadius:5.0];
    
    // Make all subsequent drawin =g ci to this rounded retcangle
    [path addClip];
    
    // Center the image in teh thumbnail rectangle
    CGRect projectRect;
    
    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
    
    // Draw the image on it
    [image drawInRect:projectRect];
    
    // Get the image from the iamge context, keep it as our thumbnail
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    [self setThumbnail:smallImage];
    
    // Get PNG representation fo the image and set it as our archivable data
    NSData *data = UIImagePNGRepresentation(smallImage);
    [self setThumbnailData:data];
    
    //cleanup iamge context resources
    UIGraphicsGetCurrentContext();
    
    
    
    
    
}

+ (id)randomItem
{
    //create an array of three adjectives
    NSArray *randomAdjectiveList = [NSArray arrayWithObjects:@"Fluffy",@"Rusty",@"Shiny",nil];
    NSArray *randomNounList = [NSArray arrayWithObjects:@"Bear",@"Spork",@"Mac",nil];
    
    NSInteger adjectiveIndex = rand() % [randomAdjectiveList count];
    NSInteger nounIndex = rand() % [randomNounList count];
    
    NSString *randomName = [NSString stringWithFormat:@"%@ %@",
                            [randomAdjectiveList objectAtIndex:adjectiveIndex],
                            [randomNounList objectAtIndex:nounIndex]];
                            
    int randomValue = rand() % 100;
    
    NSString *randomSerialNumber = [ NSString stringWithFormat:@"%c%c%c%c%c",
                                    '0' + rand() % 10,
                                    'A' + rand() % 26,
                                    '0' + rand() % 10,
                                    'A' + rand() % 26,
                                    '0' + rand() % 10];
    
    BNRItem * newItem = [[self alloc] initWithItemName:randomName
                                        valueInDollars:randomValue
                                           serialNumer:randomSerialNumber];
    
    return newItem;
    
}

- (id)initWithItemName:(NSString *)name
        valueInDollars:(int)value
           serialNumer:(NSString *)sNumber
{
    //call the superclass's designated intializer
    self = [super init];
    
    if (self)
    {
        //Give the instance variables initial values
        [self setItemName:name];
        [self setSerialNumber:sNumber];
        [self setValueInDollars:value];
        dateCreated = [[NSDate alloc] init];
    }
    //return address of newly created object
    return self;
    
}

- (id)init
{
    return [self initWithItemName:@"Item"
                   valueInDollars:0
                      serialNumer:@""];
}

- (void)dealloc
{
    NSLog(@"Destroyed: %@.",self);
}

- (void)setItemName:(NSString *)name
       serialNumber:(NSString *)sNumber
{
    itemName = name;
    serialNumber = sNumber;
    
}

- (NSString *)description
{
    NSString * descriptionString =
    [[NSString alloc] initWithFormat:@"%@ (%@): Worth $%d, recorded on %@",
     itemName,
     serialNumber,
     valueInDollars,
     dateCreated];
    
    return descriptionString;
}

- (void)setContainedItem:( BNRItem *)i
{
    containedItem = i;
    
    //when given an item to contain, the contained
    //item will be given a pointer to its container
    [i setContainer:self];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        [self setItemName:[aDecoder decodeObjectForKey:@"itemName"]];
        [self setSerialNumber:[aDecoder decodeObjectForKey:@"serialNumber"]];
        [self setImageKey:[aDecoder decodeObjectForKey:@"imageKey"]];
        
        [self setValueInDollars:[aDecoder decodeIntForKey:@"valueInDollars"]];
        
        dateCreated = [aDecoder decodeObjectForKey:@"dateCreated"];
        
        thumbnailData = [aDecoder decodeObjectForKey:@"thumbnailData"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:itemName forKey:@"itemName"];
    [aCoder encodeObject:serialNumber forKey:@"serialNumber"];
    [aCoder encodeObject:dateCreated forKey:@"dateCreated"];
    [aCoder encodeObject:imageKey forKey:@"imageKey"];
    
    [aCoder encodeInt:valueInDollars forKey:@"valueInDollars"];
    
    [aCoder encodeObject:thumbnailData forKey:@"thumbnailData"];
    
}

@end
