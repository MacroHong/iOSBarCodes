# iOSBarCodes

#系统的条码扫描   二维码和条形码

###调用:
###    MHScanViewController *scanVC = [[MHScanViewController alloc] init];
###    scanVC.rebackData = ^(NSString *retStr) {
###        NSLog(@"回传过来的的扫面结果%@", retStr);
###    };
###    [self presentViewController:scanVC animated:YES completion:nil];
