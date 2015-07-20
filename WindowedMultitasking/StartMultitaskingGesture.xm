#import "headers.h"
#import "RADesktopManager.h"
#import "RAGestureManager.h"

BOOL overrideCC = NO;

%hook SBUIController
- (void)_showControlCenterGestureBeganWithLocation:(CGPoint)arg1
{
    if (!overrideCC)
        %orig;
}

- (void)handleShowControlCenterSystemGesture:(id)arg1
{
    if (!overrideCC)
        %orig;
}
%end

%ctor
{
    __weak __block UIView *appView = nil;
    __block CGFloat lastY = 0;
    [[RAGestureManager sharedInstance] addGestureRecognizer:^RAGestureCallbackResult(UIGestureRecognizerState state, CGPoint location, CGPoint velocity) {

        SBApplication *topApp = [[UIApplication sharedApplication] _accessibilityFrontMostApplication];

        // Dismiss potential CC
        //[[%c(SBUIController) sharedInstance] _showControlCenterGestureEndedWithLocation:CGPointMake(0, UIScreen.mainScreen.bounds.size.height - 1) velocity:CGPointZero];

        if (state == UIGestureRecognizerStateBegan)
        {
            overrideCC = YES;

            // Show HS/Wallpaper
            [[%c(SBWallpaperController) sharedInstance] beginRequiringWithReason:@"BeautifulAnimation"];
            [[%c(SBUIController) sharedInstance] restoreContentAndUnscatterIconsAnimated:NO];

            // Assign view
            appView = [MSHookIvar<UIView*>(topApp.mainScene.contextHostManager, "_hostView") superview];
        }
        else if (state == UIGestureRecognizerStateChanged)
        {
            lastY = location.y;
            CGFloat scale = location.y / UIScreen.mainScreen.bounds.size.height;
            scale = MIN(MAX(scale, 0.3), 1);
            appView.transform = CGAffineTransformMakeScale(scale, scale);
        }
        else if (state == UIGestureRecognizerStateEnded)
        {
            overrideCC = NO;

            if (lastY <= (UIScreen.mainScreen.bounds.size.height / 4) * 3) // 75% down
            {
                [UIView animateWithDuration:0.2 animations:^{
                    appView.transform = CGAffineTransformMakeScale(0.5, 0.5);
                } completion:^(BOOL _) {
                    // Close app
                    FBWorkspaceEvent *event = [%c(FBWorkspaceEvent) eventWithName:@"ActivateSpringBoard" handler:^{
                        SBDeactivationSettings *settings = [[%c(SBDeactivationSettings) alloc] init];
                        [settings setFlag:YES forDeactivationSetting:20];
                        [settings setFlag:NO forDeactivationSetting:2];
                        [UIApplication.sharedApplication._accessibilityFrontMostApplication _setDeactivationSettings:settings];
                 
                        SBAppToAppWorkspaceTransaction *transaction = [[%c(SBAppToAppWorkspaceTransaction) alloc] initWithAlertManager:nil exitedApp:UIApplication.sharedApplication._accessibilityFrontMostApplication];
                        [transaction begin];
                    }];
                    [(FBWorkspaceEventQueue*)[%c(FBWorkspaceEventQueue) sharedInstance] executeOrAppendEvent:event];
                    // Open in window
                    [RADesktopManager.sharedInstance.currentDesktop createAppWindowForSBApplication:topApp animated:YES];
                }];
            }
            else            
                [UIView animateWithDuration:0.2 animations:^{ appView.transform = CGAffineTransformIdentity; }];

        }

        return RAGestureCallbackResultSuccess;
    } withCondition:^BOOL(CGPoint location, CGPoint velocity) {
        return location.x <= 100 && ![[%c(SBLockScreenManager) sharedInstance] isUILocked] && [UIApplication.sharedApplication _accessibilityFrontMostApplication] != nil;
    } forEdge:UIRectEdgeBottom identifier:@"com.efrederickson.reachapp.windowedmultitasking.systemgesture" priority:RAGesturePriorityDefault];
}