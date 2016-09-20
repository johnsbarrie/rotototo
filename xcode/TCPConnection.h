/*
    TCPConnection.h
    A basic TCP connection.
    Created by John Barrie on 06/11/14.
*/


#import <Foundation/Foundation.h>

@interface TCPConnection : NSObject

- (id)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream;

@property (nonatomic, strong, readonly ) NSInputStream *   inputStream;
@property (nonatomic, strong, readonly ) NSOutputStream *   outputStream;

- (BOOL)open;
- (void)close;

extern NSString * TCPConnectionDidCloseNotification;
extern NSString * TCPConnectionDidReceiveMessage;

@end
