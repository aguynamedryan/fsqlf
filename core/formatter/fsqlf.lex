/*
Thanks to http://vsbabu.org/software/lsqlb.html
Vattekkat Satheesh Babu, on Dec 30, 1998
Helped to learn about flex a bit
*/

%top{
    /* This code goes at the "top" of the generated file. */
#include <stdio.h>      // fprintf, stdin, stdout
#include "globals.h"    // pair_stack, sub_openings, currindent, left_p, right_p
#include "print_keywords.h" // use_token
void debug_stchange(int);
void debug_match(char*);
}


%{
char * state_to_char(int);
//#define YY_USER_ACTION fprintf(yyout,"\n %10s - rule (%d) - line(%d) " ,state_to_char(YY_START),yy_act, __LINE__);
#define DMATCH(name) fprintf(yyout,"%20s is rule (%d) : ", name , yy_act);


#define BEGIN_STATE(NEWSTATE) debug_stchange(NEWSTATE); BEGIN (NEWSTATE);
#define PUSH_STATE(NEWSTATE)  stack_push(&state_stack, &(int){YY_START}); BEGIN_STATE(NEWSTATE);
#define POP_STATE(); BEGIN_STATE(*(int*)stack_peek(&state_stack)); stack_pop(&state_stack);

// YY_USER_INIT is lex macro executed before initialising parser
#define YY_USER_INIT \
    stack_init(&state_stack, sizeof(int)); \
    stack_init(&sub_openings, sizeof(pair));
%}


DIGIT   [0-9]
NUMBER  {DIGIT}+([.]{DIGIT}+)?([eE][+-]?{DIGIT}+)?
ID      [A-Za-z_][A-Za-z0-9_]*
SPACE   [ \t\n]
DBOBJECT    ({ID}[.]){0,2}{ID}


LEFTP   [(]
RIGHTP  [)]

UNION     (?i:union)
UNION_ALL (?i:union{SPACE}+all)
INTERSECT (?i:intersect)
EXCEPT    (?i:except)
MINUS     (?i:minus)

TABLE_OPT (?i:global|volatile|set|multiset|temporary)
CREATE_TABLE (?i:create{SPACE}+({TABLE_OPT}{SPACE}+)*table)
DROP    (?i:drop)
TABLE   (?i:table)
VIEW    (?i:view)
IFEXISTS (?i:if{SPACE}+exists)
SELECT  (?i:select|sel)
AS      (?i:as)
FROM    (?i:from)
USING   (?i:using)

IJOIN   (?i:(inner{SPACE}+)?JOIN)
LJOIN   (?i:left{SPACE}+(OUTER{SPACE}+)?JOIN)
RJOIN   (?i:right{SPACE}+(OUTER{SPACE}+)?JOIN)
FJOIN   (?i:full{SPACE}+(OUTER{SPACE}+)?JOIN)
CJOIN   (?i:cross{SPACE}+JOIN{SPACE}+)
ANYJOIN ({LJOIN}|{RJOIN}|{FJOIN}|{CJOIN})

ON      (?i:on)
WHERE   (?i:where)
SAMPLE  (?i:sample)
AND     (?i:and)
OR      (?i:or)
EXISTS  (?i:exists)
IN      (?i:in)
COMPARISON (=|<>|<=|>=|<|>)

GROUPBY (?i:group{SPACE}+by)
ORDERBY (?i:order{SPACE}+by)
HAVING  (?i:having)
QUALIFY (?i:qualify)

COMMA [,]

COMMENT_ONE_LINE [-]{2,}[^\n]*[\n]
COMMENT_ONE_LINE_LAST_LINE_IN_FILE [-]{2,}[^\n]*
COMMENT_ML_START [/][*]+
COMMENT_ML_PART1 [^*]+
COMMENT_ML_PART2 [*]+[^/]
COMMENT_ML_END   [*]+[/]

STRING ([xX]?['][^'']*['])+
SEMICOLON ;

INSERTINTO (?i:(ins|insert){SPACE}+into)
UPDATE (?i:upd|update)
SET (?i:set)
DELETEFROM (?i:(del|delete){SPACE}+from)
DELETE (?i:(del|delete))

