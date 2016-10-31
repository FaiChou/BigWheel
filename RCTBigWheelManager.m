//
//  RCTBigWheelManager.m
//  Wanna
//
//  Created by 周辉 on 2016/10/27.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "RCTBigWheelManager.h"

#import "RCTConvert.h"
#import "RCTLog.h"
#import "RCTUtils.h"
#import "RCTBridge.h"
#import "RCTUIManager.h"
#import "RCTEventDispatcher.h"

#import "BigWheel.h"

@interface RCTBigWheelManager ()

@property (nonatomic) BigWheel *bigWheel;

@end

@implementation RCTBigWheelManager

@synthesize bridge = _bridge;

/// 将此模块暴露给 RN
RCT_EXPORT_MODULE();

/// 方法放在主线程执行
- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(showBigWheelWithOptions:(NSDictionary *)options
                  doneCallback:(RCTResponseSenderBlock)doneCallback)
{
    if (RCTRunningInAppExtension()) { // 在 bundle @"appex" 中运行, 即 widget 扩展, 禁止
        RCTLogError(@" Unable to show BigWheel from app extension");
        return;
    }
    
    UIViewController *controller    = [self presentedViewController];
    UIView           *sourceView    = controller.view;
    
    BOOL isTricycle                 = [RCTConvert BOOL:options[@"isTricycle"]];
    NSString *selectedTricycle      = [RCTConvert NSString:options[@"selectedTricycle"]];
    /// 数组元素类型是 NSString *, -> 搜索 "OC 泛型"
    NSArray<NSString *> *wheels     = [RCTConvert NSStringArray:options[@"wheels"]];
    NSInteger selectedWheel         = [RCTConvert NSInteger:options[@"selectedWheel"]];
    NSInteger wheelID               = [RCTConvert NSInteger:options[@"wheelID"]];
    
    _bigWheel                       = [[BigWheel alloc] init];
    self.bigWheel.wheelID           = wheelID;
    self.bigWheel.doneCallback      = doneCallback;
    if (isTricycle) {
        self.bigWheel.isTricycle    = YES;
        self.bigWheel.selectedTricycle  = selectedTricycle;
        __weak typeof(self) weakSelf    = self;
        self.bigWheel.tiredCallback = ^(NSString *dateString) {
            [weakSelf.bridge.eventDispatcher sendAppEventWithName:@"BigWheelRoll"
                                                             body:@{
                                                                    @"dob": dateString,
                                                                    @"wheelID": @(weakSelf.bigWheel.wheelID)
                                                                    }];
        };
        [sourceView addSubview:self.bigWheel];
        [self.bigWheel show];
        return;
    }
    self.bigWheel.isTricycle        = NO;
    self.bigWheel.wheels            = wheels;
    self.bigWheel.selectedIndex     = selectedWheel;
//    self.bigWheel.rollingCallback   = rollingCallback; // 此方法行不通。改用通知吧。
    __weak typeof(self) weakSelf    = self;
    self.bigWheel.rollingCallback   = ^(NSInteger index) {
        [weakSelf.bridge.eventDispatcher sendAppEventWithName:@"BigWheelRoll"
                                                     body:@{
                                                            @"index":@(index),
                                                            @"wheelID":@(weakSelf.bigWheel.wheelID)
                                                            }];
    };
    
    
    [sourceView addSubview:self.bigWheel];
    [self.bigWheel show];
}
RCT_EXPORT_METHOD(dismissBigWheel)
{
    if (_bigWheel == nil) {
        return;
    }
    [_bigWheel hide];
    _bigWheel = nil;
}

/// 获取当前 ViewController
- (UIViewController *__nullable)presentedViewController {
    /**
     * 用以下注释的方法获取到的 controller 有坑
     */
//    UIViewController *controller = RCTKeyWindow().rootViewController;
//    
//    while (controller.presentedViewController) {
//        controller = controller.presentedViewController;
//    }
    UIViewController *controller = [WN_GlobalUtil getCurrentNavigationController].topViewController;
    
    return controller;
}

@end
