%option noywrap yylineno
%x IFILE

%{
  struct fubstack
  {
    struct fubstack *prev;
    YY_BUFFER_STATE bs;
    int lineno;
    char *filename;
    FILE *f;
  } *curbs = 0;

  char *curfilename;

  int newfile(char *fn);
  int popfile(void);
}%

%%

^"#"[ \t]*include[ \t]*[\"<] { BEGIN IFILE; }
<IFILE>[^ \t\n">]+    {
                        {
                          int c;
                          
                          while((c = input()) && c != '\n')
                        }
                        yylineno++;
                        if(!newfile(yytext))
                          yyterminate();
                        BEGIN INITIAL;
                      }

<IFILE>.|\n           {
                        fprintf(stderr, "%d bad include line\n", yylineno);
                          yyterminate();
                      }

<<EOF>>               { if(!popfile()) yyterminate(); }

^.                    { fprintf(yyout, "%4d %s", yylineno, yytext); }
^\n                   { fprintf(yyout, "%4d %s", yylineno++, yytext); }
\n                    { ECHO; yylineno++; }
.                     { ECHO; }

%%

