//
//  BNRImageStore.m
//  Homepwner
//
//  Created by Brian Schick on 3/29/13.
//  Copyright (c) 2013 com.bignerdranch. All rights reserved.
//

#import "BNRImageStore.h"

@implementation BNRImageStore

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

+ (BNRImageStore *)sharedStore
{
    static BNRImageStore *sharedStore = nil;
    if(!sharedStore)
    {
        //create the singleton
        sharedStore = [[super allocWithZone:NULL] init];
    }
    return sharedStore;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        dictionary = [[NSMutableDictionary alloc] init];
        
        //register for low-memory notifications
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(clearCache:)
                   name:UIApplicationDidReceiveMemoryWarningNotification
                 object:nil];
    }
    return self;
}

- (void)clearCache:(NSNotification *)note
{
    NSLog(@"flushing %d images from cache",[dictionary count]);
    [dictionary removeAllObjects];
}

- (void)setImage:(UIImage *)i forKey:(NSString *)s
{
    [dictionary setObject:i forKey:s];
    
    // create full path for image
    NSString *imagePath = [self imagePathForKey:s];
    
    //turn image into jpeg data
    NSData *d = UIImageJPEGRepresentation(i, 0.5);
    
    //write to file path
    [d writeToFile:imagePath atomically:YES];
}

- (UIImage *)imageForKey:(NSString *)s
{
    //if possible, get it from the dictionary
    UIImage *result = [dictionary objectForKey:s];
    
    if(!result)
    {
        result = [UIImage imageWithContentsOfFile:[self imagePathForKey:s]];
    
        //if we have an image, place it in the cache
        if (result)
            [dictionary setObject:result forKey:s];
        else
            NSLog(@"error finding image %@", [self imagePathForKey:s]);
        
    }
    return result;
}

- (void)deleteImageForKey:(NSString *)s
{
    if(!s)
        return;
    else
        [dictionary removeObjectForKey:s];
    
    NSString *path = [self imagePathForKey:s];
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    
}

- (NSString *)imagePathForKey:(NSString *)key
{
    NSArray * documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:key];
}

@end
