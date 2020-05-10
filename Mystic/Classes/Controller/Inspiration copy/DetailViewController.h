//
//  DetailViewController.h
//  instagrampopular
//
//  Created by Bebek, Taha on 10/21/12.
//  Copyright (c) 2012 Bebek, Taha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController
@property(nonatomic, strong) NSString* urlString;
@property (nonatomic, strong) IBOutlet UILabel* urlLabel;
@end
