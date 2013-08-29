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

@property (readonly, assign, nonatomic) CGFloat openXOffset;
@property (readonly, assign, nonatomic) CGFloat closedXOffset;

@property (assign, nonatomic) BOOL snapping;

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

    // add some extra content so we can bounce and scroll the content view out of frame
    CGSize contentSize = self.frame.size;
    contentSize.width += (CGRectGetMaxX(self.button1.frame) - CGRectGetMinX(self.button2.frame));
    self.contentScrollView.contentSize = contentSize;
}

#pragma mark - Properties

- (CGFloat)openXOffset
{
    // fully open offest reveals button 1 and 2
    return self.frame.size.width - CGRectGetMinX(self.button2.frame);
}

- (CGFloat)closedXOffset
{
    //fully closed is no offset
    return 0.0;
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
    
    CGFloat xBoundary = self.frame.size.width - CGRectGetMinX(self.button1.frame);
    
    if ( contentOffset.x >= xBoundary )
    {
        //NSLog(@"FORCING OPEN");
        contentOffset.x = self.openXOffset;
    }
    else
    {
        //NSLog(@"FORCING CLOSED");
        contentOffset.x = self.closedXOffset;
    }
    
    if ( !self.snapping ) [scrollView setContentOffset:contentOffset animated:YES];
    self.snapping = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"Did end decelerating");
}

- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    self.snapping = NO;
    
    if ( velocity.x < 0.0 )
    {
        if ( velocity.x > -0.5 )
        {
            NSLog(@"SNAPPING SHUT!");
            targetContentOffset->x = scrollView.contentOffset.x;
            [scrollView setContentOffset:(CGPoint){self.closedXOffset, 0.0} animated:YES];
            self.snapping = YES;
        }
    }
    else if ( velocity.x > 0.0 )
    {
        if ( velocity.x < 0.5 )
        {
            NSLog(@"SNAPPING OPEN!");
            targetContentOffset->x = scrollView.contentOffset.x;
            [scrollView setContentOffset:(CGPoint){self.openXOffset, 0.0} animated:YES];
            self.snapping = YES;
        }
    }
    
}

@end
