
#import <Foundation/Foundation.h>
#import "parsed_types.h"

#ifndef PARSER_ADAPTER_H
#define PARSER_ADAPTER_H

@class ParsedExpression;

@interface ParserAdapter : NSObject

@property ParsedExpression *parsedExpression;
@property NSString *parsingError;

- (void)parse:(NSString *)input;

- (BOOL)setParseResult:(expression_t *)expression;

- (void)setParseError:(const char *)parseError;
@end

extern ParserAdapter *parserAdapter;


@interface ParsedExpression : NSObject

@property NSArray* siblings;
@property NSString *text;
@property expression_kind kind;

+ (ParsedExpression *)create:(expression_kind) kind text:(const char *)text siblings:(NSArray*)siblings;
+ (ParsedExpression *)create:(expression_t *)expr;

@end


#endif  // PARSER_ADAPTER_H
