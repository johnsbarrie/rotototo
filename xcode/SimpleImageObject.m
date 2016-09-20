//
//  MyImageObject.m
//  RotoToto
//
//  Created by javanai on 06/11/14.
#import "SimpleImageObject.h"
@implementation SimpleImageObject

@synthesize url;

- (void)dealloc
{
    [url release];
    [super dealloc];
}


#pragma mark - Item data source protocol

- (NSString *)imageRepresentationType
{
    return IKImageBrowserNSURLRepresentationType;;
}

- (id)imageRepresentation
{
    return self.url;
}

- (NSString *)imageUID
{
    return [NSString stringWithFormat:@"%p", self];
}

- (id)imageTitle {
    return [url lastPathComponent];
}

@end