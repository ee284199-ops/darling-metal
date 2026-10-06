// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#import <Metal/MTLBlitCommandEncoderInternal.h>
#import <Metal/MTLBufferInternal.h>
#import <Metal/MTLTextureInternal.h>
#import <Metal/MTLTypesInternal.h>
#import <Metal/MTLDevice.h>
#import <Metal/stubs.h>

#if DARLING_METAL_ENABLED

NS_INLINE
Indium::Origin MTLOriginToIndium(MTLOrigin origin) {
	return Indium::Origin { origin.x, origin.y, origin.z };
};

#endif

@implementation MTLBlitCommandEncoderInternal

#if DARLING_METAL_ENABLED

@synthesize encoder = _encoder;
@synthesize device = _device;
@synthesize label = _label;

- (instancetype)initWithEncoder: (std::shared_ptr<Indium::BlitCommandEncoder>)encoder
                         device: (id<MTLDevice>)device
{
	self = [super init];
	if (self != nil) {
		_encoder = encoder;
		_device = [device retain];
	}
	return self;
}

- (void)dealloc
{
	[_device release];
	[_label release];
	[super dealloc];
}

- (void)endEncoding
{
	_encoder->endEncoding();
}

- (void)insertDebugSignpost: (NSString*)string
{
	// debug markers are only for GPU debugging tools, which we don't have
}

- (void)pushDebugGroup: (NSString*)string
{
}

- (void)popDebugGroup
{
}

- (void)copyFromBuffer: (id<MTLBuffer>)sourceBuffer
          sourceOffset: (NSUInteger)sourceOffset
              toBuffer: (id<MTLBuffer>)destinationBuffer
     destinationOffset: (NSUInteger)destinationOffset
                  size: (NSUInteger)size
{
	_encoder->copy(((MTLBufferInternal*)sourceBuffer).buffer, sourceOffset, ((MTLBufferInternal*)destinationBuffer).buffer, destinationOffset, size);
}

- (void)copyFromBuffer: (id<MTLBuffer>)sourceBuffer
          sourceOffset: (NSUInteger)sourceOffset
     sourceBytesPerRow: (NSUInteger)sourceBytesPerRow
   sourceBytesPerImage: (NSUInteger)sourceBytesPerImage
            sourceSize: (MTLSize)sourceSize
             toTexture: (id<MTLTexture>)destinationTexture
      destinationSlice: (NSUInteger)destinationSlice
      destinationLevel: (NSUInteger)destinationLevel
     destinationOrigin: (MTLOrigin)destinationOrigin
{
	[self copyFromBuffer: sourceBuffer
	        sourceOffset: sourceOffset
	   sourceBytesPerRow: sourceBytesPerRow
	 sourceBytesPerImage: sourceBytesPerImage
	          sourceSize: sourceSize
	           toTexture: destinationTexture
	    destinationSlice: destinationSlice
	    destinationLevel: destinationLevel
	   destinationOrigin: destinationOrigin
	             options: MTLBlitOptionNone];
}

- (void)copyFromBuffer: (id<MTLBuffer>)sourceBuffer
          sourceOffset: (NSUInteger)sourceOffset
     sourceBytesPerRow: (NSUInteger)sourceBytesPerRow
   sourceBytesPerImage: (NSUInteger)sourceBytesPerImage
            sourceSize: (MTLSize)sourceSize
             toTexture: (id<MTLTexture>)destinationTexture
      destinationSlice: (NSUInteger)destinationSlice
      destinationLevel: (NSUInteger)destinationLevel
     destinationOrigin: (MTLOrigin)destinationOrigin
               options: (MTLBlitOption)options
{
	_encoder->copy(((MTLBufferInternal*)sourceBuffer).buffer, sourceOffset, sourceBytesPerRow, sourceBytesPerImage, MTLSizeToIndium(sourceSize), ((MTLTextureInternal*)destinationTexture).texture, destinationSlice, destinationLevel, MTLOriginToIndium(destinationOrigin), static_cast<Indium::BlitOption>(options));
}

- (void)copyFromTexture: (id<MTLTexture>)sourceTexture
            sourceSlice: (NSUInteger)sourceSlice
            sourceLevel: (NSUInteger)sourceLevel
           sourceOrigin: (MTLOrigin)sourceOrigin
             sourceSize: (MTLSize)sourceSize
               toBuffer: (id<MTLBuffer>)destinationBuffer
      destinationOffset: (NSUInteger)destinationOffset
 destinationBytesPerRow: (NSUInteger)destinationBytesPerRow
