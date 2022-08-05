//
//  UIView+BlocksKit.m
//  BlocksKit
//

#import "UIView+BlocksKit.h"
#import "UIGestureRecognizer+BlocksKit.h"

@implementation UIView (BlocksKit)

- (void)bk_whenTouches:(NSUInteger)numberOfTouches tapped:(NSUInteger)numberOfTaps handler:(void (^)(void))block
{
	if (!block) return;
	
	self.userInteractionEnabled = YES;
	
	UITapGestureRecognizer *gesture = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
		if (state == UIGestureRecognizerStateRecognized) block();
	}];
	
	gesture.numberOfTouchesRequired = numberOfTouches;
	gesture.numberOfTapsRequired = numberOfTaps;

	[self.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if (![obj isKindOfClass:[UITapGestureRecognizer class]]) return;

		UITapGestureRecognizer *tap = obj;
		BOOL rightTouches = (tap.numberOfTouchesRequired == numberOfTouches);
		BOOL rightTaps = (tap.numberOfTapsRequired == numberOfTaps);
		if (rightTouches && rightTaps) {
			[gesture requireGestureRecognizerToFail:tap];
		}
	}];

	[self addGestureRecognizer:gesture];
}

- (void)bk_whenTapped:(void (^)(void))block
{
	[self bk_whenTouches:1 tapped:1 handler:block];
}

- (void)bk_whenDoubleTapped:(void (^)(void))block
{
	[self bk_whenTouches:1 tapped:2 handler:block];
}

- (void)bk_eachSubview:(void (^)(UIView *subview))block
{
	NSParameterAssert(block != nil);

	[self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
		block(subview);
	}];
}

- (void)bk_whenLongPressed:(void (^)(void))longBlock tapped:(void (^)(void))tapBlock {
    if (!longBlock && !tapBlock) return;
    
    self.userInteractionEnabled = YES;

    UITapGestureRecognizer *gesture = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (state == UIGestureRecognizerStateRecognized) tapBlock();
    }];
    gesture.numberOfTouchesRequired = 1;
    gesture.numberOfTapsRequired = 1;
    
    [self.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[UITapGestureRecognizer class]]) return;
        
        UITapGestureRecognizer *tap = obj;
        BOOL rightTouches = (tap.numberOfTouchesRequired == 1);
        BOOL rightTaps = (tap.numberOfTapsRequired == 1);
        if (rightTouches && rightTaps) {
            [gesture requireGestureRecognizerToFail:tap];
        }
    }];
    if (tapBlock) {
        [self addGestureRecognizer:gesture];
    }

    UILongPressGestureRecognizer *longGesture = [UILongPressGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (state == UIGestureRecognizerStateRecognized) longBlock();
    }];
    if (longBlock) {
        [gesture requireGestureRecognizerToFail:longGesture];
        [self addGestureRecognizer:longGesture];
    }
}

@end
