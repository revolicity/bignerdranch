//
//  BNRImageStore.h
//  Homepwner
//
//  Created by Brian Schick on 3/29/13.
//  Copyright (c) 2013 com.bignerdranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BNRImageStore : NSObject
{
    NSMutableDictionary *dictionary;
}

+ (BNRImageStore *)sharedStore;

- (void)setImage:(UIImage *)i forKey:(NSString *)s;
- (UIImage *)imageForKey:(NSString *)s;
- (void)deleteImageForKey:(NSString *)s;

- (NSString *)imagePathForKey:(NSString *)key;

@end
