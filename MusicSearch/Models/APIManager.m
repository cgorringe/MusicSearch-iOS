//
//  APIManager.m
//  MusicSearch
//
//  Created by Carl on 2/21/18.
//  Copyright © 2018 Carl Gorringe. All rights reserved.
//

#import "APIManager.h"
#import "ImageCache.h"
#import "MusicModel.h"

@interface APIManager ()

@property (nonatomic, strong) ImageCache *imageCache;

@end

@implementation APIManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.imageCache = [[ImageCache alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadImageWithNotification:)
                                                     name:@"DownloadImage"
                                                   object:nil];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - General

/** URLencodes value so that spaces are replaced with pluses, and non-allowed characters are percent-encoded. */

- (NSString *)urlEncodedValue:(NSString *)value {

    NSMutableCharacterSet *cset = [NSCharacterSet.URLQueryAllowedCharacterSet mutableCopy];
    [cset removeCharactersInString:@"&"];  // "+&"
    NSString *value2 = [value stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *escaped = [value2 stringByAddingPercentEncodingWithAllowedCharacters:cset];
    return escaped;
}


- (NSData *)fixInvalidJSONData:(NSData *)data {

    /* Steps to fix:
     * 1. Remove all characters before the first '{' for dictionaries, or '[' for arrays.
     * 2. Replace all (") with (\")
     * 3. Replace all (') with ("), except (\') which are replaced with (')
     *
     * Note: This routine will break if given valid JSON where double quotes surround key/values.
     * It assumes all key/value strings are surrounded by single quotes.
     */

    // step 1
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSRange clipRange = [text rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"{["]];
    if (clipRange.location == NSNotFound) { return nil; }
    NSString *outText = [text substringFromIndex:clipRange.location];

    // step 2
    outText = [outText stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];

    // step 3 (uses § as a temp single quote)
    outText = [outText stringByReplacingOccurrencesOfString:@"\\'" withString:@"§"];
    outText = [outText stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    outText = [outText stringByReplacingOccurrencesOfString:@"§" withString:@"'"];

    return [outText dataUsingEncoding:NSUTF8StringEncoding];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - API Calls

- (void)getMusic:(NSString *)query
    onCompletion:(void (^)(NSArray<MusicModel *> *music))completionHandler {

    NSString *url = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@",
                     [self urlEncodedValue:query]];
    NSLog(@"GET: %@", url);

    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:url]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error)
        {
            NSError *jsonError;
            NSMutableArray<MusicModel *> *musicResults = [NSMutableArray array];
            if (data) {
                NSDictionary *jsonRoot = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                NSArray *jsonResults;
                if ((jsonResults = jsonRoot[@"results"]) != nil) {
                    for (NSDictionary *item in jsonResults) {
                        MusicModel *music = [[MusicModel alloc] init];
                        music.trackName = (item[@"trackName"]) ? item[@"trackName"] : @"";
                        music.artistName = (item[@"artistName"]) ? item[@"artistName"] : @"";
                        music.albumName = (item[@"collectionName"]) ? item[@"collectionName"] : @"";
                        music.albumImageUrl = (item[@"artworkUrl100"]) ? item[@"artworkUrl100"] : nil;
                        [musicResults addObject:music];
                    }
                }
            }
            completionHandler(musicResults);
        }
    ] resume];
}

- (void)getLyricsForArtist:(NSString *)artist andSong:(NSString *)song
              onCompletion:(void (^)(NSString *lyrics))completionHandler {

    /* Notes on Lyrics API:
     * The data returned isn't valid JSON, as it's in the form:
     *   song = { 'key' : 'value', ... }
     * It's also using single quotes for key/values, while valid JSON uses double quotes.
     */

    NSString *url = [NSString stringWithFormat:@"https://lyrics.wikia.com/api.php?func=getSong&artist=%@&song=%@&fmt=json",
                     [self urlEncodedValue:artist],
                     [self urlEncodedValue:song]];
    NSLog(@"GET: %@", url);

    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:url]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error)
        {
            NSString *lyrics = @"Lyrics are unavailable.";
            if (data) {
                NSDictionary *jsonRoot;
                NSData *fixedData;
                // first parse as-if it's valid JSON
                jsonRoot = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                if (jsonRoot == nil) {
                    // JSON is invalid, so try parsing again after fixing it
                    fixedData = [self fixInvalidJSONData:data];
                    jsonRoot = [NSJSONSerialization JSONObjectWithData:fixedData options:kNilOptions error:nil];
                }
                if (jsonRoot && jsonRoot[@"lyrics"]) {
                    lyrics = jsonRoot[@"lyrics"];
                }
            }
            completionHandler(lyrics);
        }
    ] resume];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Notification methods

- (void)downloadImageWithNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo == nil) return;

    UIImageView *imageView = userInfo[@"imageView"];
    NSString *imageUrl = userInfo[@"imageUrl"];
    //NSString *filename = [[NSURL URLWithString:imageUrl] lastPathComponent];  // not a good choice
    NSString *filename = [[[NSURL URLWithString:imageUrl] pathComponents] componentsJoinedByString:@""]; // better

    // first check if image is in local cache
    UIImage *image;
    if ((image = [self.imageCache loadImageWithFilename:filename])) {
        imageView.image = image;
        return;
    }

    // if not, download image
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:imageUrl]
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (data) {
                        UIImage *downloadedImg = [UIImage imageWithData:data];
                        if (downloadedImg) {
                            imageView.image = downloadedImg;
                            if (![self.imageCache saveImage:downloadedImg withFilename:filename]) {
                                NSLog(@"*** image didn't save! filename: %@", filename);
                            }
                        }
                        else {
                            NSLog(@"*** downloadedImg is nil!");
                        }
                    }
                });
    }] resume];
}


@end
