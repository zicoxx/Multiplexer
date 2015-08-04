#import "headers.h"

@interface RASwipeOverOverlay : UIAutoRotatingWindow <UIGestureRecognizerDelegate, UILongPressGestureRecognizerDelegate> {
	BOOL isHidingUnderlyingApp;

	UIView *darkenerView;
}
@property (nonatomic, retain) UIView *grabberView;

-(BOOL) isHidingUnderlyingApp;
-(void) showEnoughToDarkenUnderlyingApp;
-(void) removeOverlayFromUnderlyingApp;
-(void) removeOverlayFromUnderlyingAppImmediately;

-(BOOL) isShowingAppSelector;
-(void) showAppSelector;

-(UIView*) currentView;
@end