GCDAsyncSocket is a TCP socket library built upon Grand Central Dispatch. The project also contains a RunLoop based version, as well as UDP socket libraries.

The CocoaAsyncSocket project is a mature open source framework that has been around since 2003. As such it has benefitted from a wide variety of networking developers who have submitted code or suggested features. The goal of the project is to create powerful yet easy to use socket libraries.

Specific features of GCDAsyncSocket include:

-   Classic delegate-style support.<br/>
  _All of the following result in calls to your delegate method: connections, accepts, read completions, write completions, progress, disconnections, errors, etc. The delegate methods include a socket parameter, allowing you to distinguish between many instances._
-   Delegate dispatch.<br/>
  _Every delegate method is invoked on a configurable dispatch\_queue. This allows for parallel socket IO and data processing, as well as easy thread-safety._
-   Queued non-blocking reads and writes, with optional timeouts.<br/>
  _You tell it what to read or write, and it will call you when it's done._
-   Automatic socket acceptance.<br/>
  _If you tell it to accept connections, it will call you with new instances of itself for each connection. You can, of course, disconnect them immediately._
-   Automatic support for IPv4 and IPv6.
-   SSL/TLS support.
-   Built upon the latest technologies such as kqueues and GCD.
-   Self-contained in one class.<br/>
  _You don't need to muck around with streams or sockets. The class handles all of that._

One of the more powerful features of GCDAsyncSocket is its queued architecture. This allows you to control the socket when it is convenient for YOU, and not when the socket tells you it's ready. A few examples:

```objective-c
// Start asynchronous connection.
// The method below will return immediately,
// and the delegate method socket:didConnectToHost:port: will
// be invoked when the connection has completed.
[asyncSocket connectToHost:host onPort:port error:nil];

// At this moment in time, the socket is not yet connected.
// It has just started the asynchronous connection attempt.
// But AsyncSocket was designed to make socket programming easier for you.
// You are free to start reading/writing if it is convenient for you.
// So we are going to start the read request for our message header now.
// The read request will automatically be queued.
// And after the socket connects, this read request will automatically be dequeued and executed.
[asyncSocket readDataToLength:LENGTH_HEADER withTimeout:TIMEOUT_NONE tag:TAG_HEADER];
```

In addition to this, you can invoke multiple read/write requests as is convenient.

```objective-c
// Start asynchronous write operation
[asyncSocket writeData:msgHeader withTimeout:TIMEOUT_NONE tag:TAG_HEADER];

// We don't have to wait for that write to complete before starting the next one
[asyncSocket writeData:msgBody withTimeout:TIMEOUT_NONE tag:TAG_BODY];
```

```objective-c
// Start asynchronous read operation.
// Read and ignore the welcome message.
[asyncSocket readDataToData:msgSeparator withTimeout:TIMEOUT_NONE tag:TAG_WELCOME];

// We don't have to wait for that read to complete before starting the next one.
// Read server capabilities.
[asyncSocket readDataToData:msgSeparator withTimeout:TIMEOUT_NONE tag:TAG_CAPABILITIES];
```

The queued architecture even extends into the SSL/TLS support!

```objective-c
// Send startTLS confirmation ACK.
// Remember this is an asynchronous operation.
[asyncSocket writeData:ack withTimeout:TIMEOUT_NONE tag:TAG_ACK];

// We don't have to wait for the write to complete before invoking startTLS.
// The socket will automatically queue the operation, and wait for previous reads/writes to complete.
// Once that has happened, the upgrade to SSL/TLS will automatically start.
[asyncSocket startTLS:tlsSettings];

// Again, we don't have to wait for the security handshakes to complete.
// We can immediately queue our next operation if it's convenient for us.
// So we can start reading the next request from the client.
// This read will occur over a secure connection.
[asyncSocket readDataToData:msgSeparator withTimeout:TIMEOUT_NONE tag:TAG_MSG];
```

Timeouts are optional parameters to most operations.

In addition to this you've probably noticed the tag parameter. The tag you pass during the read/write operation is passed back to you via the delegate method once the read/write operation completes. It does not get sent over the socket or read from the socket. It is designed to help simplify the code in your delegate method. For example, your delegate method might look like this:

```objective-c
#define TAG_WELCOME 10
#define TAG_CAPABILITIES 11
#define TAG_MSG 12

... 

- (void)socket:(AsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag
{
    if (tag == TAG_WELCOME)
    {
        // Ignore welcome message
    }
    else if (tag == TAG_CAPABILITIES)
    {
        [self processCapabilities:data];
    }
    else if (tag == TAG_MSG)
    {
        [self processMessage:data];
    }
}
```

GCDAsyncSocket is thread-safe.

# License

This class is in the public domain.

Originally created by Robbie Hanson in Q3 2010.

Updated and maintained by Deusty Designs and the Mac development community.

# Reference

