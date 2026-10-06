// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#import <MetalKit/MTKView.h>
#import <Metal/stubs.h>
#import <Foundation/NSObjectInternal.h>

#if DARLING_METAL_ENABLED

static BOOL pixelFormatHasDepth(MTLPixelFormat format) {
	switch (format) {
		case MTLPixelFormatDepth16Unorm:
		case MTLPixelFormatDepth32Float:
		case MTLPixelFormatDepth24Unorm_Stencil8:
		case MTLPixelFormatDepth32Float_Stencil8:
			return YES;
		default:
			return NO;
	}
};

static BOOL pixelFormatHasStencil(MTLPixelFormat format) {
	switch (format) {
		case MTLPixelFormatStencil8:
		case MTLPixelFormatDepth24Unorm_Stencil8:
		case MTLPixelFormatDepth32Float_Stencil8:
		case MTLPixelFormatX32_Stencil8:
		case MTLPixelFormatX24_Stencil8:
			return YES;
		default:
			return NO;
	}
};

#endif

@implementation MTKView

#if DARLING_METAL_ENABLED

{
	id<MTKViewDelegate> _delegate;
	NSInteger _preferredFramesPerSecond;
	BOOL _paused;
	BOOL _enableSetNeedsDisplay;
	id<CAMetalDrawable> _currentDrawable;
	NSTimer* _frameTimer;
	id<MTLTexture> _depthStencilTexture;
}

//
// properties
//

@synthesize autoResizeDrawable = _autoResizeDrawable;
@synthesize clearColor = _clearColor;
@synthesize depthStencilPixelFormat = _depthStencilPixelFormat;
@synthesize depthStencilAttachmentTextureUsage = _depthStencilAttachmentTextureUsage;
@synthesize depthStencilStorageMode = _depthStencilStorageMode;
@synthesize clearDepth = _clearDepth;
@synthesize clearStencil = _clearStencil;
@synthesize sampleCount = _sampleCount;
@synthesize multisampleColorAttachmentTextureUsage = _multisampleColorAttachmentTextureUsage;
@synthesize preferredFramesPerSecond = _preferredFramesPerSecond;
@synthesize paused = _paused;
@synthesize enableSetNeedsDisplay = _enableSetNeedsDisplay;

- (id<MTKViewDelegate>)delegate
{
	return objc_loadWeak(&_delegate);
}

- (void)setDelegate: (id<MTKViewDelegate>)delegate
{
	objc_storeWeak(&_delegate, delegate);
}

- (id<MTLDevice>)device
{
	return ((CAMetalLayer*)_layer).device;
}

- (void)setDevice: (id<MTLDevice>)device
{
	((CAMetalLayer*)_layer).device = device;
}

- (id<MTLDevice>)preferredDevice
{
	return ((CAMetalLayer*)_layer).preferredDevice;
}

- (MTLPixelFormat)colorPixelFormat
{
	return ((CAMetalLayer*)_layer).pixelFormat;
}

- (void)setColorPixelFormat: (MTLPixelFormat)colorPixelFormat
{
	((CAMetalLayer*)_layer).pixelFormat = colorPixelFormat;
}

- (CGColorSpaceRef)colorspace
{
	return ((CAMetalLayer*)_layer).colorspace;
}

- (void)setColorspace: (CGColorSpaceRef)colorspace
{
	((CAMetalLayer*)_layer).colorspace = colorspace;
}

- (BOOL)framebufferOnly
{
	return ((CAMetalLayer*)_layer).framebufferOnly;
}

- (void)setFramebufferOnly: (BOOL)framebufferOnly
{
	((CAMetalLayer*)_layer).framebufferOnly = framebufferOnly;
}

- (CGSize)drawableSize
{
	return ((CAMetalLayer*)_layer).drawableSize;
}

- (void)setDrawableSize: (CGSize)drawableSize
{
	((CAMetalLayer*)_layer).drawableSize = drawableSize;
	[_delegate mtkView: self drawableSizeWillChange: drawableSize];
}

- (CGSize)preferredDrawableSize
{
	// TODO: multiply by contentsScale
	return self.bounds.size;
}

