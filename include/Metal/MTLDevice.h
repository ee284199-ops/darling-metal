// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#ifndef _METAL_MTLDEVICE_H_
#define _METAL_MTLDEVICE_H_

#import <Foundation/Foundation.h>

#import <Metal/MTLResource.h>
#import <Metal/MTLDefines.h>
#import <Metal/MTLPixelFormat.h>
#import <Metal/MTLTypes.h>

METAL_DECLARATIONS_BEGIN

@protocol MTLComputePipelineState;
@protocol MTLFunction;
@protocol MTLCommandQueue;
@protocol MTLDevice;
@protocol MTLBuffer;
@protocol MTLLibrary;
@protocol MTLRenderPipelineState;
@protocol MTLTexture;
@protocol MTLSamplerState;
@protocol MTLDepthStencilState;

@class MTLComputePipelineDescriptor;
@class MTLAutoreleasedComputePipelineReflection;
@class MTLRenderPipelineDescriptor;
@class MTLRenderPipelineReflection;
@class MTLTextureDescriptor;
@class MTLSamplerDescriptor;
@class MTLDepthStencilDescriptor;
@class MTLCompileOptions;

typedef __autoreleasing MTLRenderPipelineReflection* MTLAutoreleasedRenderPipelineReflection;

typedef void (^MTLNewLibraryCompletionHandler)(id<MTLLibrary> library, NSError* error);
typedef void (^MTLNewRenderPipelineStateCompletionHandler)(id<MTLRenderPipelineState> renderPipelineState, NSError* error);
typedef void (^MTLNewComputePipelineStateCompletionHandler)(id<MTLComputePipelineState> computePipelineState, NSError* error);

typedef NS_ENUM(NSInteger, MTLGPUFamily) {
	MTLGPUFamilyApple1 = 1001,
	MTLGPUFamilyApple2 = 1002,
	MTLGPUFamilyApple3 = 1003,
	MTLGPUFamilyApple4 = 1004,
	MTLGPUFamilyApple5 = 1005,
	MTLGPUFamilyApple6 = 1006,
	MTLGPUFamilyApple7 = 1007,
	MTLGPUFamilyApple8 = 1008,
	MTLGPUFamilyApple9 = 1009,
	MTLGPUFamilyMac1 = 2001,
	MTLGPUFamilyMac2 = 2002,
	MTLGPUFamilyCommon1 = 3001,
	MTLGPUFamilyCommon2 = 3002,
	MTLGPUFamilyCommon3 = 3003,
	MTLGPUFamilyMacCatalyst1 = 4001,
	MTLGPUFamilyMacCatalyst2 = 4002,
	MTLGPUFamilyMetal3 = 5001,
};

typedef NS_ENUM(NSUInteger, MTLFeatureSet) {
	MTLFeatureSet_macOS_GPUFamily1_v1 = 10000,
	MTLFeatureSet_macOS_GPUFamily1_v2 = 10001,
	MTLFeatureSet_macOS_ReadWriteTextureTier2 = 10002,
	MTLFeatureSet_macOS_GPUFamily1_v3 = 10003,
	MTLFeatureSet_macOS_GPUFamily1_v4 = 10004,
	MTLFeatureSet_macOS_GPUFamily2_v1 = 10005,
};

typedef NS_ENUM(NSUInteger, MTLReadWriteTextureTier) {
	MTLReadWriteTextureTierNone = 0,
	MTLReadWriteTextureTier1 = 1,
	MTLReadWriteTextureTier2 = 2,
};

typedef NS_ENUM(NSUInteger, MTLArgumentBuffersTier) {
	MTLArgumentBuffersTier1 = 0,
	MTLArgumentBuffersTier2 = 1,
};

typedef NS_ENUM(NSUInteger, MTLDeviceLocation) {
	MTLDeviceLocationBuiltIn = 0,
	MTLDeviceLocationSlot = 1,
	MTLDeviceLocationExternal = 2,
	MTLDeviceLocationUnspecified = NSUIntegerMax,
};

