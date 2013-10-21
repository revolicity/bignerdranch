//
//  BNRItemStore.m
//  Homepwner
//
//  Created by Brian Schick on 3/3/13.
//  Copyright (c) 2013 com.bignerdranch. All rights reserved.
//

#import "BNRItemStore.h"
#import "BNRItem.h"
#import "BNRImageStore.h"

@implementation BNRItemStore

- (id)init
{
    self = [super init];
    if (self)
    {
        NSString *path = [self itemArchivePath];
        allItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if(!allItems)
            allItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *)allItems
{
    return allItems;
}

- (BNRItem *)createItem
{
    BNRItem *p = [[BNRItem alloc] init];
    
    [allItems addObject:p];
    
    return p;
}

+ (BNRItemStore *)sharedStore
{
    // Look! Lazy instantiation of an object
    static BNRItemStore *sharedStore = nil;
    if(!sharedStore)
    {
        sharedStore = [[super allocWithZone:nil] init];
    }
                       return sharedStore;
    
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

-(void)moveItemAtIndex:(int)from
               toIndex:(int)to
{
    //if not actually moving...
    if (from == to)
        return;
    
    // get pointer to onkect nbeing mpved to we can re-insert it
    BNRItem *p = [allItems objectAtIndex:from];
    
    // remove p from array
    [allItems removeObjectAtIndex:from];
    
    // insert at new place
    [allItems insertObject:p atIndex:to];
    
}

-(void)removeItem:(BNRItem *)p
{
    NSString *key = [p imageKey];
    [[BNRImageStore sharedStore] deleteImageForKey:key];

    [allItems removeObjectIdenticalTo:p];
}

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"items.archive"];
    
}

- (BOOL)saveChanges
{
    //return success or failure
    NSString *path = [self itemArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:allItems toFile:path];
}

@end
