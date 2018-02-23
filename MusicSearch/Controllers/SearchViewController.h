//
//  SearchViewController.h
//  MusicSearch
//
//  Created by Carl on 2/21/18.
//  Copyright © 2018 Carl Gorringe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APIManager;

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,
    UISearchBarDelegate, UIScrollViewDelegate>

// UI
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, weak) IBOutlet UITableView *resultsTableView;

@property (nonatomic, strong) APIManager *api;


@end
