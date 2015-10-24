//
//  FrostedView.m
//  MHFrostedGlassDemo
//
//  Created by MacroHong on 9/2/15.
//  Copyright © 2015 MacroHong. All rights reserved.
//

#import "FrostedView.h"

#define kWidth [[UIScreen mainScreen] bounds].size.width
#define kHeight [[UIScreen mainScreen] bounds].size.height

@interface FrostedView ()
{
    CGRect _translucentRect;
    UIImageView *_scanLine;
    BOOL _scanDirection;
}
@end

@implementation FrostedView

- (instancetype)initWithTranslucentRect:(CGRect)translucentRect {
    self = [super init];
    if (self) {
        // init code
        _translucentRect = translucentRect;
        UIImage *img = [UIImage imageNamed:@"扫描线"];
        _scanLine = [[UIImageView alloc] initWithFrame:CGRectMake(translucentRect.origin.x, translucentRect.origin.y, translucentRect.size.width, 5)];
        _scanLine.image = img;
        _scanDirection = YES;
        [self addSubview:_scanLine];
        [self config];
    }
    return self;
}

- (void)config {
    self.frame = CGRectMake(0, 0, kWidth, kHeight);
    self.backgroundColor = [UIColor clearColor];
    
    UIColor *color = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    
    CGFloat X = _translucentRect.origin.x;
    CGFloat Y = _translucentRect.origin.y;
    CGFloat W = _translucentRect.size.width;
    CGFloat H = _translucentRect.size.height;
    
    // add top view
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, Y)];
    topView.backgroundColor = color;
    [self addSubview:topView];
    
    // add bottom view
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, Y + H, kWidth, kHeight - Y - H)];
    bottomView.backgroundColor = color;
    [self addSubview:bottomView];
    
    // add left view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, Y, X, H)];
    leftView.backgroundColor = color;
    [self addSubview:leftView];
    
    // add right view
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(X + W, Y, kWidth - X - W, H)];
    rightView.backgroundColor = color;
    [self addSubview:rightView];
    
    // add scanView bounds
    UIImage *image = [UIImage imageNamed:@"扫描框"];
    image = [image stretchableImageWithLeftCapWidth:floorf(image.size.width/2) topCapHeight:floorf(image.size.height/2)];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:_translucentRect];
    iv.image = image;
    [self addSubview: iv];
    
    [NSTimer scheduledTimerWithTimeInterval:0.005 target:self selector:@selector(changeScanLine) userInfo:nil repeats:YES];

}

- (void)changeScanLine {
    CGRect oldFrame = _scanLine.frame;
    if (oldFrame.origin.y + oldFrame.size.height > _translucentRect.origin.y + _translucentRect.size.height || oldFrame.origin.y < _translucentRect.origin.y) {
        _scanDirection = !_scanDirection;
    }
    _scanLine.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y + (_scanDirection ? 1 : -1), oldFrame.size.width, oldFrame.size.height);
}

@end
