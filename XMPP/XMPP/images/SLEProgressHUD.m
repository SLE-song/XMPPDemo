//
//  SLEProgressHUD.m
//  
//
//  Created by sle on 16/10/10.
//  Copyright © 2016年 宋帅超. All rights reserved.
//

#import "SLEProgressHUD.h"


#define SLE_MainSreenWidth [[UIScreen mainScreen] bounds].size.width
#define SLE_MainSreenHeight [[UIScreen mainScreen] bounds].size.height
#define SLE_DEFAULT_HEIGHT 30
#define SLE_DEFAULT_WIDTH  30
#define SLE_DEFAULT_MARGIN 10
#define SLE_DEFAULT_HALF_SCREEN_WIDTH (SLE_MainSreenWidth *0.5)
#define SLE_DEFAULT_HALF_SCREEN_HEIGHT (SLE_MainSreenHeight *0.5)

typedef enum {
    
    kSLEDefault,
    kSLECustom
}SLEWindowStatus;

typedef enum {
    kUnloaded,
    kLoading
}SLEProgressHudStatus;

@interface SLEProgressHUD()

// 指示器状态
@property (nonatomic, assign) SLEProgressHudStatus sle_progressHudStatus;

// 显示灰色背景
@property (nonatomic, weak) UIView *statusView;
// 获取窗口
@property (nonatomic, strong) UIWindow *window;

// 当前颜色
@property (nonatomic, weak) UIColor *currentColor;

// 窗口的状态   判断是否是系统，还是在这里自定义 <未使用>
@property (nonatomic, assign) SLEWindowStatus windowStatus;

// 定时器
@property (nonatomic, weak) NSTimer *sletimer;

// 图片
//@property (nonatomic, weak) UIImageView *sle_imageView;

// label。加载文字
@property (nonatomic, weak) UILabel *sle_label;

// 中间 白色背景
@property (nonatomic, weak) UIView *sle_view;

// 保存图片
@property (nonatomic, copy) NSString *imageString;

// 角度
@property (nonatomic, assign) CGFloat currentAngle;

// yuan
@property (nonatomic, weak) UIView *statusSuperView;

@end


@implementation SLEProgressHUD


- (NSTimer *)sletimer
{
    if (_sletimer == nil) {
        
        self.sletimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(turn) userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:self.sletimer forMode:NSRunLoopCommonModes];
    }
    return _sletimer;

}

- (UIView *)statusView
{

    if (_statusView == nil) {
        UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _statusView = view;
    }
    return _statusView;
}



static SLEProgressHUD *sleProHud;
+ (instancetype)shareView{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sleProHud = [[SLEProgressHUD alloc] init];
    });
    return sleProHud;
}




- (instancetype)init {
    if (self = [super init]) {
     
        
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        UIViewController *viewVc = [UIViewController new];
        window.rootViewController = viewVc;
        window.backgroundColor = [UIColor clearColor];
        [window setHidden:NO];
        
        self.window = window;
        self.sle_progressHudStatus = kUnloaded;
        
        window.windowLevel = UIWindowLevelStatusBar + 10000;
//        [self setupWindowLevel];
        // 监听旋转
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
    }
    return self;
}


- (void)statusBarOrientationChange:(NSNotification *)notification

{

    self.statusView.frame = CGRectMake(0, 0, SLE_MainSreenWidth, SLE_MainSreenHeight);
    self.sle_view.center = CGPointMake(SLE_MainSreenWidth *0.5, SLE_MainSreenHeight *0.5);
}



- (void)setupWindowLevel
{

    if ([UIApplication sharedApplication].keyWindow != nil) {
        
        UIWindow *keywindow = [UIApplication sharedApplication].keyWindow;
        _window.windowLevel = keywindow.windowLevel + 1;
        
    }else{
        
        _window.windowLevel = UIWindowLevelStatusBar + 10000;
    }
}



- (void)turn{

    
    static CGFloat angle = M_PI_4;
    self.statusSuperView.transform = CGAffineTransformMakeRotation(angle);
    angle += M_PI_4;
}





