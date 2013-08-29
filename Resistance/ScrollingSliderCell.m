//
//  ScrollingSliderCell.m
//  Resistance
//
//  Created by 23 on 8/25/13.
//  Copyright (c) 2013 Aged and Distilled. All rights reserved.
//

#import "ScrollingSliderCell.h"

@interface DebuggingScrollView : UIScrollView

@end


@implementation DebuggingScrollView

- (void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    NSLog(@"Content size was set: %f,%f", contentSize.width, contentSize.height);
}

@end

@interface ScrollingSliderCell () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIView *slidingContentView;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;

@end


@implementation ScrollingSliderCell

#pragma mark - Life cycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self )
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self )
    {
        [self commonInit];
    }
    return self;
}


- (void) commonInit
{
    
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGSize contentSize = self.frame.size;
    contentSize.width += 160.0;
        // 160 is the width of our buttons, but you'd want to commute
        // this rather than use a magic #
    self.contentScrollView.contentSize = contentSize;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"Scrollview scrolled offset %f, %f", scrollView.contentOffset.x, scrollView.contentOffset.y);
    
    // prevent scrolling to the right
    if ( scrollView.contentOffset.x < 0.0 )
    {
        CGPoint offset = scrollView.contentOffset;
        offset.x = 0.0;
        scrollView.contentOffset = offset;
    }
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ( decelerate ) return;
    
    CGPoint contentOffset = scrollView.contentOffset;

    // snap open or shut depending on where scrolling finished
    // Using button 1 / button 2 boundary as the deciding line between open or shut
    
    CGFloat xClosed = 0.0;
    CGFloat xOpen = self.frame.size.width - CGRectGetMinX(self.button2.frame);
    CGFloat xBoundary = self.frame.size.width - CGRectGetMinX(self.button1.frame);
    
    if ( contentOffset.x >= xBoundary )
    {
        contentOffset.x =xOpen;
    }
    else
    {
        contentOffset.x = xClosed;
    }
    
    [scrollView setContentOffset:contentOffset animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"Did end decelerating");
}

- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    //NSLog(@"Will end dragging");
}

@end
