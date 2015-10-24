//
//  MHScanViewController.m
//  MHBarCodesDemo
//
//  Created by Macro on 8/29/15.
//  Copyright © 2015 Macro. All rights reserved.
//

#import "MHScanViewController.h"
#import "FrostedView.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "MHDefine.h"

enum {
    ALERTVIEWTAG = 1000,
};

@interface MHScanViewController ()<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UIAlertViewDelegate>
{
    AVCaptureVideoPreviewLayer *_captureVideoPreviewLayer;
    AVCaptureSession *_captureSession;
    UIButton *_cancelScanBtn;
}

@end

@implementation MHScanViewController

#pragma mark - vc life cycle

- (void)viewDidLoad {
    
    //get the authority of camera
    BOOL cameraIsAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
//    BOOL cameraIsAvailable = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];

    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    if (cameraIsAvailable && authStatus != AVAuthorizationStatusRestricted && authStatus != AVAuthorizationStatusDenied) {
        // camera is available and has the authority
        [self initCapture]; // 启动摄像头
    } else {
        // camera is not availble
        [self alertWithTitle:@"温馨提示" msg:@"请在设置中打开摄像头权限" btnTitle:@"确定"];
    }
    
    
    CGRect cropRect = CGRectMake(87, 100, 240, 240);
    
    FrostedView *frostedView = [[FrostedView alloc] initWithTranslucentRect:cropRect];
    [self.view addSubview:frostedView];
    
    UIButton *returnBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    returnBtn.frame = CGRectMake(kCenterX - 40, kCenterY + 50, 80, 25);
    returnBtn.backgroundColor = [UIColor lightGrayColor];
    [returnBtn setTitle:@"取消扫描" forState:(UIControlStateNormal)];
    [returnBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [returnBtn addTarget:self action:@selector(goBack) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:returnBtn];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - coding

- (void)initCapture {
    // capture session 数据的捕获,操作,输出
    _captureSession = [[AVCaptureSession alloc] init];
    // 捕获设备,这里是摄像头
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    AVCaptureDevice *inputDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];

    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    
    // 捕获设备的输入
    NSError *error = nil;
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    if (!error) {
        // 正常捕获数据
        [_captureSession addInput:captureInput]; // 将输入添加到session上
    } else {
        // 捕获数据失败
        [self alertWithTitle:@"警告" msg:@"手机摄像头捕获图像出现故障,请检查权限设置!" btnTitle:@"确定"];
    }
    if (IOS7) {
        // 捕获到的数据的输出
        AVCaptureMetadataOutput *captureOutput = [[AVCaptureMetadataOutput alloc] init];
        [captureOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        CGSize size = self.view.bounds.size;
        CGRect cropRect = CGRectMake(87, 100, 240, 240);
        CGFloat p1 = size.height/size.width;
        CGFloat p2 = 1920./1080.; //使用了1080p的图像输出
        if (p1 < p2) {
            CGFloat fixHeight = self.view.bounds.size.width * 1920. / 1080.;
            CGFloat fixPadding = (fixHeight - size.height)/2;
            captureOutput.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight, cropRect.origin.x/size.width, cropRect.size.height/fixHeight, cropRect.size.width/size.width);
        } else {
            CGFloat fixWidth = self.view.bounds.size.height * 1080. / 1920.;
            CGFloat fixPadding = (fixWidth - size.width)/2;
            captureOutput.rectOfInterest = CGRectMake(cropRect.origin.y/size.height, (cropRect.origin.x + fixPadding)/fixWidth, cropRect.size.height/size.height, cropRect.size.width/fixWidth);
        }
        
        
        [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
        [_captureSession addOutput:captureOutput];
        captureOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code];
        if (!_captureVideoPreviewLayer) {
            _captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
        }
        _captureVideoPreviewLayer.frame = self.view.bounds;
        _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.view.layer addSublayer:_captureVideoPreviewLayer];
        [_captureSession startRunning];
    } else {
        // 捕获媒体数据的输出
        AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
        captureOutput.alwaysDiscardsLateVideoFrames = YES;
        [captureOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        
        NSString* key = (NSString *)kCVPixelBufferPixelFormatTypeKey;
        NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
        NSDictionary *videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
        [captureOutput setVideoSettings:videoSettings];
        [_captureSession addOutput:captureOutput];
        
        NSString* preset = nil;
        if (NSClassFromString(@"NSOrderedSet") && // Proxy for "is this iOS 5" ...
            [UIScreen mainScreen].scale > 1 &&
            [inputDevice
             supportsAVCaptureSessionPreset:AVCaptureSessionPresetiFrame960x540]) {
                // NSLog(@"960");
                preset = AVCaptureSessionPresetiFrame960x540;
            }
        if (!preset) {
            // NSLog(@"MED");
            preset = AVCaptureSessionPresetMedium;
        }
        _captureSession.sessionPreset = preset;
        
        if (!_captureVideoPreviewLayer) {
            _captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
        }
        // NSLog(@"prev %p %@", self.prevLayer, self.prevLayer);
        _captureVideoPreviewLayer.frame = self.view.bounds;
        _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.view.layer addSublayer: _captureVideoPreviewLayer];
        
        [_captureSession startRunning];

    }
}

- (void)alertWithTitle:(NSString *)titleStr msg:(NSString *)msgStr btnTitle:(NSString *)btnTitle {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:titleStr message:msgStr delegate:self cancelButtonTitle:btnTitle otherButtonTitles:nil, nil];
    av.tag = ALERTVIEWTAG;
    [av show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ALERTVIEWTAG) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -btn action 
- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        NSLog(@"扫描页面里的扫描结果输出:%@", metadataObject.stringValue);
        self.rebackData(metadataObject.stringValue);
    }
    
    [_captureSession stopRunning];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
