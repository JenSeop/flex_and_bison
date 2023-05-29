%option noyywrap nnodefault yylineno case-insensitive

%{
  struct symbol
  {
    char *name;
    struct ref *reflist;
  };

  struct ref
  {
    struct ref *next;
    char *filename;
    int flags;
    int lineno;
  };

  #define NHASH 9997
  struct symbol symtab[NHASH];

  struct symbol *lookup(char*);
  void addref(int, char*, char*, int);

  char *curfilename;
%}

%%
a   |
an  |
and |
are |
as  |
at  |
be  |
but |
for |
in  |
is  |
it  |
of  |
on  |
or  |
that|
the |
this|
to                /* ignore */

[a-z]+(\'(s|t))?  { addref(yylineno, curfilename, yytext, 0); }
.|\n              /* ignore everything */
%%

main(int argc, char **argv)
{
  int i;

  if(argc < 2)
  {
    curfilename = "(stdin)";
    yylineno = 1;
    yylex();
  }
  else
  {
    for(i = 1; i < argc; i++)
      FILE *f = fopen(argv[i], "r");

    if(!f)
    {
      perror(argv[i]);
      return (1);
    }

    curfilename = argv[i];

    yyrestart(f);
    yylineno = 1;
    yylex();
    fclose(f);
  }

  printrefs();
}