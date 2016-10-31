//
//  BigWheel.m
//  Wanna
//
//  Created by 周辉 on 2016/10/27.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "BigWheel.h"

@interface BigWheel () <
  UIPickerViewDelegate,
  UIPickerViewDataSource>

@property (nonatomic) UIPickerView *bigWheel;       // 咱的BigWheel
@property (nonatomic) UIView       *blackSeptember; // 轮子上方的黑条
@property (nonatomic) UIButton     *doneButton;     // 黑条上的完成按钮
@property (nonatomic) BOOL          isOnScreen;     // 是否在屏幕上显示

@end

@implementation BigWheel

#pragma mark - life cycle
- (id)init {
    if (self = [super init]) {
        _wheels         = [[NSArray alloc] init];
        _selectedIndex  = NSNotFound;
        _wheelID        = NSNotFound;
        _isOnScreen     = NO;
        self.frame      = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 400);
        
        [self addSubview:self.bigWheel];
        [self addSubview:self.tricycle];
        [self addSubview:self.blackSeptember];
        [self.blackSeptember addSubview:self.doneButton];
    }
    return self;
}

#pragma mark - UIPickerViewDelegate  & UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.wheels.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.wheels[row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedIndex = row;
    if (nil == self.rollingCallback) {
        return;
    }
    self.rollingCallback(row);
}
#pragma mark - event response
/// 点击完成的response
- (void)didClickDone: (UIButton *)button {
    if (nil == self.doneCallback) {
        return;
    }
    self.doneCallback(@[]);
}
/// datePicker 的 response
- (void)tiredForGoingOn: (UIDatePicker *)tricycle {
    if (nil == self.tiredCallback) {
        return;
    }
    NSDate *date = [self.tricycle date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [formatter stringFromDate:date];
    self.tiredCallback(dateString); // 将 date 传给 RN
}
#pragma mark - private methods
/// 弹出
- (void)show {
    /// 不加此限制则会重复添加轮子
    if (self.isOnScreen) {
        return;
    }
    [UIView animateWithDuration:0.2f
                          delay:0
                        options:UIViewAnimationOptionTransitionCurlUp
                     animations:^{
                         self.frame = CGRectMake(0, SCREEN_HEIGHT-315, SCREEN_WIDTH, 400); // 这个315不准啊，打假！打假！
                     } completion:^(BOOL finished) {
                         self.isOnScreen = YES;
                     }];
}
/// 隐藏到屏幕下面
- (void)hide {
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 400);
                     } completion:^(BOOL finished) {
                         self.isOnScreen = NO;
                         [self removeFromSuperview];
                     }];
}
#pragma mark - getters & setters
- (UIPickerView *)bigWheel {
    if (_bigWheel == nil) {
        _bigWheel = [[UIPickerView alloc] init];
        _bigWheel.delegate = self;
        _bigWheel.dataSource = self;
        _bigWheel.frame = CGRectMake(0, 50, SCREEN_WIDTH, 300);
    }
    return _bigWheel;
}
/// 完成 button 贴在 blackSeptember上
- (UIView *)blackSeptember {
    if (_blackSeptember == nil) {
        _blackSeptember = [[UIView alloc] init];
        _blackSeptember.backgroundColor = [UIColor blackColor];
        _blackSeptember.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
    }
    return _blackSeptember;
}
- (UIButton *)doneButton {
    if (_doneButton == nil) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneButton.frame = CGRectMake(SCREEN_WIDTH-80, 5, 70, 40);
        [_doneButton setTitle:@"完成" forState: UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneButton addTarget:self
                        action:@selector(didClickDone:)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}
/// datePicker，默认隐藏
- (UIDatePicker *)tricycle {
    if (_tricycle == nil) {
        _tricycle                   = [[UIDatePicker alloc] init];
        _tricycle.hidden            = YES;
        _tricycle.datePickerMode    = UIDatePickerModeDate;
        _tricycle.backgroundColor   = [UIColor whiteColor];
        _tricycle.frame             = CGRectMake(0, 50, SCREEN_WIDTH, 300);
        _tricycle.locale            = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [_tricycle addTarget:self
                      action:@selector(tiredForGoingOn:)
            forControlEvents:UIControlEventValueChanged];
    }
    return _tricycle;
}
/// setter 方法将轮子初始化到指定位置
- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (_selectedIndex != selectedIndex) {
        BOOL animated  = _selectedIndex != NSNotFound; // Don't animate the initial value
        _selectedIndex = selectedIndex;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.bigWheel selectRow:selectedIndex
                         inComponent:0
                            animated:animated];
        });
    }
}
- (void)setWheels:(NSArray *)wheels {
    _wheels = wheels;
    [self.bigWheel reloadAllComponents];
}
/// 通过isTricycle属性来实现 datePicker的隐藏与否
- (void)setIsTricycle:(BOOL)isTricycle {
    _isTricycle = isTricycle;
    if (isTricycle) {
        self.tricycle.hidden = NO;
    } else {
        self.tricycle.hidden = YES;
    }
}
/// 设置指定日期
- (void)setSelectedTricycle:(NSString *)selectedTricycle {
    _selectedTricycle = selectedTricycle;
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
     [dateFormatter setDateFormat: @ "yyyy-MM-dd"];
     NSDate * date = [dateFormatter dateFromString:selectedTricycle];
     if (date != nil) {
         [self.tricycle setDate: date
                       animated: YES];
     }
}
@end
