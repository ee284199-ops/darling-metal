// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#import <Metal/MTLCommandBufferInternal.h>
#import <Metal/MTLComputeCommandEncoderInternal.h>
#import <Metal/MTLDevice.h>
#import <Metal/MTLCommandQueue.h>
#import <Metal/MTLDrawableInternal.h>
#import <Metal/stubs.h>
#import <Metal/MTLRenderCommandEncoderInternal.h>
#import <Metal/MTLBlitCommandEncoderInternal.h>

#if DARLING_METAL_ENABLED
// used to take care of RR while passing the block around in C++ code
struct MTLCommandBufferHandlerWrapper {
	MTLCommandBufferHandler handler = nil;
	id<MTLCommandBuffer> commandBuffer = nil;

	MTLCommandBufferHandlerWrapper(MTLCommandBufferHandler theHandler, id<MTLCommandBuffer> theCommandBuffer):
		handler([theHandler copy]),
		commandBuffer([theCommandBuffer retain])
		{};

	MTLCommandBufferHandlerWrapper(const MTLCommandBufferHandlerWrapper& other):
		handler([other.handler copy]),
		commandBuffer([other.commandBuffer retain])
		{};

	~MTLCommandBufferHandlerWrapper() {
		[handler release];
		[commandBuffer release];
	};

	MTLCommandBufferHandlerWrapper& operator=(const MTLCommandBufferHandlerWrapper& other) {
		[handler release];
		handler = [other.handler copy];
		[commandBuffer release];
		commandBuffer = [other.commandBuffer retain];
		return *this;
	};

	void operator()(std::shared_ptr<Indium::CommandBuffer> ignored) {
		// we assume that the Indium command buffer given as an argument refers to the same command buffer
		// as the one that created this wrapper (which is a currently always true).
		handler(commandBuffer);
	};
};
#endif

@implementation MTLCommandBufferInternal

#if DARLING_METAL_ENABLED

{
	std::shared_ptr<Indium::CommandBuffer> _commandBuffer;
	MTLCommandBufferStatus _status;
}

@synthesize device = _device;
@synthesize commandQueue = _commandQueue;
@synthesize label = _label;

- (instancetype)initWithCommandBuffer: (std::shared_ptr<Indium::CommandBuffer>)commandBuffer
                         commandQueue: (id<MTLCommandQueue>)commandQueue
{
	self = [super init];
	if (self != nil) {
		_commandBuffer = commandBuffer;
		_device = [commandQueue.device retain];
		_commandQueue = [commandQueue retain];
		_status = MTLCommandBufferStatusNotEnqueued;
	}
	return self;
}

- (void)dealloc
{
	[_device release];
	[_commandQueue release];
	[_label release];
	[super dealloc];
}

- (id<MTLComputeCommandEncoder>)computeCommandEncoderWithDescriptor: (MTLComputePassDescriptor*)computePassDescriptor
{
	auto encoder = _commandBuffer->computeCommandEncoder(computePassDescriptor.asIndiumDescriptor);
	if (!encoder) {
		return nil;
	}
	return [[[MTLComputeCommandEncoderInternal alloc] initWithEncoder: encoder device: _device] autorelease];
}

- (id<MTLComputeCommandEncoder>)computeCommandEncoderWithDispatchType: (MTLDispatchType)dispatchType
{
	auto encoder = _commandBuffer->computeCommandEncoder(static_cast<Indium::DispatchType>(dispatchType));
	if (!encoder) {
		return nil;
	}
	return [[[MTLComputeCommandEncoderInternal alloc] initWithEncoder: encoder device: _device] autorelease];
}

- (id<MTLComputeCommandEncoder>)computeCommandEncoder
{
	auto encoder = _commandBuffer->computeCommandEncoder();
	if (!encoder) {
		return nil;
	}
	return [[[MTLComputeCommandEncoderInternal alloc] initWithEncoder: encoder device: _device] autorelease];
}

- (id<MTLRenderCommandEncoder>)renderCommandEncoderWithDescriptor: (MTLRenderPassDescriptor*)renderPassDescriptor
{
	auto encoder = _commandBuffer->renderCommandEncoder([renderPassDescriptor asIndiumDescriptor]);
	if (!encoder) {
		return nil;
	}
	return [[[MTLRenderCommandEncoderInternal alloc] initWithEncoder: encoder device: _device] autorelease];
}

