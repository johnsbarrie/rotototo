#import "Controller.h"
#import "ControllerBrowsing.h"
#import "SimpleImageObject.h"

NSString *kDesktopPicturesTitle = @"Desktop Pictures";

@implementation Controller(Browsing)

#pragma mark - Import images from file system

- (void)addImageWithURL:(NSURL *)imageURL {
    NSNumber *hiddenFlag = nil;
    if ([imageURL getResourceValue:&hiddenFlag forKey:NSURLIsHiddenKey error:nil]) {
        NSNumber *isDirectoryFlag = nil;
        if ([imageURL getResourceValue:&isDirectoryFlag forKey:NSURLIsDirectoryKey error:nil]) {
            NSNumber *isPackageFlag = nil;
            if ([imageURL getResourceValue:&isPackageFlag forKey:NSURLIsPackageKey error:nil]) {
                if (![hiddenFlag boolValue] && ![isPackageFlag boolValue] &&
                    ([isDirectoryFlag boolValue] || [self isImageFile:imageURL])) {
                    SimpleImageObject * item = [[SimpleImageObject alloc] init];
                    item.url = imageURL;
                    [images addObject:item];
                    
                    [item release];
                }
            }
        }
    }
}

- (void)addImagesFromDirectory:(NSURL *)directoryURL {
	NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:directoryURL
                                                    includingPropertiesForKeys:nil
                                                    options:NSDirectoryEnumerationSkipsHiddenFiles
                                                    error:nil];
    for (NSURL *imageURL in content) {
        [self addImageWithURL:imageURL];
    }
    
    [self updateBigImage:0];
	[imageBrowser reloadData];
    
    if(videoProjectorKeepAwakeTimer){
        [videoProjectorKeepAwakeTimer invalidate];
        videoProjectorKeepAwakeTimer=nil;
    }
    videoProjectorKeepAwakeTimer = [NSTimer scheduledTimerWithTimeInterval:60.f target:self selector:@selector(videoProjectorKeepAwakeTimerMethod:) userInfo:nil repeats:YES];
}


- (void)videoProjectorKeepAwakeTimerMethod:(NSTimer *)timer {
    [self updateBigImage:[[imageBrowser selectionIndexes] firstIndex]];
}

#pragma mark - Setup Browsing
- (IBAction)frameNumberTextField:(NSTextField *)sender {
}

- (void)setupBrowsing {
	images = [[NSMutableArray alloc] init];
    
	NSString *finalPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/"];
	
    if ([[NSFileManager defaultManager] fileExistsAtPath:finalPath]) {
        NSURL *desktopPicsURL = [NSURL fileURLWithPath:finalPath];
        [self addImagesFromDirectory:desktopPicsURL];
        [pathControl setURL:desktopPicsURL];
    }
}

- (void)changeLocationToNewLocation:(NSURL *)newLocationURL {
	[images removeAllObjects];
	[self addImagesFromDirectory:newLocationURL];
	[imageBrowser reloadData];
}

- (void)updatePathControlWithNewLocation:(NSURL *)newLocationURL {
    [pathControl setURL:newLocationURL];
}

- (IBAction)changeLocationAction:(id)sender {
    NSPathControl *pathCntl = (NSPathControl *)sender;
    NSPathComponentCell *component = [pathCntl clickedPathComponentCell];
    
    NSURL *url = [component URL];
    [self changeLocationToNewLocation:url];
    [self updatePathControlWithNewLocation:url];
}

- (void)pathControl:(NSPathControl *)pathControl willDisplayOpenPanel:(NSOpenPanel *)openPanel {
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanChooseFiles:NO];
	[openPanel setResolvesAliases:YES];
	[openPanel setTitle:@"Choisir un dossier d'images"];
	[openPanel setPrompt:@"Choisir"];
}

- (void)menuItemAction:(id)sender {
	[pathControl setURL:[sender representedObject]];
	
	[images removeAllObjects];
	[self addImagesFromDirectory:[sender representedObject]];
}

