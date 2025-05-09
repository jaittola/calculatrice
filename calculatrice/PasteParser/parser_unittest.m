
#include "parsed_types.h"
#import <stdio.h>
#import <stdlib.h>
#import <string.h>

#include <objc/runtime.h>

#import "parser_unittest.h"

typedef void *YY_BUFFER_STATE;

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
static int check_matrix_row(expression_t *parsed_row, const char *row[]);
static int check_complex(expression_t *complex, const char *re, const char *im);
static int test_parse_matrix(const char *input, const char *row1[], const char *row2[]);
static int test_parse_matrix_onerow_complex(const char *input,
                                            const char *complex_1_re,
                                            const char *complex_1_im,
                                            const char *complex_2_re,
                                            const char *complex_2_im);
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
    T(test_parse_matrix("[1  2  3]", (const char *[]) {"1", "2", "3", NULL}, NULL));
    T(test_parse_matrix("[1  2  3\n4  5  6]",
                        (const char *[]) {"1", "2", "3", NULL},
                        (const char *[]) {"4", "5", "6", NULL}));
    T(test_parse_matrix_onerow_complex("[1 + i  2 + 2i]", "1", "1", "2", "2"));
    T(test_parse_err("BOOM"));
    T(test_parse_err("123 BOOM"));
    T(test_parse_err("123 ∠ 89A"));

    [parserAdapter dealloc];

    fprintf(stderr, "Run %d tests with %d errors\n", tests, errors);

    return errors;
}

#define ASSERT(expr)                                            \
    if (!(expr)) {                                              \
        fprintf(stderr, "Assertion for '%s' failed (%s:%d)\n", #expr, __FILE__, __LINE__); \
        errors += 1;                                            \
    }

#define ASSERT_STOP(expr)                                       \
    if (!(expr)) {                                              \
        fprintf(stderr, "Assertion for '%s' failed (%s:%d)\n", #expr, __FILE__, __LINE__); \
        errors += 1;                                            \
        goto test_end;                                          \
    }

int test_basic_success_parsing(const char *input,
                               expression_kind expected_kind) {
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

int test_parse_matrix(const char *input,
                      const char *row1[],
                      const char *row2[]) {
    int errors = 0;

    run_parse(input);

    ASSERT(parseError == NULL);
    ASSERT(parseResult != NULL);
    if (parseResult != NULL) {
        ASSERT(parseResult->kind == e_matrix);

        ASSERT_STOP(parseResult->siblings[0] != NULL);
        errors += check_matrix_row(parseResult->siblings[0], row1);

        if (row2 != NULL) {
            ASSERT_STOP(parseResult->siblings[1] != NULL);
            errors += check_matrix_row(parseResult->siblings[1], row2);
        }
    }

 test_end:

    test_cleanup();

    return errors;
}

int test_parse_matrix_onerow_complex(const char *input,
                                     const char *complex_1_re,
                                     const char *complex_1_im,
                                     const char *complex_2_re,
                                     const char *complex_2_im) {
    int errors = 0;

    run_parse(input);

    ASSERT(parseError == NULL);
    ASSERT_STOP(parseResult != NULL);

    ASSERT_STOP(parseResult->kind == e_matrix);

    expression_t *row1 = parseResult->siblings[0];
    ASSERT_STOP(row1 != NULL);

    ASSERT_STOP(row1->kind == e_matrix_row);
    ASSERT_STOP(row1->siblings[0] != NULL);
    ASSERT_STOP(row1->siblings[1] != NULL);

    errors += check_complex(row1->siblings[0], complex_1_re, complex_1_im);
    errors += check_complex(row1->siblings[1], complex_2_re, complex_2_im);

 test_end:

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

int check_matrix_row(expression_t *parsed_row, const char *row[]) {
    int errors = 0;
    int i = 0;

    ASSERT_STOP(parsed_row->kind == e_matrix_row);
    ASSERT_STOP(parsed_row->siblings != NULL);

    for (i = 0; row[i] != NULL; ++i) {
        ASSERT_STOP(parsed_row->siblings[i] != NULL);
        ASSERT(parsed_row->siblings[i]->kind == e_double);
        ASSERT_STOP(parsed_row->siblings[i]->text != NULL);
        ASSERT(strcmp(parsed_row->siblings[i]->text, row[i]) == 0);
    }

 test_end:

    return errors;
}

int check_complex(expression_t *expression, const char *re, const char *im) {
    int errors = 0;

    ASSERT_STOP(expression != NULL);
    ASSERT_STOP(expression->kind == e_complex_cart);
    ASSERT_STOP(expression->siblings != NULL);

    expression_t *re_expr = expression->siblings[0];
    ASSERT_STOP(re_expr != NULL);

    expression_t *im_expr = expression->siblings[1];
    ASSERT_STOP(im_expr != NULL);

    ASSERT(strcmp(re_expr->text, re) == 0);
    ASSERT(strcmp(im_expr->text, im) == 0);

 test_end:

    return errors;
}
