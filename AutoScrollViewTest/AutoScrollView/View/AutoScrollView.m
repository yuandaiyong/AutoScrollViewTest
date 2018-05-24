//
//  AutoScrollView.m
//  AutoScrollViewTest
//
//  Created by Clover on 2018/5/14.
//  Copyright © 2018年 Clover. All rights reserved.
//

#import "AutoScrollView.h"
#import "UIImageView+WebCache.h"
@interface AutoScrollView()
<UIScrollViewDelegate>

@property (nonatomic,strong) UIScrollView              *scrollView;
@property (nonatomic,strong) UIPageControl              *pageControl;
@property (nonatomic,strong) UIView                     *titleBgView;
@property (nonatomic,strong) UILabel                    *titleLable;
@property (nonatomic,strong) NSTimer                    *scrollTimer;
@property (nonatomic,assign) NSInteger                  pageIndex;

@end

@implementation AutoScrollView

//初始化UIScrollView
- (UIScrollView *)scrollView {
    if(!_scrollView) {
        
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        if(@available(iOS 11.0,*)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

//初始化UIPageControl
- (UIPageControl *)pageControl {
    if(!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.backgroundColor = [UIColor clearColor];
        _pageControl.currentPageIndicatorTintColor = [[UIColor grayColor] colorWithAlphaComponent:.8];
        _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.hidesForSinglePage = YES;
        [self.titleBgView addSubview:_pageControl];
    }
    return _pageControl;
}

- (UILabel *)titleLable {
    if(!_titleLable) {
        _titleLable = [[UILabel alloc] init];
        _titleLable.font = [UIFont systemFontOfSize:13];
        _titleLable.textColor = [UIColor whiteColor];
        _titleLable.minimumScaleFactor = .7;
        _titleLable.adjustsFontSizeToFitWidth = YES;
        [self.titleBgView addSubview:_titleLable];
    }
    return _titleLable;
}

- (UIView *)titleBgView {
    
    if(!_titleBgView) {
        _titleBgView = [[UIView alloc] init];
        [self addSubview:_titleBgView];
    }
    return _titleBgView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    
    [self reloadImages];
}

- (UIImageView *)createImageView:(CGRect)frame {
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
    imgView.backgroundColor = [UIColor clearColor];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    return imgView;
}

//数据发生变化后,调用该方法刷新UI
- (void)reloadImages {
    
    self.pageIndex = 0;
    
    //重置UIScrollView
    
    [self reloadScroll];
    
    self.titleBgView.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 20, CGRectGetWidth(self.frame), 20);
    
    //重置UIPageControl
    CGSize size = [self.pageControl sizeForNumberOfPages:self.images.count];
    self.pageControl.frame = CGRectMake(CGRectGetWidth(self.titleBgView.frame) - size.width - 5,0, size.width, CGRectGetHeight(self.titleBgView.frame));
    self.pageControl.numberOfPages = self.images.count;
    self.pageControl.currentPage = 0;
    [self bringSubviewToFront:self.pageControl];
    
    if(self.showTitle) {
        self.titleBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
        self.titleLable.frame = CGRectMake(5, 0, CGRectGetWidth(self.titleBgView.frame) - size.width - 15, CGRectGetHeight(self.titleBgView.frame));
    }else{
        self.titleBgView.backgroundColor = [UIColor clearColor];
        self.titleLable.frame = CGRectZero;
        self.titleLable.text = @"";
    }
    
    if(self.scrollTimer) {
        if([self.scrollTimer isValid]) {
            [self.scrollTimer invalidate];
        }
        self.scrollTimer = nil;
    }
    
    if(self.images.count > 1 && self.scrollInterval > 1.) {
        self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.scrollInterval target:self selector:@selector(handlerScrollTimer) userInfo:nil repeats:YES];
    }
}

//自动滚动事件处理
- (void)handlerScrollTimer {
    
    self.pageIndex += 1;
    if(self.pageIndex >= self.images.count) {
        self.pageIndex = 0;
    }
    [UIView animateWithDuration:.25 animations:^{
        self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame) * 2, 0);
    } completion:^(BOOL finished) {
        [self refreshScrollView:self.pageIndex];
    }];
}

