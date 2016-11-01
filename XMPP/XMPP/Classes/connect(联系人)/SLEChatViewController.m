//
//  SLEChatViewController.m
//  XMPP
//
//  Created by mzyw on 16/10/28.
//  Copyright © 2016年 宋帅超. All rights reserved.
//

#import "SLEChatViewController.h"
#import "SLEChatInputView.h"
#import "SLELoginTools.h"
#import "HttpTool.h"
#import "UIImageView+WebCache.h"

@interface SLEChatViewController ()<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate,UITextViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{

    NSFetchedResultsController *_resultVc;
}

// sel
@property (nonatomic, strong) NSLayoutConstraint *inputViewVirConstant;
// tablview
@property (nonatomic, weak) UITableView *tableView;

// s
@property (nonatomic, strong) SLEChatInputView *inputView;

// shang chuan
@property (nonatomic, strong) HttpTool *httpTool;

@end

@implementation SLEChatViewController

- (HttpTool *)httpTool
{
    if (_httpTool == nil) {
        
        _httpTool = [[HttpTool alloc] init];
    }

    return _httpTool;

}


- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupInputView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidFrameChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
    
    [self loadMessage];
    [self scrollTableView];
}


#pragma mark----清楚观察者
- (void)dealloc
{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark----设置输入文字视图
- (void)setupInputView
{

    UITableView *tableview = [[UITableView alloc] init];
    [self.view addSubview:tableview];
    tableview.translatesAutoresizingMaskIntoConstraints = NO;
    tableview.delegate = self;
    tableview.dataSource = self;
//    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:chatCellID];
    [tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:chatCellID];
    self.tableView = tableview;
    
    SLEChatInputView *inputView = [SLEChatInputView sle_loadSLEChatInputView];
    [self.view addSubview:inputView];
    inputView.chatTextView.delegate = self;
    inputView.translatesAutoresizingMaskIntoConstraints = NO;
    [inputView.addOtherButton addTarget:self action:@selector(addOtherButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    self.inputView = inputView;
    
    
    // 1.tableview水平约束
    NSDictionary *viewDic = @{
                              @"tableView" : tableview,
                              @"inputView" : inputView
                              };
    NSArray *tableViewHconstaint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tableView]-0-|" options:0 metrics:nil views:viewDic];
    
    [self.view addConstraints:tableViewHconstaint];
    
    // 2.inputview 水平约束
    NSArray *inputViewHconstaint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[inputView]-0-|" options:0 metrics:nil views:viewDic];

    [self.view addConstraints:inputViewHconstaint];
    
    
    // 垂直方向约束
    NSArray *virConstaint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tableView]-0-[inputView(50)]-0-|" options:0 metrics:nil views:viewDic];
    [self.view addConstraints:virConstaint];
    self.inputViewVirConstant = virConstaint.lastObject;
    
}

#pragma mark----监听键盘弹出
- (void)keyboardFrameChange:(NSNotification *)info
{

    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    CGRect keyboardC = [info.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardEndY = keyboardC.origin.y;
    
    self.inputViewVirConstant.constant = screenH - keyboardEndY;

}


- (void)keyboardDidFrameChange:(NSNotification *)info
{

    [self scrollTableView];

}




#pragma mark----加载消息
- (void)loadMessage
{

    // 上下文
    NSManagedObjectContext *managedObjectContext = [SLELoginTools shareTools].xmppMessageArVCoreDStorage.mainThreadManagedObjectContext;
    // 请求对象  XMPPMessageArchiving_Message_CoreDataObject:聊天数据表名
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    // 过滤
    // 当前登录用户的JID消息
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",[SLELoginTools shareTools].userName];

    // 好友jid
    NSPredicate *friendPredicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@",[SLELoginTools shareTools].currentJid,self.friendJID.bare];
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sortDes];
    request.predicate = friendPredicate;
 
    _resultVc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error = nil;
    [_resultVc performFetch:&error];
    if (error) {
        
        NSLog(@"%@",error);
    }
    _resultVc.delegate = self;
    
    
    
}


#pragma mark----UITbaleViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{


    return _resultVc.fetchedObjects.count;
}

static NSString *chatCellID = @"chatCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"------------------****日志标志位 1 ***--------------");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:chatCellID];
    
    cell.textLabel.text = nil;
    cell.imageView.image = nil;
    
    XMPPMessageArchiving_Message_CoreDataObject *msgCoreDataObject = _resultVc.fetchedObjects[indexPath.row];

    
    
    NSString *chatType = [msgCoreDataObject.message attributeStringValueForName:@"bodyType"];

    if ([chatType isEqualToString:@"image"]) {
        
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:msgCoreDataObject.body] placeholderImage:[UIImage imageNamed:@"ToolViewEmotionHL"]];
    }
    
    if ([chatType isEqualToString:@"text"]) {
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@",[SLELoginTools shareTools].currentJid,msgCoreDataObject.body];
    }
    
    if (![msgCoreDataObject.outgoing boolValue]) {
        
       cell.textLabel.text = [NSString stringWithFormat:@"%@: %@",self.friendJID,msgCoreDataObject.body];
    }
    

    return cell;
}



#pragma mark----NSFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    [self.tableView reloadData];
    [self scrollTableView];
}


#pragma mark----UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{

    CGSize size = textView.contentSize;
    
    if (self.inputView.chatTextView.frame.size.height < size.height) {
        
        CGRect tmp = self.inputView.chatTextView.frame;
        tmp.size.height = size.height;

        self.inputView.chatTextView.frame = tmp;
        self.inputViewVirConstant.constant += size.height - self.inputView.chatTextView.frame.size.height;
    }
    
    if ([textView.text rangeOfString:@"\n"].length != 0) {
        
        // 去除换行符
        textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [self sendMessage:textView.text type:@"text"];
        textView.text = nil;
    }


}



#pragma mark----发送数据
- (void)sendMessage:(NSString *)text type:(NSString *)type
{

    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJID];
    [msg addAttributeWithName:@"bodyType" stringValue:type];
    [msg addBody:text];
    
    [[SLELoginTools shareTools].xmppStream sendElement:msg];
    

}

#pragma mark----滚动表格
- (void)scrollTableView
{

    NSInteger lastRow = _resultVc.fetchedObjects.count - 1;
    
    if (lastRow < 0) {
        
        return;
    }
    
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
    
    [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

}


#pragma mark----其他按钮点击
- (void)addOtherButtonDidClick
{

    UIImagePickerController *imagePickerVc = [[UIImagePickerController alloc] init];
    imagePickerVc.delegate = self;
    imagePickerVc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePickerVc animated:YES completion:^{
        
    }];

}


#pragma mark----UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{

    [self dismissViewControllerAnimated:YES completion:nil];
    // 获取图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    // 把图片发送到服务器
    NSString *user = [SLELoginTools shareTools].userName;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyyMMddHHmmss";
    NSString *timeStr = [dateFormat stringFromDate: [NSDate date]];
    NSString *fileName = [user stringByAppendingString:timeStr];
    
    // 拼接上传路径
    NSString *uploadUrl = [@"http://localhost:8080/imfileserver/Upload/Image/" stringByAppendingString:fileName];
    
    // 使用HTTP put 上传
    [self.httpTool uploadData:UIImageJPEGRepresentation(image, 0.75) url:[NSURL URLWithString:uploadUrl] progressBlock:nil completion:^(NSError *error) {
       
        if (!error) {
            
            NSLog(@"上传成功！");
            [self sendMessage:uploadUrl type:@"image"];
        }
    }];
    
    // 图片发送成功，把图片URL 发送到 openfire 服务器
    
    
}

@end
