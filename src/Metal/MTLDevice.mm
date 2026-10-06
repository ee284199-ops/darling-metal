// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#import <Metal/MTLDeviceInternal.h>
#import <dispatch/dispatch.h>
#import <Metal/MTLLibraryInternal.h>
#import <Metal/MTLComputePipelineInternal.h>
#import <Metal/MTLCommandQueueInternal.h>
#import <Metal/MTLBufferInternal.h>
#import <Metal/MTLLibraryInternal.h>
#import <Metal/MTLRenderPipelineInternal.h>
#import <Metal/MTLTextureInternal.h>
#import <Metal/MTLSamplerInternal.h>
#import <Metal/MTLDepthStencilInternal.h>
#import <Metal/stubs.h>

#import <objc/runtime.h>

MTL_EXTERN const MTLDeviceNotificationName MTLDeviceWasAddedNotification = @"MTLDeviceWasAdded";
MTL_EXTERN const MTLDeviceNotificationName MTLDeviceRemovalRequestedNotification = @"MTLDeviceRemovalRequested";
MTL_EXTERN const MTLDeviceNotificationName MTLDeviceWasRemovedNotification = @"MTLDeviceWasRemoved";

#if DARLING_METAL_ENABLED

static NSMutableArray<MTLDeviceInternal*>* devices = nil;
static dispatch_once_t devicesInitToken = 0;
static MTLDeviceInternal* systemDefaultDevice = nil;

static void ensureDevices(void) {
	dispatch_once(&devicesInitToken, ^{
		devices = [NSMutableArray new];

		// for now, we just have the system default device
		auto indiumDevice = Indium::createSystemDefaultDevice();
		if (indiumDevice) {
			systemDefaultDevice = [[MTLDeviceInternal alloc] initWithDevice: indiumDevice];

			[devices addObject: systemDefaultDevice];
		}
	});
};

void MTLDeviceDestroyAll(void) {
	for (MTLDeviceInternal* device in devices) {
		[device stopPolling];
		[device waitUntilPollingIsStopped];
	}

	if (systemDefaultDevice) {
		[systemDefaultDevice release];
	}

	if (devices) {
		[devices release];
	}
};

#endif

MTL_EXTERN
id<MTLDevice> MTLCreateSystemDefaultDevice(void) {
#if DARLING_METAL_ENABLED
	ensureDevices();
	if (systemDefaultDevice) {
		return [systemDefaultDevice retain];
	}
#endif
	return nil;
};

MTL_EXTERN
NSArray<id<MTLDevice>>* MTLCopyAllDevices(void) {
#if DARLING_METAL_ENABLED
	ensureDevices();
	return [devices copy];
#else
	return [NSArray new];
#endif
};

MTL_EXTERN
NSArray<id<MTLDevice>>* MTLCopyAllDevicesWithObserver(id<NSObject>* observer, MTLDeviceNotificationHandler handler) {
	// TODO: actually use observer
	if (observer) {
		*observer = [NSObject new];
	}
	return MTLCopyAllDevices();
};

MTL_EXTERN
void MTLRemoveDeviceObserver(id<NSObject> observer) {
	// TODO: actually use observer
	[observer release];
};

#if DARLING_METAL_ENABLED

// Calls the deallocator of a "no copy" buffer once released, which happens when the buffer
// it's attached to (as an associated object) is deallocated.
@interface MTLBufferNoCopyDeallocator : NSObject
{
	void (^_deallocator)(void* pointer, NSUInteger length);
	void* _pointer;
	NSUInteger _length;
}

- (instancetype)initWithDeallocator: (void (^)(void* pointer, NSUInteger length))deallocator
                            pointer: (void*)pointer
                             length: (NSUInteger)length;

@end

@implementation MTLBufferNoCopyDeallocator

- (instancetype)initWithDeallocator: (void (^)(void* pointer, NSUInteger length))deallocator
                            pointer: (void*)pointer
                             length: (NSUInteger)length
{
	self = [super init];
	if (self != nil) {
		_deallocator = [deallocator copy];
		_pointer = pointer;
		_length = length;
	}
	return self;
}