- (void)addCompletedHandler: (MTLCommandBufferHandler)block
{
	MTLCommandBufferHandler handler = ^(id<MTLCommandBuffer> commandBuffer) {
		// Metal reports the buffer as completed by the time its completion handlers run
		((MTLCommandBufferInternal*)commandBuffer)->_status = MTLCommandBufferStatusCompleted;
		block(commandBuffer);
	};
	_commandBuffer->addCompletedHandler(MTLCommandBufferHandlerWrapper(handler, self));
}

- (void)addScheduledHandler: (MTLCommandBufferHandler)block
{
	MTLCommandBufferHandler handler = ^(id<MTLCommandBuffer> commandBuffer) {
		MTLCommandBufferInternal* internal = (MTLCommandBufferInternal*)commandBuffer;
		if (internal->_status < MTLCommandBufferStatusScheduled) {
			internal->_status = MTLCommandBufferStatusScheduled;
		}
		block(commandBuffer);
	};
	_commandBuffer->addScheduledHandler(MTLCommandBufferHandlerWrapper(handler, self));
}

- (void)waitUntilScheduled
{
	// Indium submits the work as soon as the buffer is committed
	if (_status == MTLCommandBufferStatusCommitted) {
		_status = MTLCommandBufferStatusScheduled;
	}
}

- (void)waitUntilCompleted
{
	_commandBuffer->waitUntilCompleted();

	// Indium wakes us up before it runs the completed handlers, and one of those is what normally
	// updates `_status`; it has to read "completed" as soon as this returns
	if (_status < MTLCommandBufferStatusCompleted) {
		_status = MTLCommandBufferStatusCompleted;
	}
}

- (void)presentDrawable: (id<MTLDrawable>)drawable
{
	_commandBuffer->presentDrawable(((id<MTLDrawableInternal>)drawable).drawable);
}

- (void)presentDrawable: (id<MTLDrawable>)drawable
                 atTime: (CFTimeInterval)presentationTime
{
	// no presentation timing control; present as soon as possible
	[self presentDrawable: drawable];
}

- (void)presentDrawable: (id<MTLDrawable>)drawable
   afterMinimumDuration: (CFTimeInterval)duration
{
	[self presentDrawable: drawable];
}

- (void)enqueue
{
	if (_status < MTLCommandBufferStatusEnqueued) {
		_status = MTLCommandBufferStatusEnqueued;
	}
}

- (void)commit
{
	if (_status < MTLCommandBufferStatusCommitted) {
		_status = MTLCommandBufferStatusCommitted;
	}

	// keep `status` up to date even when nobody else waits for completion
	_commandBuffer->addCompletedHandler(MTLCommandBufferHandlerWrapper(^(id<MTLCommandBuffer> commandBuffer) {
		((MTLCommandBufferInternal*)commandBuffer)->_status = MTLCommandBufferStatusCompleted;
	}, self));

	_commandBuffer->commit();
}

- (id<MTLBlitCommandEncoder>)blitCommandEncoder
{
	auto encoder = _commandBuffer->blitCommandEncoder();
	if (!encoder) {
		return nil;
	}
	return [[[MTLBlitCommandEncoderInternal alloc] initWithEncoder: encoder device: _device] autorelease];
}

- (MTLCommandBufferStatus)status
{
	return _status;
}

- (NSError*)error
{
	// Indium doesn't report command buffer failures
	return nil;
}

- (BOOL)retainedReferences
{
	return YES;
}

// GPU timing isn't tracked

- (CFTimeInterval)kernelStartTime
{
	return 0;
}

- (CFTimeInterval)kernelEndTime
{
	return 0;
}

- (CFTimeInterval)GPUStartTime
{
	return 0;
}

- (CFTimeInterval)GPUEndTime
{
	return 0;
}

- (void)pushDebugGroup: (NSString*)string
{
	// debug groups are only for GPU debugging tools, which we don't have
}

- (void)popDebugGroup
{
}

#else

@dynamic commandQueue;
@dynamic device;
@dynamic label;

MTL_UNSUPPORTED_CLASS

#endif

@end
