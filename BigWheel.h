//
//  BigWheel.h
//  Wanna
//
//  Created by 周辉 on 2016/10/27.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^rollingCallback)(NSInteger);
typedef void (^tiredForThisBlock)(NSString *);
typedef void (^doneCallback)(NSArray *);

@interface BigWheel : UIView

@property (nonatomic) NSArray *wheels;                          // 所有的轮子
@property (nonatomic) NSInteger selectedIndex;                  // 默认选中的轮子 index
@property (nonatomic, copy) rollingCallback rollingCallback;    // didSelectRow回调
@property (nonatomic, copy) doneCallback doneCallback;          // 点击完成回调

@property (nonatomic) UIDatePicker *tricycle;                   // 三个轮子
@property (nonatomic, copy) tiredForThisBlock tiredCallback;    // datePicker 回调
@property (nonatomic) BOOL isTricycle;                          // 是否为 datePicker
@property (nonatomic) NSString *selectedTricycle;               // default

@property (nonatomic) NSInteger wheelID;                        // 区分轮子的 id号

- (void)show; // 弹出咱的 BigWheel
- (void)hide; // 隐藏

@end
