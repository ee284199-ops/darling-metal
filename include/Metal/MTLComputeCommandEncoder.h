// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#import <Foundation/Foundation.h>

#import <Metal/MTLCommandBuffer.h>
#import <Metal/MTLCommandEncoder.h>
#import <Metal/MTLComputePipeline.h>
#import <Metal/MTLDefines.h>

METAL_DECLARATIONS_BEGIN

@protocol MTLComputeCommandEncoder;
@protocol MTLCounterSampleBuffer;
@protocol MTLBuffer;
@protocol MTLTexture;
@protocol MTLSamplerState;
@protocol MTLResource;

@class MTLComputePassDescriptor;
@class MTLComputePassSampleBufferAttachmentDescriptorArray;
@class MTLComputePassSampleBufferAttachmentDescriptor;

#define MTLCounterDontSample ((NSUInteger)-1)

MTL_EXPORT
@interface MTLComputePassSampleBufferAttachmentDescriptor : NSObject <NSCopying>

@property(readwrite, nullable, nonatomic, retain) id<MTLCounterSampleBuffer> sampleBuffer;
@property(readwrite, nonatomic, assign) NSUInteger startOfEncoderSampleIndex;
@property(nonatomic) NSUInteger endOfEncoderSampleIndex;

@end

MTL_EXPORT
@interface MTLComputePassSampleBufferAttachmentDescriptorArray : NSObject

- (MTLComputePassSampleBufferAttachmentDescriptor*)objectAtIndexedSubscript: (NSUInteger)index;
-    (void)setObject: (MTLComputePassSampleBufferAttachmentDescriptor*)attachment
  atIndexedSubscript: (NSUInteger)index;

@end

MTL_EXPORT
@interface MTLComputePassDescriptor : NSObject <NSCopying>

+ (MTLComputePassDescriptor*)computePassDescriptor;

@property(readwrite, nonatomic, assign) MTLDispatchType dispatchType;
@property(readonly) MTLComputePassSampleBufferAttachmentDescriptorArray* sampleBufferAttachments;

@end

@protocol MTLComputeCommandEncoder <MTLCommandEncoder>

@property(readonly) MTLDispatchType dispatchType;

- (void)setComputePipelineState:(id<MTLComputePipelineState>)state;

- (void)setBuffer: (id<MTLBuffer>)buffer
           offset: (NSUInteger)offset
          atIndex: (NSUInteger)index;

- (void)setBuffers: (const id<MTLBuffer>*)buffers
           offsets: (const NSUInteger *)offsets
         withRange: (NSRange)range;

- (void)setBufferOffset: (NSUInteger)offset
                atIndex: (NSUInteger)index;

- (void)setBytes: (const void*)bytes
          length: (NSUInteger)length
         atIndex: (NSUInteger)index;

- (void)dispatchThreadgroups: (MTLSize)threadgroupsPerGrid
       threadsPerThreadgroup: (MTLSize)threadsPerThreadgroup;

- (void)dispatchThreads: (MTLSize)threadsPerGrid
  threadsPerThreadgroup: (MTLSize)threadsPerThreadgroup;

- (void)setTexture: (id<MTLTexture>)texture
           atIndex: (NSUInteger)index;

- (void)setTextures: (const id<MTLTexture> __nullable [__nonnull])textures
          withRange: (NSRange)range;

- (void)setSamplerState: (id<MTLSamplerState>)sampler
                atIndex: (NSUInteger)index;

- (void)setSamplerState: (id<MTLSamplerState>)sampler
            lodMinClamp: (float)lodMinClamp
            lodMaxClamp: (float)lodMaxClamp
                atIndex: (NSUInteger)index;

- (void)setSamplerStates: (const id<MTLSamplerState> __nullable [__nonnull])samplers
               withRange: (NSRange)range;

- (void)setThreadgroupMemoryLength: (NSUInteger)length
                           atIndex: (NSUInteger)index;

// all memory Indium hands out is resident, so these are hints only
- (void)useResource: (id<MTLResource>)resource
              usage: (NSUInteger)usage;

- (void)useResources: (const id<MTLResource> __nonnull [__nonnull])resources
               count: (NSUInteger)count
               usage: (NSUInteger)usage;

@end

METAL_DECLARATIONS_END
