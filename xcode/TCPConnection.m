/*
 
 ROTOTOTO
 
 A basic TCP connection.
 Created by John Barrie on 06/11/14.
 */

#import "TCPConnection.h"

NSString * TCPConnectionDidCloseNotification = @"TCPConnectionDidCloseNotification";
NSString * TCPConnectionDidReceiveMessage = @"TCPConnectionDidReceiveMessage";

@interface TCPConnection () <NSStreamDelegate>
@end

@implementation TCPConnection
@synthesize inputStream  = _inputStream;
@synthesize outputStream = _outputStream;

- (id)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    self = [super init];
    if (self != nil) {
        self->_inputStream = inputStream;
        self->_outputStream = outputStream;
    }
    return self;
}

- (BOOL)open {
    [self.inputStream  setDelegate:self];
    
    [self.inputStream  scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.inputStream  open];
    [self.outputStream open];
    return YES;
}

- (void)close {
    [self.inputStream  setDelegate:nil];
    [self.inputStream  close];
    [self.inputStream  removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [(NSNotificationCenter *)[NSNotificationCenter defaultCenter] postNotificationName:TCPConnectionDidCloseNotification object:self];
}

-(void) postMessage:(NSString*) message {
    NSDictionary* dico= [NSDictionary dictionaryWithObject:message forKey:@"message"];
    [(NSNotificationCenter *)[NSNotificationCenter defaultCenter] postNotificationName:TCPConnectionDidReceiveMessage object:self userInfo:dico];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent {
    assert(aStream == self.inputStream || aStream == self.outputStream);
    #pragma unused(aStream)
    
    switch(streamEvent) {
        case NSStreamEventHasBytesAvailable: {
            uint8_t buffer[2048];
            
            NSInteger actuallyRead = [self.inputStream read:(uint8_t *)buffer maxLength:sizeof(buffer)];

            if (actuallyRead > 0) {
                NSString *output = [[NSString alloc] initWithBytes:buffer length:actuallyRead encoding:NSASCIIStringEncoding];
                [self postMessage:output];
            } else {
                // A non-positive value from -read:maxLength: indicates either end of file (0) or 
                // an error (-1).
                [self close];
            }
        } break;
        case NSStreamEventEndEncountered:
        case NSStreamEventErrorOccurred: {
            [self close];
        } break;
        case NSStreamEventHasSpaceAvailable:
        case NSStreamEventOpenCompleted:
        default: {
            // do nothing
        } break;
    }
}

@end