typedef NS_OPTIONS(NSUInteger, MTLPipelineOption) {
	MTLPipelineOptionNone = 0,
	MTLPipelineOptionArgumentInfo = 1 << 0,
	MTLPipelineOptionBufferTypeInfo = 1 << 1,
	MTLPipelineOptionFailOnBinaryArchiveMiss = 1 << 2,
};

typedef NSString* MTLDeviceNotificationName;
typedef void (^MTLDeviceNotificationHandler)(id<MTLDevice> device, MTLDeviceNotificationName notifyName);

MTL_EXPORT MTL_EXTERN const MTLDeviceNotificationName MTLDeviceWasAddedNotification;
MTL_EXPORT MTL_EXTERN const MTLDeviceNotificationName MTLDeviceRemovalRequestedNotification;
MTL_EXPORT MTL_EXTERN const MTLDeviceNotificationName MTLDeviceWasRemovedNotification;

MTL_EXPORT id<MTLDevice> MTLCreateSystemDefaultDevice(void);
MTL_EXPORT NSArray<id<MTLDevice>>* MTLCopyAllDevices(void);
MTL_EXPORT NSArray<id<MTLDevice>>* MTLCopyAllDevicesWithObserver(id<NSObject>* observer, MTLDeviceNotificationHandler handler);
MTL_EXPORT void MTLRemoveDeviceObserver(id<NSObject> observer);

@protocol MTLDevice <NSObject>

- (id<MTLComputePipelineState>)newComputePipelineStateWithDescriptor: (MTLComputePipelineDescriptor*)descriptor
                                                             options: (MTLPipelineOption)options
                                                          reflection: (MTLAutoreleasedComputePipelineReflection*)reflection
                                                               error: (NSError**)error;

- (id<MTLComputePipelineState>)newComputePipelineStateWithFunction: (id<MTLFunction>)computeFunction 
                                                             error: (NSError**)error;

- (id<MTLComputePipelineState>)newComputePipelineStateWithFunction: (id<MTLFunction>)computeFunction 
                                                           options: (MTLPipelineOption)options 
                                                        reflection: (MTLAutoreleasedComputePipelineReflection*)reflection 
                                                             error: (NSError**)error;

- (id<MTLRenderPipelineState>)newRenderPipelineStateWithDescriptor: (MTLRenderPipelineDescriptor*)descriptor
                                                             error: (NSError**)error;

- (id<MTLCommandQueue>)newCommandQueue;

- (id<MTLBuffer>)newBufferWithLength: (NSUInteger)length
                             options: (MTLResourceOptions)options;

- (id<MTLBuffer>)newBufferWithBytes: (const void*)pointer
                             length: (NSUInteger)length
                            options: (MTLResourceOptions)options;

- (id<MTLLibrary>)newDefaultLibrary;

- (id<MTLLibrary>)newDefaultLibraryWithBundle: (NSBundle*)bundle
                                        error: (NSError**)error;

- (id<MTLLibrary>)newLibraryWithURL: (NSURL*)url
                              error: (NSError**)error;

- (id<MTLLibrary>)newLibraryWithData: (dispatch_data_t)data
                               error: (NSError**)error;

//
// device information
//