CASE (?i:case)
WHEN (?i:when)
THEN (?i:then)
ELSE (?i:else)
END (?i:end)


%option noyywrap nounput noinput

/* always-interactive - removes usage of fileno, isatty (not C99 compliant).
 * See details at:
 *     http://flex.sourceforge.net/manual/Why-do-flex-scanners-call-fileno-if-it-is-not-ANSI-compatible_003f.html
 */
%option always-interactive

%s stSELECT stFROM stWHERE stON stEXISTS stLEFTP stJOIN stIN stCOMMA stINLIST stFROM_LEFTP stP_SUB stORDERBY stGROUPBY stINSERT stINSCOLLIST stUPDATE stSET stDELETE stIN_CONSTLIST stCREATE_TABLE stTAB_COL_LIST
%x stCOMMENTML stSTRING

%%

{DELETEFROM}  { BEGIN_STATE(stDELETE);use_token(yyout,yytext,kw("kw_deletefrom")); }
{DELETE}      { BEGIN_STATE(stDELETE);use_token(yyout,yytext,kw("kw_deletefrom")); }
{INSERTINTO}  { BEGIN_STATE(stINSERT);use_token(yyout,yytext,kw("kw_insertinto")); }
{UPDATE}      { BEGIN_STATE(stUPDATE);use_token(yyout,yytext,kw("kw_update")); }
<stUPDATE,stFROM>{SET} { BEGIN_STATE(stSET);use_token(yyout,yytext,kw("kw_set")); }
<stSET>{COMMA} { use_token(yyout,yytext,kw("kw_comma_set")); }
                /* SET operations */

{CREATE_TABLE} {BEGIN_STATE(stCREATE_TABLE);use_token(yyout,yytext,kw("kw_create_table"))   ; };
{DROP}       {BEGIN_STATE(INITIAL);use_token(yyout,yytext,kw("kw_drop"))     ; };
{TABLE}      {BEGIN_STATE(INITIAL);use_token(yyout,yytext,kw("kw_table"))    ; };
{IFEXISTS}   {BEGIN_STATE(INITIAL);use_token(yyout,yytext,kw("kw_ifexists")) ; };
{VIEW}       {BEGIN_STATE(INITIAL);use_token(yyout,yytext,kw("kw_view"))     ; };
{UNION}      {BEGIN_STATE(INITIAL);use_token(yyout,yytext,kw("kw_union"))    ; };
{UNION_ALL}  {BEGIN_STATE(INITIAL);use_token(yyout,yytext,kw("kw_union_all")); };
{MINUS}      {BEGIN_STATE(INITIAL);use_token(yyout,yytext,kw("kw_minus"));     };
{INTERSECT}  {BEGIN_STATE(INITIAL);use_token(yyout,yytext,kw("kw_intersect")); };
{EXCEPT}     {BEGIN_STATE(INITIAL);use_token(yyout,yytext,kw("kw_except"));    };

                /* SELECT ... FROM */
<INITIAL,stINSERT>{SELECT}           {BEGIN_STATE(stSELECT); use_token(yyout,yytext,kw("kw_select")); };
<stSELECT,stCOMMA>{COMMA}   {BEGIN_STATE(stCOMMA);  use_token(yyout,yytext,kw("kw_comma"));  };

{IN}    { use_token(yyout,yytext,kw("kw_in")); };

<stSELECT,stCOMMA>{LEFTP}   {PUSH_STATE(stLEFTP );  use_token(yyout,yytext,kw("kw_left_p")); };
<stLEFTP>{LEFTP}            {PUSH_STATE(stLEFTP ); debug_match("{LEFTP}");use_token(yyout,yytext,kw("kw_left_p"));  };
<stLEFTP>{COMMA}            {use_token(yyout,yytext, NULL); };
<stLEFTP>{ORDERBY}          {use_token(yyout,yytext, NULL); };
<stLEFTP>{FROM}             {debug_match("{FROM}" ); use_token(yyout,yytext,kw("kw_from_2"));  };
<stLEFTP>{RIGHTP}           {POP_STATE();            use_token(yyout,yytext,kw("kw_right_p")); };
<stSELECT,stCOMMA,stUPDATE>{FROM} {BEGIN_STATE(stFROM);  use_token(yyout,yytext,kw("kw_from"));    };
<stLEFTP,stSELECT>{AS}      {debug_match("{AS}"  );  use_token(yyout,yytext,kw("kw_as"));      };

                /* FROM ... JOIN ... ON ... WHERE */
