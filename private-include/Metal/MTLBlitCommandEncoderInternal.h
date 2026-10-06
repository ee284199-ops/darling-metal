// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#ifndef _METAL_MTLBLITCOMMANDENCODERINTERNAL_H_
#define _METAL_MTLBLITCOMMANDENCODERINTERNAL_H_

#import <Metal/MTLBlitCommandEncoder.h>

#if DARLING_METAL_ENABLED
#include <indium/indium.hpp>
#endif

METAL_DECLARATIONS_BEGIN

@interface MTLBlitCommandEncoderInternal : NSObject <MTLBlitCommandEncoder>

#if DARLING_METAL_ENABLED
@property(readonly) std::shared_ptr<Indium::BlitCommandEncoder> encoder;

- (instancetype)initWithEncoder: (std::shared_ptr<Indium::BlitCommandEncoder>)encoder
                         device: (id<MTLDevice>)device;
#endif

@end

METAL_DECLARATIONS_END

#endif // _METAL_MTLBLITCOMMANDENCODERINTERNAL_H_
