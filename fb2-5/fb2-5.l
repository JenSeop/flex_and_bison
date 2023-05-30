%option noywrap nodefault yylineno

%x COMMENT
%x IFILE

/* UNIV Character Name */
UCN   (\\u[0-9a-fA-F]{4}|\\U[0-9a-fA-F]{8})
/* Float exponent */
EXP   ([Ee][-+]?[0-9]+)
/* Integer length */
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

/* C++ comment */
"//".*\n

/* declaration keywords */
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

/* Keywords */
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

/* Integers */
0[0-7]*{ILEN}?
[1-9][0-9]*{ILEN}?
0[Xx][0-9a-fA-F]+{ILEN}?

/* Demical Float */
([0-9]*\.[0-9]+|[0-9]+\.){EXP}?[flFL]?
[0-9]+{EXP}[flFL]?

/* Hex Float */
0[Xx]([0-9a-fA-F]*\.[0-9a-fA-F]+|[0-9a-fA-F]+\.?)[Pp][-+]?[0-9]+[flFL]?

/* Char const */
\'([^'\\]|\\['"?\\abfnrtv]|\\[0-7]{1,3}|\\[Xx][0-9a-fA-F]+|{UCN})+\'

/* String literal */
L?\"([^\"\\]|\\['"?\\abfnrtv]|\\[0-7]{1,3}|\\[Xx][0-9a-fA-F]+|{UCN})+\"

/* punctuators */
"{"|"<%"|";"    { defining = 0; }

