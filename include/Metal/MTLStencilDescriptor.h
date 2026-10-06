// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#ifndef _METAL_MTLSTENCILDESCRIPTOR_H_
#define _METAL_MTLSTENCILDESCRIPTOR_H_

#import <Foundation/Foundation.h>

#import <Metal/MTLDefines.h>

METAL_DECLARATIONS_BEGIN

typedef NS_ENUM(NSUInteger, MTLCompareFunction) {
	MTLCompareFunctionNever = 0,
	MTLCompareFunctionLess = 1,
	MTLCompareFunctionEqual = 2,
	MTLCompareFunctionLessEqual = 3,
	MTLCompareFunctionGreater = 4,
	MTLCompareFunctionNotEqual = 5,
	MTLCompareFunctionGreaterEqual = 6,
	MTLCompareFunctionAlways = 7,
};

typedef NS_ENUM(NSUInteger, MTLStencilOperation) {
	MTLStencilOperationKeep = 0,
	MTLStencilOperationZero = 1,
	MTLStencilOperationReplace = 2,
	MTLStencilOperationIncrementClamp = 3,
	MTLStencilOperationDecrementClamp = 4,
	MTLStencilOperationInvert = 5,
	MTLStencilOperationIncrementWrap = 6,
	MTLStencilOperationDecrementWrap = 7,
};

MTL_EXPORT
@interface MTLStencilDescriptor : NSObject <NSCopying>

@property(nonatomic) MTLCompareFunction stencilCompareFunction;
@property(nonatomic) MTLStencilOperation stencilFailureOperation;
@property(nonatomic) MTLStencilOperation depthFailureOperation;
@property(nonatomic) MTLStencilOperation depthStencilPassOperation;
@property(nonatomic) uint32_t readMask;
@property(nonatomic) uint32_t writeMask;

@end

METAL_DECLARATIONS_END

#endif // _METAL_MTLSTENCILDESCRIPTOR_H_
