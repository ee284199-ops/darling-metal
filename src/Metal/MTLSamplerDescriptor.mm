// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#import <Metal/MTLSamplerInternal.h>
#import <Metal/MTLDevice.h>
#import <Metal/stubs.h>

#include <float.h>

@implementation MTLSamplerDescriptor

#if DARLING_METAL_ENABLED

@synthesize minFilter = _minFilter;
@synthesize magFilter = _magFilter;
@synthesize mipFilter = _mipFilter;
@synthesize maxAnisotropy = _maxAnisotropy;
@synthesize sAddressMode = _sAddressMode;
@synthesize tAddressMode = _tAddressMode;
@synthesize rAddressMode = _rAddressMode;
@synthesize borderColor = _borderColor;
@synthesize normalizedCoordinates = _normalizedCoordinates;
@synthesize lodMinClamp = _lodMinClamp;
@synthesize lodMaxClamp = _lodMaxClamp;
@synthesize lodAverage = _lodAverage;
@synthesize compareFunction = _compareFunction;
@synthesize supportArgumentBuffers = _supportArgumentBuffers;
@synthesize label = _label;

- (instancetype)init
{
	self = [super init];
	if (self != nil) {
		_minFilter = MTLSamplerMinMagFilterNearest;
		_magFilter = MTLSamplerMinMagFilterNearest;
		_mipFilter = MTLSamplerMipFilterNotMipmapped;
		_maxAnisotropy = 1;
		_sAddressMode = MTLSamplerAddressModeClampToEdge;
		_tAddressMode = MTLSamplerAddressModeClampToEdge;
		_rAddressMode = MTLSamplerAddressModeClampToEdge;
		_borderColor = MTLSamplerBorderColorTransparentBlack;
		_normalizedCoordinates = YES;
		_lodMinClamp = 0;
		_lodMaxClamp = FLT_MAX;
		_lodAverage = NO;
		_compareFunction = MTLCompareFunctionNever;
		_supportArgumentBuffers = NO;
	}
	return self;
}

- (void)dealloc
{
	[_label release];
	[super dealloc];
}

- (instancetype)copyWithZone: (NSZone*)zone
{
	MTLSamplerDescriptor* copy = [[self class] new];

	copy->_minFilter = _minFilter;
	copy->_magFilter = _magFilter;
	copy->_mipFilter = _mipFilter;
	copy->_maxAnisotropy = _maxAnisotropy;
	copy->_sAddressMode = _sAddressMode;
	copy->_tAddressMode = _tAddressMode;
	copy->_rAddressMode = _rAddressMode;
	copy->_borderColor = _borderColor;
	copy->_normalizedCoordinates = _normalizedCoordinates;
	copy->_lodMinClamp = _lodMinClamp;
	copy->_lodMaxClamp = _lodMaxClamp;
	copy->_lodAverage = _lodAverage;
	copy->_compareFunction = _compareFunction;
	copy->_supportArgumentBuffers = _supportArgumentBuffers;
	copy->_label = [_label copy];

	return copy;
}

- (Indium::SamplerDescriptor)asIndiumDescriptor
{
	Indium::SamplerDescriptor desc;

	desc.minFilter = static_cast<Indium::SamplerMinMagFilter>(_minFilter);
	desc.magFilter = static_cast<Indium::SamplerMinMagFilter>(_magFilter);
	desc.mipFilter = static_cast<Indium::SamplerMipFilter>(_mipFilter);
	desc.maxAnisotropy = _maxAnisotropy;
	desc.sAddressMode = static_cast<Indium::SamplerAddressMode>(_sAddressMode);
	desc.tAddressMode = static_cast<Indium::SamplerAddressMode>(_tAddressMode);
	desc.rAddressMode = static_cast<Indium::SamplerAddressMode>(_rAddressMode);
	desc.borderColor = static_cast<Indium::SamplerBorderColor>(_borderColor);
	desc.normalizedCoordinates = _normalizedCoordinates;
	desc.lodMinClamp = _lodMinClamp;
	desc.lodMaxClamp = _lodMaxClamp;
	desc.supportArgumentBuffers = _supportArgumentBuffers;
	desc.compareFunction = static_cast<Indium::CompareFunction>(_compareFunction);
	// lodAverage only affects Apple-family GPUs

	return desc;
}

#else

@dynamic minFilter;
@dynamic magFilter;
@dynamic mipFilter;
@dynamic maxAnisotropy;
@dynamic sAddressMode;
@dynamic tAddressMode;
@dynamic rAddressMode;
@dynamic borderColor;
@dynamic normalizedCoordinates;
@dynamic lodMinClamp;
@dynamic lodMaxClamp;
@dynamic lodAverage;
@dynamic compareFunction;
@dynamic supportArgumentBuffers;
@dynamic label;

MTL_UNSUPPORTED_CLASS

#endif

@end

@implementation MTLSamplerStateInternal

#if DARLING_METAL_ENABLED

@synthesize state = _state;
@synthesize device = _device;
@synthesize label = _label;

- (instancetype)initWithState: (std::shared_ptr<Indium::SamplerState>)state
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
