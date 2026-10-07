// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#ifndef _METAL_MTLVERTEXDESCRIPTORINTERNAL_H_
#define _METAL_MTLVERTEXDESCRIPTORINTERNAL_H_

#import <Metal/MTLVertexDescriptor.h>

#if DARLING_METAL_ENABLED
#include <indium/indium.hpp>
#endif

METAL_DECLARATIONS_BEGIN

#if DARLING_METAL_ENABLED
@interface MTLVertexBufferLayoutDescriptorArray (Internal) <NSCopying>

// nil when nothing was ever stored at or read from that index
- (nullable MTLVertexBufferLayoutDescriptor*)existingObjectAtIndex: (NSUInteger)index;

@end

@interface MTLVertexAttributeDescriptorArray (Internal) <NSCopying>

- (NSDictionary<NSNumber*, MTLVertexAttributeDescriptor*>*)dictionary;

@end

@interface MTLVertexDescriptor (Internal)

- (Indium::VertexDescriptor)asIndiumDescriptor;

@end
#endif

METAL_DECLARATIONS_END

#endif // _METAL_MTLVERTEXDESCRIPTORINTERNAL_H_
