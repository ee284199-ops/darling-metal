// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#ifndef _METAL_MTLSAMPLERINTERNAL_H_
#define _METAL_MTLSAMPLERINTERNAL_H_

#import <Metal/MTLSamplerDescriptor.h>

#if DARLING_METAL_ENABLED
#include <indium/indium.hpp>
#endif

METAL_DECLARATIONS_BEGIN

#if DARLING_METAL_ENABLED
@interface MTLSamplerDescriptor (Internal)
- (Indium::SamplerDescriptor)asIndiumDescriptor;
@end
#endif

@interface MTLSamplerStateInternal : NSObject <MTLSamplerState>

#if DARLING_METAL_ENABLED
@property(readonly) std::shared_ptr<Indium::SamplerState> state;

- (instancetype)initWithState: (std::shared_ptr<Indium::SamplerState>)state
                       device: (id<MTLDevice>)device
                        label: (NSString*)label;
#endif

@end

#if DARLING_METAL_ENABLED
// the Indium sampler states behind the first `count` entries of a C array of Metal sampler states (nil stays null)
NS_INLINE
std::vector<std::shared_ptr<Indium::SamplerState>> MTLSamplerStatesToIndium(const id<MTLSamplerState> __nullable samplers[], NSUInteger count) {
	std::vector<std::shared_ptr<Indium::SamplerState>> result;
	result.reserve(count);
	for (NSUInteger i = 0; i < count; ++i) {
		result.push_back(((MTLSamplerStateInternal*)samplers[i]).state);
	}
	return result;
};
#endif

METAL_DECLARATIONS_END

#endif // _METAL_MTLSAMPLERINTERNAL_H_
