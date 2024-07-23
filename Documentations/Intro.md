## Introduction to Sockets

If you're a beginner to networking, this is the place to start. Working with a socket can be very different from working with a file, even though the APIs may be similar. A little bit of investment in your knowledge and understanding of networking fundamentals can go a long way. And it can save you a lot of time and frustration in the long run.

We will keep it brief, and will maintain a focus on developers: just what developers need to accomplish their goal, while not skipping important fundamentals that could later cause problems.

## Sockets, Ports, and DNS - Oh My! 

In networking parlance, a computer is a host for a number of sockets. A socket is one end of a communication channel called a network connection; the other end is another socket. From its own point of view, any socket is the local socket, and the socket at the other end of the connection is the remote socket.

To establish the connection, one of the two sockets must contact the other socket. To make contact the socket must know the other socket's address. Every socket has an address. The address consists of two parts: the host address and the port number. The host address is the IP address of the computer, and the port number uniquely identifies each socket hosted on the computer.

A computer can have multiple host addresses because it can have multiple networking interfaces. For example, a computer might be equipped with an ethernet card, a modem, a WiFi card, a VPN connection, Bluetooth, etc. And in addition to all this, there is a special interface for connecting to itself (called "loopback" or sometimes “localhost”).

An address such as “google.com” corresponds to a host address, but it is not a host address itself. It is a DNS entry or DNS name, which is converted to a host address by a DNS look-up operation. One can think of DNS like a phone book. If you wanted to call someone, but didn't know their number, you could lookup their number in the phone book. Their name is matched to a phone number. Similarly, DNS matches a name (such as "google.com") to an IP address.

## Networking Huh?

**The crux of the problem is that the network you'll be communicating over is unreliable.** Perhaps you're sending data out over the Internet. Maybe it's going to be sent via WiFi, or some cellular connection. Or maybe it's going to be sent into space via a satellite. You might not even know.

But let's assume for a moment that you did know. Let's assume you knew that all communication was going to take place over regular ethernet, within a closed business network. The communication would be 100% reliable right? Wrong. And I'm not referring to cut wires or power outages either.

All data that gets sent or received gets broken into little packets. These packets then get pumped onto the network, and arrive at routers which have to decide where they go. But during bursts of traffic, a router might get overloaded with packets. Packets are coming in faster than the router can figure out where to route them. What happens? The same thing that happens millions of times a day all over the world: the router starts dropping packets.

In addition to lost packets on the network, the receiving computer might be forced to drop packets too. Perhaps the computer is overloaded, or the receiving application isn't reading the data from the OS fast enough. There's also the potential that the packet was corrupted during transmission, perhaps from electrical interference. And all of this is without getting into other issues introduced by things like the WiFi or the Internet.

If you're new to networking, you might be thinking that it's a miracle that everything works as well as it does. The fact is, the miracle is derived from the networking protocols that have been perfected over the last several decades, and from the developers that understand them and use them effectively. (That's you!)

## Bring on the Protocols

You can probably list dozens of protocols that have something to do with computer networking:

HTTP, FTP, XMPP, POP, IMAP, SMTP, DHCP, DNS, VoIP, SIP, RTP, RTCP, ...

But every single one of these protocols is layered on top of another protocol that handles the networking for it. These lower level protocols handle the majority of the networking aspect so that the application layer protocol (those listed above) can focus on the application aspect.

The "application layer protocols" listed above are layered on top of a "transport layer protocol". And of all the protocols listed above, there are only two transport layer protocols that are used: TCP and UDP.

### UDP

The User Datagram Protocol (UDP) is the simpler of the two. You can only put a small amount of data into a UDP packet, and then you send it on its way. And then... that's it. There is no guarantee that the message will arrive. And if you send multiple packets back-to-back, there is no guarantee that they will arrive in order. Seems pretty unreliable, no? But it's weakness is also its strength. If you are sending time-sensitive data, such as audio in a VoIP call, then you don't want your transport protocol wasting time retransmitting lost packets since the lost audio would arrive too late to be played anyway. In fact, streaming audio and video are some of the biggest uses for UDP.

UDP also has an advantage that it doesn't require a "connection handshake". Think about it like this: If you were sitting on a train, and you wanted to have a long conversation with the stranger next to you, you would probably start with an introduction. Something like, "Where are you heading? Oh yeah, I'm heading in that direction too. My name's Robbie, what's yours?" But if you just wanted to know what the time was, then you could skip the introduction. You wouldn't be expected to tell the stranger your name. You could just say, "Excuse me, do you have the time?" To which the stranger could quickly respond, and you could both go back to doing whatever you were doing. This is why a protocol like DNS uses UDP. That way your computer can say, "Excuse me, what is the IP of google.com?" And the server can quickly respond.

### TCP

The Transmission Control Protocol (TCP) is probably the protocol you use the most. Whether you're browsing the web, checking your email, or sending instant messages to friends, you're probably using TCP.

TCP is designed for "long conversations". So there is an initial connection handshake, and after that data can flow back and forth for as long as necessary. But the great thing about TCP is that it was designed to make communication reliable in the face of an unreliable network. So it does all kinds of really cool stuff for us. If you send some information over TCP, and part of it gets lost, the protocol will automatically figure out what got lost and resend it. And when you send information, TCP makes sure that information always arrives in the correct order. But wait, there's more! The protocol will also detect congestion in the network, and automatically scale accordingly so everybody can share.

So there are a lot of great reasons to use TCP, and it fits in nicely with a lot of networking tasks. Plus there is no limit to the amount of data you can send via TCP. It is designed to be an open stream of data flowing in both/either direction. It is simply up to the application layer to determine what that data looks like.

## Where do we fit in?

So... UDP and TCP... how do we use them? Is that what the CocoaAsyncSocket libraries provide? Implementations of TCP and UDP? Nope, not quite. As you can imagine, TCP and UDP are used all over the place. So naturally they are provided by the operating system. If you open up your terminal and type "man socket" you can see the low level BSD socket API. The libraries are essentially wrappers that sits on top of low-level socket API's and provide you, the developer, an easy to use framework in Objective-C.

So CocoaAsyncSocket provides a great API that simplifies networking for you. But networking can still be tricky, so we recommend you read the following before you get started:

- [[General Documentation | GeneralDocumentation]]
- [[Common Pitfalls | CommonPitfalls]]

Another invaluable resource is the [CocoaAsyncSocket mailing list](http://groups.google.com/group/cocoaasyncsocket).
