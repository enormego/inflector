/*
 An implementation of the Ruby on Rails inflector in Objective-C.
 Ciarán Walsh, 2008
 
 See README.mdown for usage info.
 
 Use ⌃R on the following line in TextMate to run tests:
 g++ "$TM_FILEPATH" "$(dirname "$TM_FILEPATH")"/RegexKitLite/RegexKitLite.m -licucore -DTEST_INFLECTOR -framework Cocoa -o "${TM_FILEPATH%.*}" && ("${TM_FILEPATH%.*}"; rm "${TM_FILEPATH%.*}")
 */

#import "CWInflector.h"
#import "RegexKitLite.h"

static CWInflector* _sharedInstance = nil;

@interface CWInflector (Private)
- (void)addInflectionsFromFile:(NSString*)path;
@end


@implementation CWInflector

+ (CWInflector*)sharedInflector {
	@synchronized(self) {
		if(!_sharedInstance) {
			_sharedInstance = [[[self class] alloc] init];
		}
	}
	
	return _sharedInstance;
}

- (id)init {
	if((self = [super init])) {
		plurals      = [[NSMutableArray alloc] init];
		singulars    = [[NSMutableArray alloc] init];
		uncountables = [[NSMutableArray alloc] init];
		
		[self addInflectionsFromFile:[[NSBundle mainBundle] pathForResource:@"inflections" ofType:@"plist"]];
	}
	
	return self;
}

- (void)addInflectionsFromFile:(NSString*)path {
	NSDictionary* inflections = [NSDictionary dictionaryWithContentsOfFile:path];
	[plurals addObjectsFromArray:[inflections objectForKey:@"plurals"]];
	[singulars addObjectsFromArray:[inflections objectForKey:@"singulars"]];
	[uncountables addObjectsFromArray:[inflections objectForKey:@"uncountables"]];
	
	for(NSArray* irregular in [inflections objectForKey:@"irregulars"])
		[self addIrregular:[irregular objectAtIndex:0] plural:[irregular objectAtIndex:1]];
}

- (void)addIrregular:(NSString*)singular plural:(NSString*)plural {
	NSString* pattern      = [NSString stringWithFormat:@"(%C)%@$", [singular characterAtIndex:0], [singular substringFromIndex:1]];
	NSString* substitution = [NSString stringWithFormat:@"$1%@", [plural substringFromIndex:1]];
	[self addPluralPattern:pattern substitution:substitution];
	
	pattern      = [NSString stringWithFormat:@"(%C)%@$", [plural characterAtIndex:0], [plural substringFromIndex:1]];
	substitution = [NSString stringWithFormat:@"$1%@", [singular substringFromIndex:1]];
	[self addSingularPattern:pattern substitution:substitution];
}

- (void)addPluralPattern:(NSString*)pattern substitution:(NSString*)substitution {
	[plurals addObject:[NSArray arrayWithObjects:pattern,substitution,nil]];
}

- (void)addSingularPattern:(NSString*)pattern substitution:(NSString*)substitution {
	[singulars addObject:[NSArray arrayWithObjects:pattern,substitution,nil]];
}

- (NSString*)pluralFormOf:(NSString*)singular {
	if([uncountables containsObject:[singular lowercaseString]])
		return singular;
	
	for(NSArray* conversion in [plurals reverseObjectEnumerator]) {
		NSString* result = [singular stringByReplacingOccurrencesOfRegex:[conversion objectAtIndex:0] withString:[conversion objectAtIndex:1]];
		if(result && ![result isEqualToString:singular])
			return result;
	}
	return singular;
}

- (NSString*)singularFormOf:(NSString*)plural {
	if([uncountables containsObject:[plural lowercaseString]])
		return plural;
	
	for(NSArray* conversion in [singulars reverseObjectEnumerator]) {
		NSString* result = [plural stringByReplacingOccurrencesOfRegex:[conversion objectAtIndex:0] withString:[conversion objectAtIndex:1]];
		if(result && ![result isEqualToString:plural])
			return result;
	}
	
	return plural;
}

- (NSString*)humanizedFormOf:(NSString*)word {
	NSString* result = word;
	if([result length] > 3 && [[result substringFromIndex:([result length]-3)] isEqualToString:@"_id"])
		result = [result substringToIndex:([result length]-3)];
	result = [result stringByReplacingOccurrencesOfString:@"_" withString:@" "];
	return [[[result substringToIndex:1] uppercaseString] stringByAppendingString:[result substringFromIndex:1]];
}

- (void)dealloc {
	[plurals release];
	[singulars release];
	[uncountables release];
	[super dealloc];
}

@end

@implementation NSString (InflectorAdditions)
- (NSString*)pluralForm    { return [[CWInflector sharedInflector] pluralFormOf:self];    }
- (NSString*)singularForm  { return [[CWInflector sharedInflector] singularFormOf:self];  }
- (NSString*)humanizedForm { return [[CWInflector sharedInflector] humanizedFormOf:self]; }
@end