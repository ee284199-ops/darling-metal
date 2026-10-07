// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#ifndef _METAL_MTLCOMPILEOPTIONS_H_
#define _METAL_MTLCOMPILEOPTIONS_H_

#import <Foundation/Foundation.h>

#import <Metal/MTLDefines.h>
#import <Metal/MTLLibrary.h>

METAL_DECLARATIONS_BEGIN

@protocol MTLDynamicLibrary;

typedef NS_ENUM(NSUInteger, MTLLanguageVersion) {
	MTLLanguageVersion1_0 = (1 << 16),
	MTLLanguageVersion1_1 = (1 << 16) + 1,
	MTLLanguageVersion1_2 = (1 << 16) + 2,
	MTLLanguageVersion2_0 = (2 << 16),
	MTLLanguageVersion2_1 = (2 << 16) + 1,
	MTLLanguageVersion2_2 = (2 << 16) + 2,
	MTLLanguageVersion2_3 = (2 << 16) + 3,
	MTLLanguageVersion2_4 = (2 << 16) + 4,
	MTLLanguageVersion3_0 = (3 << 16) + 0,
	MTLLanguageVersion3_1 = (3 << 16) + 1,
	MTLLanguageVersion3_2 = (3 << 16) + 2,
};

typedef NS_ENUM(NSInteger, MTLLibraryOptimizationLevel) {
	MTLLibraryOptimizationLevelDefault = 0,
	MTLLibraryOptimizationLevelSize = 1,
};

typedef NS_ENUM(NSInteger, MTLCompileSymbolVisibility) {
	MTLCompileSymbolVisibilityDefault = 0,
	MTLCompileSymbolVisibilityHidden = 1,
};

typedef NS_ENUM(NSInteger, MTLMathMode) {
	MTLMathModeSafe = 0,
	MTLMathModeRelaxed = 1,
	MTLMathModeFast = 2,
};

typedef NS_ENUM(NSInteger, MTLMathFloatingPointFunctions) {
	MTLMathFloatingPointFunctionsFast = 0,
	MTLMathFloatingPointFunctionsPrecise = 1,
};

// Darling can't compile Metal Shading Language source yet (newLibraryWithSource: fails),
// but apps set these options up before trying, so they are kept like Metal does.
MTL_EXPORT
@interface MTLCompileOptions : NSObject <NSCopying>

@property(nullable, copy, nonatomic) NSDictionary<NSString*, NSObject*>* preprocessorMacros;
@property(nonatomic) BOOL fastMathEnabled;
@property(nonatomic) MTLMathMode mathMode;
@property(nonatomic) MTLMathFloatingPointFunctions mathFloatingPointFunctions;
@property(nonatomic) MTLLanguageVersion languageVersion;
@property(nonatomic) MTLLibraryType libraryType;
@property(nullable, copy, nonatomic) NSString* installName;
@property(nullable, copy, nonatomic) NSArray<id<MTLDynamicLibrary>>* libraries;
@property(nonatomic) BOOL preserveInvariance;
@property(nonatomic) MTLLibraryOptimizationLevel optimizationLevel;
@property(nonatomic) MTLCompileSymbolVisibility compileSymbolVisibility;
@property(nonatomic) BOOL allowReferencingUndefinedSymbols;
@property(nonatomic) NSUInteger maxTotalThreadsPerThreadgroup;
@property(nonatomic) BOOL enableLogging;

@end

METAL_DECLARATIONS_END

#endif // _METAL_MTLCOMPILEOPTIONS_H_
