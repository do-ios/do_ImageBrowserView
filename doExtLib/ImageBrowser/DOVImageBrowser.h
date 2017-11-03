//
//  ImageBrowser.h
//  TestImageBrowser
//
//  Created by MingerW on 15/5/6.
//  Copyright (c) 2015年 MingerW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "do_ImageBrowserView_UIView.h"
#import "do_ImageBrowserView_UIModel.h"

@protocol ImageBrowserDelegate <NSObject>
- (void)photoClick;
@end

@interface DOVImageBrowser : UIView

@property (nonatomic, weak) id<ImageBrowserDelegate> delegate;
@property (nonatomic, weak) UIView *sourceImagesContainerView;
@property (nonatomic, assign) NSInteger currentImageIndex;
@property (nonatomic , weak) do_ImageBrowserView_UIModel *browserModel;

- (void)fireEvent:(NSString *)eventName;
- (void)show:(NSArray *)pics :(NSInteger)index :(NSArray *)params;
- (void)clearContents:(NSArray *)subViews;
- (void)createContents;

@end
