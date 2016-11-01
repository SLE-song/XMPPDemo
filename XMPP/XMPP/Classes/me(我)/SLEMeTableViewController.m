//
//  SLEMeTableViewController.m
//  XMPP
//
//  Created by mzyw on 16/10/25.
//  Copyright © 2016年 宋帅超. All rights reserved.
//

#import "SLEMeTableViewController.h"
#import "SLELoginTools.h"

#import "SLEMeMessageTableViewController.h"

@interface SLEMeTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *weNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;


@end

@implementation SLEMeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[SLELoginTools shareTools] saveData];
    if ([SLELoginTools shareTools].photo) {
        
        self.userImageView.image = [UIImage imageWithData:[SLELoginTools shareTools].photo];
    }
    
    if ([SLELoginTools shareTools].nickName) {
        
        self.nickNameLabel.text = [SLELoginTools shareTools].nickName;
    }

    self.weNumberLabel.text = [NSString stringWithFormat:@"微信号：%@",[SLELoginTools shareTools].userName];
}

- (instancetype)init
{
    if (self = [super init]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass([self class]) bundle:nil];
        self = [storyboard instantiateInitialViewController];
    }

    return self;
}





#pragma mark----delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3 && indexPath.row == 1) {
        
        [[SLELoginTools shareTools] logout];
    }

    if (indexPath.section == 0 && indexPath.row == 0) {
        
        SLEMeMessageTableViewController *messaVc = [[SLEMeMessageTableViewController alloc] init];
        [self.navigationController pushViewController:messaVc animated:YES];
        
        
    }

}


@end
