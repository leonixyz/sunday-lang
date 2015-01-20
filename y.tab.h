/* A Bison parser, made by GNU Bison 3.0.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2013 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    USE = 258,
    SET = 259,
    INT = 260,
    REAL = 261,
    TO = 262,
    IF = 263,
    THEN = 264,
    ELSE = 265,
    WHILE = 266,
    DO = 267,
    END = 268,
    ID = 269,
    INTN = 270,
    REALN = 271,
    STRING = 272,
    OPBR = 273,
    CLBR = 274,
    EQUA = 275,
    GT = 276,
    LT = 277,
    GOE = 278,
    LOE = 279,
    PLUS = 280,
    MINU = 281,
    MULT = 282,
    DIVI = 283,
    RETURN = 284,
    UMINUS = 285
  };
#endif
/* Tokens.  */
#define USE 258
#define SET 259
#define INT 260
#define REAL 261
#define TO 262
#define IF 263
#define THEN 264
#define ELSE 265
#define WHILE 266
#define DO 267
#define END 268
#define ID 269
#define INTN 270
#define REALN 271
#define STRING 272
#define OPBR 273
#define CLBR 274
#define EQUA 275
#define GT 276
#define LT 277
#define GOE 278
#define LOE 279
#define PLUS 280
#define MINU 281
#define MULT 282
#define DIVI 283
#define RETURN 284
#define UMINUS 285

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE YYSTYPE;
union YYSTYPE
{
#line 41 "sunday-lang-yacc.y" /* yacc.c:1909  */

        struct tnode *tnode;

#line 118 "y.tab.h" /* yacc.c:1909  */
};
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
