//
//  SLEConnectionTableViewController.m
//  XMPP
//
//  Created by mzyw on 16/10/25.
//  Copyright © 2016年 宋帅超. All rights reserved.
//

#import "SLEConnectionTableViewController.h"
#import "SLELoginTools.h"
#import "SLEAddFriendsViewController.h"
#import "SLEChatViewController.h"

@interface SLEConnectionTableViewController ()<NSFetchedResultsControllerDelegate>
{
    
    NSFetchedResultsController *_resultsContl;

}

// 朋友列表
@property (nonatomic, strong) NSArray *friends;

@end

@implementation SLEConnectionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self loadFriendsList];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加好友" style:UIBarButtonItemStyleDone target:self action:@selector(addFriends)];
    
    
    
}

#pragma mark----添加好友
- (void)addFriends
{

    [self.navigationController pushViewController:[[SLEAddFriendsViewController alloc] init] animated:YES];
}




#pragma mark----加载朋友列表
- (void)loadFriendsList
{
    
    // 使用 coredata 获取数据
    // 关联数据库
   NSManagedObjectContext *managerObjContext = [SLELoginTools shareTools].xmppRosterStorage.mainThreadManagedObjectContext;

    // FetchRuest
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    // 过滤条件  排序
    // 过滤当前登录的好友
    NSString *currendJid = [SLELoginTools shareTools].currentJid;

    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",currendJid];
    fetchRequest.predicate = predicate;
    
    // 排序
    NSSortDescriptor *sortDe = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    fetchRequest.sortDescriptors = @[sortDe];
    // 执行请求
//    NSArray *friends = [managerObjContext executeFetchRequest:fetchRequest error:nil];
//    self.friends = friends;
    _resultsContl = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managerObjContext sectionNameKeyPath:nil cacheName:nil];
    _resultsContl.delegate = self;
    NSError *error = nil;
    [_resultsContl performFetch:&error];
    if (error) {
        
        NSLog(@"%@",error);
    }
    
    

    
}
#pragma mark----NSFetchedResultsControllerDelegate 数据内容发送改变，就会调用
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"数据内容发送改变，就会调用");
    [self.tableView reloadData];
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSLog(@"-------%@",_resultsContl.fetchedObjects);
    return _resultsContl.fetchedObjects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendsCell"];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"friendsCell"];
    }
    
    XMPPUserCoreDataStorageObject *storageObject = _resultsContl.fetchedObjects[indexPath.row];
    
    cell.textLabel.text = storageObject.jidStr;

    switch ([storageObject.sectionNum intValue]) {
        case 0:
            
            cell.detailTextLabel.text = @"在线";
            break;
        case 1:
            
            cell.detailTextLabel.text = @"离开";
            break;
        case 2:
            
            cell.detailTextLabel.text = @"离线";
            break;
            
        default:
            break;
    }
    
    
    
    
    return cell;
}





#pragma mark----UITableViewDelegate
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSLog(@"delete friend");
        XMPPUserCoreDataStorageObject *storageObject = _resultsContl.fetchedObjects[indexPath.row];
        XMPPJID *friendJid = storageObject.jid;
        [[SLELoginTools shareTools].xmppRoster removeUser:friendJid];
        
    }



}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    XMPPUserCoreDataStorageObject *storageObject = _resultsContl.fetchedObjects[indexPath.row];
    SLEChatViewController *chatVc = [[SLEChatViewController alloc] init];
    chatVc.title = cell.textLabel.text;
//    NSString *temp = nil;
//    NSString *jid = nil;
//    
//    for (int i; i < storageObject.jidStr.length; i++) {
//        
//        temp = [storageObject.jidStr substringWithRange:NSMakeRange(i, 1)];
//        if ([temp isEqualToString:@"@"]) {
//            
//            break;
//        }
//        
//        jid = [userName substringToIndex:i+1];
//    }
    chatVc.friendJID = storageObject.jid;
    
    [self.navigationController pushViewController:chatVc animated:YES];
}


@end
