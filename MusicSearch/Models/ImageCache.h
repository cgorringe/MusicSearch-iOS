//
//  ImageCache.h
//  MusicSearch
//
//  Created by Carl on 2/21/18.
//  Copyright © 2018 Carl Gorringe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageCache : NSObject

- (BOOL)saveImage:(UIImage *)image withFilename:(NSString *)filename;
- (UIImage *)loadImageWithFilename:(NSString *)filename;

@end