- (void)dealloc
{
	_deallocator(_pointer, _length);
	[_deallocator release];
	[super dealloc];
}

@end

static char noCopyDeallocatorKey;

static NSError* sourceCompilationUnsupportedError(void) {
	return [NSError errorWithDomain: MTLLibraryErrorDomain code: MTLLibraryErrorUnsupported userInfo: @{
		NSLocalizedDescriptionKey: @"Compiling Metal shader source isn't supported; only precompiled libraries (metallibs) can be loaded.",
	}];
};

#endif

@implementation MTLDeviceInternal

#if DARLING_METAL_ENABLED

{
	NSThread* _pollingThread;
	NSCondition* _threadExitCondition;
	BOOL _threadIsRunning;
}

@synthesize device = _device;

- (void)pollingLoop
{
	[_threadExitCondition lock];
	_threadIsRunning = YES;
	[_threadExitCondition unlock];

	while (!_pollingThread.isCancelled) {
		_device->pollEvents(UINT64_MAX);
	}

	[_threadExitCondition lock];
	_threadIsRunning = NO;
	[_threadExitCondition broadcast];
	[_threadExitCondition unlock];
}

- (instancetype)initWithDevice: (std::shared_ptr<Indium::Device>)device
{
	self = [super init];
	if (self != nil) {
		_device = device;
		_threadExitCondition = [NSCondition new];
		_threadIsRunning = NO;
		_pollingThread = [[NSThread alloc] initWithTarget: self selector: @selector(pollingLoop) object: nil];
		[_pollingThread start];
	}
	return self;
}

- (void)dealloc
{
	[_pollingThread release];
	[_threadExitCondition release];

	[super dealloc];
}

- (void)stopPolling
{
	[_pollingThread cancel];
	_device->wakeupEventLoop();
}

- (void)waitUntilPollingIsStopped
{
	// wait for the polling thread to die
	[_threadExitCondition lock];
	while (_threadIsRunning) {
		[_threadExitCondition wait];
	}
	[_threadExitCondition unlock];
}

- (id<MTLComputePipelineState>)newComputePipelineStateWithDescriptor: (MTLComputePipelineDescriptor*)descriptor
                                                             options: (MTLPipelineOption)options
                                                          reflection: (MTLAutoreleasedComputePipelineReflection*)reflection
                                                               error: (NSError**)error
{
	auto pso = _device->newComputePipelineState(descriptor.asIndiumDescriptor, static_cast<Indium::PipelineOption>(options), nullptr);
	if (!pso) {
		if (error) {
			// TODO: better error and/or match what the official Metal method does
			*error = [NSError errorWithDomain: NSPOSIXErrorDomain code: ENOMEM userInfo: nil];
		}
		return nil;
	}
	return [[MTLComputePipelineStateInternal alloc] initWithState: pso device: self label: descriptor.label];
}

- (id<MTLComputePipelineState>)newComputePipelineStateWithFunction: (id<MTLFunction>)computeFunction 
                                                             error: (NSError**)error
{
	return [self newComputePipelineStateWithFunction: computeFunction
	                                         options: MTLPipelineOptionNone
	                                      reflection: nil
	                                           error: error];
}

- (id<MTLComputePipelineState>)newComputePipelineStateWithFunction: (id<MTLFunction>)computeFunction 
                                                           options: (MTLPipelineOption)options 
                                                        reflection: (MTLAutoreleasedComputePipelineReflection*)reflection 
                                                             error: (NSError**)error
{
	auto pso = _device->newComputePipelineState(((MTLFunctionInternal*)computeFunction).function, static_cast<Indium::PipelineOption>(options), nullptr);
	if (!pso) {
		if (error) {
			// TODO: better error and/or match what the official Metal method does
			*error = [NSError errorWithDomain: NSPOSIXErrorDomain code: ENOMEM userInfo: nil];
		}
		return nil;
	}
	return [[MTLComputePipelineStateInternal alloc] initWithState: pso device: self label: nil];
}

