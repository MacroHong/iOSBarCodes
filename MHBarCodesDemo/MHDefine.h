//
//  MacroDefine.h
//
//
//  Created by MacroHong on 15/5/22.
//  Copyright (c) 2015年 MacroHong. All rights reserved.
//

#ifndef Define_MacroDefine_h
#define Define_MacroDefine_h

#pragma mark - about screen

/*!
 *  @author Macro QQ:778165728, 15-05-22
 *
 *  @brief  获取屏幕宽度
 */
#define kWidth [[UIScreen mainScreen] bounds].size.width

/*!
 *  @author Macro QQ:778165728, 15-05-22
 *
 *  @brief  获取屏幕的高度
 */
#define kHeight [[UIScreen mainScreen] bounds].size.height

/*!
 *  @author Macro QQ:778165728, 15-06-26
 *
 *  @brief  屏幕中心点的横坐标
 */
#define kCenterX self.view.center.x

/*!
 *  @author Macro QQ:778165728, 15-06-26
 *
 *  @brief  屏幕中心点的纵坐标
 */
#define kCenterY self.view.center.y

#pragma mark - about device

#define IOS7 [[[UIDevice currentDevice] systemVersion]floatValue]>=7

#endif
