// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#import <Metal/MTLDepthStencilInternal.h>
#import <Metal/MTLDevice.h>
#import <Metal/stubs.h>

@implementation MTLDepthStencilDescriptor

#if DARLING_METAL_ENABLED

{
	MTLStencilDescriptor* _frontFaceStencil;
	MTLStencilDescriptor* _backFaceStencil;
}

@synthesize depthCompareFunction = _depthCompareFunction;
@synthesize depthWriteEnabled = _depthWriteEnabled;
@synthesize label = _label;

- (instancetype)init
{
	self = [super init];
	if (self != nil) {
		_depthCompareFunction = MTLCompareFunctionAlways;
		_depthWriteEnabled = NO;
		_frontFaceStencil = [MTLStencilDescriptor new];
		_backFaceStencil = [MTLStencilDescriptor new];
	}
	return self;
}

- (void)dealloc
{
	[_frontFaceStencil release];
	[_backFaceStencil release];
	[_label release];
	[super dealloc];
}

- (MTLStencilDescriptor*)frontFaceStencil
{
	return _frontFaceStencil;
}

- (void)setFrontFaceStencil: (MTLStencilDescriptor*)frontFaceStencil
{
	// null_resettable: nil goes back to the default descriptor
	MTLStencilDescriptor* old = _frontFaceStencil;
	_frontFaceStencil = frontFaceStencil ? [frontFaceStencil copy] : [MTLStencilDescriptor new];
	[old release];
}

- (MTLStencilDescriptor*)backFaceStencil
{
	return _backFaceStencil;
}

- (void)setBackFaceStencil: (MTLStencilDescriptor*)backFaceStencil
{
	MTLStencilDescriptor* old = _backFaceStencil;
	_backFaceStencil = backFaceStencil ? [backFaceStencil copy] : [MTLStencilDescriptor new];
	[old release];
}

- (instancetype)copyWithZone: (NSZone*)zone
{
	MTLDepthStencilDescriptor* copy = [[self class] new];

	copy.depthCompareFunction = _depthCompareFunction;
	copy.depthWriteEnabled = _depthWriteEnabled;
	copy.frontFaceStencil = _frontFaceStencil;
	copy.backFaceStencil = _backFaceStencil;
	copy.label = _label;

	return copy;
}

- (Indium::DepthStencilDescriptor)asIndiumDescriptor
{
	Indium::DepthStencilDescriptor desc;

	desc.depthCompareFunction = static_cast<Indium::CompareFunction>(_depthCompareFunction);
	desc.depthWriteEnabled = _depthWriteEnabled;

	// descriptors left at their defaults never change anything, so only enable stencil testing when one was configured
	if (![_frontFaceStencil _hasDefaultValues] || ![_backFaceStencil _hasDefaultValues]) {
		desc.frontFaceStencil = [_frontFaceStencil asIndiumDescriptor];
		desc.backFaceStencil = [_backFaceStencil asIndiumDescriptor];
	}

	return desc;
}

#else

@dynamic depthCompareFunction;
@dynamic depthWriteEnabled;
@dynamic frontFaceStencil;
@dynamic backFaceStencil;
@dynamic label;

MTL_UNSUPPORTED_CLASS

#endif

@end

@implementation MTLDepthStencilStateInternal

#if DARLING_METAL_ENABLED

@synthesize state = _state;
@synthesize device = _device;
@synthesize label = _label;

- (instancetype)initWithState: (std::shared_ptr<Indium::DepthStencilState>)state
                       device: (id<MTLDevice>)device
                        label: (NSString*)label
{
	self = [super init];
	if (self != nil) {
		_state = state;
		_device = [device retain];
		_label = [label copy];
	}
	return self;
}

- (void)dealloc
{
	[_device release];
	[_label release];
	[super dealloc];
}

#else

@dynamic device;
@dynamic label;

MTL_UNSUPPORTED_CLASS

#endif

@end
