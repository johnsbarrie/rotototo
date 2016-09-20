/*

    The primary window controller of this application.
    Version: 1.1
 
    Copyright (C) John Barrie.
 */

#import "Controller.h"
#import "TCPServer.h"
#import "SimpleImageObject.h"

@implementation Controller
@synthesize selectedImagePath;
@synthesize offsetValueTextfield=_offsetValueTextfield;

- (void)awakeFromNib {
    self.stepperObject.delegate=self;
    dragonIndex=3;
    [self.frameNumberTextField setSelectable:NO];
    [imageBrowser setZoomValue:0.2f];
    
    //start server
    self.server = [[TCPServer alloc] init];
    self.server.delegate=self;
    if ( [self.server start] ) {
        NSLog(@"Started server on port %zu.", (size_t) [self.server port]);
    } else {
        NSLog(@"Error starting server");
    }
    
    // build the screens popup menu
    NSMenu *screensMenu = [[NSMenu alloc] initWithTitle:@"screens"];
    NSArray *screens = [NSScreen screens];
    if([screens count]<2){
        [errorMessage setStringValue:@"No Video Projector !"];
        return;
    }
    
    curScreen = [screens objectAtIndex:1];
    [screenPopup setMenu:screensMenu];
    [screensMenu release];
    
    [self updateScreenOptions:curScreen];
}

- (void)updateScreenOptions:(NSScreen *)screen {
 	if (screen != nil) {
        NSMutableDictionary *screenOptions =
        [[[NSWorkspace sharedWorkspace] desktopImageOptionsForScreen:curScreen] mutableCopy];
		
		// the value is an NSNumber containing an NSImageScaling (scaling factor)
		NSNumber *scalingFactor = [screenOptions objectForKey:NSWorkspaceDesktopImageScalingKey];
        
        // select the proper menu item that matches it's representedObject value
        for (NSMenuItem *item in [scalingPopup itemArray]) {
            if ([[item representedObject] integerValue] == [scalingFactor integerValue]) {
                [scalingPopup selectItem:item];
                break;
            }
        }
		
       [screenOptions setObject: [NSNumber numberWithInt:NSImageScaleProportionallyUpOrDown] forKey:NSWorkspaceDesktopImageScalingKey];
        [screenOptions setObject:[NSColor blackColor] forKey:NSWorkspaceDesktopImageFillColorKey];
        NSError *error = nil;
        NSURL *imageURL = [[NSWorkspace sharedWorkspace] desktopImageURLForScreen:curScreen];
        if (![[NSWorkspace sharedWorkspace] setDesktopImageURL:imageURL
                                                     forScreen:curScreen
                                                       options:screenOptions
                                                         error:&error]) {
            [self presentError:error];
        }
        
        [screenOptions release];
	}
}

static NSArray* openFiles() {
	// Get a list of extensions to filter in our NSOpenPanel.
	NSOpenPanel* panel = [NSOpenPanel openPanel];
    
    [panel setCanChooseDirectories:YES];	// The user can choose a folder; images in the folder are added recursively.
    [panel setCanChooseFiles:YES];
	[panel setAllowsMultipleSelection:YES];
    
    [panel setAllowedFileTypes:[NSImage imageUnfilteredTypes]];
    NSInteger result = [panel runModal];
    if (result == NSFileHandlingPanelOKButton)
		return [panel URLs];
    
    return nil;
} 

-(void) stepperValueChanged:(int)stepperValue {
    [NSTimer scheduledTimerWithTimeInterval:.1f target:self selector:@selector(updateInterface) userInfo:nil repeats:NO];
}

-(void)updateInterface {
    int newIndex=self.stepperObject.stepperValue + dragonIndex;
    NSMutableIndexSet *myImmutableIndexes=[[NSMutableIndexSet alloc] init];
    [myImmutableIndexes addIndex: newIndex];
    [imageBrowser setSelectionIndexes: myImmutableIndexes byExtendingSelection:NO];
}

- (void)dealloc
{
	[images release];
	[super dealloc];
}

- (IBAction)screensMenuAction:(id)sender
{
	NSMenuItem *chosenItem = (NSMenuItem *)sender;
	NSScreen *screen = [chosenItem representedObject];
	curScreen = screen;	// keep track of the current screen selection
	[self updateScreenOptions:screen];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}


#pragma mark - Actions

- (IBAction)scalingAction:(id)sender {
	// get the current screen options
	NSMutableDictionary *screenOptions =
        [[[NSWorkspace sharedWorkspace] desktopImageOptionsForScreen:curScreen] mutableCopy];
	
	// the value is the representedObject of the menu item describing the NSNumber
    // containing an NSImageScaling (scaling factor)
	NSPopUpButton *popupButton = sender;
    NSNumber *scalingFactor = [[popupButton selectedItem] representedObject];
    
	// replace out the old scaling factor with the new
	[screenOptions setObject:scalingFactor forKey:NSWorkspaceDesktopImageScalingKey];
	
	NSError *error = nil;
	NSURL *imageURL = [[NSWorkspace sharedWorkspace] desktopImageURLForScreen:curScreen];
	if (![[NSWorkspace sharedWorkspace] setDesktopImageURL:imageURL
                                                 forScreen:curScreen
                                                   options:screenOptions
                                                     error:&error]) {
		[self presentError:error];
	}
	
	[screenOptions release];
}

