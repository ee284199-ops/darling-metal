// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#import <Metal/MTLCompileOptions.h>
#import <Metal/stubs.h>

@implementation MTLCompileOptions

#if DARLING_METAL_ENABLED

@synthesize preprocessorMacros = _preprocessorMacros;
@synthesize mathMode = _mathMode;
@synthesize mathFloatingPointFunctions = _mathFloatingPointFunctions;
@synthesize languageVersion = _languageVersion;
@synthesize libraryType = _libraryType;
@synthesize installName = _installName;
@synthesize libraries = _libraries;
@synthesize preserveInvariance = _preserveInvariance;
@synthesize optimizationLevel = _optimizationLevel;
@synthesize compileSymbolVisibility = _compileSymbolVisibility;
@synthesize allowReferencingUndefinedSymbols = _allowReferencingUndefinedSymbols;
@synthesize maxTotalThreadsPerThreadgroup = _maxTotalThreadsPerThreadgroup;
@synthesize enableLogging = _enableLogging;

- (instancetype)init
{
	self = [super init];
	if (self != nil) {
		// Metal enables fast math unless told otherwise
		_mathMode = MTLMathModeFast;
		_mathFloatingPointFunctions = MTLMathFloatingPointFunctionsFast;
		_languageVersion = MTLLanguageVersion3_1;
		_libraryType = MTLLibraryTypeExecutable;
		_optimizationLevel = MTLLibraryOptimizationLevelDefault;
		_compileSymbolVisibility = MTLCompileSymbolVisibilityDefault;
	}
	return self;
}

- (void)dealloc
{
	[_preprocessorMacros release];
	[_installName release];
	[_libraries release];
	[super dealloc];
}

// the older switch for the same setting as mathMode
- (BOOL)fastMathEnabled
{
	return _mathMode == MTLMathModeFast;
}

- (void)setFastMathEnabled: (BOOL)fastMathEnabled
{
	_mathMode = fastMathEnabled ? MTLMathModeFast : MTLMathModeSafe;
}

- (id)copyWithZone: (NSZone*)zone
{
	MTLCompileOptions* copy = [[self class] new];
	copy.preprocessorMacros = _preprocessorMacros;
	copy.mathMode = _mathMode;
	copy.mathFloatingPointFunctions = _mathFloatingPointFunctions;
	copy.languageVersion = _languageVersion;
	copy.libraryType = _libraryType;
	copy.installName = _installName;
	copy.libraries = _libraries;
	copy.preserveInvariance = _preserveInvariance;
	copy.optimizationLevel = _optimizationLevel;
	copy.compileSymbolVisibility = _compileSymbolVisibility;
	copy.allowReferencingUndefinedSymbols = _allowReferencingUndefinedSymbols;
	copy.maxTotalThreadsPerThreadgroup = _maxTotalThreadsPerThreadgroup;
	copy.enableLogging = _enableLogging;
	return copy;
}

#else

@dynamic preprocessorMacros;
@dynamic fastMathEnabled;
@dynamic mathMode;
@dynamic mathFloatingPointFunctions;
@dynamic languageVersion;
@dynamic libraryType;
@dynamic installName;
@dynamic libraries;
@dynamic preserveInvariance;
@dynamic optimizationLevel;
@dynamic compileSymbolVisibility;
@dynamic allowReferencingUndefinedSymbols;
@dynamic maxTotalThreadsPerThreadgroup;
@dynamic enableLogging;

MTL_UNSUPPORTED_CLASS

#endif

@end
