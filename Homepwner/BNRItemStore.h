//
//  BNRItemStore.h
//  Homepwner
//
//  Created by Brian Schick on 3/3/13.
//  Copyright (c) 2013 com.bignerdranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BNRItem;

@interface BNRItemStore : NSObject
{
    //put any class variables in here
    NSMutableArray *allItems;
    NSMutableArray *allAssetTypes;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

// class method gets a +
+ (BNRItemStore *)sharedStore;

- (NSArray *)allAssetTypes;

- (NSArray *)allItems;
- (BNRItem *)createItem;
- (void)removeItem:(BNRItem *)p;

- (void)moveItemAtIndex:(int)from
                toIndex:(int)to;

- (NSString *)itemArchivePath;
- (BOOL)saveChanges;

- (void)loadAllItems;

@end
