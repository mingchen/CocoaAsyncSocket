[Automatic Reference Counting](http://clang.llvm.org/docs/AutomaticReferenceCounting.html) (ARC) is an amazing new technology. It makes life easier for developers and speeds up your code at the same time. However, since it's such a radical change, it requires some new tools (Xcode 4.2+, Apple LLVM 3.0+ compiler) and some code changes (remove retain/release/autorelease, etc). This leaves library developers in a tough position: To ARC, or not to ARC? If the library is converted to ARC, those who haven't converted their apps will complain. If the library isn't converted to ARC, those who have converted their apps will complain! What to do?

One possibility is to maintain 2 branches: arc & non-arc. These would have to be kept in sync for every new commit and every push. Obviously this is a large burden. And library developers, especially those who actively develop and improve their libraries, don't consider this a solution. So ultimately, a decision must be made.

We believe that ARC will quickly become the defacto standard. Manual memory management has long been the single largest entrance barrier to the language, and the most common complaint. It required sometimes tedious balancing of retain/release statements, and even seasoned professionals were known to occasionally leak an object or forget a release in a dealloc method. Garbage collection was tried and largely rejected (for apparent performance reasons). But now ARC has arrived! And we believe it is the future.

If you've already adopted ARC, then you can just drop in CocoaAsyncSocket libraries and go. If not, then read on.

## Older Non-ARC versions of CocoaAsyncSocket

The project was converted to ARC in version 7.1. So if you're unable to adapt the ARC versions due to requirements, then you can grab the latest 7.0.X release.

Note: The 7.0.X branch is deprecated. It may receive major bug fixes, but that's it. Please adopt recent versions of Xcode and Apple's modern LLVM compilers so you can take advantage of recent technology improvements.

## Supporting ARC versions of CocoaAsyncSocket in Non-ARC projects

The first thing to note is the requirements for supporting ARC in any capacity in your project.

**Development requirements for ARC**

- Xcode 4.2
- Apple LLVM compiler 3.0+ (Build Setting)

**Minimum Deployment Targets for ARC**

- iOS: iOS 4.0 or newer
- Mac: 64-Bit processor running Snow Leopard 10.6 or newer.

If you attempt to compile the latest versions of CocoaAsyncSocket in a non-arc project, you'll receive a warning:

![Screenshot of ARC warnings](http://www.deusty.com/blog/CocoaAsyncSocket/arc1.png)

Don't ignore these warnings! You'll leak memory like crazy if you do!

(If it weren't for complications when using Xcode's "Convert to Objective-C ARC" tool, the warnings would be errors.)

First ensure you're using the Apple LLVM compiler (version 3.0 or newer):

![Xcode build setting for Apple LLVM compiler](http://www.deusty.com/blog/CocoaAsyncSocket/arc2.png)

Then tell the compiler that the CocoaAsyncSocket library files are ARC:

![Flagging files as ARC in Xcode](http://www.deusty.com/blog/CocoaAsyncSocket/arc3.png)

The warnings will go away, and the compiler will automatically add all the proper retain/release/autorelease calls to the ARC files during compilation.
