/*
    EchoServer.h
    A basic TCP  server which will reply to dragon frame .
*/

#import <Foundation/Foundation.h>

@protocol TCPServerDelegate <NSObject>
    -(void) dragonMessageReceived:(NSString*) message;
@end


@interface TCPServer : NSObject{
    id <TCPServerDelegate> delegate;
}


@property (retain) id <TCPServerDelegate> delegate;
@property (nonatomic, assign, readonly ) NSUInteger port;

- (BOOL)start;
- (void)stop;

@end
