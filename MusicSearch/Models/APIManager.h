//
//  APIManager.h
//  MusicSearch
//
//  Created by Carl on 2/21/18.
//  Copyright © 2018 Carl Gorringe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MusicModel;

@interface APIManager : NSObject

- (void)getMusic:(NSString *)query
    onCompletion:(void (^)(NSArray<MusicModel *> *music))completionHandler;

- (void)getLyricsForArtist:(NSString *)artist andSong:(NSString *)song
              onCompletion:(void (^)(NSString *lyrics))completionHandler;

@end
