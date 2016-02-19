D			[0-9]
L			[a-zA-Z_]
H			[a-fA-F0-9]
E			[Ee][+-]?{D}+
FS			(f|F|l|L)
IS			(u|U|l|L)*

%option noyywrap

%{
#include <stdio.h>
#include <string.h>
#define LCHAR 0
#define LSTR 1
#define FP 2
#define HOI 3
#define KEYWORD 4
#define ID 5
#define OPERATOR 6
#define COMMENT 7
#define DIRECTIVE 8
#define INDENT 4
#define MAXSYMBOLS 200

int col = 4, paren = 0, line =1, tok=-1;
%}


%%
"/*"			{ comment(); }
"//"			{
					char c;
					printf("<font color='#00FF00'><i>//");
					while((c=input())!='\n' && c!=0) write_html_char(c);;
					printf("</i></font>"); indent();
				}
[#] 			{
					char c;
					printf("<font color='#FF00FF'><i>#");
					while((c=input())!='\n' && c!=0) write_html_char(c);;
					printf("</i></font>");
					printf("\n");
				}
"auto"			{ count(KEYWORD); }
"break"			{ count(KEYWORD); }
"case"			{ count(KEYWORD); }
"char"			{ count(KEYWORD); }
"const"			{ count(KEYWORD); }
"continue"		{ count(KEYWORD); }
"default"		{ count(KEYWORD); }
"do"			{ count(KEYWORD); }
"double"		{ count(KEYWORD); }
"else"			{ count(KEYWORD); }
"enum"			{ count(KEYWORD); }
"extern"		{ count(KEYWORD); }
"float"			{ count(KEYWORD); }
"for"			{ count(KEYWORD); }
"goto"			{ count(KEYWORD); }
"if"			{ count(KEYWORD); }
"int"			{ count(KEYWORD); }
"long"			{ count(KEYWORD); }
"register"		{ count(KEYWORD); }
"return"		{ count(KEYWORD); }
"short"			{ count(KEYWORD); }
"signed"		{ count(KEYWORD); }
"sizeof"		{ count(KEYWORD); }
"static"		{ count(KEYWORD); }
"struct"		{ count(KEYWORD); }
"switch"		{ count(KEYWORD); }
"typedef"		{ count(KEYWORD); }
"union"			{ count(KEYWORD); }
"unsigned"		{ count(KEYWORD); }
"void"			{ count(KEYWORD); }
"volatile"		{ count(KEYWORD); }
"while"			{ count(KEYWORD); }

{L}({L}|{D})*	{ count(ID); }

0[xX]{H}+{IS}?	{ count(HOI); }
0{D}+{IS}?		{ count(HOI); }
{D}+{IS}?		{ count(HOI); }
L?'(\\.|[^\\'])+'	{ count(LCHAR); }

{D}+{E}{FS}?			{ count(HOI); }
{D}*"."{D}+({E})?{FS}?	{ count(FP); }
{D}+"."{D}*({E})?{FS}?	{ count(FP); }

L?\"(\\.|[^\\"])*\"		{ count(LSTR); }

"..."			{ count(OPERATOR); }
">>="			{ count(OPERATOR); }
"<<="			{ count(OPERATOR); }
"+="			{ count(OPERATOR); }
"-="			{ count(OPERATOR); }
"*="			{ count(OPERATOR); }
"/="			{ count(OPERATOR); }
"%="			{ count(OPERATOR); }
"&="			{ count(OPERATOR); }
"^="			{ count(OPERATOR); }
"|="			{ count(OPERATOR); }
">>"			{ count(OPERATOR); }
"<<"			{ count(OPERATOR); }
"++"			{ count(OPERATOR); }
"--"			{ count(OPERATOR); }
"->"			{ count(OPERATOR); }
"&&"			{ count(OPERATOR); }
"||"			{ count(OPERATOR); }
"<="			{ count(OPERATOR); }
">="			{ count(OPERATOR); }
"=="			{ count(OPERATOR); }
"!="			{ count(OPERATOR); }
";"				{ count(-1); write_sep(); }
"{"				{ count(-2); write_begin(); }
"}"				{ count(-2); write_end(); }
","				{ count(OPERATOR); }
":"				{ count(OPERATOR); }
"="				{ count(OPERATOR); }
"("				{ count(-3); write_open(); }
")"				{ count(-3); write_close(); }
"["				{ count(OPERATOR); }
"]"				{ count(OPERATOR); }
"."				{ count(OPERATOR); }
"&"				{ count(OPERATOR); }
"!"				{ count(OPERATOR); }
"~"				{ count(OPERATOR); }
"-"				{ count(OPERATOR); }
"+"				{ count(OPERATOR); }
"*"				{ count(OPERATOR); }
"/"				{ count(OPERATOR); }
"%"				{ count(OPERATOR); }
"<"				{ count(OPERATOR); }
">"				{ count(OPERATOR); }
"^"				{ count(OPERATOR); }
"|"				{ count(OPERATOR); }
"?"				{ count(OPERATOR); }

