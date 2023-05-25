#import <UIKit/UIKit.h>

@interface NCNotificationSeamlessContentView : UIView
@property (nonatomic, retain) NSString *primaryText;
@property (nonatomic, retain) NSString *secondaryText;
@end

void showToastWithTextOnView(NSString *text, UIView *view) {
	UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
	[customView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
	customView.layer.cornerRadius = 10;
	customView.userInteractionEnabled = NO;
	customView.alpha = 0;

	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	[label setText:text];
	[label setTextColor:[UIColor whiteColor]];
	[label sizeToFit];

	[customView setCenter:view.center];
	[view addSubview:customView];

	CGRect labelFrame = label.frame;
	labelFrame.origin.x = (customView.frame.size.width - label.frame.size.width) / 2;
	labelFrame.origin.y = (customView.frame.size.height - label.frame.size.height) / 2;
	label.frame = labelFrame;

	[customView addSubview:label];

	[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		customView.alpha = 1;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.3 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
			customView.alpha = 0;
		} completion:^(BOOL finished) {
			[customView removeFromSuperview];
		}];
	}];
}

%hook NCNotificationSeamlessContentView
-(void)setFrame:(CGRect)frame {
	%orig;

	// Long press with 2 fingers to copy primary text
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(noticopy_copyPrimary:)];
	longPress.numberOfTouchesRequired = 2;
	longPress.minimumPressDuration = 0.5;
	[self addGestureRecognizer:longPress];

	// Tap with 2 fingers to copy secondary text
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(noticopy_copySecondary)];
	tap.numberOfTapsRequired = 1;
	tap.numberOfTouchesRequired = 2;
	[self addGestureRecognizer:tap];
}

%new
-(void)noticopy_copyPrimary:(UILongPressGestureRecognizer *)gesture {
	if (gesture.state != UIGestureRecognizerStateEnded) return;

	if (!self.primaryText) {
		showToastWithTextOnView(@"No primary text", self);
		return;
	}
	
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = self.primaryText;
	showToastWithTextOnView(@"Copied to clipboard", self);
}

%new
-(void)noticopy_copySecondary {
	if (!self.secondaryText) {
		showToastWithTextOnView(@"No secondary text", self);
		return;
	}

	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = self.secondaryText;
	showToastWithTextOnView(@"Copied to clipboard", self);
}
%end

