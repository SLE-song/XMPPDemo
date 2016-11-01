//
//  SLEEditeViewController.m
//  XMPP
//
//  Created by mzyw on 16/10/26.
//  Copyright © 2016年 宋帅超. All rights reserved.
//

#import "SLEEditeViewController.h"

@interface SLEEditeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *editTextField;

@end

@implementation SLEEditeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.editCell.textLabel.text;
    self.editTextField.text = self.editCell.detailTextLabel.text;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(savemyData)];
    
    
}


- (void)savemyData
{
    
    if ([_delegate respondsToSelector:@selector(didClickSaveButton:withSaveDataString:)]) {
        
        
        [_delegate didClickSaveButton:self withSaveDataString:self.editTextField.text];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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
