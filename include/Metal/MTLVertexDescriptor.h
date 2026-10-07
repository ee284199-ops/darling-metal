// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#ifndef _METAL_MTLVERTEXDESCRIPTOR_H_
#define _METAL_MTLVERTEXDESCRIPTOR_H_

#import <Foundation/Foundation.h>

#import <Metal/MTLDefines.h>

METAL_DECLARATIONS_BEGIN

typedef NS_ENUM(NSUInteger, MTLVertexFormat) {
	MTLVertexFormatInvalid = 0,
	MTLVertexFormatUChar2 = 1,
	MTLVertexFormatUChar3 = 2,
	MTLVertexFormatUChar4 = 3,
	MTLVertexFormatChar2 = 4,
	MTLVertexFormatChar3 = 5,
	MTLVertexFormatChar4 = 6,
	MTLVertexFormatUChar2Normalized = 7,
	MTLVertexFormatUChar3Normalized = 8,
	MTLVertexFormatUChar4Normalized = 9,
	MTLVertexFormatChar2Normalized = 10,
	MTLVertexFormatChar3Normalized = 11,
	MTLVertexFormatChar4Normalized = 12,
	MTLVertexFormatUShort2 = 13,
	MTLVertexFormatUShort3 = 14,
	MTLVertexFormatUShort4 = 15,
	MTLVertexFormatShort2 = 16,
	MTLVertexFormatShort3 = 17,
	MTLVertexFormatShort4 = 18,
	MTLVertexFormatUShort2Normalized = 19,
	MTLVertexFormatUShort3Normalized = 20,
	MTLVertexFormatUShort4Normalized = 21,
	MTLVertexFormatShort2Normalized = 22,
	MTLVertexFormatShort3Normalized = 23,
	MTLVertexFormatShort4Normalized = 24,
	MTLVertexFormatHalf2 = 25,
	MTLVertexFormatHalf3 = 26,
	MTLVertexFormatHalf4 = 27,
	MTLVertexFormatFloat = 28,
	MTLVertexFormatFloat2 = 29,
	MTLVertexFormatFloat3 = 30,
	MTLVertexFormatFloat4 = 31,
	MTLVertexFormatInt = 32,
	MTLVertexFormatInt2 = 33,
	MTLVertexFormatInt3 = 34,
	MTLVertexFormatInt4 = 35,
	MTLVertexFormatUInt = 36,
	MTLVertexFormatUInt2 = 37,
	MTLVertexFormatUInt3 = 38,
	MTLVertexFormatUInt4 = 39,
	MTLVertexFormatInt1010102Normalized = 40,
	MTLVertexFormatUInt1010102Normalized = 41,
	MTLVertexFormatUChar4Normalized_BGRA = 42,
	MTLVertexFormatUChar = 45,
	MTLVertexFormatChar = 46,
	MTLVertexFormatUCharNormalized = 47,
	MTLVertexFormatCharNormalized = 48,
	MTLVertexFormatUShort = 49,
	MTLVertexFormatShort = 50,
	MTLVertexFormatUShortNormalized = 51,
	MTLVertexFormatShortNormalized = 52,
	MTLVertexFormatHalf = 53,
	MTLVertexFormatFloatRG11B10 = 54,
	MTLVertexFormatFloatRGB9E5 = 55,
};

typedef NS_ENUM(NSUInteger, MTLVertexStepFunction) {
	MTLVertexStepFunctionConstant = 0,
	MTLVertexStepFunctionPerVertex = 1,
	MTLVertexStepFunctionPerInstance = 2,
	MTLVertexStepFunctionPerPatch = 3,
	MTLVertexStepFunctionPerPatchControlPoint = 4,
};

static const NSUInteger MTLBufferLayoutStrideDynamic = NSUIntegerMax;

MTL_EXPORT
@interface MTLVertexBufferLayoutDescriptor : NSObject <NSCopying>

@property(assign, nonatomic) NSUInteger stride;
@property(assign, nonatomic) MTLVertexStepFunction stepFunction;
@property(assign, nonatomic) NSUInteger stepRate;

@end

MTL_EXPORT
@interface MTLVertexBufferLayoutDescriptorArray : NSObject

- (MTLVertexBufferLayoutDescriptor*)objectAtIndexedSubscript: (NSUInteger)index;
- (void)setObject: (nullable MTLVertexBufferLayoutDescriptor*)bufferDesc atIndexedSubscript: (NSUInteger)index;

@end

MTL_EXPORT
@interface MTLVertexAttributeDescriptor : NSObject <NSCopying>

@property(assign, nonatomic) MTLVertexFormat format;
@property(assign, nonatomic) NSUInteger offset;
@property(assign, nonatomic) NSUInteger bufferIndex;

@end

MTL_EXPORT
@interface MTLVertexAttributeDescriptorArray : NSObject

- (MTLVertexAttributeDescriptor*)objectAtIndexedSubscript: (NSUInteger)index;
- (void)setObject: (nullable MTLVertexAttributeDescriptor*)attributeDesc atIndexedSubscript: (NSUInteger)index;

@end

MTL_EXPORT
@interface MTLVertexDescriptor : NSObject <NSCopying>

+ (MTLVertexDescriptor*)vertexDescriptor;

@property(readonly) MTLVertexBufferLayoutDescriptorArray* layouts;
@property(readonly) MTLVertexAttributeDescriptorArray* attributes;

- (void)reset;

@end

METAL_DECLARATIONS_END

#endif // _METAL_MTLVERTEXDESCRIPTOR_H_
