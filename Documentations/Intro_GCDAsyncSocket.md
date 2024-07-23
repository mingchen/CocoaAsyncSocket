**GCDAsyncSocket** is a TCP library. It's built atop Grand Central Dispatch.

This page provides an introduction to the library.

## Initialization

The most common way to initialize an instance is simply like this:
```objective-c
socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
```

The delegate and delegate_queue are required in order for GCDAsyncSocket to invoke your delegate methods. The code above specifies "self" as the delegate, and instructs the library to invoke all delegate methods on the main thread.

Setting a delegate is likely a familiar operation. However, providing a delegateQueue may be a new concept. Most typical libraries are single-threaded. When it's time to invoke a delegate method, they just call it. The libraries assume your delegate code is also single-thread. Or the libraries may be multi-threaded internally, but they assume your delegate code is only single-threaded, and designed to run only on the main thread. So they simply always invoke all delegate methods on the main thread.

GCDAsyncSocket, on the other hand, was designed for performance. It allows you to receive delegate callbacks on dedicated gcd queues of your choosing. This allows it to be used in high-performance servers, and can support thousands upon thousands of concurrent connections. But it also helps in typical applications. Want your UI to be a bit snappier? Ever considered moving that network processing code off the UI thread? Even today's mobile devices have multiple CPU cores... perhaps it's time to start taking advantage of them.

## Configuration

Most of the time no configuration is necessary. There are various configuration options (as described in the header file), but they're mainly for advanced use cases.