- (id<MTLRenderPipelineState>)newRenderPipelineStateWithDescriptor: (MTLRenderPipelineDescriptor*)descriptor
                                                             error: (NSError**)error
{
	auto pso = _device->newRenderPipelineState([descriptor asIndiumDescriptor]);
	if (!pso) {
		if (error) {
			// TODO: better error and/or match what the official Metal method does
			*error = [NSError errorWithDomain: NSPOSIXErrorDomain code: ENOMEM userInfo: nil];
		}
		return nil;
	}
	return [[MTLRenderPipelineStateInternal alloc] initWithState: pso device: self label: descriptor.label];
}

- (id<MTLCommandQueue>)newCommandQueue
{
	auto queue = _device->newCommandQueue();
	if (!queue) {
		return nil;
	}
	return [[MTLCommandQueueInternal alloc] initWithQueue: queue device: self];
}

- (id<MTLBuffer>)newBufferWithLength: (NSUInteger)length
                             options: (MTLResourceOptions)options
{
	auto buf = _device->newBuffer(length, static_cast<Indium::ResourceOptions>(options));
	if (!buf) {
		return nil;
	}
	return [[MTLBufferInternal alloc] initWithBuffer: buf device: self resourceOptions: options];
}

- (id<MTLBuffer>)newBufferWithBytes: (const void*)pointer
                             length: (NSUInteger)length
                            options: (MTLResourceOptions)options
{
	auto buf = _device->newBuffer(pointer, length, static_cast<Indium::ResourceOptions>(options));
	if (!buf) {
		return nil;
	}
	return [[MTLBufferInternal alloc] initWithBuffer: buf device: self resourceOptions: options];
}

- (id<MTLLibrary>)newDefaultLibrary
{
	return [self newDefaultLibraryWithBundle: [NSBundle mainBundle] error: nil];
}

- (id<MTLLibrary>)newDefaultLibraryWithBundle: (NSBundle*)bundle
                                        error: (NSError**)error
{
	NSURL* url = [bundle URLForResource: @"default" withExtension: @"metallib"];
	if (url == nil) {
		if (error) {
			// TODO: better error
			*error = [NSError errorWithDomain: NSPOSIXErrorDomain code: ENOENT userInfo: nil];
		}
		return nil;
	}
	return [self newLibraryWithURL: url error: error];
}

- (id<MTLLibrary>)newLibraryWithURL: (NSURL*)url
                              error: (NSError**)error
{
	NSData* data = [NSData dataWithContentsOfURL: url options: 0 error: error];
	if (data == nil) {
		// error was already written
		return nil;
	}
	auto lib = _device->newLibrary(data.bytes, data.length);
	if (!lib) {
		return nil;
	}
	return [[MTLLibraryInternal alloc] initWithLibrary: lib device: self];
}

- (id<MTLLibrary>)newLibraryWithData: (dispatch_data_t)data
                               error: (NSError**)error
{
	NSData* nsdata = (NSData*)data;
	auto lib = _device->newLibrary(nsdata.bytes, nsdata.length);
	if (!lib) {
		return nil;
	}
	return [[MTLLibraryInternal alloc] initWithLibrary: lib device: self];
}

//
// device information
//
// Indium doesn't report most of these, so we answer as a typical discrete Mac GPU would.
//

- (NSString*)name
{
	return [NSString stringWithUTF8String: _device->name().c_str()];
}

- (uint64_t)registryID
{
	// on macOS, this is the GPU's IORegistry entry ID; any stable, unique value will do
	return 0x100000000ull + [devices indexOfObjectIdenticalTo: self];
}

- (MTLSize)maxThreadsPerThreadgroup
{
	return MTLSizeMake(1024, 1024, 1024);
}

- (BOOL)isLowPower
{
	return NO;
}

- (BOOL)isHeadless
{
	return NO;
}

- (BOOL)isRemovable
{
	return NO;
}

- (BOOL)hasUnifiedMemory
{
	return NO;
}

- (uint64_t)recommendedMaxWorkingSetSize
{
	// Indium doesn't tell us how much memory the GPU has; assume a 4 GiB card
	return 4ull << 30;
}

- (MTLDeviceLocation)location
{
	return MTLDeviceLocationSlot;
}

- (NSUInteger)locationNumber
{
	return 0;
}

- (uint64_t)maxTransferRate
{
	return 0;
}

