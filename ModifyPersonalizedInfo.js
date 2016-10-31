/// FaiChou. 修改个性化资料. 2016-10-24

'use strict';

import React, {
  Component
} from 'react';
import {
  View,
  TouchableHighlight,
  Text,
  AppRegistry,
  StyleSheet,
  Image,
  ListView,
  NativeAppEventEmitter,
  Dimensions,
  ActionSheetIOS,

} from 'react-native';
import BigWheel from './BigWheel';
const ReactTool = require('react-native').NativeModules.WN_ReactTool;
const {
  width,
  height
} = Dimensions.get('window');

var SUBSCRIPTION_SAVE = null;
var SUBSCRIPTION_ROLL = null;
var CELL_HEIGHT = 58;
var LEADING_TEXT = ['性别', '身高', '体重', '生日'];
var SHEET_OPTIONS = ['男', '女', '取消'];
var WHEELS_HEIGHT = []; // 身高数组
for (let i = 124; i < 262; i++) {
  WHEELS_HEIGHT.push(i.toString());
}
var WHEELS_WEIGHT = []; // 体重数组
var weight = 24.0;
for (let i = 24; i < 1285; i++) {
  weight = weight + 0.1;
  // weight = weight.toFixed(1); // 浮点数精确到 0.1，不用 toFixed()则会成为24.00000000000009..
  // toFixed(1) -> return string
  WHEELS_WEIGHT.push(weight.toFixed(1));
}
var WHEEL_DID_SELECTED = {
  NONE: 0,
  HEIGHT: 2,
  WEIGHT: 4,
  DOB: 8,
};

