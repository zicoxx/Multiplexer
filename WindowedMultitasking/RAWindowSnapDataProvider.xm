#import "RAWindowSnapDataProvider.h"

@implementation RAWindowSnapDataProvider
+(BOOL) shouldSnapWindowAtLocation:(CGRect)location
{
	return [RAWindowSnapDataProvider snapLocationForWindowLocation:location] != RAWindowSnapLocationInvalid;
}

+(RAWindowSnapLocation) snapLocationForWindowLocation:(CGRect)location
{
	// Convienence values
	CGFloat width = UIScreen.mainScreen.bounds.size.width;
	CGFloat height = UIScreen.mainScreen.bounds.size.height;
	CGFloat oneThirdsHeight = height / 4;
	CGFloat twoThirdsHeight = (height / 4) * 3;

	CGFloat leftXBuffer = 25;
	CGFloat rightXBuffer = width - 25;
	CGFloat bottomBuffer = height - 25;

	// Left
	if (location.origin.x < leftXBuffer && location.origin.y < height / 8)
		return RAWindowSnapLocationLeftTop;
	if (location.origin.x < leftXBuffer && (location.origin.y >= twoThirdsHeight || location.origin.y + location.size.height > height))
		return RAWindowSnapLocationLeftBottom;
	if (location.origin.x < leftXBuffer && location.origin.y >= oneThirdsHeight && location.origin.y < twoThirdsHeight)
		return RAWindowSnapLocationLeftMiddle;

	// Right
	if (location.origin.x + location.size.width > rightXBuffer && location.origin.y < height / 8)
		return RAWindowSnapLocationRightTop;
	if (location.origin.x + location.size.width > rightXBuffer && (location.origin.y >= twoThirdsHeight || location.origin.y + location.size.height > height))
		return RAWindowSnapLocationRightBottom;
	if (location.origin.x + location.size.width > rightXBuffer && location.origin.y >= oneThirdsHeight && location.origin.y < twoThirdsHeight)
		return RAWindowSnapLocationRightMiddle;

	if (location.origin.y + location.size.height > bottomBuffer)
		return RAWindowSnapLocationBottom;
	if (location.origin.y < 20 + 25)
		return RAWindowSnapLocationTop;

	return RAWindowSnapLocationNone;
}

+(void) snapWindow:(RAWindowBar*)window toLocation:(RAWindowSnapLocation)location animated:(BOOL)animated
{
	// Convienence values
	CGFloat width = UIScreen.mainScreen.bounds.size.width;
	CGFloat height = UIScreen.mainScreen.bounds.size.height;

	// Target frame values
	CGRect frame = window.frame;
	CGPoint adjustedOrigin = window.frame.origin;

	switch (location)
	{
		case RAWindowSnapLocationLeftTop:
			adjustedOrigin = CGPointMake(0, 20);
			break;
		case RAWindowSnapLocationLeftMiddle:
			adjustedOrigin.x = 0;
			break;
		case RAWindowSnapLocationLeftBottom:
			adjustedOrigin = CGPointMake(0, height - frame.size.height);
			break;

		case RAWindowSnapLocationRightTop:
			adjustedOrigin = CGPointMake(width - frame.size.width, 20);
			break;
		case RAWindowSnapLocationRightMiddle:
			adjustedOrigin.x = width - frame.size.width;
			break;
		case RAWindowSnapLocationRightBottom:
			adjustedOrigin = CGPointMake(width - frame.size.width, height - frame.size.height);
			break;

		case RAWindowSnapLocationTop:
			adjustedOrigin.y = 20;
			break;
		case RAWindowSnapLocationBottom:
			adjustedOrigin.y = height - frame.size.height;
			break;

		case RAWindowSnapLocationInvalid:
		default:
			break;
	}

	if (animated)
	{
		[UIView animateWithDuration:0.2 animations:^{
			window.frame = (CGRect) { adjustedOrigin, frame.size };
		}];
	}
	else
		window.frame = (CGRect) { adjustedOrigin, frame.size };
}
@end