destinationBytesPerImage: (NSUInteger)destinationBytesPerImage
{
	[self copyFromTexture: sourceTexture
	          sourceSlice: sourceSlice
	          sourceLevel: sourceLevel
	         sourceOrigin: sourceOrigin
	           sourceSize: sourceSize
	             toBuffer: destinationBuffer
	    destinationOffset: destinationOffset
	destinationBytesPerRow: destinationBytesPerRow
	destinationBytesPerImage: destinationBytesPerImage
	              options: MTLBlitOptionNone];
}

- (void)copyFromTexture: (id<MTLTexture>)sourceTexture
            sourceSlice: (NSUInteger)sourceSlice
            sourceLevel: (NSUInteger)sourceLevel
           sourceOrigin: (MTLOrigin)sourceOrigin
             sourceSize: (MTLSize)sourceSize
               toBuffer: (id<MTLBuffer>)destinationBuffer
      destinationOffset: (NSUInteger)destinationOffset
 destinationBytesPerRow: (NSUInteger)destinationBytesPerRow
destinationBytesPerImage: (NSUInteger)destinationBytesPerImage
                options: (MTLBlitOption)options
{
	_encoder->copy(((MTLTextureInternal*)sourceTexture).texture, sourceSlice, sourceLevel, MTLOriginToIndium(sourceOrigin), MTLSizeToIndium(sourceSize), ((MTLBufferInternal*)destinationBuffer).buffer, destinationOffset, destinationBytesPerRow, destinationBytesPerImage, static_cast<Indium::BlitOption>(options));
}

- (void)copyFromTexture: (id<MTLTexture>)sourceTexture
            sourceSlice: (NSUInteger)sourceSlice
            sourceLevel: (NSUInteger)sourceLevel
           sourceOrigin: (MTLOrigin)sourceOrigin
             sourceSize: (MTLSize)sourceSize
              toTexture: (id<MTLTexture>)destinationTexture
       destinationSlice: (NSUInteger)destinationSlice
       destinationLevel: (NSUInteger)destinationLevel
      destinationOrigin: (MTLOrigin)destinationOrigin
{
	_encoder->copy(((MTLTextureInternal*)sourceTexture).texture, sourceSlice, sourceLevel, MTLOriginToIndium(sourceOrigin), MTLSizeToIndium(sourceSize), ((MTLTextureInternal*)destinationTexture).texture, destinationSlice, destinationLevel, MTLOriginToIndium(destinationOrigin));
}

- (void)copyFromTexture: (id<MTLTexture>)sourceTexture
            sourceSlice: (NSUInteger)sourceSlice
            sourceLevel: (NSUInteger)sourceLevel
              toTexture: (id<MTLTexture>)destinationTexture
       destinationSlice: (NSUInteger)destinationSlice
       destinationLevel: (NSUInteger)destinationLevel
             sliceCount: (NSUInteger)sliceCount
             levelCount: (NSUInteger)levelCount
{
	_encoder->copy(((MTLTextureInternal*)sourceTexture).texture, sourceSlice, sourceLevel, ((MTLTextureInternal*)destinationTexture).texture, destinationSlice, destinationLevel, sliceCount, levelCount);
}

- (void)copyFromTexture: (id<MTLTexture>)sourceTexture
              toTexture: (id<MTLTexture>)destinationTexture
{
	_encoder->copy(((MTLTextureInternal*)sourceTexture).texture, ((MTLTextureInternal*)destinationTexture).texture);
}

- (void)fillBuffer: (id<MTLBuffer>)buffer
             range: (NSRange)range
             value: (uint8_t)value
{
	_encoder->fillBuffer(((MTLBufferInternal*)buffer).buffer, NSRangeToIndium(range), value);
}

- (void)generateMipmapsForTexture: (id<MTLTexture>)texture
{
	_encoder->generateMipmapsForTexture(((MTLTextureInternal*)texture).texture);
}

// Indium keeps managed resources in a single host-visible allocation rather than separate CPU and GPU
// copies, so there is nothing to synchronize; it also has no special layouts to optimize contents for.

- (void)synchronizeResource: (id<MTLResource>)resource
{
}

- (void)synchronizeTexture: (id<MTLTexture>)texture
                     slice: (NSUInteger)slice
                     level: (NSUInteger)level
{
}

- (void)optimizeContentsForGPUAccess: (id<MTLTexture>)texture
{
}

- (void)optimizeContentsForCPUAccess: (id<MTLTexture>)texture
{
}

#else

@dynamic device;
@dynamic label;

MTL_UNSUPPORTED_CLASS

#endif

@end
