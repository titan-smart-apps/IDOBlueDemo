//
//  SetDialParamViewModel.m
//  IDOBlue
//
//  Created by hedongyang on 2018/9/30.
//  Copyright © 2018年 hedongyang. All rights reserved.
//

#import "SetDialParamViewModel.h"
#import "FuncCellModel.h"
#import "OneButtonTableViewCell.h"
#import "EmpltyCellModel.h"
#import "EmptyTableViewCell.h"
#import "TextFieldCellModel.h"
#import "OneTextFieldTableViewCell.h"
#import "FuncViewController.h"

@interface SetDialParamViewModel()
@property (nonatomic,strong)IDOSetWatchDiaInfoBluetoothModel * watchDiaModel;
@property (nonatomic,copy)void(^buttconCallback)(UIViewController * viewController,UITableViewCell * tableViewCell);
@property (nonatomic,copy)void(^textFeildCallback)(UIViewController * viewController,UITextField * textField,UITableViewCell * tableViewCell);
@end

@implementation SetDialParamViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self getTextFieldCallback];
        [self getButtonCallback];
        [self getCellModels];
    }
    return self;
}

- (IDOSetWatchDiaInfoBluetoothModel *)watchDiaModel
{
    if (!_watchDiaModel) {
        _watchDiaModel = [IDOSetWatchDiaInfoBluetoothModel currentModel];
    }
    return _watchDiaModel;
}

- (void)getTextFieldCallback
{
    __weak typeof(self) weakSelf = self;
    self.textFeildCallback = ^(UIViewController *viewController, UITextField *textField, UITableViewCell *tableViewCell) {
        __strong typeof(self) strongSelf = weakSelf;
        FuncViewController * funcVC = (FuncViewController *)viewController;
        NSIndexPath * indexPath = [funcVC.tableView indexPathForCell:tableViewCell];
        TextFieldCellModel * textFieldModel = [strongSelf.cellModels objectAtIndex:indexPath.row];
        funcVC.pickerView.pickerArray = strongSelf.pickerDataModel.tenArray;
        funcVC.pickerView.currentIndex = [strongSelf.pickerDataModel.tenArray containsObject:@([textField.text intValue])] ? [strongSelf.pickerDataModel.tenArray indexOfObject:@([textField.text intValue])] : 0 ;
        [funcVC.pickerView show];
        funcVC.pickerView.pickerViewCallback = ^(NSString *selectStr) {
            textField.text = selectStr;
            textFieldModel.data = @[@([selectStr integerValue])];
            [[(FuncViewController *)viewController tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            strongSelf.watchDiaModel.dialId = [selectStr integerValue];
        };
    };
}

- (void)getButtonCallback
{
    __weak typeof(self) weakSelf = self;
    self.buttconCallback = ^(UIViewController *viewController, UITableViewCell *tableViewCell) {
        __strong typeof(self) strongSelf = weakSelf;
        FuncViewController * funcVC = (FuncViewController *)viewController;
        [funcVC showLoadingWithMessage:[NSString stringWithFormat:@"%@...",lang(@"set dial parameters")]];
        [IDOFoundationCommand setWatchDiaCommand:strongSelf.watchDiaModel
                                        callback:^(int errorCode) {
            if(errorCode == 0) {
                [funcVC showToastWithText:lang(@"set dial parameters success")];
            }else if (errorCode == 6) {
                [funcVC showToastWithText:lang(@"feature is not supported on the current device")];
            }else {
                [funcVC showToastWithText:lang(@"set dial parameters failed")];
            }
        }];
    };
}

- (void)getCellModels
{
    NSMutableArray * cellModels = [NSMutableArray array];
    
    TextFieldCellModel * model1 = [[TextFieldCellModel alloc]init];
    model1.typeStr = @"oneTextField";
    model1.titleStr = [NSString stringWithFormat:@"%@:",lang(@"set dial parameters")];
    model1.data = @[@(self.watchDiaModel.dialId)];
    model1.cellHeight = 70.0f;
    model1.cellClass = [OneTextFieldTableViewCell class];
    model1.modelClass = [NSNull class];
    model1.isShowLine = YES;
    model1.textFeildCallback = self.textFeildCallback;
    [cellModels addObject:model1];
    
    EmpltyCellModel * model2 = [[EmpltyCellModel alloc]init];
    model2.typeStr = @"empty";
    model2.cellHeight = 30.0f;
    model2.isShowLine = YES;
    model2.cellClass  = [EmptyTableViewCell class];
    [cellModels addObject:model2];
    
    FuncCellModel * model3 = [[FuncCellModel alloc]init];
    model3.typeStr = @"oneButton";
    model3.data = @[lang(@"set dial parameters")];
    model3.cellHeight = 70.0f;
    model3.cellClass = [OneButtonTableViewCell class];
    model3.modelClass = [NSNull class];
    model3.isShowLine = YES;
    model3.buttconCallback = self.buttconCallback;
    [cellModels addObject:model3];
    
    self.cellModels = cellModels;
}
@end
