// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#ifndef _METAL_MTLTEXTUREDESCRIPTOR_H_
#define _METAL_MTLTEXTUREDESCRIPTOR_H_

#import <Foundation/Foundation.h>

#import <Metal/MTLDefines.h>
#import <Metal/MTLPixelFormat.h>
#import <Metal/MTLResource.h>
#import <Metal/MTLTexture.h>

METAL_DECLARATIONS_BEGIN

MTL_EXPORT
@interface MTLTextureDescriptor : NSObject <NSCopying>

+ (MTLTextureDescriptor*)texture2DDescriptorWithPixelFormat: (MTLPixelFormat)pixelFormat
                                                      width: (NSUInteger)width
                                                     height: (NSUInteger)height
                                                  mipmapped: (BOOL)mipmapped;

+ (MTLTextureDescriptor*)textureCubeDescriptorWithPixelFormat: (MTLPixelFormat)pixelFormat
                                                         size: (NSUInteger)size
                                                    mipmapped: (BOOL)mipmapped;

+ (MTLTextureDescriptor*)textureBufferDescriptorWithPixelFormat: (MTLPixelFormat)pixelFormat
                                                          width: (NSUInteger)width
                                                resourceOptions: (MTLResourceOptions)resourceOptions
                                                          usage: (MTLTextureUsage)usage;

@property(readwrite, nonatomic) MTLTextureType textureType;
@property(readwrite, nonatomic) MTLPixelFormat pixelFormat;
@property(readwrite, nonatomic) NSUInteger width;
@property(readwrite, nonatomic) NSUInteger height;
@property(readwrite, nonatomic) NSUInteger depth;
@property(readwrite, nonatomic) NSUInteger mipmapLevelCount;
@property(readwrite, nonatomic) NSUInteger sampleCount;
@property(readwrite, nonatomic) NSUInteger arrayLength;
@property(readwrite, nonatomic) MTLResourceOptions resourceOptions;
@property(readwrite, nonatomic) MTLCPUCacheMode cpuCacheMode;
@property(readwrite, nonatomic) MTLStorageMode storageMode;
@property(readwrite, nonatomic) MTLHazardTrackingMode hazardTrackingMode;
@property(readwrite, nonatomic) MTLTextureUsage usage;
@property(readwrite, nonatomic) BOOL allowGPUOptimizedContents;
@property(readwrite, nonatomic) MTLTextureSwizzleChannels swizzle;

@end

METAL_DECLARATIONS_END

#endif // _METAL_MTLTEXTUREDESCRIPTOR_H_
