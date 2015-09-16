//
//  RepoResultsViewController.m
//  GithubDemo
//
//  Created by Nicholas Aiwazian on 9/15/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "RepoResultsViewController.h"
#import "MBProgressHUD.h"
#import "GithubRepo.h"
#import "GithubRepoSearchSettings.h"
#import "myTableViewCell.h"
#import "UIImageView+AFNetworking.h"

@interface RepoResultsViewController ()
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) GithubRepoSearchSettings *searchSettings;
@property (nonatomic,strong) NSArray *gitRepos;
@end

@implementation RepoResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchSettings = [[GithubRepoSearchSettings alloc] init];
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    [self.searchBar sizeToFit];
    self.navigationItem.titleView = self.searchBar;

    self.myTableView.dataSource = self;
    self.myTableView.delegate = self;
    
    UINib *myCellNib = [UINib nibWithNibName:@"myTableViewCell" bundle:nil];
    [self.myTableView registerNib:myCellNib forCellReuseIdentifier:@"myTableViewCell"];
    [self doSearch];
    self.myTableView.estimatedRowHeight = 250;
    self.myTableView.rowHeight = UITableViewAutomaticDimension;

}

- (void)doSearch {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [GithubRepo fetchRepos:self.searchSettings successCallback:^(NSArray *repos) {
        for (GithubRepo *repo in repos) {
            NSLog(@"%@", [NSString stringWithFormat:
                   @"Name:%@\n\tDescription:%@\n\tStars:%ld\n\tForks:%ld,Owner:%@\n\tAvatar:%@\n\t",
                          repo.name,
                          repo.repoDescription,
                          repo.stars,
                          repo.forks,
                          repo.ownerHandle,
                          repo.ownerAvatarURL
                   ]);
        }
        self.gitRepos = repos;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.myTableView reloadData];
    }];
}

- (long)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.gitRepos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *detailTableIdentifier = @"com.github.tableViewCell";
    
    myTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:detailTableIdentifier];
    
    if (cell == nil) {
        cell = [[myTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:detailTableIdentifier];
    }
    
    // NSLog(@"This is a row");
    //cell.nameLabel.text = self.gitRepos[indexPath.row][@"name"];
    // NSLog(@"This is a row %@", self.gitRepos[indexPath.row][@"name"]);
    GithubRepo *repo = self.gitRepos[indexPath.row];
    cell.nameLabel.text = repo.name;
    cell.starsLabel.text =  [NSString stringWithFormat:@"%ld", repo.stars];
    cell.forksLabel.text = [NSString stringWithFormat:@"%ld", repo.forks];
    cell.descriptionLabel.text = repo.repoDescription;
    [cell.avatarImage setImageWithURL:[NSURL URLWithString:repo.ownerAvatarURL] placeholderImage:[UIImage imageNamed:@"test.jpg"]];
    // self.myTableView.estimatedRowHeight = 300;
    // self.myTableView.rowHeight = UITableViewAutomaticDimension;
    return cell;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searchSettings.searchString = searchBar.text;
    [searchBar resignFirstResponder];
    [self doSearch];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