- (MTLRenderPassDescriptor*)currentRenderPassDescriptor
{
	id<MTLDevice> device = self.device;

	if (!device) {
		return nil;
	}

	id<CAMetalDrawable> drawable = self.currentDrawable;

	if (!drawable) {
		return nil;
	}

	MTLRenderPassDescriptor* desc = [MTLRenderPassDescriptor renderPassDescriptor];

	desc.colorAttachments[0].texture = drawable.texture;
	desc.colorAttachments[0].clearColor = _clearColor;
	desc.colorAttachments[0].loadAction = MTLLoadActionClear;
	desc.colorAttachments[0].storeAction = MTLStoreActionStore;

	id<MTLTexture> depthStencilTexture = self.depthStencilTexture;

	if (depthStencilTexture) {
		if (pixelFormatHasDepth(_depthStencilPixelFormat)) {
			desc.depthAttachment.texture = depthStencilTexture;
			desc.depthAttachment.clearDepth = _clearDepth;
			desc.depthAttachment.loadAction = MTLLoadActionClear;
			desc.depthAttachment.storeAction = MTLStoreActionDontCare;
		}

		if (pixelFormatHasStencil(_depthStencilPixelFormat)) {
			desc.stencilAttachment.texture = depthStencilTexture;
			desc.stencilAttachment.clearStencil = _clearStencil;
			desc.stencilAttachment.loadAction = MTLLoadActionClear;
			desc.stencilAttachment.storeAction = MTLStoreActionDontCare;
		}
	}

	return desc;
}

- (id<CAMetalDrawable>)currentDrawable
{
	if (!_currentDrawable) {
		_currentDrawable = [[(CAMetalLayer*)_layer nextDrawable] retain];
	}
	return _currentDrawable;
}

- (id<MTLTexture>)depthStencilTexture
{
	id<MTLDevice> device = self.device;
	CGSize size = self.drawableSize;

	if (_depthStencilPixelFormat == MTLPixelFormatInvalid || !device || size.width < 1 || size.height < 1) {
		return nil;
	}

	// (re)create it whenever it no longer matches the drawable or the requested format
	if (_depthStencilTexture == nil
		|| _depthStencilTexture.width != (NSUInteger)size.width
		|| _depthStencilTexture.height != (NSUInteger)size.height
		|| _depthStencilTexture.pixelFormat != _depthStencilPixelFormat
		|| _depthStencilTexture.sampleCount != _sampleCount)
	{
		[_depthStencilTexture release];

		MTLTextureDescriptor* desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat: _depthStencilPixelFormat width: size.width height: size.height mipmapped: NO];
		desc.textureType = (_sampleCount > 1) ? MTLTextureType2DMultisample : MTLTextureType2D;
		desc.sampleCount = _sampleCount;
		desc.usage = _depthStencilAttachmentTextureUsage;
		desc.storageMode = _depthStencilStorageMode;

		_depthStencilTexture = [device newTextureWithDescriptor: desc];
	}

	return _depthStencilTexture;
}

- (id<MTLTexture>)multisampleColorTexture
{
	// TODO: Indium doesn't resolve multisample attachments yet
	return nil;
}

// use the synthesized `preferredFramesPerSecond` getter

- (void)setPreferredFramesPerSecond: (NSInteger)preferredFramesPerSecond
{
	if (preferredFramesPerSecond > 60) {
		preferredFramesPerSecond = 60;
	}

	if (preferredFramesPerSecond < 1) {
		preferredFramesPerSecond = 1;
	}

	if (preferredFramesPerSecond == _preferredFramesPerSecond) {
		return;
	}

	_preferredFramesPerSecond = preferredFramesPerSecond;

	[self _resetTimer];
}

// use the synthesized `paused` getter

- (void)setPaused: (BOOL)paused
{
	if (paused == _paused) {
		return;
	}

	_paused = paused;

	[self _resetTimer];
}

// use the synthesized `enableSetNeedsDisplay` getter

- (void)setEnableSetNeedsDisplay: (BOOL)enableSetNeedsDisplay
{
	if (enableSetNeedsDisplay == _enableSetNeedsDisplay) {
		return;
	}

	_enableSetNeedsDisplay = enableSetNeedsDisplay;

	[self _resetTimer];
}

- (BOOL)presentsWithTransaction
{
	return ((CAMetalLayer*)_layer).presentsWithTransaction;
}

- (void)setPresentsWithTransaction: (BOOL)presentsWithTransaction
{
	((CAMetalLayer*)_layer).presentsWithTransaction = presentsWithTransaction;
}

//
// methods
//

- (void)_initCommon
{
	_autoResizeDrawable = YES;
	_clearColor = MTLClearColorMake(0, 0, 0, 1);
	_depthStencilPixelFormat = MTLPixelFormatInvalid;
	_depthStencilAttachmentTextureUsage = MTLTextureUsageRenderTarget;
	_depthStencilStorageMode = MTLStorageModePrivate;
	_clearDepth = 1;
	_clearStencil = 0;
	_sampleCount = 1;
	_multisampleColorAttachmentTextureUsage = MTLTextureUsageRenderTarget;
	_preferredFramesPerSecond = 60;
	_paused = NO;
	_enableSetNeedsDisplay = NO;

	[self _resetTimer];
}

