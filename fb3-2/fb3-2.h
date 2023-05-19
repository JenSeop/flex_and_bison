#pragma once
#define NHASH 9997

extern int yylineno;
void yyerror(char *s, ...);

enum bifs { B_sqrt, B_exp, B_log, B_print};

struct ast {
	int nodetype;
	struct ast *l;
	struct ast *r;
};

struct numval {
		int nodetype;
		double number;
};

struct fncall {
	int nodetype;
	struct ast *l;
	enum bifs functype;
};

struct symbol {
	char *name;
	double value;
	struct ast *func;
	struct symlist *syms;
};

struct ufncall {
	int nodetype;
	struct ast *l;
	struct symbol *s;
};

struct symref {
	int nodetype;
	struct symbol *s;
};

struct symasgn {
	int nodetype;
	struct symbol *s;
	struct ast *v;
};

struct flow {
	int nodetype;
	struct ast *cond;
	struct ast *tl;
	struct ast *el;
};

struct symlist {
	struct symbol *sym;
	struct symlist *next;
};

static unsigned symhash(char *);
struct symbol *lookup(char *sym);

struct ast *newast(int nodetype, struct ast *l, struct ast *r);
struct ast *newnum(double d);
struct ast *newcmp(int cmptype, struct ast *l, struct ast *r);
struct ast *newfunc(int functype, struct ast *l);
struct ast *newcall(struct symbol *s, struct ast *l);
struct ast *newref(struct symbol *s);
struct ast *newasgn(struct symbol *s, struct ast *v);

struct ast *newflow(int nodetype, struct ast *cond, struct ast *tl, struct ast *el);
struct symlist *newsymlist(struct symbol *sym, struct symlist *next);
void symlistfree(struct symlist *sl);

static double callbuiltin(struct fncall *f);
void dodef(struct symbol *name, struct symlist *syms, struct ast *func);

double eval(struct ast *);

void treefree(struct ast *);