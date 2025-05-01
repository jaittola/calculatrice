#ifndef PARSED_TYPES_H
#define PARSED_TYPES_H

typedef enum expression_kind { e_unknown, e_double, e_int, e_complex_cart, e_fraction } expression_kind;

struct expression {
    expression_kind kind;
    char *text;

    struct expression *siblings[3];
};

typedef struct expression expression_t;

expression_t *expression_zero(void);
expression_t *expression_one(int sign);
expression_t *expression_int(const char *text);
expression_t *expression_double(const char *text);
expression_t *expression_complex_cart(expression_t *real, expression_t *imag);
expression_t *expression_fraction(expression_t *whole, expression_t *numerator, expression_t *denominator);


expression_t *expression_neg(int sign, expression_t *expression);

expression_t *expression_scalar(const char *text, expression_kind kind);
expression_t *expression_multicomponent(expression_t *c1, expression_t *c2, expression_t *c3, expression_kind kind);

void expression_free(expression_t *expression);

#endif
