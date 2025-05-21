#ifndef PARSED_TYPES_H
#define PARSED_TYPES_H

typedef enum expression_kind { e_unknown, e_double, e_int, e_complex_cart,
                               e_complex_polar, e_fraction,
                               e_matrix, e_matrix_row } expression_kind;
typedef enum expression_angle_unit { e_au_unknown, e_au_deg, e_au_rad } expression_angle_unit;

struct expression {
    expression_kind kind;
    expression_angle_unit angle_unit;
    char *text;

    struct expression **siblings;
};

typedef struct expression expression_t;

expression_t *expression_zero(void);
expression_t *expression_one(int sign);
expression_t *expression_int(const char *text);
expression_t *expression_double(const char *text);
expression_t *expression_complex_cart(expression_t *real, expression_t *imag);
expression_t *expression_complex_polar(expression_t *abs, expression_t *arg,
                                       expression_angle_unit angle_unit);
expression_t *expression_fraction(expression_t *whole, expression_t *numerator, expression_t *denominator);
expression_t *expression_matrix(expression_t *rows[]);
expression_t *expression_matrix_row(expression_t *elements[]);

expression_t *expression_neg(int sign, expression_t *expression);

expression_t *expression_scalar(const char *text, expression_kind kind);
expression_t *expression_multicomponent(expression_t *expressions[], expression_kind kind);
expression_t *expression_append_sibling(expression_t *expr, expression_t *sibling);

void expression_free(expression_t *expression);

#endif
