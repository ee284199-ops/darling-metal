// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#import <Metal/MTLVertexDescriptorInternal.h>
#import <Metal/stubs.h>

@implementation MTLVertexBufferLayoutDescriptor

#if DARLING_METAL_ENABLED

@synthesize stride = _stride;
@synthesize stepFunction = _stepFunction;
@synthesize stepRate = _stepRate;

- (instancetype)init
{
	self = [super init];
	if (self != nil) {
		_stride = 0;
		_stepFunction = MTLVertexStepFunctionPerVertex;
		_stepRate = 1;
	}
	return self;
}

- (id)copyWithZone: (NSZone*)zone
{
	MTLVertexBufferLayoutDescriptor* copy = [[self class] new];
	copy.stride = _stride;
	copy.stepFunction = _stepFunction;
	copy.stepRate = _stepRate;
	return copy;
}

#else

@dynamic stride;
@dynamic stepFunction;
@dynamic stepRate;

MTL_UNSUPPORTED_CLASS

#endif

@end

@implementation MTLVertexAttributeDescriptor

#if DARLING_METAL_ENABLED

@synthesize format = _format;
@synthesize offset = _offset;
@synthesize bufferIndex = _bufferIndex;

- (instancetype)init
{
	self = [super init];
	if (self != nil) {
		_format = MTLVertexFormatInvalid;
		_offset = 0;
		_bufferIndex = 0;
	}
	return self;
}

- (id)copyWithZone: (NSZone*)zone
{
	MTLVertexAttributeDescriptor* copy = [[self class] new];
	copy.format = _format;
	copy.offset = _offset;
	copy.bufferIndex = _bufferIndex;
	return copy;
}

#else

@dynamic format;
@dynamic offset;
@dynamic bufferIndex;

MTL_UNSUPPORTED_CLASS

#endif

@end

#if DARLING_METAL_ENABLED

// Both descriptor arrays behave like Metal's: every index has a descriptor (created with
// default values on first access), and setting one stores a copy (nil restores the default).
static NSMutableDictionary* copyDescriptorDictionary(NSDictionary* dictionary)
{
	NSMutableDictionary* result = [[NSMutableDictionary alloc] initWithCapacity: dictionary.count];
	for (NSNumber* index in dictionary) {
		id copy = [dictionary[index] copy];
		result[index] = copy;
		[copy release];
	}
	return result;
}

#endif

@implementation MTLVertexBufferLayoutDescriptorArray

#if DARLING_METAL_ENABLED

{
	NSMutableDictionary<NSNumber*, MTLVertexBufferLayoutDescriptor*>* _dict;
}

- (instancetype)init
{
	self = [super init];
	if (self != nil) {
		_dict = [NSMutableDictionary new];
	}
	return self;
}

- (void)dealloc
{
	[_dict release];
	[super dealloc];
}

- (MTLVertexBufferLayoutDescriptor*)objectAtIndexedSubscript: (NSUInteger)index
{
	MTLVertexBufferLayoutDescriptor* desc = _dict[@(index)];
	if (desc == nil) {
		desc = [[MTLVertexBufferLayoutDescriptor new] autorelease];
		_dict[@(index)] = desc;
	}
	return desc;
}

- (void)setObject: (MTLVertexBufferLayoutDescriptor*)bufferDesc atIndexedSubscript: (NSUInteger)index
{
	if (bufferDesc == nil) {
		[_dict removeObjectForKey: @(index)];
		return;
	}
	MTLVertexBufferLayoutDescriptor* copy = [bufferDesc copy];
	_dict[@(index)] = copy;
	[copy release];
}

#else

MTL_UNSUPPORTED_CLASS

#endif

@end

@implementation MTLVertexBufferLayoutDescriptorArray (Internal)

#if DARLING_METAL_ENABLED

- (id)copyWithZone: (NSZone*)zone
{
	MTLVertexBufferLayoutDescriptorArray* copy = [MTLVertexBufferLayoutDescriptorArray new];
	[copy->_dict release];
	copy->_dict = copyDescriptorDictionary(_dict);
	return copy;
}

- (MTLVertexBufferLayoutDescriptor*)existingObjectAtIndex: (NSUInteger)index
{
	return _dict[@(index)];
}

#endif

@end

@implementation MTLVertexAttributeDescriptorArray

#if DARLING_METAL_ENABLED

{
	NSMutableDictionary<NSNumber*, MTLVertexAttributeDescriptor*>* _dict;
}

- (instancetype)init
{
	self = [super init];
	if (self != nil) {
		_dict = [NSMutableDictionary new];
	}
	return self;
}

