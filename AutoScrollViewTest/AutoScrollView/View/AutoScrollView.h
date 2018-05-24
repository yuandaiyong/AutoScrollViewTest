//
//  AutoScrollView.h
//  AutoScrollViewTest
//
//  Created by Clover on 2018/5/14.
//  Copyright © 2018年 Clover. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScrollImageModel.h"

@class AutoScrollView;

@protocol AutoScrollViewDelegate<NSObject>

- (void)autoScrollView:(AutoScrollView *)scrollView selectedImage:(ScrollImageModel *)imageModel;

@end

@interface AutoScrollView : UIView

@property (nonatomic,strong) NSArray<ScrollImageModel *>    *images;
@property (nonatomic,assign) CGFloat                        scrollInterval;
@property (nonatomic,weak) id<AutoScrollViewDelegate>       delegate;
@property (nonatomic,assign) BOOL                           showTitle;

- (void)reloadImages;

@end
