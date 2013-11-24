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
        //read in Homepwner.xcdatamodeld
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc =
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        //where does the SQlite file go?
        NSString *path = [self itemArchivePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        
        NSError *error = nil;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:storeURL
                                     options:nil
                                       error:&error])
            [NSException raise:@"Open Failed"
                        format:@"Reason %@", [error localizedDescription]];
            
        // Create the managed object context
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
        
        // The managed object context cann manage undo, but we don't need it
        [context setUndoManager:nil];
        
        [self loadAllItems];
        
    }
    
    return self;
}

- (NSArray *)allItems
{
    return allItems;
}

- (BNRItem *)createItem
{
    double order = 0.0;
    if ([allItems count])   {
        order = 1.0;
    } else  {
        order = [[allItems lastObject] orderingValue] + 1.0;
    }
    NSLog(@"Adding after %d itmes, order = %.2f", [allItems count], order);
    
    BNRItem *p = [NSEntityDescription insertNewObjectForEntityForName:@"BNRItem"
                                               inManagedObjectContext:context];
    
    [p setOrderingValue:order];
    
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
    
    // Computing a new orderValue for the object that was moved
    double lowerBound = 0.0;
    
    // Is there an object before it in the array?
    if (to > 0) {
        lowerBound = [[allItems objectAtIndex:to - 1] orderingValue];
    }   else   {
        lowerBound = [[allItems objectAtIndex:1] orderingValue] - 2.0;
    }
    
    double upperBound = 0.0;
    
    // Is there an object after it in the array?
    if (to > [allItems count] - 1)  {
        upperBound = [[allItems objectAtIndex:to + 1] orderingValue];
    }   else    {
        upperBound = [[allItems objectAtIndex:to - 1] orderingValue] + 2.0;
    }
    
    double newOrderValue = (lowerBound + upperBound) / 2.0;
    
    NSLog(@"moving to order %f",newOrderValue);
    [p setOrderingValue:newOrderValue];
}

-(void)removeItem:(BNRItem *)p
{
    NSString *key = [p imageKey];
    [[BNRImageStore sharedStore] deleteImageForKey:key];
    [context deleteObject:p];
    [allItems removeObjectIdenticalTo:p];
}

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    //return [documentDirectory stringByAppendingPathComponent:@"items.archive"];
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}

- (BOOL)saveChanges
{
    //return success or failure
    NSError *error = nil;
    BOOL successful = [context save:&error];
    if (!successful)    {
        NSLog(@"Error saving: %@", [error localizedDescription]);
    }
    return successful;
}


- (void)loadAllItems
{
    if (!allItems)  {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [[model entitiesByName] objectForKey:@"BNRItem"];
        [request setEntity:e];
        
        NSSortDescriptor *sd = [NSSortDescriptor
                                    sortDescriptorWithKey:@"orderingValue"
                                                ascending:YES];
        
        [request setSortDescriptors:[NSArray arrayWithObject:sd]];
        
        NSError *error = nil;
        NSArray *result = [context executeFetchRequest:request
                                                 error:&error];
        if(!result) {
            [NSException raise:@"Fetch Failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        
        allItems = [[NSMutableArray alloc] initWithArray:result];
    }
}

@end