- (void)dealloc
{
	[_dict release];
	[super dealloc];
}

- (MTLVertexAttributeDescriptor*)objectAtIndexedSubscript: (NSUInteger)index
{
	MTLVertexAttributeDescriptor* desc = _dict[@(index)];
	if (desc == nil) {
		desc = [[MTLVertexAttributeDescriptor new] autorelease];
		_dict[@(index)] = desc;
	}
	return desc;
}

- (void)setObject: (MTLVertexAttributeDescriptor*)attributeDesc atIndexedSubscript: (NSUInteger)index
{
	if (attributeDesc == nil) {
		[_dict removeObjectForKey: @(index)];
		return;
	}
	MTLVertexAttributeDescriptor* copy = [attributeDesc copy];
	_dict[@(index)] = copy;
	[copy release];
}

#else

MTL_UNSUPPORTED_CLASS

#endif

@end

@implementation MTLVertexAttributeDescriptorArray (Internal)

#if DARLING_METAL_ENABLED

- (id)copyWithZone: (NSZone*)zone
{
	MTLVertexAttributeDescriptorArray* copy = [MTLVertexAttributeDescriptorArray new];
	[copy->_dict release];
	copy->_dict = copyDescriptorDictionary(_dict);
	return copy;
}

- (NSDictionary<NSNumber*, MTLVertexAttributeDescriptor*>*)dictionary
{
	return _dict;
}

#endif

@end

@implementation MTLVertexDescriptor

#if DARLING_METAL_ENABLED

@synthesize layouts = _layouts;
@synthesize attributes = _attributes;

+ (MTLVertexDescriptor*)vertexDescriptor
{
	return [[[MTLVertexDescriptor alloc] init] autorelease];
}

- (instancetype)init
{
	self = [super init];
	if (self != nil) {
		_layouts = [MTLVertexBufferLayoutDescriptorArray new];
		_attributes = [MTLVertexAttributeDescriptorArray new];
	}
	return self;
}

- (void)dealloc
{
	[_layouts release];
	[_attributes release];
	[super dealloc];
}

- (id)copyWithZone: (NSZone*)zone
{
	MTLVertexDescriptor* copy = [[self class] new];
	[copy->_layouts release];
	copy->_layouts = [_layouts copy];
	[copy->_attributes release];
	copy->_attributes = [_attributes copy];
	return copy;
}

- (void)reset
{
	[_layouts release];
	_layouts = [MTLVertexBufferLayoutDescriptorArray new];
	[_attributes release];
	_attributes = [MTLVertexAttributeDescriptorArray new];
}

#else

@dynamic layouts;
@dynamic attributes;

MTL_UNSUPPORTED_CLASS

#endif

@end

@implementation MTLVertexDescriptor (Internal)

#if DARLING_METAL_ENABLED

- (Indium::VertexDescriptor)asIndiumDescriptor
{
	Indium::VertexDescriptor result;
	NSDictionary<NSNumber*, MTLVertexAttributeDescriptor*>* attributes = [_attributes dictionary];

	// Metal has a descriptor for every attribute and buffer index; only the attributes with a
	// format are real, and only the layouts of the buffers they read from matter
	for (NSNumber* index in attributes) {
		MTLVertexAttributeDescriptor* attribute = attributes[index];

		if (attribute.format == MTLVertexFormatInvalid) {
			continue;
		}

		result.attributes[index.unsignedIntegerValue] = Indium::VertexAttributeDescriptor {
			static_cast<Indium::VertexFormat>(attribute.format),
			attribute.offset,
			attribute.bufferIndex,
		};

		if (result.layouts.find(attribute.bufferIndex) != result.layouts.end()) {
			continue;
		}

		MTLVertexBufferLayoutDescriptor* layout = [_layouts existingObjectAtIndex: attribute.bufferIndex];
		Indium::VertexBufferLayoutDescriptor indiumLayout;

		if (layout != nil) {
			indiumLayout.stride = layout.stride;
			indiumLayout.stepFunction = static_cast<Indium::VertexStepFunction>(layout.stepFunction);
			indiumLayout.stepRate = layout.stepRate;
		}

		if (indiumLayout.stepFunction == Indium::VertexStepFunction::Constant) {
			// every vertex reads the same element: a per-vertex buffer that doesn't advance
			indiumLayout.stride = 0;
			indiumLayout.stepFunction = Indium::VertexStepFunction::PerVertex;
			indiumLayout.stepRate = 1;
		}

		result.layouts[attribute.bufferIndex] = indiumLayout;
	}

	return result;
}

#endif

@end
