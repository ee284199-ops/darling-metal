// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#ifndef _METAL_MTLDEPTHSTENCILDESCRIPTOR_H_
#define _METAL_MTLDEPTHSTENCILDESCRIPTOR_H_

#import <Foundation/Foundation.h>

#import <Metal/MTLDefines.h>
#import <Metal/MTLStencilDescriptor.h>

METAL_DECLARATIONS_BEGIN

@protocol MTLDevice;

MTL_EXPORT
@interface MTLDepthStencilDescriptor : NSObject <NSCopying>

@property(nonatomic) MTLCompareFunction depthCompareFunction;
@property(nonatomic, getter=isDepthWriteEnabled) BOOL depthWriteEnabled;
@property(copy, nonatomic, null_resettable) MTLStencilDescriptor* frontFaceStencil;
@property(copy, nonatomic, null_resettable) MTLStencilDescriptor* backFaceStencil;
@property(nullable, copy, nonatomic) NSString* label;

@end

@protocol MTLDepthStencilState <NSObject>

@property(nullable, readonly) NSString* label;
@property(readonly) id<MTLDevice> device;

@end

METAL_DECLARATIONS_END

#endif // _METAL_MTLDEPTHSTENCILDESCRIPTOR_H_
