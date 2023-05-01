%{
        #include<stdio.h>
        #define MAX_LINE_LENG 256
        #define TABLE_LENGTH 100
        #define WORD_LENGTH 20
        #define LIST strcat(buf,yytext)
        #define STR strcat(str_const,yytext)
        #define token(t) {LIST; printf("<%s>\n",t);}
        #define tokenInteger(t,i) {LIST; printf("<%s:%d>\n",t,i);}
        #define tokenFloat(t,f) {LIST; printf("<%s:%f>\n",t,f);}
        #define tokenString(t,s) {LIST; printf("<%s:%s>\n",t,s);}
        int linenum = 1;
        int total_index = 0;
        char buf[MAX_LINE_LENG];
        char str_const[MAX_LINE_LENG];
        char** symbol_table;
        void create();
        int lookup(char* s);
        int insert(char* s);
        void dump();
%}

%s LONG_COMMENT STRING_CONST

%%
        /* End Of Line */
<STRING_CONST><<EOF>>   {
                                printf("%d: Wrong input of string\n", linenum);
                                dump();
                                exit(-1);
                        }
<<EOF>> {
                LIST;
                printf("%d: %s\n", linenum, buf);
                dump();
                exit(-1);
        }

<STRING_CONST>\n        {
                                BEGIN 0;
                                str_const[0] = '\0';
                                printf("%d: Wrong input of string\n", linenum);
                                linenum++;
                                buf[0] = '\0';
                        }

        /* String Const */
<STRING_CONST>\"\"      {
                                strcat(buf,"\"");
                                strcat(str_const,"\"");
                        }

<STRING_CONST>\"        {
                                BEGIN 0;
                                tokenString("string", str_const);
                                str_const[0] = '\0';
                        }

<STRING_CONST>[^"]*     {
                                LIST;
                                STR;
                        }

        /* Next Line */
\n      {
                LIST;
                printf("%d: %s", linenum, buf);
                linenum++;
                buf[0] = '\0';
        }
 
        /* Long comment */
<INITIAL>"{%"   {
                        BEGIN LONG_COMMENT;
                        LIST;
                }

<LONG_COMMENT>"%}"      {
                                BEGIN 0;
                                LIST;
                        }

<LONG_COMMENT>.         {
                                LIST;
                        }


        /* Start String Const */
<INITIAL>\"     {
                        BEGIN STRING_CONST;
                        LIST;
                }

        /* Tabs, whitespace and short comment */
<INITIAL>[ \t]* |
<INITIAL>\%.*   {
                        LIST;
                } 

        /* Keywords */
<INITIAL>array |
<INITIAL>begin |
<INITIAL>bool |
<INITIAL>char |
<INITIAL>const |
<INITIAL>decreasing |
<INITIAL>default |
<INITIAL>do |
<INITIAL>else |
<INITIAL>end |
<INITIAL>exit |
<INITIAL>false |
<INITIAL>for |
<INITIAL>function |
<INITIAL>get |
<INITIAL>if |
<INITIAL>int |
<INITIAL>loop |
<INITIAL>of |
<INITIAL>put |
<INITIAL>procedure |
<INITIAL>real |
<INITIAL>result |
<INITIAL>return |
<INITIAL>skip |
<INITIAL>string |
<INITIAL>then |
<INITIAL>true |
<INITIAL>var |
<INITIAL>when   {
                        token(yytext);
                }

        /* Integer Const */
<INITIAL>0 |
<INITIAL>[1-9][0-9]*    {
                                tokenInteger("number", atoi(yytext));
                        }

        /* Float Const */
<INITIAL>0.[0-9]+ |
<INITIAL>[1-9][0-9]*.[0-9]+     {
                                        tokenFloat("number", atof(yytext)); 
                                }

        /* Operators and Tokens*/
<INITIAL>\+ |
<INITIAL>\- |
<INITIAL>\* |
<INITIAL>\/ |
<INITIAL>mod |
<INITIAL>:= |
<INITIAL>\< |
<INITIAL>"<=" |
<INITIAL>\> |
<INITIAL>">=" |
<INITIAL>= |
<INITIAL>not= |
<INITIAL>and |
<INITIAL>or |
<INITIAL>not |
<INITIAL>\. |
<INITIAL>, |
<INITIAL>: |
<INITIAL>; |
<INITIAL>\( |
<INITIAL>\) |
<INITIAL>\[ |
<INITIAL>\] |
<INITIAL>\{ |
<INITIAL>\}     {
                        token(yytext);
                }

        /* Identifiers */
<INITIAL>[a-zA-Z][a-zA-Z0-9]*   {
                                        insert(yytext);
                                        tokenString("identifier", yytext);  
                                }

        /* Others that doesn't follow rules */
<INITIAL>.      {
                        LIST;
                        printf("%d: badchar: %s", linenum, buf);
                        linenum++;
                        buf[0] = '\0';
                }
%%

void create()   {
                        symbol_table = malloc(TABLE_LENGTH * sizeof(char*));
                }

int lookup(char* s)     {       
                                int found_index = -1;
                                for(int i=0; i<total_index; i++){
                                        if(strcmp(symbol_table[i],s) == 0){
                                                found_index = i;
                                                break;
                                        }
                                }
                                return found_index;
                        }

int insert(char* s)     {
                                for(int i=0; i<total_index; i++){
                                        if(strcmp(symbol_table[i], s) == 0){
                                                return -1;
                                        }
                                }
                                symbol_table[total_index] = malloc(sizeof(s));
                                strcpy(symbol_table[total_index], s);
                                total_index++;
                                return total_index-1;
                        }

int dump()     {       
                        total_index = 0;
                        free(symbol_table);
                        return -1;
                }

int main(int argc, char *argv[])
{
        create();
        yyin = fopen(argv[1], "r");
        yylex();

        fclose(yyin);
}

int yywrap()
{
        return 1;
}