- (void)getViewWithString:(NSString *)string withImage:(NSString *)image
{
    
    
    self.sle_label = nil;
    self.statusSuperView = nil;
    self.sle_view = nil;
    self.statusView = nil;
    
    UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SLE_MainSreenWidth, SLE_MainSreenHeight)];
    self.statusView = statusView;
    
    // 白色背景
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    self.sle_view = view;
    
    // 图片
    if ([image isEqualToString:@"angle-mask"]) {
        
        UIView *statusSuperView = [[UIView alloc] init];
        [view addSubview:statusSuperView];
        self.statusSuperView = statusSuperView;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = nil;
        imageView.image = [UIImage imageNamed:image];
        imageView.frame = CGRectMake( 0, 0, SLE_DEFAULT_WIDTH, SLE_DEFAULT_HEIGHT);
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = imageView.frame.size.width *0.5;
        [statusSuperView addSubview:imageView];
        
        UIView *view2 = [[UIView alloc] init];
        view2.frame = CGRectMake(0, 0, SLE_DEFAULT_WIDTH - 4,SLE_DEFAULT_HEIGHT - 4);
        view2.layer.masksToBounds = YES;
        view2.layer.cornerRadius = view2.frame.size.width *0.5;
        view2.backgroundColor = [UIColor whiteColor];
        view2.center = imageView.center;
        [statusSuperView addSubview:view2];
       
    }else{
    
        UIView *statusSuperView = [[UIView alloc] init];
        [view addSubview:statusSuperView];
        self.statusSuperView = statusSuperView;
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = nil;
        
        NSLog(@"%@",image);
        imageView.image = [UIImage imageNamed:image];
        imageView.frame = CGRectMake( 0, 0, SLE_DEFAULT_WIDTH, SLE_DEFAULT_HEIGHT);
        [statusSuperView addSubview:imageView];
    }
    
    
    
    
    
    // label
    UILabel *label = [[UILabel alloc] init];
    [view addSubview:label];
    label.font = [UIFont systemFontOfSize:18];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    if (string.length != 0) {
        label.text = nil;
        label.text = string;
    }
    self.sle_label = label;
    

    statusView.backgroundColor = [UIColor colorWithWhite:.3 alpha:.4];
    [self.window addSubview:statusView];
    [self.window addSubview:view];
    
    [self setupFrame];
    

}


/******************* 内部方法 ************************/
- (void)dismiss{

    [SLEProgressHUD dismiss];
}



- (void)setupFrame{
    
    
    CGFloat MaxW = MIN(SLE_MainSreenWidth, SLE_MainSreenHeight) *0.6;

    // 中间白色背景
    self.sle_view.frame = CGRectMake(0, 0, MIN(MaxW, SLE_MainSreenWidth * 0.3),  MIN(MaxW, SLE_MainSreenWidth * 0.3));
    
    // 图片
    CGFloat imageViewH = SLE_DEFAULT_HEIGHT;//self.sle_view.frame.size.height * 0.4;
    CGFloat imageViewW = SLE_DEFAULT_WIDTH;//imageViewH;
    self.statusSuperView.frame = CGRectMake((self.sle_view.frame.size.width - imageViewW) * 0.5, SLE_DEFAULT_MARGIN, imageViewW, imageViewH);
    
    CGRect tmp = self.sle_view.frame;
    tmp.size.height = 10 + imageViewH;
    
    // label
    if (self.sle_label.text.length == 0) {
        
        self.statusSuperView.center = CGPointMake(self.sle_view.frame.size.width *0.5, self.sle_view.frame.size.height *0.5);
        self.sle_view.center = CGPointMake(SLE_MainSreenWidth * 0.5, SLE_MainSreenHeight * 0.5);
    }else{
        
        CGSize size = [self.sle_label.text boundingRectWithSize:CGSizeMake(MaxW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.sle_label.font} context:nil].size;
        
        tmp.size.height += size.height + 2 *SLE_DEFAULT_MARGIN;
        
        if (self.sle_label.numberOfLines == 1) {
            
            tmp.size.width = tmp.size.height;
        }
      
        
        if (size.width > tmp.size.height) {

            tmp.size.width = size.width + 10;
        }
        
        
        if (size.width > MaxW) {
            
            tmp.size.width = MaxW;
            tmp.size.height = CGRectGetMaxY(self.sle_label.frame) + SLE_DEFAULT_MARGIN;
        }
        
        // 确定位置
        self.sle_view.frame = CGRectMake(0, 0, tmp.size.width, tmp.size.height);
        self.sle_label.frame = CGRectMake(0, 0, size.width, size.height);
        self.statusSuperView.center = CGPointMake(self.sle_view.frame.size.width *0.5, self.statusSuperView.frame.size.height * 0.5 + 10);
        self.sle_label.center = CGPointMake(self.sle_view.frame.size.width *0.5, CGRectGetMaxY(self.statusSuperView.frame) + self.sle_label.frame.size.height *0.5 + SLE_DEFAULT_MARGIN);
        self.sle_view.center = CGPointMake(SLE_DEFAULT_HALF_SCREEN_WIDTH, SLE_DEFAULT_HALF_SCREEN_HEIGHT);
    }

    
}