[ \t\n\v\r\f]	{ECHO;}
.				{ /* ignore bad characters */ }
%%

indent() 		{ printf("\n%-*s",col,""); }

write_html_char(int c)
{
	switch (c)
	{
		case '<': printf("&lt;"); break;
		case '>': printf("&gt;"); break;
		case '"': printf("&quot;"); break;
		case '&': printf("&amp;"); break;
		default:  putchar(c);
	}
}

write_html()
{
	char *s = yytext;
	while (*s)
		write_html_char(*s++);
}

write_open()
{
 	write_html();
	putchar(' ');
	paren++;
}

write_close()
{
	write_html();
	putchar(' ');
	paren--;
}

write_sep()
{
	write_html();
	if (!paren)
		indent();
	else
		putchar(' ');
}

// begin {}-block
write_begin()
{
	indent();
	write_html();
	col += INDENT;
	indent();
}

// end {}-block
write_end()
{
	col -= INDENT;
	indent();
	write_html();
	indent();
}

struct entry
{
	char *lexptr;
	int token;
};

struct entry symtable[MAXSYMBOLS];

int insert(char *a, int token){

	strcat(a,"\0");
	symtable[tok].lexptr = (char *)malloc(sizeof(a)*sizeof(char));
	strcpy(symtable[tok].lexptr, a);
	symtable[tok].token = token;
	return 1;
}

int lookup(char *lexeme){
	int i=0;
	int j;
	while(i<=tok){
		j = strcmp(symtable[i].lexptr, lexeme);
		if(j==0){
			return i;
		}
		i++;
	}
	return -1;
}

void init(){
	int i = 0;
	while(i<MAXSYMBOLS){
		symtable[i].token=-1;
		symtable[i].lexptr=NULL;
		i++;
	}
}

void write_id()
{	
	char *s = yytext;
	int check = lookup(s);
	if(check >= 0 && check < MAXSYMBOLS){
		printf("<a href=\"#%s\">", s);
		printf("<font color='#0000FF'><b>");
		printf("%s",s);
		printf("</b></font></a> ");
	}
	else{
		insert(s,++tok);
		printf("<a name=\"%s\">",s);
		printf("<font color='#0000FF'><b>");
		printf("%s",s);
		printf("</b></font></a> ");
	}
}

void write_id1()
{
	char *s = yytext;
	int check = lookup(s);
	if(check >= 0 && check < MAXSYMBOLS){
		printf("<a href=\"#%s\">", s);
		printf("<font color='#0000FF'>");
		printf("%s",s);
		printf("</font></a> ");
	}
	else{
		insert(s,++tok);
		printf("<a name=\"%s\">",s);
		printf("<font color='#0000FF'>");
		printf("%s",s);
		printf("</font></a> ");
	}
}


comment()
{
	char c1, c2;
	printf("<font color='#00FF00'>/*");
	loop:
		while ((c1 = input()) != '*' && c1 != 0)
			write_html_char(c1);

	if ((c2 = input()) != '/' && c1 != 0)
	{
		unput(c2);
		goto loop;
	}

	if (c1 != 0)
		write_html_char(c2);
		printf("</font>");
}


count(int type)
{
	if(type>=0){
  		switch(type){
			case LCHAR: 		printf("<font color='#00FFFF'><u>"); ECHO; printf("</u></font>"); break;
			case LSTR: 			printf("<font color='#FF0000'>"); ECHO; printf("</font>"); break;
			case FP: 			printf("<font color='#00FFFF'>"); ECHO; printf("</font>"); break;
			case HOI: 			printf("<font color='#00FFFF'><i>"); ECHO; printf("</i></font>"); break;
			case KEYWORD:		write_id(); break;
			case ID: 			write_id1(); break;
			case OPERATOR:		printf("<b>"); ECHO; printf("</b>"); break;
			case DIRECTIVE:		printf("<font color='#FF00FF'><i>"); ECHO; printf("</i></font>\n"); break;
			default:			printf("<br></br>");	ECHO;
		};
	}
}


main (int argc, char **argv){
	++argv, --argc;
	init();
	if(argc > 0) yyin = fopen(argv[0],"r");
	else yyin=stdin;
	printf("<html><pre>\n");
	yylex();
	printf("</pre></html>\n");

}
