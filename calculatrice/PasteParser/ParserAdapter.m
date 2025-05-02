#import "ParserAdapter.h"
#import "parsed_types.h"

// Defining these yacc functions and data types is kind of rubbish.
// But that's what it's like with these old-fashioned tools
// that do not produce header files with these symbols.

typedef void* YY_BUFFER_STATE;

extern YY_BUFFER_STATE yy_scan_string(const char *str);
extern void yyparse(void);
extern void yy_delete_buffer(YY_BUFFER_STATE *buf);

@implementation ParserAdapter {
    NSString *_parseError;
}

NSString *identifier;

- (void)parse:(NSString *)input
{
    parserAdapter = self;

    const char *input_ptr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    YY_BUFFER_STATE buf = yy_scan_string(input_ptr);
    yyparse();
    yy_delete_buffer(buf);

    parserAdapter = nil;
}

- (BOOL)setParseResult:(expression_t*)expression {
    if (expression == NULL || _parseError != nil || expression->kind == e_unknown) {
        return NO;
    }

    _parsedExpression = [ParsedExpression create:expression];

    return YES;
}


- (void)setParseError:(const char *)parseError {
    NSLog(@"Parsing failed: %s", parseError);
    if (parseError == NULL) {
        return;
    }

    [self setParsedExpression:nil];
    [self setParsingError:[NSString stringWithUTF8String:parseError]];
}
@end

@implementation ParsedExpression

+ (ParsedExpression *)create:(expression_kind) kind angle_unit:(expression_angle_unit) angle_unit text:(const char *)text siblings:(NSArray*)siblings {
    ParsedExpression *e = [ParsedExpression alloc];

    e->_kind = kind;
    e->_angle_unit = angle_unit;
    e->_text = text != NULL ? [NSString stringWithUTF8String:text] : nil;
    e->_siblings = siblings != nil ? siblings : [[NSArray alloc] init];
    return e;
}

+ (ParsedExpression *)create:(expression_t *)expr {
    NSArray *siblings = [[NSArray alloc] init];
    for (int i = 0; i < 3; ++i) {
        if (expr->siblings[i] != NULL) {
            ParsedExpression *sibling = [ParsedExpression create:expr->siblings[i]];
            siblings = [siblings arrayByAddingObject:sibling];
        }
    }

    ParsedExpression *pe = [ParsedExpression create:expr->kind angle_unit:expr->angle_unit text:expr->text siblings:siblings];
    return pe;
}

@end

// Global, eww.
ParserAdapter *parserAdapter = nil;
