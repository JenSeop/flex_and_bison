%option noywrap nodefault yylineno

%x COMMENT
%x IFILE

UCN   (\\u[0-9a-fA-F]{4}|\\U[0-9a-fA-F]{8})
EXP   ([Ee][-+]?[0-9]+)
ILEN  ([Uu](L|l|LL|ll)?|(L|l|LL|ll)[Uu]?)

%{
  struct symbol
  {
    struct ref *reflist;
    char *name;
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

  struct bufstack
  {
    struct bufstack *prev;
    YY_BUFFER_STATE bs;
    int lineno;
    char *filename;
    FILE *f;
  } *curbs;

  int newfile(char *fn);
  int popfile(void);

  int defining;

%}

%%

"/*"                  { BEGIN(COMMENT); }
<COMMENT>"*/"         { BEGIN(INITIAL); }
<COMMENT>([^*]|\n)+|.
<COMMENT><<EOF>>      { printf("%s:%d: Unterminated comment\n", curfilename, yylineno); return (0); }

"//".*\n

_Bool |
_Complex |
_Imaginary |
auto |
char |
const |
double |
enum |
extern |
float |
inline |
int |
long |
register |
restrict |
short |
signed |
static |
struct |
typedef |
union |
unsigned |
void |
volatile { defining = 1; }

break
case
continue
default
doubleelse
for
goto
IFILEreturn
sizeof
switch
while

0[0-7]*{ILEN}?
[1-9][0-9]*{ILEN}?
0[Xx][0-9a-fA-F]+{ILEN}?

([0-9]*\.[0-9]+|[0-9]+\.){EXP}?[flFL]?
[0-9]+{EXP}[flFL]?

0[Xx]([0-9a-fA-F]*\.[0-9a-fA-F]+|[0-9a-fA-F]+\.?)[Pp][-+]?[0-9]+[flFL]?