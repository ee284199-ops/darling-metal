// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#import <Metal/MTLDepthStencilInternal.h>
#import <Metal/stubs.h>

@implementation MTLStencilDescriptor

#if DARLING_METAL_ENABLED

@synthesize stencilCompareFunction = _stencilCompareFunction;
@synthesize stencilFailureOperation = _stencilFailureOperation;
@synthesize depthFailureOperation = _depthFailureOperation;
@synthesize depthStencilPassOperation = _depthStencilPassOperation;
@synthesize readMask = _readMask;
@synthesize writeMask = _writeMask;

- (instancetype)init
{
	self = [super init];
	if (self != nil) {
		_stencilCompareFunction = MTLCompareFunctionAlways;
		_stencilFailureOperation = MTLStencilOperationKeep;
		_depthFailureOperation = MTLStencilOperationKeep;
		_depthStencilPassOperation = MTLStencilOperationKeep;
		_readMask = UINT32_MAX;
		_writeMask = UINT32_MAX;
	}
	return self;
}

- (instancetype)copyWithZone: (NSZone*)zone
{
	MTLStencilDescriptor* copy = [[self class] new];

	copy->_stencilCompareFunction = _stencilCompareFunction;
	copy->_stencilFailureOperation = _stencilFailureOperation;
	copy->_depthFailureOperation = _depthFailureOperation;
	copy->_depthStencilPassOperation = _depthStencilPassOperation;
	copy->_readMask = _readMask;
	copy->_writeMask = _writeMask;

	return copy;
}

- (BOOL)_hasDefaultValues
{
	return _stencilCompareFunction == MTLCompareFunctionAlways
		&& _stencilFailureOperation == MTLStencilOperationKeep
		&& _depthFailureOperation == MTLStencilOperationKeep
		&& _depthStencilPassOperation == MTLStencilOperationKeep
		&& _readMask == UINT32_MAX
		&& _writeMask == UINT32_MAX;
}

- (Indium::StencilDescriptor)asIndiumDescriptor
{
	Indium::StencilDescriptor desc;

	desc.stencilCompareFunction = static_cast<Indium::CompareFunction>(_stencilCompareFunction);
	desc.stencilFailureOperation = static_cast<Indium::StencilOperation>(_stencilFailureOperation);
	desc.depthFailureOperation = static_cast<Indium::StencilOperation>(_depthFailureOperation);
	desc.depthStencilPassOperation = static_cast<Indium::StencilOperation>(_depthStencilPassOperation);
	desc.readMask = _readMask;
	desc.writeMask = _writeMask;

	return desc;
}

#else

@dynamic stencilCompareFunction;
@dynamic stencilFailureOperation;
@dynamic depthFailureOperation;
@dynamic depthStencilPassOperation;
@dynamic readMask;
@dynamic writeMask;

MTL_UNSUPPORTED_CLASS

#endif

@end
