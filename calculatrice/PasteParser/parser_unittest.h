
#ifndef PARSER_UNITTEST_H
#define PARSER_UNITTEST_H

#import "parsed_types.h"

#include <stdlib.h>
#include <stdio.h>

#if !defined(nil)
#define nil NULL
#endif

@interface ParserAdapter

+ (id) alloc;

- (void) setParseResult:(expression_t*) expression;
- (void) setParseError:(const char *) msg;

@end

extern ParserAdapter *parserAdapter;

#endif  // PARSER_UNITTEST_H
