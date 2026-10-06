// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#ifndef _METAL_MTLTEXTUREINTERNAL_H_
#define _METAL_MTLTEXTUREINTERNAL_H_

#import <Metal/MTLTexture.h>
#import <Metal/MTLTextureDescriptor.h>

#if DARLING_METAL_ENABLED
#include <indium/indium.hpp>
#endif

#if DARLING_METAL_ENABLED
@interface MTLTextureDescriptor (Internal)
- (Indium::TextureDescriptor)asIndiumDescriptor;
@end
#endif

#if DARLING_METAL_ENABLED
NS_INLINE
Indium::TextureSwizzleChannels MTLTextureSwizzleChannelsToIndium(MTLTextureSwizzleChannels channels) {
	return Indium::TextureSwizzleChannels {
		static_cast<Indium::TextureSwizzle>(channels.red),
		static_cast<Indium::TextureSwizzle>(channels.green),
		static_cast<Indium::TextureSwizzle>(channels.blue),
		static_cast<Indium::TextureSwizzle>(channels.alpha),
	};
};

NS_INLINE
MTLTextureSwizzleChannels MTLTextureSwizzleChannelsFromIndium(Indium::TextureSwizzleChannels channels) {
	return MTLTextureSwizzleChannels {
		static_cast<MTLTextureSwizzle>(channels.red),
		static_cast<MTLTextureSwizzle>(channels.green),
		static_cast<MTLTextureSwizzle>(channels.blue),
		static_cast<MTLTextureSwizzle>(channels.alpha),
	};
};
#endif

// private export
MTL_EXPORT
@interface MTLTextureInternal : NSObject <MTLTexture>

#if DARLING_METAL_ENABLED
@property(readonly) std::shared_ptr<Indium::Texture> texture;

- (instancetype)initWithTexture: (std::shared_ptr<Indium::Texture>)texture
                         device: (id<MTLDevice>)device
                resourceOptions: (MTLResourceOptions)options;

- (instancetype)initWithTexture: (std::shared_ptr<Indium::Texture>)texture
                         device: (id<MTLDevice>)device
                resourceOptions: (MTLResourceOptions)options
                          usage: (MTLTextureUsage)usage;
#endif

@end

#if DARLING_METAL_ENABLED
// the Indium textures behind the first `count` entries of a C array of Metal textures (nil stays null)
NS_INLINE
std::vector<std::shared_ptr<Indium::Texture>> MTLTexturesToIndium(const id<MTLTexture> __nullable textures[], NSUInteger count) {
	std::vector<std::shared_ptr<Indium::Texture>> result;
	result.reserve(count);
	for (NSUInteger i = 0; i < count; ++i) {
		result.push_back(((MTLTextureInternal*)textures[i]).texture);
	}
	return result;
};
#endif

#endif // _METAL_MTLTEXTUREINTERNAL_H_