- (uint64_t)peerGroupID
{
	return 0;
}

- (uint32_t)peerIndex
{
	return 0;
}

- (uint32_t)peerCount
{
	return 0;
}

- (BOOL)isDepth24Stencil8PixelFormatSupported
{
	// Indium has no mapping for it, so steer apps towards Depth32Float_Stencil8
	return NO;
}

- (MTLReadWriteTextureTier)readWriteTextureSupport
{
	return MTLReadWriteTextureTier1;
}

- (MTLArgumentBuffersTier)argumentBuffersSupport
{
	return MTLArgumentBuffersTier1;
}

- (BOOL)areRasterOrderGroupsSupported
{
	return NO;
}

- (BOOL)supports32BitFloatFiltering
{
	return YES;
}

- (BOOL)supports32BitMSAA
{
	return YES;
}

- (BOOL)supportsBCTextureCompression
{
	return YES;
}

- (BOOL)supportsQueryTextureLOD
{
	return YES;
}

- (BOOL)supportsPullModelInterpolation
{
	return NO;
}

- (BOOL)supportsShaderBarycentricCoordinates
{
	return NO;
}

- (BOOL)areBarycentricCoordsSupported
{
	return NO;
}

- (BOOL)areProgrammableSamplePositionsSupported
{
	return NO;
}

- (BOOL)supportsRaytracing
{
	return NO;
}

- (BOOL)supportsFunctionPointers
{
	return NO;
}

- (BOOL)supportsDynamicLibraries
{
	return NO;
}

- (NSUInteger)currentAllocatedSize
{
	// not tracked
	return 0;
}

- (NSUInteger)maxThreadgroupMemoryLength
{
	return 32 * 1024;
}

- (NSUInteger)maxArgumentBufferSamplerCount
{
	return 16;
}

- (NSUInteger)maxBufferLength
{
	return 1ull << 30;
}

- (BOOL)supportsFamily: (MTLGPUFamily)gpuFamily
{
	switch (gpuFamily) {
		case MTLGPUFamilyMac1:
		case MTLGPUFamilyMac2:
		case MTLGPUFamilyCommon1:
		case MTLGPUFamilyCommon2:
		case MTLGPUFamilyCommon3:
		case MTLGPUFamilyMacCatalyst1:
		case MTLGPUFamilyMacCatalyst2:
			return YES;

		default:
			// the Apple GPU families and Metal 3 need features Indium doesn't implement
			return NO;
	}
}

- (BOOL)supportsFeatureSet: (MTLFeatureSet)featureSet
{
	return featureSet >= MTLFeatureSet_macOS_GPUFamily1_v1 && featureSet <= MTLFeatureSet_macOS_GPUFamily2_v1;
}

- (BOOL)supportsTextureSampleCount: (NSUInteger)sampleCount
{
	return sampleCount == 1 || sampleCount == 2 || sampleCount == 4 || sampleCount == 8;
}

- (NSUInteger)minimumLinearTextureAlignmentForPixelFormat: (MTLPixelFormat)format
{
	return 256;
}

- (NSUInteger)minimumTextureBufferAlignmentForPixelFormat: (MTLPixelFormat)format
{
	return 256;
}

//
// resource and state creation
//

- (id<MTLCommandQueue>)newCommandQueueWithMaxCommandBufferCount: (NSUInteger)maxCommandBufferCount
{
	// Indium doesn't limit how many command buffers a queue has in flight
	return [self newCommandQueue];
}

- (id<MTLBuffer>)newBufferWithBytesNoCopy: (void*)pointer
                                   length: (NSUInteger)length
                                  options: (MTLResourceOptions)options
                              deallocator: (void (^)(void* pointer, NSUInteger length))deallocator
{
	// Indium can't wrap existing memory, so the buffer gets a copy of the bytes. That's enough for data
	// that's set up once, but unlike on macOS, later CPU writes through `pointer` won't reach the buffer
	// (nor will GPU writes show up there).
	id<MTLBuffer> buffer = [self newBufferWithBytes: pointer length: length options: options];

	if (buffer != nil && deallocator != nil) {
		// like Metal, hand the memory back once the buffer goes away
		MTLBufferNoCopyDeallocator* invoker = [[MTLBufferNoCopyDeallocator alloc] initWithDeallocator: deallocator pointer: pointer length: length];
		objc_setAssociatedObject(buffer, &noCopyDeallocatorKey, invoker, OBJC_ASSOCIATION_RETAIN);
		[invoker release];
	}

	return buffer;
}