<stON,stFROM,stJOIN>{IJOIN} { BEGIN_STATE(stJOIN);  use_token(yyout,yytext,kw("kw_inner_join")); };
<stON,stFROM,stJOIN>{LJOIN} { BEGIN_STATE(stJOIN);  use_token(yyout,yytext,kw("kw_left_join") ); };
<stON,stFROM,stJOIN>{RJOIN} { BEGIN_STATE(stJOIN);  use_token(yyout,yytext,kw("kw_right_join")); };
<stON,stFROM,stJOIN>{FJOIN} { BEGIN_STATE(stJOIN);  use_token(yyout,yytext,kw("kw_full_join") ); };
<stON,stFROM,stJOIN>{CJOIN} { BEGIN_STATE(stJOIN);  use_token(yyout,yytext,kw("kw_cross_join")); };
<stON,stFROM,stJOIN>{COMMA} { use_token(yyout,yytext,kw("kw_comma_join")); };

<stJOIN>{ON}    {BEGIN_STATE(stON);   use_token(yyout,yytext,kw("kw_on")); };



                /* WHERE ... (also join conditions) */
<stFROM,stJOIN,stON,stSET,stDELETE>{WHERE} {BEGIN_STATE(stWHERE );  use_token(yyout,yytext,kw("kw_where")); };
<stWHERE,stON,stJOIN>{AND}  { debug_match("{AND}");  use_token(yyout,yytext,kw("kw_and"));   };
<stWHERE,stON,stJOIN>{OR}   { debug_match("{OR}");   use_token(yyout,yytext,kw("kw_or"));    };

<stWHERE>{EXISTS}   {use_token(yyout,yytext,kw("kw_exists")); };


{GROUPBY}    {BEGIN_STATE(stGROUPBY); use_token(yyout,yytext,kw("kw_groupby")); };
{ORDERBY}    {BEGIN_STATE(stORDERBY); use_token(yyout,yytext,kw("kw_orderby")); };
<stORDERBY>{COMMA}   { use_token(yyout,yytext,kw("kw_comma_ordby")); };
<stGROUPBY>{COMMA}   { use_token(yyout,yytext,kw("kw_comma_grpby")); };
{HAVING}     {BEGIN_STATE(stWHERE); use_token(yyout,yytext,kw("kw_having"));  };
{QUALIFY}    {BEGIN_STATE(stWHERE); use_token(yyout,yytext,kw("kw_qualify")); };


<stINSERT>{LEFTP}        { PUSH_STATE(stINSCOLLIST); use_token(yyout,yytext,kw("kw_left_p_ins") ); };
<stINSCOLLIST>{COMMA}    { use_token(yyout,yytext,kw("kw_comma_ins") ); }
<stINSCOLLIST>{RIGHTP}   { POP_STATE();              use_token(yyout,yytext,kw("kw_right_p_ins") ); };

<stCREATE_TABLE>{LEFTP}  { PUSH_STATE(stTAB_COL_LIST); use_token(yyout,yytext,kw("kw_left_p_create_table") ); };
<stTAB_COL_LIST>{COMMA}    { use_token(yyout,yytext,kw("kw_comma_create_table") ); }
<stTAB_COL_LIST>{RIGHTP}   { POP_STATE();              use_token(yyout,yytext,kw("kw_right_p_create_table") ); };