/******************* 提供其他人员使用 ************************/
+ (void)dismiss{

    
    [[SLEProgressHUD shareView].window setHidden:YES];
    [[SLEProgressHUD shareView].sle_view removeFromSuperview];
    [[SLEProgressHUD shareView].statusView removeFromSuperview];
    for (UIView *view in [SLEProgressHUD shareView].sle_view.subviews) {
        [view removeFromSuperview];
    }
    for (UIView *view in [SLEProgressHUD shareView].statusView.subviews) {
        [view removeFromSuperview];
    }
    [SLEProgressHUD shareView].sle_view = nil;
    [SLEProgressHUD shareView].statusSuperView = nil;
    [SLEProgressHUD shareView].sle_label = nil;
    [SLEProgressHUD shareView].statusView = nil;
    [SLEProgressHUD shareView].sle_progressHudStatus = kUnloaded;
    
    if ([SLEProgressHUD shareView].sletimer != nil) {
        [[SLEProgressHUD shareView].sletimer invalidate];
        [SLEProgressHUD shareView].sletimer = nil;
    }
    
}



+ (void)showStatusWithString:(NSString *) str{
    if ([SLEProgressHUD shareView].sle_progressHudStatus == kLoading) {
        
        [SLEProgressHUD dismiss];
        [SLEProgressHUD showStatusWithString:str];
    }else{
        
        [[SLEProgressHUD shareView].window setHidden:NO];
        [[SLEProgressHUD shareView].sletimer fire];
        [[SLEProgressHUD shareView] getViewWithString:str withImage:@"angle-mask"];
        [SLEProgressHUD shareView].sle_progressHudStatus = kLoading;
    }
}



+ (void)showStatusWithString:(NSString *) str dismiss:(CGFloat)duration{
    
    
    if ([SLEProgressHUD shareView].sle_progressHudStatus == kLoading) {
        
        [[SLEProgressHUD shareView] dismiss];
        [SLEProgressHUD showStatusWithString:str dismiss:duration];
    }else{
    
        [[SLEProgressHUD shareView].window setHidden:NO];
        [[SLEProgressHUD shareView].sletimer fire];
        [[SLEProgressHUD shareView] getViewWithString:str withImage:@"angle-mask"];
        [SLEProgressHUD shareView].sle_progressHudStatus = kLoading;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SLEProgressHUD dismiss];
        });
    }
    
}


+ (void)showErrorWithString:(NSString *) str dismiss:(CGFloat)duration{
    
    
    if ([SLEProgressHUD shareView].sle_progressHudStatus == kLoading) {
        [SLEProgressHUD dismiss];
        [SLEProgressHUD showErrorWithString:str dismiss:duration];
        
    }else{
        
        [[SLEProgressHUD shareView].window setHidden:NO];
        [[SLEProgressHUD shareView] getViewWithString:str withImage:@"error"];
        [SLEProgressHUD shareView].sle_progressHudStatus = kLoading;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SLEProgressHUD dismiss];
        });
    }

}



+ (void)showSuccessWithString:(NSString *) str dismiss:(CGFloat)duration{
    
    
    if ([SLEProgressHUD shareView].sle_progressHudStatus == kLoading) {
        
        [[SLEProgressHUD shareView] dismiss];
        [SLEProgressHUD showSuccessWithString:str dismiss:duration];
        
    }else{
    
        [[SLEProgressHUD shareView].window setHidden:NO];
        [[SLEProgressHUD shareView] getViewWithString:str withImage:@"success"];
        [SLEProgressHUD shareView].sle_progressHudStatus = kLoading;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SLEProgressHUD dismiss];
        });
    }
    

}








@end
