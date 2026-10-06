// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#import <Foundation/Foundation.h>

#import <Metal/MTLDefines.h>

METAL_DECLARATIONS_BEGIN

@protocol MTLDevice;

@protocol MTLCommandEncoder <NSObject>

@property(readonly) id<MTLDevice> device;
@property(nullable, copy, atomic) NSString* label;

- (void)endEncoding;

- (void)insertDebugSignpost: (NSString*)string;
- (void)pushDebugGroup: (NSString*)string;
- (void)popDebugGroup;

@end

METAL_DECLARATIONS_END