- (id<MTLTexture>)newTextureWithDescriptor: (MTLTextureDescriptor*)descriptor
{
	auto texture = _device->newTexture([descriptor asIndiumDescriptor]);
	if (!texture) {
		return nil;
	}
	return [[MTLTextureInternal alloc] initWithTexture: texture device: self resourceOptions: descriptor.resourceOptions usage: descriptor.usage];
}

- (id<MTLSamplerState>)newSamplerStateWithDescriptor: (MTLSamplerDescriptor*)descriptor
{
	auto state = _device->newSamplerState([descriptor asIndiumDescriptor]);
	if (!state) {
		return nil;
	}
	return [[MTLSamplerStateInternal alloc] initWithState: state device: self label: descriptor.label];
}

- (id<MTLDepthStencilState>)newDepthStencilStateWithDescriptor: (MTLDepthStencilDescriptor*)descriptor
{
	auto state = _device->newDepthStencilState([descriptor asIndiumDescriptor]);
	if (!state) {
		return nil;
	}
	return [[MTLDepthStencilStateInternal alloc] initWithState: state device: self label: descriptor.label];
}

- (id<MTLLibrary>)newLibraryWithFile: (NSString*)filepath
                               error: (NSError**)error
{
	return [self newLibraryWithURL: [NSURL fileURLWithPath: filepath] error: error];
}

- (id<MTLLibrary>)newLibraryWithSource: (NSString*)source
                               options: (MTLCompileOptions*)options
                                 error: (NSError**)error
{
	// Iridium translates compiled AIR; there's no Metal Shading Language compiler to produce it from source
	if (error) {
		*error = sourceCompilationUnsupportedError();
	}
	return nil;
}

- (void)newLibraryWithSource: (NSString*)source
                     options: (MTLCompileOptions*)options
           completionHandler: (MTLNewLibraryCompletionHandler)completionHandler
{
	MTLNewLibraryCompletionHandler handler = [completionHandler copy];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		handler(nil, sourceCompilationUnsupportedError());
		[handler release];
	});
}

- (id<MTLRenderPipelineState>)newRenderPipelineStateWithDescriptor: (MTLRenderPipelineDescriptor*)descriptor
                                                           options: (MTLPipelineOption)options
                                                        reflection: (MTLAutoreleasedRenderPipelineReflection*)reflection
                                                             error: (NSError**)error
{
	// TODO: reflection
	if (reflection) {
		*reflection = nil;
	}
	return [self newRenderPipelineStateWithDescriptor: descriptor error: error];
}

- (void)newRenderPipelineStateWithDescriptor: (MTLRenderPipelineDescriptor*)descriptor
                           completionHandler: (MTLNewRenderPipelineStateCompletionHandler)completionHandler
{
	MTLRenderPipelineDescriptor* descriptorCopy = [descriptor copy];
	MTLNewRenderPipelineStateCompletionHandler handler = [completionHandler copy];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSError* error = nil;
		id<MTLRenderPipelineState> state = [self newRenderPipelineStateWithDescriptor: descriptorCopy error: &error];
		handler(state, error);
		[state release];
		[handler release];
		[descriptorCopy release];
	});
}

- (void)newComputePipelineStateWithFunction: (id<MTLFunction>)computeFunction
                          completionHandler: (MTLNewComputePipelineStateCompletionHandler)completionHandler
{
	id<MTLFunction> function = [computeFunction retain];
	MTLNewComputePipelineStateCompletionHandler handler = [completionHandler copy];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSError* error = nil;
		id<MTLComputePipelineState> state = [self newComputePipelineStateWithFunction: function error: &error];
		handler(state, error);
		[state release];
		[handler release];
		[function release];
	});
}

#else

MTL_UNSUPPORTED_CLASS

#endif

@end
