//
//  SearchViewController.m
//  MusicSearch
//
//  Created by Carl on 2/21/18.
//  Copyright © 2018 Carl Gorringe. All rights reserved.
//

#import "SearchViewController.h"
#import "LyricsViewController.h"
#import "APIManager.h"
#import "MusicCell.h"
#import "MusicModel.h"

@interface SearchViewController ()

@property (nonatomic, strong) NSArray<MusicModel *> *resultsList;

@end

@implementation SearchViewController

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // init vars
    self.resultsList = @[];
    self.api = [[APIManager alloc] init];

    // setup search controller & search bar
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.dimsBackgroundDuringPresentation = NO;
    //self.definesPresentationContext = YES;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.placeholder = @"Search Music";
    self.navigationItem.titleView = self.searchController.searchBar;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"idLyricsSegue"]) {
        LyricsViewController *lvc = [segue destinationViewController];
        lvc.api = self.api;
        lvc.music = self.resultsList[self.resultsTableView.indexPathForSelectedRow.row];

        // replace 'Back' button with empty text on pushed view controller
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil
                                                style:UIBarButtonItemStylePlain target:self action:NULL];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - General

- (void)searchMusic:(NSString *)query {

    [self.api getMusic:query onCompletion:^(NSArray<MusicModel *> *music) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultsList = music;
            [self.resultsTableView reloadData];
        });
    }];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    MusicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idMusicCell" forIndexPath:indexPath];

    cell.albumImageView.image = [UIImage imageNamed:@"music-placeholder"];  // default image
    [cell updateWithMusicModel:self.resultsList[indexPath.row]];

    return cell;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchMusic:searchBar.text];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchController.searchBar resignFirstResponder];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
@end
