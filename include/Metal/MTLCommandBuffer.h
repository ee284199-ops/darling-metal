// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#ifndef _METAL_MTLCOMMANDBUFFER_H_
#define _METAL_MTLCOMMANDBUFFER_H_

#import <Foundation/Foundation.h>

#import <Metal/MTLDefines.h>

METAL_DECLARATIONS_BEGIN

@protocol MTLDevice;
@protocol MTLCommandBuffer;
@protocol MTLDrawable;
@protocol MTLBlitCommandEncoder;
@protocol MTLComputeCommandEncoder;
@protocol MTLCommandQueue;
@protocol MTLRenderCommandEncoder;

@class MTLComputePassDescriptor;
@class MTLRenderPassDescriptor;

typedef NS_ENUM(NSUInteger, MTLDispatchType) {
	MTLDispatchTypeSerial = 0,
	MTLDispatchTypeConcurrent = 1,
};

typedef NS_ENUM(NSUInteger, MTLCommandBufferStatus) {
	MTLCommandBufferStatusNotEnqueued = 0,
	MTLCommandBufferStatusEnqueued = 1,
	MTLCommandBufferStatusCommitted = 2,
	MTLCommandBufferStatusScheduled = 3,
	MTLCommandBufferStatusCompleted = 4,
	MTLCommandBufferStatusError = 5,
};

typedef void (^MTLCommandBufferHandler)(id<MTLCommandBuffer>);

@protocol MTLCommandBuffer <NSObject>

@property(readonly) id<MTLCommandQueue> commandQueue;
@property (readonly) id<MTLDevice> device;
@property(nullable, copy, atomic) NSString* label;
@property(readonly) MTLCommandBufferStatus status;
@property(nullable, readonly) NSError* error;
@property(readonly) BOOL retainedReferences;
@property(readonly) CFTimeInterval kernelStartTime;
@property(readonly) CFTimeInterval kernelEndTime;
@property(readonly) CFTimeInterval GPUStartTime;
@property(readonly) CFTimeInterval GPUEndTime;

- (id<MTLBlitCommandEncoder>)blitCommandEncoder;

- (id<MTLComputeCommandEncoder>)computeCommandEncoderWithDescriptor: (MTLComputePassDescriptor*)computePassDescriptor;
- (id<MTLComputeCommandEncoder>)computeCommandEncoderWithDispatchType: (MTLDispatchType)dispatchType;
- (id<MTLComputeCommandEncoder>)computeCommandEncoder;

- (id<MTLRenderCommandEncoder>)renderCommandEncoderWithDescriptor: (MTLRenderPassDescriptor*)renderPassDescriptor;

- (void)addScheduledHandler: (MTLCommandBufferHandler)block;
- (void)addCompletedHandler: (MTLCommandBufferHandler)block;
- (void)waitUntilScheduled;
- (void)waitUntilCompleted;
- (void)presentDrawable: (id<MTLDrawable>)drawable;
- (void)presentDrawable: (id<MTLDrawable>)drawable
                 atTime: (CFTimeInterval)presentationTime;
- (void)presentDrawable: (id<MTLDrawable>)drawable
   afterMinimumDuration: (CFTimeInterval)duration;
- (void)enqueue;
- (void)commit;

- (void)pushDebugGroup: (NSString*)string;
- (void)popDebugGroup;

// TODO: other methods

@end

METAL_DECLARATIONS_END

#endif // _METAL_MTLCOMMANDBUFFER_H_
