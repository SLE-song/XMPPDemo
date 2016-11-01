//
//  ALEMeMessageTableViewController.m
//  XMPP
//
//  Created by mzyw on 16/10/26.
//  Copyright © 2016年 宋帅超. All rights reserved.
//

#import "SLEMeMessageTableViewController.h"
#import "SLELoginTools.h"
#import "SLEEditeViewController.h"
#import "XMPPvCardTemp.h"



@interface SLEMeMessageTableViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,SLEEditeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *wxNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *bumenLabel;
@property (weak, nonatomic) IBOutlet UILabel *zhiweiLabel;
@property (weak, nonatomic) IBOutlet UILabel *teleLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;


// 索引
@property (nonatomic, strong) NSIndexPath *myIndexPath;

@end

@implementation SLEMeMessageTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"个人信息";
    self.hidesBottomBarWhenPushed = YES;
    [[SLELoginTools shareTools] saveData];
    [self setupLabels];
    
}





- (void)setupLabels
{
    
    if ([SLELoginTools shareTools].photo) {
        
        self.userImageView.image = [UIImage imageWithData:[SLELoginTools shareTools].photo];
    }
    self.teleLabel.text = [SLELoginTools shareTools].teleNumber;
    self.wxNumLabel.text = [SLELoginTools shareTools].userName;
//    if ([SLELoginTools shareTools].orgUnits) {
//        
//        self.bumenLabel.text = [SLELoginTools shareTools].orgUnits[0];
//    }
    self.emailLabel.text = [SLELoginTools shareTools].mailer;
    
    self.zhiweiLabel.text = [SLELoginTools shareTools].title;
    self.companyLabel.text = [SLELoginTools shareTools].orgName;
    self.nickNameLabel.text = [SLELoginTools shareTools].nickName;

}



- (instancetype)init
{
    if (self = [super init]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass([self class]) bundle:nil];
        self = [storyboard instantiateInitialViewController];
    }
    
    return self;
}


- (void)updateDataToHost
{

    // 上传数据
    XMPPvCardTemp *myEditvCardTemp = [SLELoginTools shareTools].xmppvCAModule.myvCardTemp;
    
    myEditvCardTemp.photo = UIImagePNGRepresentation(self.userImageView.image);
    myEditvCardTemp.note = self.teleLabel.text;
    if (myEditvCardTemp.orgUnits.count) {
        
        myEditvCardTemp.orgUnits = @[self.bumenLabel.text];
    }
    if (self.emailLabel.text.length > 0) {
        
        myEditvCardTemp.emailAddresses = @[self.emailLabel.text];
    }
    myEditvCardTemp.title = self.zhiweiLabel.text;
    myEditvCardTemp.orgName = self.companyLabel.text;
    myEditvCardTemp.nickname = self.nickNameLabel.text;
    
    [[SLELoginTools shareTools].xmppvCAModule updateMyvCardTemp:myEditvCardTemp];

}



#pragma mark - SLEEditeViewControllerDelegate
- (void)didClickSaveButton:(SLEEditeViewController *)meMeTaVc withSaveDataString:(NSString *)dataString
{
    
    UITableViewCell *cell = [self getCellAtIndexPath:self.myIndexPath tableView:self.tableView];
    
    if ([dataString isEqualToString:cell.detailTextLabel.text]) {
        
        NSLog(@"数据未发生改变");
        return;
    }
    
    cell.detailTextLabel.text = dataString;
    
   
    [self updateDataToHost];
}





#pragma mark----delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    SLEEditeViewController *editVc = [[SLEEditeViewController alloc] init];
    editVc.editCell = cell;
    editVc.delegate = self;
    self.myIndexPath = indexPath;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
    
        [self getImageFromPhoto];
    }else{
    
        [self.navigationController pushViewController:editVc animated:YES];
        self.hidesBottomBarWhenPushed = YES;
    }
    
}


#pragma mark----获取相册图片


- (UITableViewCell *)getCellAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    return cell;
}





- (void)getImageFromPhoto
{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"选择图片" message:@"请从下面选项选择图片资源，用来更换头像！" preferredStyle:UIAlertControllerStyleActionSheet];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        NSLog(@"支持相机");
        
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
            pickerController.delegate = self;
            pickerController.allowsEditing = YES;
            pickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
            
            
            [alertVc addAction:cameraAction];
        }];
        
    }
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        NSLog(@"支持图库");
        UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
            pickerController.delegate = self;
            pickerController.allowsEditing = YES;
            pickerController.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            
            
            [self presentViewController:pickerController animated:YES completion:nil];
        }];
        [alertVc addAction:photoAction];
    }
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertVc addAction:cancelAction];
    
    [self presentViewController:alertVc animated:YES completion:nil];


}



#pragma mark----UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    

    self.userImageView.image = info[UIImagePickerControllerEditedImage];
    [self updateDataToHost];
    [picker dismissViewControllerAnimated:YES completion:nil];
    

}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{


    [picker dismissViewControllerAnimated:YES completion:nil];


}


@end
