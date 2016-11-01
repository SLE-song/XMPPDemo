//
//  SLEEditeViewController.h
//  XMPP
//
//  Created by mzyw on 16/10/26.
//  Copyright © 2016年 宋帅超. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLEEditeViewController;

@protocol SLEEditeViewControllerDelegate <NSObject>

- (void)didClickSaveButton:(SLEEditeViewController *)meMeTaVc withSaveDataString:(NSString *)dataString;

@end


@interface SLEEditeViewController : UIViewController

// cell
@property (nonatomic, weak) UITableViewCell *editCell;



// 代理
@property (nonatomic, weak) id<SLEEditeViewControllerDelegate> delegate;

@end
