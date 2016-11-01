//
//  SLEChatInputView.m
//  XMPP
//
//  Created by mzyw on 16/10/28.
//  Copyright © 2016年 宋帅超. All rights reserved.
//

#import "SLEChatInputView.h"

@interface SLEChatInputView()

@property (weak, nonatomic) IBOutlet UIButton *keyboardChang;
@property (weak, nonatomic) IBOutlet UIButton *emojButton;
//@property (weak, nonatomic) IBOutlet UIButton *addOtherButton;

@end


@implementation SLEChatInputView


+ (instancetype)sle_loadSLEChatInputView
{

    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil].lastObject;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    

}
- (IBAction)emojButton:(id)sender {
    
    self.emojButton.selected = !self.emojButton.selected;
}

- (IBAction)keyboardChang:(id)sender {
    
    self.keyboardChang.selected = !self.keyboardChang.selected;
}
//- (IBAction)addOtherButton:(id)sender {
//    
//    UIImagePickerController *pickVc = [[UIImagePickerController alloc] init];
//    pickVc.delegate = self;
//    pickVc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//
//}

@end
