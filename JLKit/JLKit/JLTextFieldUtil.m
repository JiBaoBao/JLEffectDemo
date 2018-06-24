//
//  JLTextFieldUtil.m
//  JLKit
//
//  Created by JiBaoBao on 2018/6/24.
//  Copyright © 2018年 JiBaoBao. All rights reserved.
//

#import "JLTextFieldUtil.h"

@implementation JLTextFieldUtil

/**
 金钱输入 合法性检验
 
 规则：只能是0-9数字，最多输入9位，最多两位小数，小数点后不能在出现小数点
 （0:空格键  46:"."   48:"0"   57:"9"）
 */
+ (BOOL)validateAmountWithTextField:(UITextField *)textField range:(NSRange )range replacementString:(NSString *)string {
    // 即将输入的下一个字符
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    const char * ch=[string cStringUsingEncoding:NSASCIIStringEncoding];
    
    /** 是否可输入 */
    if (*ch==0)return YES;
    if ((textField.text.length==1) && [textField.text isEqualToString:@"0"]){// 首字符0，后续只能输入 “.”
        if ([string isEqualToString:@"."]) return YES;
        else return NO;
    }
    if (toBeString.length>9) return NO; //大于9位数
    if((*ch != 46) && (*ch<48 || *ch>57)) return NO; // 只可以输入：“.”、0-9的数字
    if([textField.text rangeOfString:@"."].length==1){ // 有了小数点
        NSUInteger length=[textField.text rangeOfString:@"."].location;
        // 小数点后面两位小数 且不能再是小数点
        if([[textField.text substringFromIndex:length] length]>2 || *ch ==46) return NO;
    }
    return YES;
}


+ (BOOL)formatPhone_addBlankWithtextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [self jl_addBlankWithtextField:textField shouldChangeCharactersInRange:range replacementString:string isPhone:YES];
}

+ (BOOL)formatBankCard_addBlankWithtextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [self jl_addBlankWithtextField:textField shouldChangeCharactersInRange:range replacementString:string isPhone:NO];
}


#pragma mark - private method

+ (BOOL)jl_addBlankWithtextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string isPhone:(BOOL)isPhone {
    NSString *text = [textField text];
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789\b"];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) {
        return NO;
    }
    text = [text stringByReplacingCharactersInRange:range withString:string];
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (isPhone) {
        // 如果是电话号码格式化，需要添加这三行代码
        NSMutableString *temString = [NSMutableString stringWithString:text];
        [temString insertString:@" " atIndex:0];
        text = temString;
    }
    
    NSString *newString = @"";
    while (text.length > 0) {
        NSString *subString = [text substringToIndex:MIN(text.length, 4)];
        newString = [newString stringByAppendingString:subString];
        if (subString.length == 4) {
            newString = [newString stringByAppendingString:@" "];
        }
        text = [text substringFromIndex:MIN(text.length, 4)];
    }
    newString = [newString stringByTrimmingCharactersInSet:[characterSet invertedSet]];
    NSInteger limitCount = isPhone? 13:23;
    if (newString.length >= limitCount) {
        newString = [newString substringToIndex:limitCount];
    }
    [textField setText:newString];
    return NO;
}

+ (void)jl_addValueChangeWithTextField:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:nil];
    [textField sendActionsForControlEvents:UIControlEventEditingChanged];
}


@end