//重置UIScrollView的contentSize,并删除就得UIImageView，添加新的UIImageView
- (void)reloadScroll {
    
    for(UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    if(self.images.count <= 0) {
        return;
    }
    if(self.images.count <= 1) {
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        self.scrollView.bounces = NO;
        UIImageView *imageView = [self createImageView:self.scrollView.bounds];
        imageView.tag = 1000;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedImage:)];
        [imageView addGestureRecognizer:imageTap];
        [self.scrollView addSubview:imageView];
        ScrollImageModel *imageModel = self.images[0];
        if(imageModel.image_url.length > 0) {
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageModel.image_url]];
        }else if(imageModel.image_path.length > 0) {
            [imageView setImage:[UIImage imageNamed:imageModel.image_path]];
        }
        
    }else{
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) * 3, CGRectGetHeight(self.scrollView.frame));
        for(int i = 0;i < 3;i ++) {
            UIImageView *imageView = [self createImageView:CGRectMake(CGRectGetWidth(self.scrollView.frame) * i, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame))];
            imageView.tag = 1000 + i;
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedImage:)];
            [imageView addGestureRecognizer:imageTap];
            [self.scrollView addSubview:imageView];
        }
        
        [self refreshScrollView:0];
    }
}


//刷新UI,将当前显示的图片放到UIScrollView的第二页,UIScrollView的第一页显示上一个图片,UIScrollView的
//第三页显示下一个图片
- (void)refreshScrollView:(NSInteger)index {
    self.pageIndex = index;
    if(index >= self.images.count) {
        self.pageIndex = 0;
    }
    
    if(index < 0) {
        self.pageIndex = self.images.count - 1;
    }
    
    UIImageView *firstImgView = (UIImageView *)[self.scrollView viewWithTag:1000];
    UIImageView *secondImgView = (UIImageView *)[self.scrollView viewWithTag:1001];
    UIImageView *thirdImgView = (UIImageView *)[self.scrollView viewWithTag:1002];
    
    NSInteger lastIndex = self.pageIndex - 1;
    NSInteger nextIndex = self.pageIndex + 1;
    if(lastIndex < 0) {
        lastIndex = self.images.count - 1;
    }
    if(nextIndex >= self.images.count) {
        nextIndex = 0;
    }
    ScrollImageModel *lastModel = self.images[lastIndex];
    ScrollImageModel *nextModel = self.images[nextIndex];
    ScrollImageModel *currentModel = self.images[self.pageIndex];
    if(lastModel.image_url.length > 0){
        [firstImgView sd_setImageWithURL:[NSURL URLWithString:lastModel.image_url]];
    }else if(lastModel.image_path.length > 0) {
        [firstImgView setImage:[UIImage imageNamed:lastModel.image_path]];
    }
    
    if(nextModel.image_url.length > 0){
        [thirdImgView sd_setImageWithURL:[NSURL URLWithString:nextModel.image_url]];
    }else if(nextModel.image_path.length > 0) {
        [thirdImgView setImage:[UIImage imageNamed:nextModel.image_path]];
    }
    
    if(currentModel.image_url.length > 0){
        [secondImgView sd_setImageWithURL:[NSURL URLWithString:currentModel.image_url]];
    }else if(currentModel.image_path.length > 0) {
        [secondImgView setImage:[UIImage imageNamed:currentModel.image_path]];
    }
    
    self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
    
    self.pageControl.currentPage = self.pageIndex;
    
    if(self.showTitle &&
       currentModel.title.length > 0) {
        self.titleLable.text = currentModel.title;
    }
}

- (void)selectedImage:(UITapGestureRecognizer *)tapGesture {
    if(self.pageIndex < 0 ||
       self.pageIndex >= self.images.count) {
        return;
    }
    ScrollImageModel *imageModel = self.images[self.pageIndex];
    if(self.delegate && [self.delegate respondsToSelector:@selector(autoScrollView:selectedImage:)]) {
        [self.delegate autoScrollView:self selectedImage:imageModel];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate 滚动处理

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if(self.scrollTimer) {
        if([self.scrollTimer isValid]) {
            [self.scrollTimer invalidate];
        }
        self.scrollTimer = nil;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        NSInteger index = self.scrollView.contentOffset.x / CGRectGetWidth(self.scrollView.frame);
        if(index == 0) {
            NSInteger pageIndex = self.pageIndex - 1;
            [self refreshScrollView:pageIndex];
        }else if(index == 2) {
            NSInteger pageIndex = self.pageIndex + 1;
            [self refreshScrollView:pageIndex];
        }
        
        if(self.images.count > 1 && self.scrollInterval > 1.) {
            self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.scrollInterval target:self selector:@selector(handlerScrollTimer) userInfo:nil repeats:YES];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = self.scrollView.contentOffset.x / CGRectGetWidth(self.scrollView.frame);
    if(index == 0) {
        NSInteger pageIndex = self.pageIndex - 1;
        [self refreshScrollView:pageIndex];
    }else if(index == 2) {
        NSInteger pageIndex = self.pageIndex + 1;
        [self refreshScrollView:pageIndex];
    }
    if(self.images.count > 1 && self.scrollInterval > 1.) {
        self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.scrollInterval target:self selector:@selector(handlerScrollTimer) userInfo:nil repeats:YES];
    }
}

@end
