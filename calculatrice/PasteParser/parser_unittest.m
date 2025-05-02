
#import <stdio.h>
#import <stdlib.h>
#import <string.h>

#include <objc/runtime.h>

#import "parser_unittest.h"


typedef void* YY_BUFFER_STATE;

extern YY_BUFFER_STATE yy_scan_string(const char *str);
extern void yyparse(void);
extern void yy_delete_buffer(YY_BUFFER_STATE *buf);


static expression_t *parseResult = NULL;
static char *parseError = NULL;

ParserAdapter *parserAdapter = NULL;

@implementation ParserAdapter

+ (id) alloc {
    return class_createInstance(self, 0);
}

-(void) dealloc {
    object_dispose(self);
}

- (void) setParseResult:(expression_t*) expression {
    parseResult = expression;
}

- (void) setParseError:(const char *) msg {
    if (parseError == NULL) {
        parseError = strdup(msg);
    }
}

@end

static int test_basic_success_parsing(const char *input, expression_kind expected_kind);
static int test_parse_mixed_fract(const char *input,
                                  const char *whole,
                                  const char *num,
                                  const char *den);
static int test_parse_err(const char *input);
static void run_parse(const char *input);
static void test_cleanup(void);

#define T(expr) { errors += (expr); tests +=1; }

int main(int argc, char *argv[]) {
    int errors = 0;
    int tests = 0;

    parserAdapter = [ParserAdapter alloc];

    fprintf(stderr, "Running tests!\n");

    T(test_basic_success_parsing("4", e_double));
    T(test_basic_success_parsing("-4", e_double));
    T(test_basic_success_parsing("-4.1", e_double));
    T(test_parse_mixed_fract("1 3/4", "1", "3", "4"));
    T(test_parse_mixed_fract("-1 3/4", "-1", "3", "4"));
    T(test_parse_err("BOOM"));
    T(test_parse_err("123 BOOM"));
    T(test_parse_err("123 ∠ 89A"));

    [parserAdapter dealloc];

    fprintf(stderr, "Run %d tests with %d errors\n", tests, errors);

    return errors;
}

#define ASSERT(expr) if (!(expr)) { fprintf(stderr, "Assertion for '%s' failed\n", #expr); \
        errors += 1; }

int test_basic_success_parsing(const char *input, expression_kind expected_kind) {
    int errors = 0;

    run_parse(input);

    ASSERT(parseError == NULL);
    ASSERT(parseResult != NULL);
    if (parseResult != NULL) {
        ASSERT(parseResult->kind == expected_kind);
        ASSERT(strcmp(parseResult->text, input) == 0);
    }

    test_cleanup();

    return errors;
}

int test_parse_mixed_fract(const char *input,
                           const char *whole,
                           const char *num,
                           const char *den) {
    int errors = 0;

    run_parse(input);

    ASSERT(parseError == NULL);
    ASSERT(parseResult != NULL);
    if (parseResult != NULL) {
        ASSERT(parseResult->kind == e_fraction);
        ASSERT(parseResult->siblings[0] != NULL);
        ASSERT(parseResult->siblings[1] != NULL);
        ASSERT(parseResult->siblings[2] != NULL);
        ASSERT(parseResult->siblings[0] != NULL && strcmp(parseResult->siblings[0]->text, whole) == 0);
        ASSERT(parseResult->siblings[1] != NULL && strcmp(parseResult->siblings[1]->text, num) == 0);
        ASSERT(parseResult->siblings[2] != NULL && strcmp(parseResult->siblings[2]->text, den) == 0);
    }

    test_cleanup();

    return errors;
}

int test_parse_err(const char *input) {
    int errors = 0;

    run_parse(input);

    ASSERT(parseError != NULL);

    test_cleanup();

    return errors;
}

void run_parse(const char *input) {
    YY_BUFFER_STATE buf = yy_scan_string(input);
    yyparse();
    yy_delete_buffer(buf);
}

void test_cleanup() {
    expression_free(parseResult); parseResult = NULL;
    free(parseError); parseError = NULL;
}
