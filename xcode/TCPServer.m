/*
 EchoServer.h
 A basic TCP  server which will reply to dragon frame .
 */

#import "TCPServer.h"
#import "TCPConnection.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

@interface TCPServer () <NSStreamDelegate>

@property (nonatomic, assign, readwrite) NSUInteger         port;
@property (nonatomic, strong, readwrite) NSNetService *     netService;
@property (nonatomic, strong, readonly ) NSMutableSet *     connections;    // of EchoConnection

@end

@implementation TCPServer {
    CFSocketRef             _ipv4socket;
    CFSocketRef             _ipv6socket;
}
@synthesize delegate;

@synthesize port = _port;

@synthesize netService = _netService;
@synthesize connections = _connections;

- (id)init {
    self = [super init];
    if (self != nil) {
        _connections = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc {
    [self stop];
}

- (void)echoConnectionDidCloseNotification:(NSNotification *)note {
    TCPConnection *connection = [note object];
    assert([connection isKindOfClass:[TCPConnection class]]);
    [(NSNotificationCenter *)[NSNotificationCenter defaultCenter] removeObserver:self name:TCPConnectionDidCloseNotification object:connection];
    [self.connections removeObject:connection];
    NSLog(@"Connection closed.");
}

- (void)echoConnectionDidReceiveMessage:(NSNotification *)note {
     NSDictionary *msg = [note userInfo];
    [delegate dragonMessageReceived:[msg objectForKey:@"message"]];

}

- (void)acceptConnection:(CFSocketNativeHandle)nativeSocketHandle {
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle, &readStream, &writeStream);
    if (readStream && writeStream) {
        CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);

        TCPConnection * connection = [[TCPConnection alloc] initWithInputStream:(__bridge NSInputStream *)readStream outputStream:(__bridge NSOutputStream *)writeStream];
        [self.connections addObject:connection];
        [connection open];
        [(NSNotificationCenter *)[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(echoConnectionDidCloseNotification:) name:TCPConnectionDidCloseNotification object:connection];
        
        [(NSNotificationCenter *)[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(echoConnectionDidReceiveMessage:) name:TCPConnectionDidReceiveMessage object:connection];
        NSLog(@"Added connection.");
    } else {
        NSLog(@"closing connection.");
        // On any failure, we need to destroy the CFSocketNativeHandle 
        // since we are not going to use it any more.
        (void) close(nativeSocketHandle);
    }
    if (readStream) CFRelease(readStream);
    if (writeStream) CFRelease(writeStream);
}

static void EchoServerAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    assert(type == kCFSocketAcceptCallBack);
    #pragma unused(type)
    #pragma unused(address)
    
    TCPServer *server = (__bridge TCPServer *)info;
    assert(socket == server->_ipv4socket || socket == server->_ipv6socket);
    #pragma unused(socket)
    
    [server acceptConnection:*(CFSocketNativeHandle *)data];
}

- (BOOL)start {
    assert(_ipv4socket == NULL && _ipv6socket == NULL);       // don't call -start twice!

    CFSocketContext socketCtxt = {0, (__bridge void *) self, NULL, NULL, NULL};
    _ipv4socket = CFSocketCreate(kCFAllocatorDefault, AF_INET,  SOCK_STREAM, 0, kCFSocketAcceptCallBack, &EchoServerAcceptCallBack, &socketCtxt);
    _ipv6socket = CFSocketCreate(kCFAllocatorDefault, AF_INET6, SOCK_STREAM, 0, kCFSocketAcceptCallBack, &EchoServerAcceptCallBack, &socketCtxt);

    if (NULL == _ipv4socket || NULL == _ipv6socket) {
        [self stop];
        return NO;
    }

    static const int yes = 1;
    (void) setsockopt(CFSocketGetNative(_ipv4socket), SOL_SOCKET, SO_REUSEADDR, (const void *) &yes, sizeof(yes));
    (void) setsockopt(CFSocketGetNative(_ipv6socket), SOL_SOCKET, SO_REUSEADDR, (const void *) &yes, sizeof(yes));

    struct sockaddr_in addr4;
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_port = htons(0);
    addr4.sin_addr.s_addr = htonl(INADDR_ANY);
    if (kCFSocketSuccess != CFSocketSetAddress(_ipv4socket, (__bridge CFDataRef) [NSData dataWithBytes:&addr4 length:sizeof(addr4)])) {
        [self stop];
        return NO;
    }
    
    NSData *addr = (__bridge_transfer NSData *)CFSocketCopyAddress(_ipv4socket);
    assert([addr length] == sizeof(struct sockaddr_in));
    self.port = 3001;

    struct sockaddr_in6 addr6;
    memset(&addr6, 0, sizeof(addr6));
    addr6.sin6_len = sizeof(addr6);
    addr6.sin6_family = AF_INET6;
    addr6.sin6_port = htons(self.port);
    memcpy(&(addr6.sin6_addr), &in6addr_any, sizeof(addr6.sin6_addr));
    if (kCFSocketSuccess != CFSocketSetAddress(_ipv6socket, (__bridge CFDataRef) [NSData dataWithBytes:&addr6 length:sizeof(addr6)])) {
        [self stop];
        return NO;
    }

    CFRunLoopSourceRef source4 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _ipv4socket, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source4, kCFRunLoopCommonModes);
    CFRelease(source4);

    CFRunLoopSourceRef source6 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _ipv6socket, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source6, kCFRunLoopCommonModes);
    CFRelease(source6);

    return YES;
}

- (void)stop {
    [self.netService stop];
    self.netService = nil;
    
    for (TCPConnection * connection in [self.connections copy]) {
        [connection close];
    }
    if (_ipv4socket != NULL) {
        CFSocketInvalidate(_ipv4socket);
        CFRelease(_ipv4socket);
        _ipv4socket = NULL;
    }
    if (_ipv6socket != NULL) {
        CFSocketInvalidate(_ipv6socket);
        CFRelease(_ipv6socket);
        _ipv6socket = NULL;
    }
}

@end
