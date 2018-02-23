//
//  ImageCache.m
//  MusicSearch
//
//  Created by Carl on 2/21/18.
//  Copyright © 2018 Carl Gorringe. All rights reserved.
//

#import "ImageCache.h"

@interface ImageCache ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, UIImage *> *imageCache;
@property (nonatomic, strong) NSURL *cacheDir;

@end

@implementation ImageCache

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cacheDir = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask][0];
    }
    return self;
}

- (BOOL)saveImage:(UIImage *)image withFilename:(NSString *)filename {
    NSURL *url = [self.cacheDir URLByAppendingPathComponent:filename];
    NSData *data = UIImagePNGRepresentation(image);
    if (data == nil) return false;
    return [data writeToURL:url atomically:NO];
}

- (UIImage *)loadImageWithFilename:(NSString *)filename {
    NSURL *url = [self.cacheDir URLByAppendingPathComponent:filename];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data == nil) return nil;
    return [UIImage imageWithData:data];
}


@end