- (void)pathControl:(NSPathControl *)pathControl willPopUpMenu:(NSMenu *)menu {
	NSMenuItem *newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Home"
                                                                               action:@selector(menuItemAction:)
                                                                        keyEquivalent:@""];
	[newItem setTarget:self];
	NSString *homeDir = NSHomeDirectory();
    [newItem setRepresentedObject:[NSURL fileURLWithPath:homeDir]];
	NSImage *menuItemIcon = [[NSWorkspace sharedWorkspace] iconForFile:NSHomeDirectory()];
	[menuItemIcon setSize:NSMakeSize(16, 16)];
	[newItem setImage:menuItemIcon];
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItem:newItem];
	[newItem release];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSLocalDomainMask, YES);
	NSString *libraryDirectory = [paths objectAtIndex:0];
	NSString *finalPath = [libraryDirectory stringByAppendingPathComponent:kDesktopPicturesTitle];
	newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:kDesktopPicturesTitle
                                                                   action:@selector(menuItemAction:)
                                                            keyEquivalent:@""];
	[newItem setTarget:self];
	[newItem setRepresentedObject:[NSURL fileURLWithPath:finalPath]];
	menuItemIcon = [[NSWorkspace sharedWorkspace] iconForFile:finalPath];
	[menuItemIcon setSize:NSMakeSize(16, 16)];
	[newItem setImage:menuItemIcon];
	[menu addItem:newItem];
   
	[newItem release];
}

#pragma mark - Actions
- (IBAction)zoomSliderDidChange:(id)sender {
	[imageBrowser setZoomValue:[sender floatValue]];
}

#pragma mark - IKImageBrowserDataSource
- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)view {
	return [images count];
}

- (id)imageBrowser:(IKImageBrowserView *)view itemAtIndex:(NSUInteger)index {
	return [images objectAtIndex:index];
}

#pragma mark - big image update
- (void) updateBigImage: (int) imageIndex {
    SimpleImageObject *anItem = [images objectAtIndex:imageIndex];
    NSURL *url = [anItem imageRepresentation];
    self.selectedImagePath=url;
    
    [bigImage setImage: [[[NSImage alloc] initWithContentsOfFile:[url path]] autorelease]];
}

#pragma mark - optional datasource methods

- (void)imageBrowser:(IKImageBrowserView *)aBrowser removeItemsAtIndexes:(NSIndexSet *)indexes {
	[images removeObjectsAtIndexes:indexes];
	[imageBrowser reloadData];
}

- (BOOL)imageBrowser:(IKImageBrowserView *)aBrowser moveItemsAtIndexes:(NSIndexSet *)indexes toIndex:(NSUInteger)destinationIndex {
	NSArray *tempArray = [images objectsAtIndexes:indexes];
	[images removeObjectsAtIndexes:indexes];
	
	destinationIndex -= [indexes countOfIndexesInRange:NSMakeRange(0, destinationIndex)];
	[images insertObjects:tempArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(destinationIndex, [tempArray count])]];
	[imageBrowser reloadData];
	
	return YES;
}

#pragma mark - IKImageBrowserDelegate

- (void)imageBrowserSelectionDidChange:(IKImageBrowserView *)aBrowser {
	NSIndexSet *selectionIndexes = [aBrowser selectionIndexes];	
    
	if ([selectionIndexes count] > 0) {
        SimpleImageObject *anItem = [images objectAtIndex:[selectionIndexes firstIndex]];
		NSURL *url = [anItem imageRepresentation];
        self.selectedImagePath=url;
        [self.frameNumberTextField setStringValue: [NSString stringWithFormat: @"Image %li",[selectionIndexes firstIndex]+1]];
        NSNumber *isDirectoryFlag = nil;
        [self updateBigImage:  [[imageBrowser selectionIndexes] firstIndex]];
        NSDictionary *screenOptions = [[NSWorkspace sharedWorkspace] desktopImageOptionsForScreen:curScreen];
        if ([url getResourceValue:&isDirectoryFlag forKey:NSURLIsDirectoryKey error:nil] && ![isDirectoryFlag boolValue])
        {
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
}

- (void)imageBrowser:(IKImageBrowserView *)aBrowser cellWasDoubleClickedAtIndex:(NSUInteger)index {
    SimpleImageObject *imageObject = (SimpleImageObject *)[images objectAtIndex:index];
    if (imageObject) {
        NSURL *url = [imageObject url];
        
        NSNumber *isDirectoryFlag = nil;
        if ([url getResourceValue:&isDirectoryFlag forKey:NSURLIsDirectoryKey error:nil] && [isDirectoryFlag boolValue]) {
            [self changeLocationToNewLocation:url];
            [self updatePathControlWithNewLocation:url];
        }
    }
}

- (NSDictionary *) imageBrowser:(IKImageBrowserView *) aBrowser groupAtIndex:(NSUInteger) index {
    CALayer *headerLayer = [CALayer layer];
    headerLayer.bounds = CGRectMake(0.0, 0.0, 100.0, 30.0);
    CGColorRef colour = CGColorCreateGenericRGB(1.0, 0.5, 0.7, 1.0);
    headerLayer.backgroundColor = colour;
    CGColorRelease(colour);
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt: IKGroupDisclosureStyle], IKImageBrowserGroupStyleKey,
            headerLayer, IKImageBrowserGroupHeaderLayer,
            nil];
}

@end
