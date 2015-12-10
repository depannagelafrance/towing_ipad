#import "CECUtils.h"

@implementation CECUtils
+ (NSString *) encode:(NSString *)value {
    NSMutableCharacterSet *URLQueryPartAllowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [URLQueryPartAllowedCharacterSet removeCharactersInString:@"?&=@+/'"];
    
    return [value stringByAddingPercentEncodingWithAllowedCharacters:URLQueryPartAllowedCharacterSet];
}

+ (BOOL) empty:(NSString *) value
{
    return (nil == value || value.length == 0 || [[CECUtils trim:value] isEqualToString:@""]);
}

+ (NSString *) trim:(NSString *) value
{
    return [value stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
}
@end
