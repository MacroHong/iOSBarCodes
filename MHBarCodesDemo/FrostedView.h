//
//  FrostedView.h
//  MHFrostedGlassDemo
//
//  Created by MacroHong on 9/2/15.
//  Copyright © 2015 MacroHong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrostedView : UIView

/*!
 *  @author Macro QQ:778165728, 15-10-14
 *
 *  @brief  创建扫描界面
 *
 *  @param translucentRect 透明的矩形框
 *
 *  @return UIView
 */
- (instancetype)initWithTranslucentRect:(CGRect)translucentRect;

@end