[Delegate Methods](#Delegate_Methods)

-   [socket: didConnectToHost: port:](#socket_didConnectToHost_port)
-   [socket: didReadData: withTag:](#socket_didReadData_withTag)
-   [socket: didReadPartialDataOfLength: tag:](#socket_didReadPartialDataOfLength_tag)
-   [socket: shouldTimeoutReadWithTag: elapsed: bytesDone:](#socket_shouldTimeoutReadWithTag_elapsed_bytesDone)
-   [socket: didWriteDataWithTag:](#socket_didWriteDataWithTag)
-   [socket: didWritePartialDataOfLength: tag:](#socket_didWritePartialDataOfLength_tag)
-   [socket: shouldTimeoutWriteWithTag: elapsed: bytesDone:](#socket_shouldTimeoutWriteWithTag_elapsed_bytesDone)
-   [socketDidSecure:](#socketDidSecure)
-   [socket: didAcceptNewSocket:](#socket_didAcceptNewSocket)
-   [newSocketQueueForConnectionFromAddress: onSocket:](#newSocketQueueForConnectionFromAddress_onSocket)
-   [socketDidCloseReadStream:](#socketDidCloseReadStream)
-   [socketDidDisconnect: withError:](#socketDidDisconnect_withError)

[Initialization](#Initialization)

-   [init](#init)
-   [initWithSocketQueue:](#initWithSocketQueue)
-   [initWithDelegate: delegateQueue:](#initWithDelegate_delegateQueue)
-   [initWithDelegate: delegateQueue: socketQueue:](#initWithDelegate_delegateQueue_socketQueue)

[Configuration](#Configuration)

-   [delegate](#delegate)
-   [setDelegate:](#setDelegate)
-   [delegateQueue](#delegateQueue)
-   [setDelegateQueue:](#setDelegateQueue)
-   [getDelegate: delegateQueue:](#getDelegate_delegateQueue)
-   [setDelegate: delegateQueue:](#setDelegate_delegateQueue)
-   [autoDisconnectOnClosedReadStream](#autoDisconnectOnClosedReadStream)
-   [setAutoDisconnectOnClosedReadStream:](#setAutoDisconnectOnClosedReadStream)
-   [isIPv4Enabled](#isIPv4Enabled)
-   [setIPv4Enabled:](#setIPv4Enabled)
-   [isIPv6Enabled](#isIPv6Enabled)
-   [setIPv6Enabled:](#setIPv6Enabled)
-   [isIPv4PreferredOverIPv6](#isIPv4PreferredOverIPv6)
-   [setPreferIPv4OverIPv6:](#setPreferIPv4OverIPv6)

[Accepting](#Accepting)

-   [acceptOnPort: error:](#acceptOnPort_error)
-   [acceptOnInterface: port: error:](#acceptOnInterface_port_error)

[Connecting](#Connecting)

-   [connectToHost: onPort: error:](#connectToHost_onPort_error)
-   [connectToHost: onPort: withTimeout: error:](#connectToHost_onPort_withTimeout_error)
-   [connectToHost: onPort: viaInterface: withTimeout: error:](#connectToHost_onPort_viaInterface_withTimeout_error)

[Reading](#Reading)

-   [readDataWithTimeout: tag:](#readDataWithTimeout_tag)
-   [readDataWithTimeout: buffer: bufferOffset: tag:](#readDataWithTimeout_buffer_bufferOffset_tag)
-   [readDataWithTimeout: buffer: bufferOffset: maxLength: tag:](#readDataWithTimeout_buffer_bufferOffset_maxLength_tag)
-   [readDataToLength: withTimeout: tag:](#readDataToLength_withTimeout_tag)
-   [readDataToLength: withTimeout: buffer: bufferOffset: tag:](#readDataToLength_withTimeout_buffer_bufferOffset_tag)
-   [readDataToData: withTimeout: tag:](#readDataToData_withTimeout_tag)
-   [readDataToData: withTimeout: buffer: bufferOffset: tag:](#readDataToData_withTimeout_buffer_bufferOffset_tag)
-   [readDataToData: withTimeout: maxLength: tag:](#readDataToData_withTimeout_maxLength_tag)
-   [readDataToData: withTimeout: buffer: bufferOffset: maxLength: tag:](#readDataToData_withTimeout_buffer_bufferOffset_maxLength_tag)

[Writing](#Writing)

-   [writeData: withTimeout: tag:](#writeData_withTimeout_tag)

[Diagnostics](#Diagnostics)

-   [isDisconnected](#isDisconnected)
-   [connectedHost](#connectedHost)
-   [connectedPort](#connectedPort)
-   [localHost](#localHost)
-   [localPort](#localPort)
-   [connectedAddress](#connectedAddress)
-   [localAddress](#localAddress)
-   [isIPv4](#isIPv4)
-   [isIPv6](#isIPv6)

[Disconnecting](#Disconnecting)

-   [disconnect](#disconnect)
-   [disconnectAfterReading](#disconnectAfterReading)
-   [disconnectAfterWriting](#disconnectAfterWriting)
-   [disconnectAfterReadingAndWriting](#disconnectAfterReadingAndWriting)

[Security](#Security)

-   [startTLS:](#startTLS)

[Advanced](#Advanced)

-   [performBlock:](#performBlock)
-   [socketFD](#socketFD)
-   [socket4FD](#socket4FD)
-   [socket6FD](#socket6FD)
-   [readStream](#readStream)
-   [writeStream](#writeStream)
-   [sslContext](#sslContext)

[Utilities](#Utilities)

-   [hostFromAddress:](#hostFromAddress)
-   [portFromAddress:](#portFromAddress)
-   [getHost: port: fromAddress:](#getHost_port_fromAddress)
-   [CRLFData](#CRLFData)
-   [CRData](#CRData)
-   [LFData](#LFData)
-   [ZeroData](#ZeroData)

* * * 
<a name="Delegate_Methods"/>
## Delegate Methods

GCDAsyncSocket is asynchronous. So for most methods, when you initiate an action on a socket (connecting, accepting, reading, writing) the method will return immediately, and the result of the action will be returned to you via the corresponding delegate method.

<br/><a name="socket_didConnectToHost_port"/>
**socket: didConnectToHost: port:**

` - (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port `

> Called when a socket connects and is ready to start reading and writing. The host parameter will be an IP address, not a DNS name.

<br/><a name="socket_didReadData_withTag"/>
**socket: didReadData: withTag:**

` - (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag `

> Called when a socket has completed reading the requested data into memory. Not called if there is an error.

> The tag parameter is the tag you passed when you requested the read operation. For example, in the readDataWithTimeout:tag: method.

<br/><a name="socket_didReadPartialDataOfLength_tag"/>
**socket: didReadPartialDataOfLength: tag:**

` - (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag `

> Called when a socket has read in data, but has not yet completed the read. This would occur if using readDataToData: or readDataToLength: methods. It may be used to for things such as updating progress bars.

> The tag parameter is the tag you passed when you requested the read operation. For example, in the readDataToLength:withTimeout:tag: method.

<br/><a name="socket_shouldTimeoutReadWithTag_elapsed_bytesDone"/>
**socket: shouldTimeoutReadWithTag: elapsed: bytesDone:**

```objective-c
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                                                                 elapsed:(NSTimeInterval)elapsed
                                                               bytesDone:(NSUInteger)length
```

> Called if a read operation has reached its timeout without completing. This method allows you to optionally extend the timeout. If you return a positive time interval (\> 0) the read's timeout will be extended by the given amount. If you don't implement this method, or return a non-positive time interval (<= 0) the read will timeout as usual.

> The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method. The length parameter is the number of bytes that have been read so far for the read operation.

> Note that this method may be called multiple times for a single read if you return positive numbers.

<br/><a name="socket_didWriteDataWithTag"/>
**socket: didWriteDataWithTag:**

` - (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag `

> Called when a socket has completed writing the requested data. Not called if there is an error.

> The tag parameter is the tag you passed when you requested the write operation For example, in the writeData:withTimeout:tag: method.

<br/><a name="socket_didWritePartialDataOfLength_tag"/>
**socket: didWritePartialDataOfLength: tag:**

` - (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag `

> Called when a socket has written some data, but has not yet completed the entire write. It may be used to for things such as updating progress bars.

> The tag parameter is the tag you passed when you requested the write operation For example, in the writeData:withTimeout:tag: method.

<br/><a name="socket_shouldTimeoutWriteWithTag_elapsed_bytesDone"/>
**socket: shouldTimeoutWriteWithTag: elapsed: bytesDone:**

```objective-c
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                                                                  elapsed:(NSTimeInterval)elapsed
                                                                bytesDone:(NSUInteger)length;
```

> Called if a write operation has reached its timeout without completing. This method allows you to optionally extend the timeout. If you return a positive time interval (\> 0) the write's timeout will be extended by the given amount. If you don't implement this method, or return a non-positive time interval (<= 0) the write will timeout as usual.

> The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method. The length parameter is the number of bytes that have been written so far for the write operation.

> Note that this method may be called multiple times for a single write if you return positive numbers.

<br/><a name="socketDidSecure"/>
**socketDidSecure:**

` - (void)socketDidSecure:(GCDAsyncSocket *)sock `

> Called after the socket has successfully completed SSL/TLS negotiation. This method is not called unless you use the provided startTLS method.

> If a SSL/TLS negotiation fails (invalid certificate, etc) then the socket will immediately close, and the socketDidDisconnect:withError: delegate method will be called with the specific SSL error code.

> See Apple's SecureTransport.h file in Security.framework for the list of SSL error codes and their meaning.

<br/><a name="socket_didAcceptNewSocket"/>
**socket: didAcceptNewSocket:**

` - (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket `

> Called when a "server" socket accepts an incoming "client" connection. Another socket is automatically spawned to handle it.

> You must retain the newSocket if you wish to handle the connection. Otherwise the newSocket instance will be released and the spawned connection will be closed.

> By default the new socket will have the same delegate and delegateQueue. You may, of course, change this at any time.

> By default the socket will create its own internal socket queue to operate on. This is configurable by implementing the newSocketQueueForConnectionFromAddress:onSocket: method.

<br/><a name="newSocketQueueForConnectionFromAddress_onSocket"/>
**newSocketQueueForConnectionFromAddress: onSocket:**

` - (dispatch_queue_t)newSocketQueueForConnectionFromAddress:(NSData *)address onSocket:(GCDAsyncSocket *)sock; `

> This method is called immediately prior to socket:didAcceptNewSocket:. It optionally allows a listening socket to specify the socketQueue for a new accepted socket. If this method is not implemented, or returns NULL, the new accepted socket will create its own default queue.

> Since you cannot autorelease a dispatch\_queue, this method uses the "new" prefix in its name to specify that the returned queue has been retained.

> Thus you could do something like this in the implementation:

```objective-c
return dispatch_queue_create("MyQueue", NULL);
```

> If you are placing multiple sockets on the same queue, then care should be taken to increment the retain count each time this method is invoked.

> For example, your implementation might look something like this:

```objective-c
dispatch_retain(myExistingQueue);
return myExistingQueue;
```

<br/><a name="socketDidCloseReadStream"/>
**socketDidCloseReadStream:**

` - (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock `

> Conditionally called if the read stream closes, but the write stream may still be writeable.

> This delegate method is only called if autoDisconnectOnClosedReadStream has been set to NO. See the discussion on the autoDisconnectOnClosedReadStream method for more information.

<br/><a name="socketDidDisconnect_withError"/>
**socketDidDisconnect: withError:**

` - (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error `

> Called when a socket disconnects with or without error.

> If you call the disconnect method, and the socket wasn't already disconnected, this delegate method will be called before the disconnect method returns. (Since the disconnect method is synchronous.)

* * *

## Initialization

GCDAsyncSocket uses the standard delegate paradigm, but executes all delegate callbacks on a given delegate dispatch queue. This allows for maximum concurrency, while at the same time providing easy thread safety.

You MUST set a delegate AND delegate dispatch queue before attempting to use the socket, or you will get an error.

The socket queue is the dispatch queue that the GCDAsyncSocket instance operates on internally. You may optionally set the socket queue during initialization. If you choose not to, or pass NULL, GCDAsyncSocket will automatically create it's own socket queue. If you choose to provide a socket queue, the socket queue must not be a concurrent queue.

The delegate queue and socket queue can optionally be the same.

<br/><a name="init"/>
**init**

` - (id)init `

> Invokes the designated initializer with nil values. You will need to set the delegate and delegateQueue before using the socket.

<br/><a name="initWithSocketQueue"/>
**initWithSocketQueue:**

` - (id)initWithSocketQueue:(dispatch_queue_t)sq `

> Invokes the designated initializer with the given socketQueue. You will need to set the delegate and delegateQueue before using the socket.

<br/><a name="initWithDelegate_delegateQueue"/>
**initWithDelegate: delegateQueue:**

` - (id)initWithDelegate:(id)aDelegate delegateQueue:(dispatch_queue_t)dq `

> Invokes the designated initializer with the given delegate and delegateQueue.

<br/><a name="initWithDelegate_delegateQueue_socketQueue"/>
**initWithDelegate: delegateQueue: socketQueue:**

` - (id)initWithDelegate:(id)aDelegate delegateQueue:(dispatch_queue_t)dq socketQueue:(dispatch_queue_t)sq `

> Designated initializer.

> Initializes the socket with the given delegate and delegate dispatch queue.

> The socket dispatch queue is optional. This is the dispatch queue the socket will operate on internally. If NULL, a new dispatch queue will be created automatically. If you choose to provide a socket queue, the socket queue must not be a concurrent queue.

> The delegate queue and socket queue can optionally be the same.

* * *

## Configuration

<br/><a name="delegate"/>
**delegate**

` - (id)delegate `

> Returns the delegate that is currently set for the socket.

<br/><a name="setDelegate"/>
**setDelegate:**

` - (void)setDelegate:(id)delegate `

> Sets the delegate of the socket.

> It is recommended that you nilify a socket's delegate before releasing the socket. See the disconnect method for more information.

<br/><a name="delegateQueue"/>
**delegateQueue**

` - (dispatch_queue_t)delegateQueue `

> Returns the delegateQueue that is currently set for the socket. All delegate methods will be invoked asynchronously on this queue.

<br/><a name="setDelegateQueue"/>
**setDelegateQueue:**

` - (void)setDelegateQueue:(dispatch_queue_t)delegateQueue `

> Sets the delegateQueue for the socket. After invoking this method, all future delegate methods will be dispatched on the given delegate queue.

<br/><a name="getDelegate_delegateQueue"/>
**getDelegate: delegateQueue:**

` - (void)getDelegate:(id *)delegatePtr delegateQueue:(dispatch_queue_t *)delegateQueuePtr `

> The delegate and delegateQueue often go hand-in-hand. This method provides a thread-safe way to get the current delegate configuration (both the delegate and its queue) in one operation.

<br/><a name="setDelegate_delegateQueue"/>
**setDelegate: delegateQueue:**

` - (void)setDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue `

> Provides an easy and thread-safe way to change both the delegate and delegateQueue in one operation.

> If you plan to change both the delegate and delegateQueue, this method is the preferred way to do so.

<br/><a name="autoDisconnectOnClosedReadStream"/>
**autoDisconnectOnClosedReadStream**

` - (BOOL)autoDisconnectOnClosedReadStream `

> Traditionally sockets are not closed until the conversation is over. However, it is technically possible for the remote endpoint to close its write stream. Our socket would then be notified that there is no more data to be read, but our socket would still be writeable and the remote endpoint could continue to receive our data.

> The argument for this confusing functionality stems from the idea that a client could shut down its write stream after sending a request to the server, thus notifying the server there are to be no further requests. In practice, however, this technique did little to help server developers.

> To make matters worse, from a TCP perspective there is no way to tell the difference from a read stream close and a full socket close. They both result in the TCP stack receiving a FIN packet. The only way to tell is by continuing to write to the socket. If it was only a read stream close, then writes will continue to work. Otherwise an error will be occur shortly (when the remote end sends us a RST packet).

> In addition to the technical challenges and confusion, many high level socket/stream API's provide no support for dealing with the problem. If the read stream is closed, the API immediately declares the socket to be closed, and shuts down the write stream as well. In fact, this is what Apple's CFStream API does. It might sound like poor design at first, but in fact it simplifies development.

> The vast majority of the time if the read stream is closed it's because the remote endpoint closed its socket. Thus it actually makes sense to close the socket at this point. And in fact this is what most networking developers want and expect to happen. However, if you are writing a server that interacts with a plethora of clients, you might encounter a client that uses the discouraged technique of shutting down its write stream. If this is the case, you can set this property to NO, and make use of the [socketDidCloseReadStream](#socketDidCloseReadStream:) delegate method.

> The default value is YES.

<br/><a name="setAutoDisconnectOnClosedReadStream"/>
**setAutoDisconnectOnClosedReadStream:**

` - (void)setAutoDisconnectOnClosedReadStream:(BOOL)flag `

> Sets the autoDisconnectOnClosedReadStream configuration option. See the discussion above for the autoDisconnectOnClosedReadStream method.

<br/><a name="isIPv4Enabled"/>
**isIPv4Enabled**

` - (BOOL)isIPv4Enabled `

> By default, both IPv4 and IPv6 are enabled.

> For accepting incoming connections, this means GCDAsyncSocket automatically supports both protocols, and can simulataneously accept incoming connections on either protocol.

> For outgoing connections, this means GCDAsyncSocket can connect to remote hosts running either protocol. If a DNS lookup returns only IPv4 results, GCDAsyncSocket will automatically use IPv4. If a DNS lookup returns only IPv6 results, GCDAsyncSocket will automatically use IPv6. If a DNS lookup returns both IPv4 and IPv6 results, the preferred protocol will be chosen. By default, the preferred protocol is IPv4, but may be configured as desired.

<br/><a name="setIPv4Enabled"/>
**setIPv4Enabled:**

` - (void)setIPv4Enabled:(BOOL)flag `

> Enables or disables support for IPv4.

> Note: Changing this property on a socket that is already connected or accepting connections does not affect the current socket. It will only affect future connections (after the current socket has been disconnected). Once set, the preference will affect all future connections on the GCDAsyncSocket instance.

<br/><a name="isIPv6Enabled"/>
**isIPv6Enabled**

` - (BOOL)isIPv6Enabled `

> By default, both IPv4 and IPv6 are enabled.

> For accepting incoming connections, this means GCDAsyncSocket automatically supports both protocols, and can simultaneously accept incoming connections on either protocol.

> For outgoing connections, this means GCDAsyncSocket can connect to remote hosts running either protocol. If a DNS lookup returns only IPv4 results, GCDAsyncSocket will automatically use IPv4. If a DNS lookup returns only IPv6 results, GCDAsyncSocket will automatically use IPv6. If a DNS lookup returns both IPv4 and IPv6 results, the preferred protocol will be chosen. By default, the preferred protocol is IPv4, but may be configured as desired.

<br/><a name="setIPv6Enabled"/>
**setIPv6Enabled:**

` - (void)setIPv6Enabled:(BOOL)flag `

> Enables or disables support for IPv6.

> Note: Changing this property on a socket that is already connected or accepting connections does not affect the current socket. It will only affect future connections (after the current socket has been disconnected). Once set, the preference will affect all future connections on the GCDAsyncSocket instance.

<br/><a name="isIPv4PreferredOverIPv6"/>
**isIPv4PreferredOverIPv6**

` - (BOOL)isIPv4PreferredOverIPv6 `

> By default, the preferred protocol is IPv4.

<br/><a name="setPreferIPv4OverIPv6"/>
**setPreferIPv4OverIPv6:**

` - (void)setPreferIPv4OverIPv6:(BOOL)flag `

> Sets the preferred protocol. See the discussions on isIPv4Enabled for more information.

* * *

## Accepting

Once one of the accept or connect methods are called, the GCDAsyncSocket instance is locked in and the other accept/connect methods can't be called without disconnecting the socket first.

When an incoming connection is accepted, GCDAsyncSocket invokes the following delegate methods (in chronological order):

1. newSocketQueueForConnectionFromAddress:onSocket:
2. socket:didAcceptNewSocket:

Your server code will need to retain the accepted socket (if you want to accept it). Otherwise the newly accepted socket will be deallocated shortly after the delegate method returns (during which time the socketDidDisconnect:withError: may fire.)

<br/><a name="acceptOnPort_error"/>
**acceptOnPort: error:**

` - (BOOL)acceptOnPort:(UInt16)port error:(NSError **)errPtr `

> Tells the socket to begin listening and accepting connections on the given port. When a connection is accepted, a new instance of GCDAsyncSocket will be spawned to handle it, and the socket:didAcceptNewSocket: delegate method will be invoked.

> The socket will listen on all available interfaces (e.g. wifi, ethernet, etc).

> This method returns YES if the socket was able to start listening. If an error occurs, this method returns NO and sets the optional errPtr variable. An example of an error might be that no delegate has been set, or the socket is already accepting connections.

<br/><a name="acceptOnInterface_port_error"/>
**acceptOnInterface: port: error:**

` - (BOOL)acceptOnInterface:(NSString *)interface port:(UInt16)port error:(NSError **)errPtr `

> This method is the same as acceptOnPort:error: with the additional option of specifying which interface to listen on.

> For example, you could specify that the socket should only accept connections over ethernet, and not other interfaces such as wifi.

> The interface may be specified by name (e.g. "en1" or "lo0") or by IP address (e.g. "192.168.4.34"). You may also use the special strings "localhost" or "loopback" to specify that the socket only accept connections from the local machine.

> You can see the list of interfaces via the command line utility "ifconfig", or programmatically via the getifaddrs() function.

> To accept connections on any interface pass nil, or simply use the acceptOnPort:error: method.

> This method returns YES if the socket was able to start listening. If an error occurs, this method returns NO and sets the optional errPtr variable. An example of an error might be that no delegate has been set, or the requested interface cannot be found.

* * *

## Connecting

Once one of the accept or connect methods are called, the GCDAsyncSocket instance is locked in and the other accept/connect methods can't be called without disconnecting the socket first.

<br/><a name="connectToHost_onPort_error"/>
**connectToHost: onPort: error:**

` - (BOOL)connectToHost:(NSString *)host onPort:(UInt16)port error:(NSError **)errPtr `

> Connects to the given host and port.

> This method invokes connectToHost:onPort:viaInterface:withTimeout:error: and uses the default interface, and no timeout.

> Returns YES if the asynchronous connection attempt was started. Returns NO If an error was detected with the request and sets the optional errPtr variable.

<br/><a name="connectToHost_onPort_withTimeout_error"/>
**connectToHost: onPort: withTimeout: error:**

` - (BOOL)connectToHost:(NSString *)host onPort:(UInt16)port withTimeout:(NSTimeInterval)timeout error:(NSError **)errPtr `

> Connects to the given host and port with an optional timeout.

> This method invokes connectToHost:onPort:viaInterface:withTimeout:error: and uses the default interface.

<br/><a name="connectToHost_onPort_viaInterface_withTimeout_error"/>
**connectToHost: onPort: viaInterface: withTimeout: error:**

```objective-c
- (BOOL)connectToHost:(NSString *)host
               onPort:(UInt16)port
         viaInterface:(NSString *)interface
          withTimeout:(NSTimeInterval)timeout
                error:(NSError **)errPtr
```

> Connects to the given host & port, via the optional interface, with an optional timeout.

> The host may be a domain name (e.g. "deusty.com") or an IP address string (e.g. "192.168.0.2"). The interface may be a name (e.g. "en1" or "lo0") or the corresponding IP address (e.g. "192.168.4.35").

> To not time out use a negative time interval.

> This method will return NO if an error is detected, and set the error pointer (if one was given). Possible errors would be a nil host, invalid interface, or socket is already connected.

> If no errors are detected, this method will start a background connect operation and immediately return YES. The delegate callbacks are used to notify you when the socket connects, or if the host was unreachable.

> Since this class supports queued reads and writes, you can immediately start reading and/or writing. All read/write operations will be queued, and upon socket connection, the operations will be dequeued and processed in order.

* * *

## Reading

The read methods won't block (they are asynchronous). When a read is complete the socket:didReadData:withTag: delegate method is called.

You may optionally set a timeout for any read operation. (To not timeout, use a negative time interval.) If a read operation times out, the corresponding "socket:shouldTimeoutReadWithTag..." delegate method is called to optionally allow you to extend the timeout. Upon a timeout the "socketDidDisconnect:withError:" method is called.

The tag is for your convenience. The tag you pass to the read operation is the tag that is passed back to you in the socket:didReadData:withTag: delegate callback. You can use it as a state id, an array index, widget number, pointer, etc.

You can invoke multiple read methods back-to-back. The reads will queued in request order, and will be dequeued and executed serially.

<br/><a name="readDataWithTimeout_tag"/>
**readDataWithTimeout: tag:**

` - (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag `

> Reads the first available bytes that become available on the socket.

> If the timeout value is negative, the read operation will not use a timeout. If the timeout is zero, the read operation will timeout if data is not immediately available on the socket at the time the read operation is dequeued.

> The tag is for your convenience. The tag you pass to the read operation is the tag that is passed back to you in the socket:didReadData:withTag: delegate callback.

<br/><a name="readDataWithTimeout_buffer_bufferOffset_tag"/>
**readDataWithTimeout: buffer: bufferOffset: tag:**

```objective-c
- (void)readDataWithTimeout:(NSTimeInterval)timeout
                     buffer:(NSMutableData *)buffer
               bufferOffset:(NSUInteger)offset
                        tag:(long)tag;
```

> Reads the first available bytes that become available on the socket. The bytes will be appended to the given byte buffer starting at the given offset. The given buffer will automatically be increased in size if needed.

> If the timeout value is negative, the read operation will not use a timeout. If the timeout is zero, the read operation will timeout if data is not immediately available on the socket at the time the read operation is dequeued.

> If the buffer if nil, the socket will automatically manage the buffer.

> If the bufferOffset is greater than the length of the given buffer, the method will do nothing, and the delegate will not be called.

> If you pass a buffer, you must not alter it in any way while GCDAsyncSocket is using it. After completion, the data returned in socket:didReadData:withTag: will be a subset of the given buffer. That is, it will reference the bytes that were appended to the given buffer.

> The tag is for your convenience. The tag you pass to the read operation is the tag that is passed back to you in the onSocket:didReadData:withTag: delegate callback.

<br/><a name="readDataWithTimeout_buffer_bufferOffset_maxLength_tag"/>
**readDataWithTimeout: buffer: bufferOffset: maxLength: tag:**

```objective-c
- (void)readDataWithTimeout:(NSTimeInterval)timeout
                     buffer:(NSMutableData *)buffer
               bufferOffset:(NSUInteger)offset
                  maxLength:(NSUInteger)length
                        tag:(long)tag;
```

> Reads the first available bytes that become available on the socket. The bytes will be appended to the given byte buffer starting at the given offset. The given buffer will automatically be increased in size if needed. A maximum of length bytes will be read.

> If the timeout value is negative, the read operation will not use a timeout. If the timeout is zero, the read operation will timeout if data is not immediately available on the socket at the time the read operation is dequeued.

> If the buffer if nil, the socket will automatically manage the buffer. If maxLength is zero, no length restriction is enforced.

> If the bufferOffset is greater than the length of the given buffer, the method will do nothing, and the delegate will not be called.

> If you pass a buffer, you must not alter it in any way while GCDAsyncSocket is using it. After completion, the data returned in socket:didReadData:withTag: will be a subset of the given buffer. That is, it will reference the bytes that were appended to the given buffer.

> The tag is for your convenience. The tag you pass to the read operation is the tag that is passed back to you in the onSocket:didReadData:withTag: delegate callback.

<br/><a name="readDataToLength_withTimeout_tag"/>
**readDataToLength: withTimeout: tag:**

` - (void)readDataToLength:(NSUInteger)length withTimeout:(NSTimeInterval)timeout tag:(long)tag `

> Reads the given number of bytes.

> If the timeout value is negative, the read operation will not use a timeout. If the timeout is zero, the read operation will timeout if enough data is not immediately available on the socket at the time the read operation is dequeued.

> If the length is 0, this method does nothing and the delegate is not called.

> The tag is for your convenience. The tag you pass to the read operation is the tag that is passed back to you in the onSocket:didReadData:withTag: delegate callback.

<br/><a name="readDataToLength_withTimeout_buffer_bufferOffset_tag"/>
**readDataToLength: withTimeout: buffer: bufferOffset: tag:**

```objective-c
- (void)readDataToLength:(NSUInteger)length
             withTimeout:(NSTimeInterval)timeout
                  buffer:(NSMutableData *)buffer
            bufferOffset:(NSUInteger)offset
                     tag:(long)tag;
```

> Reads the given number of bytes. The bytes will be appended to the given byte buffer starting at the given offset. The given buffer will automatically be increased in size if needed.

> If the timeout value is negative, the read operation will not use a timeout. If the timeout is zero, the read operation will timeout if enough data is not immediately available on the socket at the time the read operation is dequeued.

> If the buffer if nil, the socket will automatically manage the buffer.

> If the length is 0, this method does nothing and the delegate is not called. If the bufferOffset is greater than the length of the given buffer, the method will do nothing, and the delegate will not be called.

> If you pass a buffer, you must not alter it in any way while GCDAsyncSocket is using it. After completion, the data returned in socket:didReadData:withTag: will be a subset of the given buffer. That is, it will reference the bytes that were appended to the given buffer.

> The tag is for your convenience. The tag you pass to the read operation is the tag that is passed back to you in the onSocket:didReadData:withTag: delegate callback

<br/><a name="readDataToData_withTimeout_tag"/>
**readDataToData: withTimeout: tag:**

` - (void)readDataToData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag `

> Reads bytes until (and including) the passed "data" parameter, which acts as a separator.

> If the timeout value is negative, the read operation will not use a timeout. If the timeout is zero, the read operation will timeout if enough data is not immediately available on the socket at the time the read operation is dequeued.

> If you pass nil or zero-length data as the "data" parameter, the method will do nothing, and the delegate will not be called.

> The tag is for your convenience. The tag you pass to the read operation is the tag that is passed back to you in the onSocket:didReadData:withTag: delegate callback.

> To read a line from the socket, use the line separator (e.g. CRLF for HTTP) as the "data" parameter. Note that this method is not character-set aware, so if a separator can occur naturally as part of the encoding for a character, the read will prematurely end.

<br/><a name="readDataToData_withTimeout_buffer_bufferOffset_tag"/>
**readDataToData: withTimeout: buffer: bufferOffset: tag:**

```objective-c
- (void)readDataToData:(NSData *)data
           withTimeout:(NSTimeInterval)timeout
                buffer:(NSMutableData *)buffer
          bufferOffset:(NSUInteger)offset
                   tag:(long)tag;
```

> Reads bytes until (and including) the passed "data" parameter, which acts as a separator. The bytes will be appended to the given byte buffer starting at the given offset. The given buffer will automatically be increased in size if needed.

> If the timeout value is negative, the read operation will not use a timeout. If the timeout is zero, the read operation will timeout if enough data is not immediately available on the socket at the time the read operation is dequeued.

> If the buffer if nil, a buffer will automatically be created for you.

> If the bufferOffset is greater than the length of the given buffer, the method will do nothing, and the delegate will not be called.

> If you pass a buffer, you must not alter it in any way while GCDAsyncSocket is using it. After completion, the data returned in socket:didReadData:withTag: will be a subset of the given buffer. That is, it will reference the bytes that were appended to the given buffer.

> The tag is for your convenience. The tag you pass to the read operation is the tag that is passed back to you in the socket:didReadData:withTag: delegate callback.

> To read a line from the socket, use the line separator (e.g. CRLF for HTTP) as the "data" parameter. Note that this method is not character-set aware, so if a separator can occur naturally as part of the encoding for a character, the read will prematurely end.

<br/><a name="readDataToData_withTimeout_maxLength_tag"/>
**readDataToData: withTimeout: maxLength: tag:**

```objective-c
- (void)readDataToData:(NSData *)data
           withTimeout:(NSTimeInterval)timeout
             maxLength:(NSUInteger)length
                   tag:(long)tag;
```

> Reads bytes until (and including) the passed "data" parameter, which acts as a separator.

> If the timeout value is negative, the read operation will not use a timeout. If the timeout is zero, the read operation will timeout if enough data is not immediately available on the socket at the time the read operation is dequeued.

> If maxLength is zero, no length restriction is enforced. Otherwise if maxLength bytes are read without completing the read, it is treated similarly to a timeout - the socket is closed with a GCDAsyncSocketReadMaxedOutError. The read will complete successfully if exactly maxLength bytes are read and the given data is found at the end.

> If you pass nil or zero-length data as the "data" parameter, the method will do nothing, and the delegate will not be called. If you pass a maxLength parameter that is less than the length of the data parameter, the method will do nothing, and the delegate will not be called.

> The tag is for your convenience. The tag you pass to the read operation is the tag that is passed back to you in the onSocket:didReadData:withTag: delegate callback.

> To read a line from the socket, use the line separator (e.g. CRLF for HTTP) as the "data" parameter. Note that this method is not character-set aware, so if a separator can occur naturally as part of the encoding for a character, the read will prematurely end.

<br/><a name="readDataToData_withTimeout_buffer_bufferOffset_maxLength_tag"/>
**readDataToData: withTimeout: buffer: bufferOffset: maxLength: tag:**

```objective-c
- (void)readDataToData:(NSData *)data
           withTimeout:(NSTimeInterval)timeout
                buffer:(NSMutableData *)buffer
          bufferOffset:(NSUInteger)offset
             maxLength:(NSUInteger)length
                   tag:(long)tag;
```

> Reads bytes until (and including) the passed "data" parameter, which acts as a separator. The bytes will be appended to the given byte buffer starting at the given offset. The given buffer will automatically be increased in size if needed. A maximum of length bytes will be read.

> If the timeout value is negative, the read operation will not use a timeout. If the timeout is zero, the read operation will timeout if enough data is not immediately available on the socket at the time the read operation is dequeued.

> If the buffer if nil, a buffer will automatically be created for you.

> If maxLength is zero, no length restriction is enforced. Otherwise if maxLength bytes are read without completing the read, it is treated similarly to a timeout - the socket is closed with a AsyncSocketReadMaxedOutError. The read will complete successfully if exactly maxLength bytes are read and the given data is found at the end.

> If you pass a maxLength parameter that is less than the length of the data parameter, the method will do nothing, and the delegate will not be called. If the bufferOffset is greater than the length of the given buffer, the method will do nothing, and the delegate will not be called.

> If you pass a buffer, you must not alter it in any way while GCDAsyncSocket is using it. After completion, the data returned in socket:didReadData:withTag: will be a subset of the given buffer. That is, it will reference the bytes that were appended to the given buffer.

> The tag is for your convenience. The tag you pass to the read operation is the tag that is passed back to you in the onSocket:didReadData:withTag: delegate callback.

> To read a line from the socket, use the line separator (e.g. CRLF for HTTP, see below) as the "data" parameter. Note that this method is not character-set aware, so if a separator can occur naturally as part of the encoding for a character, the read will prematurely end.

* * *

## Writing

The write method won't block (it is asynchronous). When a write is complete the socket:didWriteDataWithTag: delegate method is called.

You may optionally set a timeout for a write operation. (To not timeout, use a negative time interval.) If a write operation times out, the corresponding "socket:shouldTimeoutWriteWithTag..." delegate method is called to optionally allow you to extend the timeout. Upon a timeout the "socketDidDisconnect:withError:" method is called.

The tag is for your convenience. The tag you pass to the write operation is the tag that is passed back to you in the socket:didWriteDataWithTag: delegate callback. You can use it as a state id, an array index, widget number, pointer, etc.

You can invoke multiple write methods back-to-back. The writes will be queued in request order, and will be dequeued and executed serially.

<br/><a name="writeData_withTimeout_tag"/>
**writeData: withTimeout: tag:**

` - (void)writeData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag `

> Writes data to the socket, and calls the delegate when finished.

> If you pass in nil or zero-length data, this method does nothing and the delegate will not be called.

> If the timeout value is negative, the write operation will not use a timeout. If the timeout is zero, the write operation will timeout if all the data cannot immediately be written to the socket at the time the write operation is dequeued.

* * *

## Diagnostics

<br/><a name="isDisconnected"/>
**isDisconnected**

` - (BOOL)isDisconnected `

> Returns YES if the socket is disconnected.

> A disconnected socket may be recycled. That is, it can used again for connecting or listening.

<br/><a name="connectedHost"/>
**connectedHost**

` - (NSString *)connectedHost `

> Returns the IP address of the connected (remote) host in string format.

> If the socket is not connected, returns nil.

<br/><a name="connectedPort"/>
**connectedPort**

` - (UInt16)connectedPort `

> Returns the port number of the connected (remote) host.

> If the socket is not connected, returns 0.

<br/><a name="localHost"/>
**localHost**

` - (NSString *)localHost `

> Returns the IP address of the local interface that was used to connect. For example, this might be something like "192.168.0.4".

> If the socket is not connected, returns nil.

<br/><a name="localPort"/>
**localPort**

` - (UInt16)localPort `

> Returns the port number that was used to connect.

> If the socket is not connected, returns 0.

<br/><a name="connectedAddress"/>
**connectedAddress**

` - (NSData *)connectedAddress `

> Returns the address of the connected (remote) host. This is a 'struct sockaddr' value wrapped in a NSData object. If the socket is IPv4, the data will be of type 'struct sockaddr\_in'. If the socket is IPv6, the data will be of type 'struct sockaddr\_in6'.

> If the socket is not connected, returns nil.

<br/><a name="localAddress"/>
**localAddress**

` - (NSData *)localAddress `

> Returns the address of the local interface that was used to connect. This is a 'struct sockaddr' value wrapped in a NSData object. If the socket is IPv4, the data will be of type 'struct sockaddr\_in'. If the socket is IPv6, the data will be of type 'struct sockaddr\_in6'.

> If the socket is not connected, returns nil.

<br/><a name="isIPv4"/>
**isIPv4**

` - (BOOL)isIPv4 `

> Returns YES if the socket is IPv4.

> For client sockets (those that connect to another host via connectTo...) the socket will either be IPv4 or IPv6.

> For server sockets (those that accept incoming connections via accept...) the socket may be both IPv4 and IPv6. This allows a server to automatically support both protocols.

<br/><a name="isIPv6"/>
**isIPv6**

` - (BOOL)isIPv6 `

> Returns YES if the socket is IPv6.

> For client sockets (those that connect to another host via connectTo...) the socket will either be IPv4 or IPv6.

> For server sockets (those that accept incoming connections via accept...) the socket may be both IPv4 and IPv6. This allows a server to automatically support both protocols.

* * *

## Disconnecting

<br/><a name="disconnect"/>
**disconnect**

` - (void)disconnect `

> Disconnects immediately. Any pending reads or writes are dropped.

> This method is **synchronous**. If the socket is not already disconnected, the socketDidDisconnect:withError: delegate method will be called immediately, before this method returns.

> Please note the recommended way of releasing a GCDAsyncSocket instance (e.g. in a dealloc method)

```objective-c
[asyncSocket setDelegate:nil delegateQueue:NULL];
[asyncSocket disconnect];
[asyncSocket release];
```

<br/><a name="disconnectAfterReading"/>
**disconnectAfterReading**

` - (void)disconnectAfterReading `

> Disconnects after all pending reads have completed. This method is asynchronous and returns immediately (even if there are no pending reads).

> After calling this method, the read and write methods will do nothing. The socket will disconnect even if there are still pending writes.

<br/><a name="disconnectAfterWriting"/>
**disconnectAfterWriting**

` - (void)disconnectAfterWriting `

> Disconnects after all pending writes have completed. This method is asynchronous and returns immediately (even if there are no pending writes).

> After calling this method, the read and write methods will do nothing. The socket will disconnect even if there are still pending reads.

<br/><a name="disconnectAfterReadingAndWriting"/>
**disconnectAfterReadingAndWriting**

` - (void)disconnectAfterReadingAndWriting `

> Disconnects after all pending reads and writes have completed. This method is asynchronous and returns immediately (even if there are no pending reads or writes).

> After calling this, the read and write methods will do nothing.

* * *

## Security

<br/><a name="startTLS"/>
**startTLS:**

` - (void)startTLS:(NSDictionary *)tlsSettings `

> Secures the connection using SSL/TLS.

> This method may be called at any time, and the SSL/TLS handshake will occur after all pending reads and writes are finished. This allows one the option of sending a protocol dependent StartTLS message, and queuing the upgrade to TLS at the same time, without having to wait for the write to finish. Any reads or writes scheduled after this method is called will occur over the secured connection.

> The possible keys and values for the TLS settings are well documented. Some possible keys are:

-   kCFStreamSSLLevel
-   kCFStreamSSLAllowsExpiredCertificates
-   kCFStreamSSLAllowsExpiredRoots
-   kCFStreamSSLAllowsAnyRoot
-   kCFStreamSSLValidatesCertificateChain
-   kCFStreamSSLPeerName
-   kCFStreamSSLCertificates
-   kCFStreamSSLIsServer

> Please refer to Apple's documentation for associated values, as well as other possible keys.

> If you pass in nil or an empty dictionary, the default settings will be used.

> The default settings will check to make sure the remote party's certificate is signed by a trusted 3rd party certificate agency (e.g. verisign) and that the certificate is not expired. However it will not verify the name on the certificate unless you give it a name to verify against via the kCFStreamSSLPeerName key.

> Note: **The security implications of this are important to understand.**

> Imagine you are attempting to create a secure connection to MySecureServer.com, but your socket gets directed to MaliciousServer.com because of a hacked DNS server. If you simply use the default settings, and MaliciousServer.com has a valid certificate, the default settings will not detect any problems since the certificate is valid. To properly secure your connection in this particular scenario you should set the kCFStreamSSLPeerName property to "MySecureServer.com".

> If you do not know the peer name of the remote host in advance (for example, you're not sure if it will be "domain.com" or "www.domain.com"), then you can use the default settings to validate the certificate, and then use the X509Certificate class to verify the issuer after the socket has been secured. The X509Certificate class is part of the CocoaAsyncSocket open source project.

> Note: The SSL/TLS support is implemented using Apple's Secure Transport framework. This means you actually have access to a much wider array of security options. Except on iOS, where Apple has decided to make Secure Transport a private framework. So on iOS you're stuck with what's available via CFStream.

* * *

## Advanced

<br/><a name="performBlock"/>
**performBlock:**

` - (void)performBlock:(dispatch_block_t)block `

> It's not thread-safe to access certain variables from outside the socket's internal queue.

> For example, the socket file descriptor. File descriptors are simply integers which reference an index in the per-process file table. However, when one requests a new file descriptor (by opening a file or socket), the file descriptor returned is guaranteed to be the lowest numbered unused descriptor. So if we're not careful, the following could be possible:

1.  Thread A invokes a method which returns the socket's file descriptor.
2.  The socket is closed via the socket's internal queue on thread B.
3.  Thread C opens a file, and subsequently receives the file descriptor that was previously the socket's FD.
4.  Thread A is now accessing/altering the file instead of the socket.

> In addition to this, other variables are not actually objects, and thus cannot be retained/released or even autoreleased. An example is the sslContext, of type SSLContextRef, which is actually a malloc'd struct.

> Although there are internal variables that make it difficult to maintain thread-safety, it is important to provide access to these variables to ensure this class can be used in a wide array of environments. This can be accomplished by invoking a block on the socket's internal queue. The methods below can be invoked from within the block to access those generally thread-unsafe internal variables in a thread-safe manner. The given block will be invoked synchronously on the socket's internal queue.

> If you save references to any protected variables and use them outside the block, you do so at your own peril.

<br/><a name="socketFD"/>
**socketFD**

` - (int)socketFD `

> This method is only available from within the context of a performBlock: invocation. See the documentation for the performBlock: method above.

> Provides access to the socket's file descriptor.

> This method is typically used for outgoing client connections. If the socket is a server socket (is accepting incoming connections), it might actually have multiple internal socket file descriptors - one for IPv4 and one for IPv6.

> Returns -1 if the socket is disconnected.

<br/><a name="socket4FD"/>
**socket4FD**

` - (int)socket4FD `

> This method is only available from within the context of a performBlock: invocation. See the documentation for the performBlock: method above.

> Provides access to the socket's file descriptor (if IPv4 is being used).

> If the socket is a server socket (is accepting incoming connections), it might actually have multiple internal socket file descriptors - one for IPv4 and one for IPv6.

> Returns -1 if the socket is disconnected, or if IPv4 is not being used.

<br/><a name="socket6FD"/>
**socket6FD**

` - (int)socket6FD `

> This method is only available from within the context of a performBlock: invocation. See the documentation for the performBlock: method above.

> Provides access to the socket's file descriptor (if IPv6 is being used).

> If the socket is a server socket (is accepting incoming connections), it might actually have multiple internal socket file descriptors - one for IPv4 and one for IPv6.

> Returns -1 if the socket is disconnected, or if IPv6 is not being used.

<br/><a name="readStream"/>
**readStream**

` - (CFReadStreamRef)readStream `

> This method is only available on iOS (TARGET\_OS\_IPHONE).

> This method is only available from within the context of a performBlock: invocation. See the documentation for the performBlock: method above.

> Provides access to the socket's internal CFReadStream (if SSL/TLS has been started on the socket).

> Note: Apple has decided to keep the SecureTransport framework private on iOS. This means the only supplied way to do SSL/TLS is via CFStream or some other API layered on top of it. Thus, in order to provide SSL/TLS support on iOS we are forced to rely on CFStream, instead of the preferred and more powerful SecureTransport. Read/write streams are only created if startTLS has been invoked to start SSL/TLS.

<br/><a name="writeStream"/>
**writeStream**

` - (CFWriteStreamRef)writeStream `

> This method is only available on iOS (TARGET\_OS\_IPHONE).

> This method is only available from within the context of a performBlock: invocation. See the documentation for the performBlock: method above.

> Provides access to the socket's internal CFWriteStream (if SSL/TLS has been started on the socket).

> Note: Apple has decided to keep the SecureTransport framework private on iOS. This means the only supplied way to do SSL/TLS is via CFStream or some other API layered on top of it. Thus, in order to provide SSL/TLS support on iOS we are forced to rely on CFStream, instead of the preferred and more powerful SecureTransport. Read/write streams are only created if startTLS has been invoked to start SSL/TLS.

<br/><a name="sslContext"/>
**sslContext**

` - (SSLContextRef)sslContext `

> This method is only available on Mac OS X (TARGET\_OS\_MAC).

> This method is only available from within the context of a performBlock: invocation. See the documentation for the performBlock: method above.

> Provides access to the socket's SSLContext, if SSL/TLS has been started on the socket.

* * *

## Utilities

<br/><a name="hostFromAddress"/>
**hostFromAddress:**

` + (NSString *)hostFromAddress:(NSData *)address `

> Extracts the host IP information from raw address data.

> The address should be a 'struct sockaddr' wrapped in NSData. For IPv4 this will be a 'struct sockaddr\_in'. For IPv6 this will be a 'struct sockaddr\_in6'.

> The returned host will be in presentation format. (inet\_ntop)

> Returns nil if an invalid address is given.

<br/><a name="portFromAddress"/>
**portFromAddress:**

` + (UInt16)portFromAddress:(NSData *)address `

> Extracts the port from raw address data.

> The address should be a 'struct sockaddr' wrapped in NSData. For IPv4 this will be a 'struct sockaddr\_in'. For IPv6 this will be a 'struct sockaddr\_in6'.

> The returned port will be converted from network order to host order. (ntohs)

> Returns 0 is an invalid address is given.

<br/><a name="getHost_port_fromAddress"/>
**getHost: port: fromAddress:**

` + (BOOL)getHost:(NSString **)hostPtr port:(UInt16 *)portPtr fromAddress:(NSData *)address `

> Extracts the host IP and port information from raw address data.

> The address should be a 'struct sockaddr' wrapped in NSData. For IPv4 this will be a 'struct sockaddr\_in'. For IPv6 this will be a 'struct sockaddr\_in6'.

> The hostPtr (if given) will be set using inet\_ntop. The portPtr (if given) will be set using ntohs.

> Returns NO if an invalid address is given (in which case neither hostPtr nor portPtr will be modified).

<br/><a name="CRLFData"/>
**CRLFData**

` + (NSData *)CRLFData `

> Carriage-Return, Line-Feed. (0x0D0A)

> A common line separator, for use with the readDataToData:... methods.

<br/><a name="CRData"/>
**CRData**

` + (NSData *)CRData `

> Carriage-Return. (0x0D)

> A common line separator, for use with the readDataToData:... methods.

<br/><a name="LFData"/>
**LFData**

` + (NSData *)LFData `

> Line-Feed. (0x0A)

> A common line separator, for use with the readDataToData:... methods.

<br/><a name="ZeroData"/>
**ZeroData**

` + (NSData *)ZeroData `

> Zero Byte. Also known as a Null Byte or Null Character (at the end of a string). (0x00)

> A common line separator, for use with the readDataToData:... methods.
