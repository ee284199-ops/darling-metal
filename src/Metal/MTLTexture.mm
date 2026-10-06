// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#import <Metal/MTLTextureInternal.h>
#import <Metal/MTLDevice.h>
#import <Metal/stubs.h>
#import <Metal/MTLPixelFormatInternal.h>
#import <Metal/MTLTypesInternal.h>

@implementation MTLTextureInternal

#if DARLING_METAL_ENABLED

{
	MTLTextureUsage _usage;
}

@synthesize texture = _texture;
@synthesize device = _device;
@synthesize resourceOptions = _resourceOptions;
@synthesize label = _label;

- (instancetype)initWithTexture: (std::shared_ptr<Indium::Texture>)texture
                         device: (id<MTLDevice>)device
                resourceOptions: (MTLResourceOptions)options
{
	return [self initWithTexture: texture device: device resourceOptions: options usage: MTLTextureUsageUnknown];
}

- (instancetype)initWithTexture: (std::shared_ptr<Indium::Texture>)texture
                         device: (id<MTLDevice>)device
                resourceOptions: (MTLResourceOptions)options
                          usage: (MTLTextureUsage)usage
{
	self = [super init];
	if (self != nil) {
		_texture = texture;
		_device = [device retain];
		_resourceOptions = options;
		_usage = usage;
	}
	return self;
}

- (void)dealloc
{
	[_device release];
	[_label release];
	[super dealloc];
}

//
// properties
//

- (MTLCPUCacheMode)cpuCacheMode
{
	return static_cast<MTLCPUCacheMode>((self.resourceOptions >> MTLResourceCPUCacheModeShift) & 0x0f);
}

- (MTLStorageMode)storageMode
{
	return static_cast<MTLStorageMode>((self.resourceOptions >> MTLResourceStorageModeShift) & 0x0f);
}

- (MTLHazardTrackingMode)hazardTrackingMode
{
	return static_cast<MTLHazardTrackingMode>((self.resourceOptions >> MTLResourceHazardTrackingModeShift) & 0x0f);
}

- (MTLTextureType)textureType
{
	return static_cast<MTLTextureType>(_texture->textureType());
}

- (MTLPixelFormat)pixelFormat
{
	return static_cast<MTLPixelFormat>(_texture->pixelFormat());
}

- (NSUInteger)width
{
	return _texture->width();
}

- (NSUInteger)height
{
	return _texture->height();
}

- (NSUInteger)depth
{
	return _texture->depth();
}

- (NSUInteger)mipmapLevelCount
{
	return _texture->mipmapLevelCount();
}

- (NSUInteger)arrayLength
{
	return _texture->arrayLength();
}

- (NSUInteger)sampleCount
{
	return _texture->sampleCount();
}

- (BOOL)isFramebufferOnly
{
	return _texture->framebufferOnly();
}

- (MTLTextureUsage)usage
{
	// only known for textures created from a descriptor
	return _usage;
}

- (BOOL)allowGPUOptimizedContents
{
	return _texture->allowGPUOptimizedContents();
}

- (BOOL)isShareable
{
	return _texture->shareable();
}

- (MTLTextureSwizzleChannels)swizzle
{
	return MTLTextureSwizzleChannelsFromIndium(_texture->swizzle());
}

//
// methods
//

- (id<MTLTexture>)newTextureViewWithPixelFormat: (MTLPixelFormat)pixelFormat
{
	auto tex = _texture->newTextureView(static_cast<Indium::PixelFormat>(pixelFormat));
	if (!tex) {
		return nil;
	}
	return [[MTLTextureInternal alloc] initWithTexture: tex device: _device resourceOptions: _resourceOptions usage: _usage];
}

- (id<MTLTexture>)newTextureViewWithPixelFormat: (MTLPixelFormat)pixelFormat
                                    textureType: (MTLTextureType)textureType
                                         levels: (NSRange)levelRange
                                         slices: (NSRange)sliceRange
{
	auto tex = _texture->newTextureView(static_cast<Indium::PixelFormat>(pixelFormat), static_cast<Indium::TextureType>(textureType), NSRangeToIndium(levelRange), NSRangeToIndium(sliceRange));
	if (!tex) {
		return nil;
	}
	return [[MTLTextureInternal alloc] initWithTexture: tex device: _device resourceOptions: _resourceOptions usage: _usage];
}

- (id<MTLTexture>)newTextureViewWithPixelFormat: (MTLPixelFormat)pixelFormat
                                    textureType: (MTLTextureType)textureType
                                         levels: (NSRange)levelRange
                                         slices: (NSRange)sliceRange
                                        swizzle: (MTLTextureSwizzleChannels)swizzle
{
	auto tex = _texture->newTextureView(static_cast<Indium::PixelFormat>(pixelFormat), static_cast<Indium::TextureType>(textureType), NSRangeToIndium(levelRange), NSRangeToIndium(sliceRange), MTLTextureSwizzleChannelsToIndium(swizzle));
	if (!tex) {
		return nil;
	}
	return [[MTLTextureInternal alloc] initWithTexture: tex device: _device resourceOptions: _resourceOptions usage: _usage];
}

- (void)replaceRegion: (MTLRegion)region
          mipmapLevel: (NSUInteger)level
            withBytes: (const void*)pixelBytes
          bytesPerRow: (NSUInteger)bytesPerRow
{
	_texture->replaceRegion(MTLRegionToIndium(region), level, pixelBytes, bytesPerRow);
}

- (void)replaceRegion: (MTLRegion)region
          mipmapLevel: (NSUInteger)level
                slice: (NSUInteger)slice
            withBytes: (const void*)pixelBytes
          bytesPerRow: (NSUInteger)bytesPerRow
        bytesPerImage: (NSUInteger)bytesPerImage
{
	_texture->replaceRegion(MTLRegionToIndium(region), level, slice, pixelBytes, bytesPerRow, bytesPerImage);
}

- (void)getBytes: (void*)pixelBytes
     bytesPerRow: (NSUInteger)bytesPerRow
      fromRegion: (MTLRegion)region
     mipmapLevel: (NSUInteger)level
{
	NSLog(@"STUB: getBytes:bytesPerRow:fromRegion:mipmapLevel:");
	abort();
}

- (void)getBytes: (void*)pixelBytes
     bytesPerRow: (NSUInteger)bytesPerRow
   bytesPerImage: (NSUInteger)bytesPerImage
      fromRegion: (MTLRegion)region
     mipmapLevel: (NSUInteger)level
           slice: (NSUInteger)slice
{
	NSLog(@"STUB: getBytes:bytesPerRow:bytesPerImage:fromRegion:mipmapLevel:slice:");
	abort();
}

#else

@dynamic textureType;
@dynamic pixelFormat;
@dynamic width;
@dynamic height;
@dynamic depth;
@dynamic mipmapLevelCount;
@dynamic arrayLength;
@dynamic sampleCount;
@dynamic framebufferOnly;
@dynamic usage;
@dynamic allowGPUOptimizedContents;
@dynamic shareable;
@dynamic swizzle;

MTL_UNSUPPORTED_CLASS

#endif

@end