@property(readonly) NSString* name;
@property(readonly) uint64_t registryID;
@property(readonly) MTLSize maxThreadsPerThreadgroup;
@property(readonly, getter=isLowPower) BOOL lowPower;
@property(readonly, getter=isHeadless) BOOL headless;
@property(readonly, getter=isRemovable) BOOL removable;
@property(readonly) BOOL hasUnifiedMemory;
@property(readonly) uint64_t recommendedMaxWorkingSetSize;
@property(readonly) MTLDeviceLocation location;
@property(readonly) NSUInteger locationNumber;
@property(readonly) uint64_t maxTransferRate;
@property(readonly) uint64_t peerGroupID;
@property(readonly) uint32_t peerIndex;
@property(readonly) uint32_t peerCount;
@property(readonly, getter=isDepth24Stencil8PixelFormatSupported) BOOL depth24Stencil8PixelFormatSupported;
@property(readonly) MTLReadWriteTextureTier readWriteTextureSupport;
@property(readonly) MTLArgumentBuffersTier argumentBuffersSupport;
@property(readonly, getter=areRasterOrderGroupsSupported) BOOL rasterOrderGroupsSupported;
@property(readonly) BOOL supports32BitFloatFiltering;
@property(readonly) BOOL supports32BitMSAA;
@property(readonly) BOOL supportsBCTextureCompression;
@property(readonly) BOOL supportsQueryTextureLOD;
@property(readonly) BOOL supportsPullModelInterpolation;
@property(readonly) BOOL supportsShaderBarycentricCoordinates;
@property(readonly, getter=areBarycentricCoordsSupported) BOOL barycentricCoordsSupported;
@property(readonly, getter=areProgrammableSamplePositionsSupported) BOOL programmableSamplePositionsSupported;
@property(readonly) BOOL supportsRaytracing;
@property(readonly) BOOL supportsFunctionPointers;
@property(readonly) BOOL supportsDynamicLibraries;
@property(readonly) NSUInteger currentAllocatedSize;
@property(readonly) NSUInteger maxThreadgroupMemoryLength;
@property(readonly) NSUInteger maxArgumentBufferSamplerCount;
@property(readonly) NSUInteger maxBufferLength;

- (BOOL)supportsFamily: (MTLGPUFamily)gpuFamily;
- (BOOL)supportsFeatureSet: (MTLFeatureSet)featureSet;
- (BOOL)supportsTextureSampleCount: (NSUInteger)sampleCount;
- (NSUInteger)minimumLinearTextureAlignmentForPixelFormat: (MTLPixelFormat)format;
- (NSUInteger)minimumTextureBufferAlignmentForPixelFormat: (MTLPixelFormat)format;

//
// resource and state creation
//

- (id<MTLCommandQueue>)newCommandQueueWithMaxCommandBufferCount: (NSUInteger)maxCommandBufferCount;

- (id<MTLBuffer>)newBufferWithBytesNoCopy: (void*)pointer
                                   length: (NSUInteger)length
                                  options: (MTLResourceOptions)options
                              deallocator: (void (^)(void* pointer, NSUInteger length))deallocator;

- (id<MTLTexture>)newTextureWithDescriptor: (MTLTextureDescriptor*)descriptor;
- (id<MTLSamplerState>)newSamplerStateWithDescriptor: (MTLSamplerDescriptor*)descriptor;
- (id<MTLDepthStencilState>)newDepthStencilStateWithDescriptor: (MTLDepthStencilDescriptor*)descriptor;

- (id<MTLLibrary>)newLibraryWithFile: (NSString*)filepath
                               error: (NSError**)error;

- (id<MTLLibrary>)newLibraryWithSource: (NSString*)source
                               options: (MTLCompileOptions*)options
                                 error: (NSError**)error;

- (void)newLibraryWithSource: (NSString*)source
                     options: (MTLCompileOptions*)options
           completionHandler: (MTLNewLibraryCompletionHandler)completionHandler;

- (id<MTLRenderPipelineState>)newRenderPipelineStateWithDescriptor: (MTLRenderPipelineDescriptor*)descriptor
                                                           options: (MTLPipelineOption)options
                                                        reflection: (MTLAutoreleasedRenderPipelineReflection*)reflection
                                                             error: (NSError**)error;

- (void)newRenderPipelineStateWithDescriptor: (MTLRenderPipelineDescriptor*)descriptor
                           completionHandler: (MTLNewRenderPipelineStateCompletionHandler)completionHandler;

- (void)newComputePipelineStateWithFunction: (id<MTLFunction>)computeFunction
                          completionHandler: (MTLNewComputePipelineStateCompletionHandler)completionHandler;

// TODO: other methods and properties

@end

METAL_DECLARATIONS_END

#endif // _METAL_MTLDEVICE_H_