- (instancetype)initWithCoder: (NSCoder*)decoder
{
	self.wantsLayer = YES;
	// TODO: check if MTKView has any coding stuff of its own
	self = [super initWithCoder: decoder];
	if (self != nil) {
		[self _initCommon];
	}
	return self;
}

- (instancetype)initWithFrame: (NSRect)frame
{
	self.wantsLayer = YES;
	self = [super initWithFrame: frame];
	if (self != nil) {
		[self _initCommon];
	}
	return self;
}

- (instancetype)initWithFrame: (NSRect)frame
                       device: (id<MTLDevice>)device
{
	self.wantsLayer = YES;
	self = [super initWithFrame: frame];
	if (self != nil) {
		self.device = device;
		[self _initCommon];
	}
	return self;
}

- (void)dealloc
{
	objc_storeWeak(&_delegate, nil);
	[_currentDrawable release];
	[_depthStencilTexture release];
	[_frameTimer invalidate];
	[_frameTimer release];
	[super dealloc];
}

- (CALayer*)makeBackingLayer
{
	return [CAMetalLayer layer];
}

- (void)draw
{
	[_currentDrawable release];
	_currentDrawable = [[(CAMetalLayer*)_layer nextDrawable] retain];

	if ([self methodForSelector: @selector(drawRect:)] != [MTKView instanceMethodForSelector: @selector(drawRect:)]) {
		// a subclass has overridden this method; invoke it.
		[self drawRect: self.bounds];
	} else {
		// `drawRect:` has not been overridden; invoke the delegate's method.
		[_delegate drawInMTKView: self];
	}

	[_currentDrawable release];
	_currentDrawable = nil;
}

- (void)releaseDrawables
{
	// it gets recreated the next time it's needed
	[_depthStencilTexture release];
	_depthStencilTexture = nil;
}

- (void)_resetTimer
{
	[_frameTimer invalidate];
	[_frameTimer release];

	if (_paused) {
		return;
	}

	_NSWeakRef* weakSelf = [[[_NSWeakRef alloc] initWithObject: self] autorelease];

	_frameTimer = [[NSTimer scheduledTimerWithTimeInterval: 1.0 / _preferredFramesPerSecond
	                                               repeats: YES
	                                                 block: ^(NSTimer* timer) {
		MTKView* me = weakSelf.object;
		[me draw];
	}] retain];
}

// FIXME: this is a lazy (and probably half-assed) implementation.
//        currently, subclassing an MTKView and implementing `drawRect:`
//        will result in the method always being invoked after `setNeedsDisplay:`,
//        regardless of whether or not `enableSetNeedsDisplay` is set.
//
//        we need to check what the official behavior regarding this method
//        is with subclasses: we need to check whether `drawRect:` is always
//        invoked from `setNeedsDisplay:` or if setting `enableSetNeedsDisplay`
//        to NO will prevent the subclass' `drawRect:` from being invoked due
//        to `setNeedsDisplay`.
//
//        the reason i didn't go ahead and do what sounds like the right behavior
//        right now is because that would requiring overridding various display-related
//        methods, not just `setNeedsDisplay`.
- (void)drawRect: (NSRect)rect
{
	// if we're not paused, we only redraw when the timer fires.
	// if we're not supposed to respond to setNeedsDisplay, we only redraw via manual calls of `draw`.
	if (!_paused || !_enableSetNeedsDisplay) {
		return;
	}
	[self draw];
}

- (void)setFrame: (NSRect)frame
{
	[super setFrame: frame];

	if (_autoResizeDrawable) {
		self.drawableSize = _frame.size;
	}
}

- (void)setBounds: (NSRect)bounds
{
	[super setBounds: bounds];

	if (_autoResizeDrawable) {
		self.drawableSize = _bounds.size;
	}
}

#else

@dynamic delegate;
@dynamic device;
@dynamic preferredDevice;
@dynamic colorPixelFormat;
@dynamic colorspace;
@dynamic framebufferOnly;
@dynamic drawableSize;
@dynamic preferredDrawableSize;
@dynamic autoResizeDrawable;
@dynamic clearColor;
@dynamic depthStencilPixelFormat;
@dynamic depthStencilAttachmentTextureUsage;
@dynamic clearDepth;
@dynamic clearStencil;
@dynamic sampleCount;
@dynamic multisampleColorAttachmentTextureUsage;
@dynamic currentRenderPassDescriptor;
@dynamic currentDrawable;
@dynamic depthStencilTexture;
@dynamic multisampleColorTexture;
@dynamic preferredFramesPerSecond;
@dynamic paused;
@dynamic enableSetNeedsDisplay;
@dynamic presentsWithTransaction;
@dynamic depthStencilStorageMode;

MTL_UNSUPPORTED_CLASS

#endif

@end