- (IBAction)allowClippingAction:(id)sender {
    NSButton *checkbox = sender;
	NSNumber *allowClipping = [NSNumber numberWithBool:[checkbox state]];
    NSLog(@"allowClipping %d", [allowClipping intValue]);
    NSURL *url;
    NSDictionary *screenOptions   = [[NSWorkspace sharedWorkspace] desktopImageOptionsForScreen:curScreen];;
	
    if([allowClipping intValue]==0){
        NSString *fileName = [[NSBundle mainBundle] pathForResource:@"blacksquare" ofType:@"jpg"];
        url = [NSURL URLWithString: [NSString stringWithFormat:@"file://%@",  fileName]];
    }else {
        url=self.selectedImagePath;
    }
        
    NSNumber *isDirectoryFlag = nil;
    if ([url getResourceValue:&isDirectoryFlag forKey:NSURLIsDirectoryKey error:nil] && ![isDirectoryFlag boolValue]) {
        NSError *error = nil;
        [[NSWorkspace sharedWorkspace] setDesktopImageURL:url
                                                forScreen:curScreen
                                                  options:screenOptions
                                                    error:&error];
        if (error) {
            [NSApp presentError:error];
        }
    }
}

- (IBAction) fillColorAction:(id) sender {
	NSMutableDictionary *screenOptions =
        [[[NSWorkspace sharedWorkspace] desktopImageOptionsForScreen:curScreen] mutableCopy];
    
	NSColorWell *colorWell = sender;
	NSColor *fillColorValue = [colorWell color];
    
	[screenOptions setObject:fillColorValue forKey:NSWorkspaceDesktopImageFillColorKey];
	
	NSError *error = nil;
	NSURL *imageURL = [[NSWorkspace sharedWorkspace] desktopImageURLForScreen:curScreen];
	if (![[NSWorkspace sharedWorkspace] setDesktopImageURL:imageURL
                                                 forScreen:curScreen
                                                   options:screenOptions
                                                     error:&error]) {
		[self presentError:error];
	}
	
	[screenOptions release];
}

#pragma mark - server delegate
- (void) dragonMessageReceived:(NSString*) message{
    NSMutableIndexSet *myImmutableIndexes=[[NSMutableIndexSet alloc] init];
    [myImmutableIndexes addIndex: [message intValue]+ self.stepperObject.stepperValue];
    dragonIndex=[message intValue];
    [imageBrowser setSelectionIndexes: myImmutableIndexes byExtendingSelection:NO];
}

- (IBAction) selectImageFolderButtonClicked:(NSButton *)sender {
    NSArray* path = openFiles();
    if (path) {
		[NSThread detachNewThreadSelector:@selector(addImagesWithPaths:) toTarget:self withObject:path];
	}
}

- (void)addImagesWithPaths:(NSArray*)paths {
    if(images){
        [images release];
    }
    images = [[NSMutableArray alloc] init];
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    [paths retain];
    
    NSInteger i, n;
	n = [paths count];
    for (i = 0; i < n; i++) {
        NSURL *url = [paths objectAtIndex:i];
		[self addImagesWithPath:[url path]];
    }
    [imageBrowser reloadData];
    [paths release];
    [pool release];
}

- (void)addImagesWithPath:(NSString*)path {
    BOOL dir;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&dir];
    
    if (dir) {
		NSInteger i, n;
		NSArray* content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        n = [content count];
        
        for ( i = 0; i < n; i++ ) {
			[self addAnImageWithPath:[path stringByAppendingPathComponent:[content objectAtIndex:i]]];
        }
    } else {
		[self addAnImageWithPath:path];
	}
}

- (void)addAnImageWithPath:(NSString*)path {
	BOOL addObject = NO;

	NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
	if (fileAttribs) {
		if ([NSFileTypeDirectory isEqualTo:[fileAttribs objectForKey:NSFileType]]){
			if ([[NSWorkspace sharedWorkspace] isFilePackageAtPath:path] == NO)
				addObject = YES;
		} else {
			addObject = YES;
		}
	}
	
	if (addObject && [self isImageFile:path]) {
        SimpleImageObject * item = [[SimpleImageObject alloc] init];
        item.url = [[[NSURL alloc] initFileURLWithPath:path] autorelease];
        [images addObject:item];

        [item release];
	}
}


- (BOOL)isImageFile:(NSString*)filePath {
	BOOL				isImageFile = NO;
	LSItemInfoRecord	info;
	CFStringRef			uti = NULL;
	
	CFURLRef url = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)filePath, kCFURLPOSIXPathStyle, FALSE);
	
	if (LSCopyItemInfoForURL(url, kLSRequestExtension | kLSRequestTypeCreator, &info) == noErr) {
		if (info.extension != NULL) {
			uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, info.extension, kUTTypeData);
			CFRelease(info.extension);
		}
        

		if (uti == NULL) {
			CFStringRef typeString = UTCreateStringForOSType(info.filetype);
			if ( typeString != NULL) {
				uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassOSType, typeString, kUTTypeData);
				CFRelease(typeString);
			}
		}
		
		if (uti != NULL) {
			CFArrayRef  supportedTypes = CGImageSourceCopyTypeIdentifiers();
			CFIndex		i, typeCount = CFArrayGetCount(supportedTypes);
            
			for (i = 0; i < typeCount; i++) {
				if (UTTypeConformsTo(uti, (CFStringRef)CFArrayGetValueAtIndex(supportedTypes, i))) {
					isImageFile = YES;
					break;
				}
			}
            
            CFRelease(supportedTypes);
            CFRelease(uti);
		}
	}
    
    CFRelease(url);
	return isImageFile;
}

@end