export default class ModifyPersonalizedInfo extends Component {
  constructor(props) {
    super(props);
    console.log('修改个性化资料-constructor');

    const ds = new ListView.DataSource({
      rowHasChanged: (r1, r2) => r1 !== r2,
    });
    this.state = {
      pSex: '',
      pHeight: '',
      pWeight: '',
      pDob: '',
      pSelected: WHEEL_DID_SELECTED.NONE,
      dataSource: ds.cloneWithRows(['', '', '', '']),
    };
  }
  componentWillMount() {
    console.log('修改个性化资料-componentWillMount');
    ReactTool.showHub();
    SUBSCRIPTION_SAVE = NativeAppEventEmitter.addListener('ModifyPersonalizedInfo', () => {
      ReactTool.savePersonalizedInfo(this.state.pSex, this.state.pHeight, this.state.pWeight, this.state.pDob);
    });
    SUBSCRIPTION_ROLL = NativeAppEventEmitter.addListener('BigWheelRoll', (reminder) => {
      console.log(reminder);
      if (reminder.wheelID == WHEEL_DID_SELECTED.HEIGHT) {
        this.setState({
          pHeight: WHEELS_HEIGHT[reminder.index],
          dataSource: this.state.dataSource.cloneWithRows([this.state.pSex,
            `${WHEELS_HEIGHT[reminder.index]}cm`,
            `${this.state.pWeight}kg`,
            this.state.pDob
          ]),
        });
      } else if (reminder.wheelID == WHEEL_DID_SELECTED.WEIGHT) {
        this.setState({
          pWeight: WHEELS_WEIGHT[reminder.index],
          dataSource: this.state.dataSource.cloneWithRows([this.state.pSex,
            `${this.state.pHeight}cm`,
            `${WHEELS_WEIGHT[reminder.index]}kg`,
            this.state.pDob
          ]),
        });
      } else if (reminder.wheelID == WHEEL_DID_SELECTED.DOB) {
        this.setState({
          pDob: reminder.dob,
          dataSource: this.state.dataSource.cloneWithRows([this.state.pSex,
            `${this.state.pHeight}cm`,
            `${this.state.pWeight}kg`,
            reminder.dob
          ]),
        });
      }

    });
    ReactTool.getPersonalizedInfo((gender, height, weight, dob) => {
      this.setState({
        pSex: gender,
        pHeight: height,
        pWeight: weight,
        pDob: dob,
        dataSource: this.state.dataSource.cloneWithRows([gender,
          `${height}cm`,
          `${weight}kg`,
          dob
        ]),
      });
      ReactTool.hideHub();
    });
  }
  componentWillUnmount() {
    console.log('修改个性化资料-componentWillUnmount');
    SUBSCRIPTION_SAVE.remove();
    SUBSCRIPTION_ROLL.remove();
  }
  onTapRow = (id) => {
    if (id == 0) {
      // console.log(`${typeof(id)}----${id}`);
      ActionSheetIOS.showActionSheetWithOptions({
          options: SHEET_OPTIONS,
          cancelButtonIndex: 2,
        },
        (index) => {
          if (index == 2) {
            return;
          }
          this.setState({
            pSex: SHEET_OPTIONS[index],
            dataSource: this.state.dataSource.cloneWithRows([SHEET_OPTIONS[index],
              `${this.state.pHeight}cm`,
              `${this.state.pWeight}kg`,
              this.state.pDob
            ]),
          });
        });
    } else if (id == 1) {
      /// 下面几个判读真麻烦
      if (this.state.pSelected == WHEEL_DID_SELECTED.HEIGHT) {
        return;
      }
      if (this.state.pSelected != WHEEL_DID_SELECTED.NONE) {
        BigWheel.dismissBigWheel();
      }
      this.setState({
        pSelected: WHEEL_DID_SELECTED.HEIGHT,
      });
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
    } else if (id == 2) {
      if (this.state.pSelected == WHEEL_DID_SELECTED.WEIGHT) {
        return;
      }
      if (this.state.pSelected != WHEEL_DID_SELECTED.NONE) {
        BigWheel.dismissBigWheel();
      }
      this.setState({
        pSelected: WHEEL_DID_SELECTED.WEIGHT,
      });
      BigWheel.showBigWheelWithOptions({
        isTricycle: false,
        wheels: WHEELS_WEIGHT,
        selectedWheel: WHEELS_WEIGHT.indexOf(this.state.pWeight),
        wheelID: WHEEL_DID_SELECTED.WEIGHT,
      }, () => {
        BigWheel.dismissBigWheel();
        this.setState({
          pSelected: WHEEL_DID_SELECTED.NONE,
        });
      });
    } else if (id == 3) {
      if (this.state.pSelected == WHEEL_DID_SELECTED.DOB) {
        return;
      }
      if (this.state.pSelected != WHEEL_DID_SELECTED.NONE) {
        BigWheel.dismissBigWheel();
      }
      this.setState({
        pSelected: WHEEL_DID_SELECTED.DOB,
      });
      BigWheel.showBigWheelWithOptions({
        isTricycle: true,
        selectedTricycle: this.state.pDob,
        wheelID: WHEEL_DID_SELECTED.DOB,
      }, () => {
        BigWheel.dismissBigWheel();
      });
    }
  };
  render() {
    return ( 
      <ListView 
      contentContainerStyle = {
        styles.contentContainer
      }
      dataSource = {
        this.state.dataSource
      }
      renderRow = {
        (rowData, sectionId, rowId) =>
        <TouchableHighlight
            onPress = { ()=>this.onTapRow(rowId) }
            underlayColor = 'transparent'
            key = { rowId }
          >
            <View>
              <View style = { styles.setUpCell}>
                <View style = { styles.setUpCellContent }>
                  <Text style = { styles.setUpCellLeadingText }> { LEADING_TEXT[rowId] } </Text>
                  <Text style = { styles.setUpCellText}> { rowData } </Text>
                </View>
                <Image
                  source = { require('image!默认右箭头') }
                  style  = { styles.rightArrow }
                />
              </View>
              <View style = { styles.line }>
              </View>
            </View>
          </TouchableHighlight>
      }
      />
    );
  }
}

const styles = StyleSheet.create({
  contentContainer: {
    flex: 1,
    backgroundColor: 'white',
  },
  setUpCell: {
    flexDirection: 'row',
    width: width,
    height: CELL_HEIGHT,
    alignItems: 'center',
  },
  line: {
    width: width,
    height: 0.5,
    backgroundColor: '#AAAAAA',
  },
  setUpCellContent: {
    flexDirection: 'row',
    width: width - 25,
    height: CELL_HEIGHT,
    alignItems: 'center',
  },
  rightArrow: {
    width: 6,
    height: 10,
    padding: 8,
    resizeMode: 'contain',
  },
  setUpCellLeadingText: {
    width: 80,
    height: 20,
    margin: 10,
    fontSize: 14,
  },
  setUpCellText: {
    width: 200,
    height: 33,
    margin: 10,
    fontSize: 14,
    textAlign: 'left',
    paddingTop: 7,
  }

});

AppRegistry.registerComponent('ModifyPersonalizedInfo', () => ModifyPersonalizedInfo);