
#import <Quartz/Quartz.h>
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
@interface Controller(Browsing){
    
}

- (void)setupBrowsing;
- (IBAction)changeLocationAction:(id)sender;
- (IBAction)zoomSliderDidChange:(id)sender;
- (void) updateBigImage:(int)imageIndex;

@end
