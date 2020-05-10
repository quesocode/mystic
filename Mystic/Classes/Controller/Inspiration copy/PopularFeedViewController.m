//
//  PopularFeedViewController.m
//  instagrampopular
//
//  Created by Bebek, Taha on 10/21/12.
//  Copyright (c) 2012 Bebek, Taha. All rights reserved.
//

#import "PopularFeedViewController.h"
#import "InstagramPostCell.h"
#import "DetailViewController.h"
#import "DataModel.h"

@interface PopularFeedViewController ()

@end

@implementation PopularFeedViewController
@synthesize posts;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.posts = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Popular";
    
    InstagramPopularFeedParser* parser = [[InstagramPopularFeedParser alloc] init];
    parser.delegate = self;
    
    NSURL* url = [NSURL URLWithString:@"https://api.instagram.com/v1/media/popular?client_id=%20df71db760d5a46de9ba167451699712a"];
    [parser parseURL:url];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 360;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InstagramPostCell* cell = [[[NSBundle mainBundle] loadNibNamed:@"InstagramPostCell" owner:nil options:nil] objectAtIndex:0];
    
    /*

    NSString* avatarURLString = [[postDict valueForKey:@"user"] valueForKey:@"profile_picture"];
    NSURL* avatarUrl = [NSURL URLWithString:avatarURLString];
    [cell performSelectorInBackground:@selector(downloadAvatar:) withObject:avatarUrl];
    
    cell.usernameLabel.text = [[postDict valueForKey:@"user"] valueForKey:@"username"];
    
    NSString* postURLString = [[[postDict valueForKey:@"images"] valueForKey:@"low_resolution"] valueForKey:@"url"];
    NSURL* postUrl = [NSURL URLWithString:postURLString];
    */
    
    NSDictionary* postDict = [self.posts objectAtIndex:indexPath.row];
    Post* currentPost = [[Post alloc] initWithDictionary:postDict];
    NSString* avatarURLString = currentPost.user.profile_picture;
    NSURL* avatarUrl = [NSURL URLWithString:avatarURLString];
    [cell performSelectorInBackground:@selector(downloadAvatar:) withObject:avatarUrl];

    cell.usernameLabel.text = currentPost.user.username;
    NSString* postURLString = currentPost.images.low_resolution.url;
    NSURL* postUrl = [NSURL URLWithString:postURLString];

    [cell performSelectorInBackground:@selector(downloadPost:) withObject:postUrl];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    NSDictionary* postDict = [self.posts objectAtIndex:indexPath.row];
    
     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    detailViewController.urlString = [postDict valueForKey:@"link"];
    
    [self.navigationController pushViewController:detailViewController animated:YES];

}

-(void)didFinishParsing:(NSArray*)somePosts
{
    self.posts = somePosts;
    [self.tableView reloadData];
}

-(void)didFailParsing:(NSError*)error
{
}


@end
