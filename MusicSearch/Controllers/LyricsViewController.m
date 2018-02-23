//
//  LyricsViewController.m
//  MusicSearch
//
//  Created by Carl on 2/21/18.
//  Copyright © 2018 Carl Gorringe. All rights reserved.
//

#import "LyricsViewController.h"
#import "APIManager.h"
#import "MusicModel.h"

@interface LyricsViewController ()

@end

@implementation LyricsViewController

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateMusic];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)updateMusic {

    self.lyricsTextView.text = @"";
    if (self.music != nil) {
        self.title = self.music.artistName;
        self.trackLabel.text = self.music.trackName;
        self.artistLabel.text = self.music.artistName;
        self.albumLabel.text = self.music.albumName;
        self.albumImageView.image = [UIImage imageNamed:@"music-placeholder"]; // TODO

        // retrieve lyrics from API
        if (self.api) {
            [self.api getLyricsForArtist:self.music.artistName
                                 andSong:self.music.trackName
                            onCompletion:^(NSString *lyrics) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    self.lyricsTextView.text = lyrics;
                                });
                            }
            ];
        }
    }
    else {
        self.title = @"";
        self.trackLabel.text = @"";
        self.artistLabel.text = @"";
        self.albumLabel.text = @"";
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
@end
