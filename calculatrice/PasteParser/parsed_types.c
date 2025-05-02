#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <errno.h>

#include "parsed_types.h"


static expression_t *expression_alloc() {
    expression_t *expr = calloc(sizeof(expression_t), 1);
    if (expr == NULL) {
        fprintf(stderr, "Memory allocation failed: %s", strerror(errno));
        return NULL;
    }
    return expr;
}

#define EXPRESSION_ALLOC(varname) \
    expression_t *varname = expression_alloc(); \
    if (varname == NULL) { \
        return NULL;       \
    }

expression_t *expression_zero(void) {
    return expression_scalar("0", e_int);
}

expression_t *expression_one(int sign) {
    const char *text = sign > 0 ? "1" : "-1";
    return expression_scalar(text, e_int);
}

expression_t *expression_int(const char *text) {
    return expression_scalar(text, e_int);
}

expression_t *expression_double(const char *text) {
    return expression_scalar(text, e_double);
}

expression_t *expression_complex_cart(expression_t *real, expression_t *imag) {
    return expression_multicomponent(real, imag, NULL, e_complex_cart);
}

expression_t *expression_complex_polar(expression_t *abs,
                                       expression_t *arg,
                                       expression_angle_unit angle_unit) {
    expression_t *expr = expression_multicomponent(abs, arg, NULL, e_complex_polar);
    expr->angle_unit = angle_unit;

    return expr;
}

expression_t *expression_fraction(expression_t *v1, expression_t *v2, expression_t *v3) {
    return expression_multicomponent(v1, v2, v3, e_fraction);
}

expression_t *expression_neg(int sign, expression_t *expression) {
    if (sign > 0 || (expression->text != NULL && expression->text[0] == '-')) {
        return expression;
    } else if (expression->text == NULL && expression->siblings[0] != NULL) {
        expression->siblings[0] = expression_neg(sign, expression->siblings[0]);
        return expression;
    } else if (expression->text == NULL) {
        return expression;
    }

    EXPRESSION_ALLOC(new_exp);

    if (expression->text != NULL) {
        char *buf = calloc(strlen(expression->text) + 2, 1);
        if (buf != NULL) {
            sprintf(buf, "-%s", expression->text);
            new_exp->text = buf;
        }
    }
    new_exp->kind = expression->kind;
    expression_free(expression);

    return new_exp;
}

expression_t *expression_scalar(const char *text, expression_kind kind) {
    if (text == NULL) {
        return NULL;
    }

    EXPRESSION_ALLOC(expr);
    expr->text = strdup(text);
    expr->kind = e_double;

    return expr;
}

expression_t *expression_multicomponent(expression_t *c1,
                                        expression_t *c2, expression_t *c3,
                                        expression_kind kind) {
    EXPRESSION_ALLOC(expr);
    expr->kind = kind;
    expr->siblings[0] = c1;
    expr->siblings[1] = c2;
    expr->siblings[2] = c3;

    return expr;
}

void expression_free(expression_t *expression) {
    if (expression != NULL) {
        expression_free(expression->siblings[0]);
        expression_free(expression->siblings[1]);
        expression_free(expression->siblings[2]);
        free(expression->text);
        memset(expression, 0, sizeof(expression_t));
        free(expression);
    }
}