<stP_SUB>{LEFTP}                      { BEGIN_STATE(*(int*)stack_peek(&state_stack)); use_token(yyout,yytext,kw("kw_left_p")    ); PUSH_STATE(stP_SUB);  };
{LEFTP}                               { PUSH_STATE(stP_SUB); };
<stP_SUB>{SELECT}                     { BEGIN_STATE(stSELECT);     use_token(yyout,"(",kw("kw_left_p_sub")); use_token(yyout,yytext,kw("kw_select"));};
<stP_SUB>{NUMBER}|{STRING}|{DBOBJECT} {
    if (*(int*)stack_peek(&state_stack) == stFROM
        || *(int*)stack_peek(&state_stack) == stJOIN)
    { BEGIN_STATE(*(int*)stack_peek(&state_stack)); use_token(yyout,"(",kw("kw_left_p")    ); use_token(yyout,yytext, NULL);}
    else
    { BEGIN_STATE(stIN_CONSTLIST); use_token(yyout,"(",kw("kw_left_p")    ); use_token(yyout,yytext, NULL); }
    };
 /* <stP_SUB>{NUMBER}|{STRING}|{DBOBJECT} { BEGIN_STATE(stIN_CONSTLIST); use_token(yyout,"(",kw("kw_left_p")    ); use_token(yyout,yytext, NULL);}; */
<stP_SUB>{COMMENT_ML_START}           { use_token(yyout,"", NULL); PUSH_STATE(stCOMMENTML)  ; use_token(yyout,yytext, NULL);};
<stP_SUB>{COMMENT_ONE_LINE}           { use_token(yyout,"", NULL); use_token(yyout,yytext, NULL);};
<stP_SUB>{SPACE}                      { use_token(yyout,"", NULL); };
<stP_SUB>{RIGHTP}                     { use_token(yyout,"(",kw("kw_left_p")    ); POP_STATE(); use_token(yyout,yytext,kw("kw_right_p")); }
<stP_SUB>.                            { BEGIN_STATE(*(int*)stack_peek(&state_stack)); use_token(yyout,"(",kw("kw_left_p")    ); use_token(yyout,yytext, NULL); };

{RIGHTP}    {
                POP_STATE();
                if (!stack_empty(&sub_openings) &&
                    left_p -(*(pair*)stack_peek(&sub_openings)).left == (right_p+1) -(*(pair*)stack_peek(&sub_openings)).right - 1) {
                    use_token(yyout,yytext,kw("kw_right_p_sub"));
                } else {
                    debug_match("<wtf-leftp>");
                    use_token(yyout,yytext,kw("kw_right_p"));
                }

            };

{CASE}  { use_token(yyout,yytext,kw("kw_case")); currindent++;}
{WHEN}  { use_token(yyout,yytext,kw("kw_when")); }
{THEN}  { use_token(yyout,yytext,kw("kw_then")); }
{ELSE}  { use_token(yyout,yytext,kw("kw_else")); }
{END}   { currindent--; use_token(yyout,yytext,kw("kw_end")); }

{USING} { use_token(yyout,yytext,kw("kw_using")); }


{COMMENT_ML_START}     {PUSH_STATE(stCOMMENTML); use_token(yyout,yytext, NULL);};
<stCOMMENTML>{COMMENT_ML_PART1}     {debug_match("COMMENT_ML_PART1") ; use_token(yyout,yytext, NULL);};
<stCOMMENTML>{COMMENT_ML_PART2}     {debug_match("COMMENT_ML_PART2") ; use_token(yyout,yytext, NULL);};
<stCOMMENTML>{COMMENT_ML_END}       {POP_STATE(); use_token(yyout,yytext, NULL);};

{COMMENT_ONE_LINE}     {use_token(yyout,yytext, NULL);};
    /* Exeption to one-line-comment: comment on last line, without new-line after it */
{COMMENT_ONE_LINE_LAST_LINE_IN_FILE}    {use_token(yyout,yytext, NULL);};


{STRING}     {use_token(yyout,yytext, NULL);};

{SPACE}+     {/* discard spaces */;};
{DBOBJECT}   {use_token(yyout,yytext, NULL);};
{NUMBER}     {use_token(yyout,yytext, NULL);};
{SEMICOLON}  {BEGIN_STATE(INITIAL); use_token(yyout,yytext,kw("kw_semicolon"));};
<*>.         {debug_match("<*>."); use_token(yyout,yytext, NULL); };


<<EOF>> {
            fprintf(yyout,"\n");
            switch (YY_START) {
                case stCOMMENTML: fprintf(yyout,"--unterminated comment \n"); break;
                case stSTRING: fprintf(yyout,"--unterminated  string\n"); break;
                default: ;
            }
            return 0 ;
        }

%%