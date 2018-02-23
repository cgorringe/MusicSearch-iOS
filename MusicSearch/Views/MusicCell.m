//
//  MusicCell.m
//  MusicSearch
//
//  Created by Carl on 2/21/18.
//  Copyright © 2018 Carl Gorringe. All rights reserved.
//

#import "MusicCell.h"
#import "MusicModel.h"

@implementation MusicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)updateWithMusicModel:(MusicModel *)musicModel {

    self.trackLabel.text = musicModel.trackName;
    self.artistLabel.text = musicModel.artistName;
    self.albumLabel.text = musicModel.albumName;

    // send notification to retrieve image
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadImage"
                                                        object:self
                                                      userInfo:@{ @"imageView" : self.albumImageView,
                                                                  @"imageUrl" : musicModel.albumImageUrl
                                                                }];
}

@end
