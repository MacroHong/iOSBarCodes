//
//  MHScanViewController.h
//  MHBarCodesDemo
//
//  Created by Macro on 8/29/15.
//  Copyright © 2015 Macro. All rights reserved.
//

#import <UIKit/UIKit.h>
// 扫描页面
@interface MHScanViewController : UIViewController

@property (strong, nonatomic) void(^rebackData)(NSString *);

@end