Note: Security (TLS/SSL) is something you setup later. These protocols actually run on **top** of TCP (they're not part of TCP itself.)

## Connecting

The most common way to connect is:
```objective-c
NSError *err = nil;
if (![socket connectToHost:@"deusty.com" onPort:80 error:&err]) // Asynchronous!
{
    // If there was an error, it's likely something like "already connected" or "no delegate set"
    NSLog(@"I goofed: %@", err);
}
```

The connect methods are asynchronous. What does this mean? It means when you call the connect methods, they start a background operation to connect to the desired host/port, and then immediately return. This asynchronous background operation will eventually either succeed or fail. Either way, the associated delegate method will be called:

```objective-c
- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Cool, I'm connected! That was easy.");
}
```

So if the connect method is asynchronous, why does it return a boolean and error? The only time this method will return NO is if something obvious prevents it from starting the connect operation. For example, if the socket is already connected, or if the delegate was never set.

There are actually several different connect methods available to you. They afford you different options such as:

- Optionally specify a connect timeout.<br/>
  _E.g. Fail if it doesn't connect in 5 seconds_

- Optionally specify the interface to connect with<br/>
  _E.g. Connect using bluetooth, or Connect using WiFi regardless of whether a wired connection is available._

- Supply a raw socket address instead of a name/port pair<br/>
  _E.g. I resolved an address using NSNetService, and I just want to connect to that address._

## Reading & Writing

One of the best features of the library is "queued read/write operations". What does that mean? A quick code example may explain it best:
```objective-c
NSError *err = nil;
if (![socket connectToHost:@"deusty.com" onPort:80 error:&err]) // Asynchronous!
{
    // If there was an error, it's likely something like "already connected" or "no delegate set"
    NSLog(@"I goofed: %@", err);
    return;
}

// At this point the socket is NOT connected.
// But I can start writing to it anyway!
// The library will queue all my write operations,
// and after the socket connects, it will automatically start executing my writes!
[socket writeData:request1 withTimeout:-1 tag:1];

// In fact, I know I have 2 requests.
// Why not just get them both out of the way now?
[socket writeData:request2 withTimeout:-1 tag:2];

// Heck, while I'm at it, I might as well queue up the read for the first response.
[socket readDataToLength:responseHeaderLength withTimeout:-1 tag:TAG_RESPONSE_HEADER];
```

You may have noticed the tag parameter. What's that all about? Well, it's all about convenience for you. The tag parameter you specify is not sent over the socket or read from the socket. The tag parameter is simply echo'd back to you via the various delegate methods. It is designed to help simplify the code in your delegate method.

```objective-c
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == 1)
        NSLog(@"First request sent");
    else if (tag == 2)
        NSLog(@"Second request sent");
}
```

Tags are most helpful when it comes to reading:
```objective-c
#define TAG_WELCOME 10
#define TAG_CAPABILITIES 11
#define TAG_MSG 12

- (void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag
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

You see, the TCP protocol is modeled on the concept of a **single continuous stream** of unlimited length. It's critical to understand this - and is, in fact, the **number one cause of confusion** that we see.

Imagine that you're trying to send a few messages over the socket. So you do something like this (in pseudocode):
```c
socket.write("Hi Sandy.");
socket.write("Are you busy tonight?");
```

How does the data show up on the other end? If you think the other end will receive two separate sentences in two separate reads, then you've just fallen victim to a common pitfall! _Gasp!_ But fear not! Your condition isn't life threatening; it's just a common cold. The cure can be found by reading the [[Common Pitfalls | CommonPitfalls]] page.

Now that we have that out of the way, you may be wondering about those read methods. Here's a few of them:

```objective-c
- (void)readDataToLength:(NSUInteger)length withTimeout:(NSTimeInterval)timeout tag:(long)tag;
- (void)readDataToData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag;
```

The first method, readDataToLength, reads and returns data of the given length. Let's take a look at an example:

You're writing the client-side of a protocol where the server sends responses with a fixed-length header. The header for all responses is exactly 8 bytes. The first 4 bytes contain various flags, etc. And the second 4 bytes contain the length of the response data, which is variable. So you might have code that looks like this:

```objective-c
- (void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag
{
    if (tag == TAG_FIXED_LENGTH_HEADER)
    {
        int bodyLength = [self parseHeader:data];
        [socket readDataToLength:bodyLength withTimeout:-1 tag:TAG_RESPONSE_BODY];
    }
    else if (tag == TAG_RESPONSE_BODY)
    {
        // Process the response
        [self handleResponseBody:data];

        // Start reading the next response
        [socket readDataToLength:headerLength withTimeout:-1 tag:TAG_FIXED_LENGTH_HEADER];
    }
}
```

Let's look at another example. After all, not all protocols use a fixed length header. HTTP is one such protocol.

A typical HTTP response looks something like this:

> HTTP/1.1 200 OK<br/>
> Date: Thu, 24 Nov 2011 02:18:50 GMT<br/>
> Server: Apache/2.2.3 (CentOS)<br/>
> X-Powered-By: PHP/5.1.6<br/>
> Content-Length: 5233<br/>
> Content-Type: text/html; charset=UTF-8<br/>

That's just an example. There could be any number of header fields. In other words, the HTTP header has a variable length. How do we read it?

Well the HTTP protocol explains how. Each line in the header is terminated with a CRLF (carriage-return, line-feed : "\\r\\n"). Furthermore, the end of the header is marked with 2 back-to-back CRLF's. And the length of the body is specified via the "Content-Length" header field. So we could do something like this:

```objective-c
- (void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag
{
    if (tag == HTTP_HEADER)
    {
        int bodyLength = [self parseHttpHeader:data];
        [socket readDataToLength:bodyLength withTimeout:-1 tag:HTTP_BODY];
    }
    else if (tag == HTTP_BODY)
    {
        // Process response
        [self processHttpBody:data];

        // Read header of next response
        NSData *term = [@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding];
        [socket readDataToData:term withTimeout:-1 tag:HTTP_HEADER];
    }
}
```

I've listed 2 available read methods. There are close to 10 different read methods available. They provide more advanced options such as specifying a maxLength, or providing your own read buffer.

## Writing a server

GCDAsyncSocket also allows you to create a server, and accept incoming connections. It looks something like this:
```objective-c
listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

NSError *error = nil;
if (![listenSocket acceptOnPort:port error:&error])
{
    NSLog(@"I goofed: %@", error);
}

- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    // The "sender" parameter is the listenSocket we created.
    // The "newSocket" is a new instance of GCDAsyncSocket.
    // It represents the accepted incoming client connection.

    // Do server stuff with newSocket...
}
```

It's as simple as that! For a more concrete example, see the "EchoServer" sample project that comes with the repository.