/*
 An implementation of the Ruby on Rails inflector in Objective-C.
 Ciarán Walsh, 2008
 
 See README.mdown for usage info.
 
 Use ⌃R on the following line in TextMate to run tests:
 g++ "$TM_FILEPATH" "$(dirname "$TM_FILEPATH")"/RegexKitLite/RegexKitLite.m -licucore -DTEST_INFLECTOR -framework Cocoa -o "${TM_FILEPATH%.*}" && ("${TM_FILEPATH%.*}"; rm "${TM_FILEPATH%.*}")
 */

#import <Foundation/Foundation.h>

@interface CWInflector : NSObject {
	NSMutableArray* plurals;
	NSMutableArray* singulars;
	NSMutableArray* uncountables;
}

+ (CWInflector*)sharedInflector;

- (void)addPluralPattern:(NSString*)pattern substitution:(NSString*)substitution;
- (void)addSingularPattern:(NSString*)pattern substitution:(NSString*)substitution;
- (void)addIrregular:(NSString*)singular plural:(NSString*)plural;

- (NSString*)pluralFormOf:(NSString*)singular;
- (NSString*)singularFormOf:(NSString*)plural;
- (NSString*)humanizedFormOf:(NSString*)word;
@end

@interface NSString (InflectorAdditions)
- (NSString*)pluralForm;
- (NSString*)singularForm;
- (NSString*)humanizedForm;
@end
