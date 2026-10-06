// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#import <Metal/MTLTextureInternal.h>
#import <Metal/stubs.h>

#if DARLING_METAL_ENABLED

// the number of mipmap levels down to 1x1 for a texture whose largest dimension is `size`
static NSUInteger fullMipmapLevelCount(NSUInteger size) {
	NSUInteger levels = 1;
	while (size > 1) {
		size >>= 1;
		++levels;
	}
	return levels;
};

#endif

@implementation MTLTextureDescriptor

#if DARLING_METAL_ENABLED

@synthesize textureType = _textureType;
@synthesize pixelFormat = _pixelFormat;
@synthesize width = _width;
@synthesize height = _height;
@synthesize depth = _depth;
@synthesize mipmapLevelCount = _mipmapLevelCount;
@synthesize sampleCount = _sampleCount;
@synthesize arrayLength = _arrayLength;
@synthesize resourceOptions = _resourceOptions;
@synthesize usage = _usage;
@synthesize allowGPUOptimizedContents = _allowGPUOptimizedContents;
@synthesize swizzle = _swizzle;

+ (MTLTextureDescriptor*)texture2DDescriptorWithPixelFormat: (MTLPixelFormat)pixelFormat
                                                      width: (NSUInteger)width
                                                     height: (NSUInteger)height
                                                  mipmapped: (BOOL)mipmapped
{
	MTLTextureDescriptor* desc = [[self new] autorelease];
	desc.textureType = MTLTextureType2D;
	desc.pixelFormat = pixelFormat;
	desc.width = width;
	desc.height = height;
	desc.mipmapLevelCount = mipmapped ? fullMipmapLevelCount(MAX(width, height)) : 1;
	return desc;
}

+ (MTLTextureDescriptor*)textureCubeDescriptorWithPixelFormat: (MTLPixelFormat)pixelFormat
                                                         size: (NSUInteger)size
                                                    mipmapped: (BOOL)mipmapped
{
	MTLTextureDescriptor* desc = [[self new] autorelease];
	desc.textureType = MTLTextureTypeCube;
	desc.pixelFormat = pixelFormat;
	desc.width = size;
	desc.height = size;
	desc.mipmapLevelCount = mipmapped ? fullMipmapLevelCount(size) : 1;
	return desc;
}

+ (MTLTextureDescriptor*)textureBufferDescriptorWithPixelFormat: (MTLPixelFormat)pixelFormat
                                                          width: (NSUInteger)width
                                                resourceOptions: (MTLResourceOptions)resourceOptions
                                                          usage: (MTLTextureUsage)usage
{
	MTLTextureDescriptor* desc = [[self new] autorelease];
	desc.textureType = MTLTextureTypeTextureBuffer;
	desc.pixelFormat = pixelFormat;
	desc.width = width;
	desc.resourceOptions = resourceOptions;
	desc.usage = usage;
	return desc;
}

- (instancetype)init
{
	self = [super init];
	if (self != nil) {
		_textureType = MTLTextureType2D;
		_pixelFormat = MTLPixelFormatRGBA8Unorm;
		_width = 1;
		_height = 1;
		_depth = 1;
		_mipmapLevelCount = 1;
		_sampleCount = 1;
		_arrayLength = 1;
		_resourceOptions = MTLResourceCPUCacheModeDefaultCache | MTLResourceStorageModeManaged | MTLResourceHazardTrackingModeDefault;
		_usage = MTLTextureUsageShaderRead;
		_allowGPUOptimizedContents = YES;
		_swizzle = MTLTextureSwizzleChannelsDefault;
	}
	return self;
}

- (instancetype)copyWithZone: (NSZone*)zone
{
	MTLTextureDescriptor* copy = [[self class] new];

	copy->_textureType = _textureType;
	copy->_pixelFormat = _pixelFormat;
	copy->_width = _width;
	copy->_height = _height;
	copy->_depth = _depth;
	copy->_mipmapLevelCount = _mipmapLevelCount;
	copy->_sampleCount = _sampleCount;
	copy->_arrayLength = _arrayLength;
	copy->_resourceOptions = _resourceOptions;
	copy->_usage = _usage;
	copy->_allowGPUOptimizedContents = _allowGPUOptimizedContents;
	copy->_swizzle = _swizzle;

	return copy;
}

//
// the storage, CPU cache, and hazard tracking modes are just views of the corresponding bits of resourceOptions
//

- (MTLCPUCacheMode)cpuCacheMode
{
	return static_cast<MTLCPUCacheMode>((_resourceOptions >> MTLResourceCPUCacheModeShift) & 0x0f);
}

- (void)setCpuCacheMode: (MTLCPUCacheMode)cpuCacheMode
{
	_resourceOptions = (_resourceOptions & ~(static_cast<NSUInteger>(0x0f) << MTLResourceCPUCacheModeShift)) | (static_cast<NSUInteger>(cpuCacheMode) << MTLResourceCPUCacheModeShift);
}

- (MTLStorageMode)storageMode
{
	return static_cast<MTLStorageMode>((_resourceOptions >> MTLResourceStorageModeShift) & 0x0f);
}

- (void)setStorageMode: (MTLStorageMode)storageMode
{
	_resourceOptions = (_resourceOptions & ~(static_cast<NSUInteger>(0x0f) << MTLResourceStorageModeShift)) | (static_cast<NSUInteger>(storageMode) << MTLResourceStorageModeShift);
}

- (MTLHazardTrackingMode)hazardTrackingMode
{
	return static_cast<MTLHazardTrackingMode>((_resourceOptions >> MTLResourceHazardTrackingModeShift) & 0x0f);
}

- (void)setHazardTrackingMode: (MTLHazardTrackingMode)hazardTrackingMode
{
	_resourceOptions = (_resourceOptions & ~(static_cast<NSUInteger>(0x0f) << MTLResourceHazardTrackingModeShift)) | (static_cast<NSUInteger>(hazardTrackingMode) << MTLResourceHazardTrackingModeShift);
}

- (Indium::TextureDescriptor)asIndiumDescriptor
{
	Indium::TextureDescriptor desc;

	desc.textureType = static_cast<Indium::TextureType>(_textureType);
	desc.pixelFormat = static_cast<Indium::PixelFormat>(_pixelFormat);
	desc.width = _width;
	desc.height = _height;
	desc.depth = _depth;
	desc.mipmapLevelCount = _mipmapLevelCount;
	desc.sampleCount = _sampleCount;
	desc.arrayLength = _arrayLength;
	desc.resourceOptions = static_cast<Indium::ResourceOptions>(_resourceOptions);
	desc.allowGPUOptimizedContents = _allowGPUOptimizedContents;
	desc.usage = static_cast<Indium::TextureUsage>(_usage);
	desc.swizzle = MTLTextureSwizzleChannelsToIndium(_swizzle);

	return desc;
}

#else

@dynamic textureType;
@dynamic pixelFormat;
@dynamic width;
@dynamic height;
@dynamic depth;
@dynamic mipmapLevelCount;
@dynamic sampleCount;
@dynamic arrayLength;
@dynamic resourceOptions;
@dynamic cpuCacheMode;
@dynamic storageMode;
@dynamic hazardTrackingMode;
@dynamic usage;
@dynamic allowGPUOptimizedContents;
@dynamic swizzle;

MTL_UNSUPPORTED_CLASS

#endif

@end
