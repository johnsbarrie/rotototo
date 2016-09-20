
#import <Quartz/Quartz.h>
#import <Cocoa/Cocoa.h>
#import "TCPServer.h"
#import "StepperObject.h"
@interface Controller : NSWindowController <NSTextFieldDelegate, StepperObjectDelegate>
{
	IBOutlet IKImageBrowserView *imageBrowser;
	
	IBOutlet NSPopUpButton		*screenPopup;
	IBOutlet NSPopUpButton		*scalingPopup;
	IBOutlet NSButton			*clippingCheckbox;
	IBOutlet NSColorWell		*fillColor;
	IBOutlet NSPathControl		*pathControl;
	IBOutlet NSTextField             *errorMessage;
	IBOutlet NSImageView             *bigImage;
    TCPServer * server;
	NSURL *selectedImagePath;
	NSMutableArray	*images;
	
	NSScreen *curScreen;
    NSTimer* videoProjectorKeepAwakeTimer;
    NSTextField *_offsetValueTextfield;
    int dragonIndex;
    NSMutableArray*importedImages;
}

@property (assign) IBOutlet NSTextField * offsetValueTextfield;
@property (assign) IBOutlet StepperObject *stepperObject;
- (IBAction)selectImageFolderButtonClicked:(NSButton *)sender;

@property (retain) 	NSURL * selectedImagePath;
@property (retain) 	TCPServer * server;
@property (assign) IBOutlet NSTextField * frameNumberTextField;

- (IBAction)scalingAction:(id)sender;
- (IBAction)allowClippingAction:(id)sender;
- (IBAction)fillColorAction:(id)sender;

@end
