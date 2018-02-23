//
//  LyricsViewController.h
//  MusicSearch
//
//  Created by Carl on 2/21/18.
//  Copyright © 2018 Carl Gorringe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MusicModel;
@class APIManager;

@interface LyricsViewController : UIViewController

// UI
@property (nonatomic, weak) IBOutlet UILabel *trackLabel;
@property (nonatomic, weak) IBOutlet UILabel *artistLabel;
@property (nonatomic, weak) IBOutlet UILabel *albumLabel;
@property (nonatomic, weak) IBOutlet UIImageView *albumImageView;
@property (nonatomic, weak) IBOutlet UITextView *lyricsTextView;

@property (nonatomic, strong) APIManager *api;
@property (nonatomic, strong) MusicModel *music;

@end
