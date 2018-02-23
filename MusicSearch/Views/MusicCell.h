//
//  MusicCell.h
//  MusicSearch
//
//  Created by Carl on 2/21/18.
//  Copyright © 2018 Carl Gorringe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MusicModel;

@interface MusicCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *trackLabel;
@property (nonatomic, weak) IBOutlet UILabel *artistLabel;
@property (nonatomic, weak) IBOutlet UILabel *albumLabel;
@property (nonatomic, weak) IBOutlet UIImageView *albumImageView;

- (void)updateWithMusicModel:(MusicModel *)musicModel;

@end
