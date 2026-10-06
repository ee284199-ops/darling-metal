// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#ifndef _METAL_MTLDEPTHSTENCILINTERNAL_H_
#define _METAL_MTLDEPTHSTENCILINTERNAL_H_

#import <Metal/MTLDepthStencilDescriptor.h>

#if DARLING_METAL_ENABLED
#include <indium/indium.hpp>
#endif

METAL_DECLARATIONS_BEGIN

#if DARLING_METAL_ENABLED
@interface MTLStencilDescriptor (Internal)
- (Indium::StencilDescriptor)asIndiumDescriptor;
// whether this descriptor still has its default values, in which case the stencil test never changes anything
- (BOOL)_hasDefaultValues;
@end

@interface MTLDepthStencilDescriptor (Internal)
- (Indium::DepthStencilDescriptor)asIndiumDescriptor;
@end
#endif

@interface MTLDepthStencilStateInternal : NSObject <MTLDepthStencilState>

#if DARLING_METAL_ENABLED
@property(readonly) std::shared_ptr<Indium::DepthStencilState> state;

- (instancetype)initWithState: (std::shared_ptr<Indium::DepthStencilState>)state
                       device: (id<MTLDevice>)device
                        label: (NSString*)label;
#endif

@end

METAL_DECLARATIONS_END

#endif // _METAL_MTLDEPTHSTENCILINTERNAL_H_
