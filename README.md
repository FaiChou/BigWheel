## Picker的 ReactNative 封装

### 前言

> 封装 Picker，学习 ReactNative。

> 页面比较简单，身高体重生日的滚动选择，封装成`BigWheel`。

> `BigWheel` 是通过 Objective-C 写的给 ReactNative 用的一个小控件。参考 [Facebook 代码][2]（说抄也不为过）。

### 食用方法

```

import BigWheel from './BigWheel';

BigWheel.showBigWheelWithOptions({
	options: ['1', '2', '3'], 	// 共有三个选项 1, 2, 3
	selectedWheel: '2',			// 控件被调用时候默认选中的 index
}, (buttonIndex) => { 			// 选中的回调
	console.log(buttonIndex);
}, () => { 						// 点击完成的回调
	// done
});

```

此食用方法是错误的示范，因为在写代码过程中踩了几个坑，以至于不得不换一种方式来实现。初心如此，就是想这么调用，也遵循了一定的封装的原则，就像当初 [Roy Fielding博士][3]设计 [REST][4]风格的软件架构模式一样，虽然不可比，膜拜还是要有的。



### 效果图

![BigWheel][1]

### 设计思路

- 如何实现类似 `alert.show()` 点语法调用

**objects**

```

var alert = {
	show() {

	},
	hide() {

	},
}

```

- 原生如何暴露给 RN

**RCTBridge**

```
#import <UIKit/UIKit.h>

#import "RCTBridge.h"

@interface RCTBigWheelManager : NSObject <RCTBridgeModule>

@end

```

- Picker 间切换是怎么实现的？

```

var WHEEL_DID_SELECTED = { 
  NONE: 0,
  HEIGHT: 2,
  WEIGHT: 4,
  DOB: 8,
};
	  if (this.state.pSelected == WHEEL_DID_SELECTED.HEIGHT) { // 假设当前身高轮已经 show
        return;												   // 当再点击身高时候直接 return
 	  }
      if (this.state.pSelected != WHEEL_DID_SELECTED.NONE) {   // 如果有轮子已经 show 了
        BigWheel.dismissBigWheel();							   // 隐藏已经show 的那个
      }
      this.setState({										   // setState()
        pSelected: WHEEL_DID_SELECTED.HEIGHT,
      });
      BigWheel.show();											// show

```

- 轮子的 view 是怎么实现 show 和 hide？

```

self.frame = CGRectMake(0, SCREEN_HEIGHT-315, SCREEN_WIDTH, 400); // show animate

self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 400);	  // hide animate

```

- 回调函数

```
/// 点击完成的response
- (void)didClickDone: (UIButton *)button {
    if (nil == self.doneCallback) {
        return;
    }
    self.doneCallback(@[]);
}

/// picker 暂停（即选中）的回调
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedIndex = row;
    if (nil == self.rollingCallback) {
        return;
    }
    self.rollingCallback(row);
}

```

- 为什么将 rollingCallback 的实现改为通知了？而不是 RN 的方法？

`RCTResponseSenderBlock`传过来的 block只能调用一次！！！ 

- 参数的传递过程

```
	  /// 将 object {}传给 BigWheel.js
 	  BigWheel.showBigWheelWithOptions({
        isTricycle: false,
        wheels: WHEELS_HEIGHT,
        selectedWheel: WHEELS_HEIGHT.indexOf(this.state.pHeight),
        wheelID: WHEEL_DID_SELECTED.HEIGHT,
      }, () => {
        console.log('完成');
        BigWheel.dismissBigWheel();
        this.setState({
          pSelected: WHEEL_DID_SELECTED.NONE,
        });
      });
  /// 将 options 展开再整合成 object
  showBigWheelWithOptions(
    options: Object,
    doneCallback: Function
  ) {
    RCTBigWheelManager.showBigWheelWithOptions({...options
      },
      doneCallback
    );
  }
	
  /// oc 端解析
  showBigWheelWithOptions:(NSDictionary *)options
             doneCallback:(RCTResponseSenderBlock)doneCallback
             
```

### 代码地址

[github][5]



### 总结

> 多研究些问题，少谈些主义！-- 胡适





[1]: http://o7bkcj7d7.bkt.clouddn.com/BigWheel.gif
[2]: https://github.com/facebook/react-native/blob/efcdef711eba82b2905d237ee9a3d094652c37ac/Libraries/Components/Picker/PickerIOS.ios.js
[3]: https://en.wikipedia.org/wiki/Roy_Fielding
[4]: http://www.restapitutorial.com/
[5]: https://github.com/FaiChou/BigWheel
