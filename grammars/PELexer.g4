/**
 * Copyright 2015 Marco LOMBARDO, mar9000 near google.com .
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 *  
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * This file is part of the PE project.
 */
lexer grammar PELexer;

// Comments.   -----------------------------------------------------------------

// Useful during development to test only the first part of the file no matter other comments
// that can be present inside the grammar file.
GRAMMAR_END:
    '///' .*? EOF   -> channel(HIDDEN)
    ;

LINE_COMMENT:
    SLASH SLASH ~[\r\n]* -> skip
    ;

BLOCK_COMMENT:
    '/*' .*? '*/' -> skip
    ;

BLANKS: [ \t\n\r]+   -> channel(HIDDEN)
    ;

// Keywords.   -----------------------------------------------------------------
// Highest priority for keywords, operators and punctuation.

LANGUAGE: 'language';
USES: 'uses';
EXTENSION: 'extension';
FOR: 'for';
ENUM: 'enum';
KEYWORDS: 'keywords';
FRAGMENT: 'fragment';
PRIMITIVE: 'primitive';
DATATYPE: 'datatype';

// Operators/punctuation.   -----------------------------------------------------------------

COLON: ':';
SEMICOLON: ';';
COMMA: ',';
EQUAL: '=';
DOT: '.';
PIPE: '|';
QUESTION: '?';
STAR: '*';
PLUS: '+';
MINUS: '-';
REGEXPNOT: '^';
SLASH: '/';
BACK_SLASH: '\\';
LPAREN: '(';
RPAREN: ')';
LSBRACKET: '[';
RSBRACKET: ']';
POUND: '#';
LT: '<';
GT: '>';
UNDERSCORE: '_';

// Identifier.   -----------------------------------------------------------------

Identifier
    : Letter LetterOrDigit*
    ;

ExtensionName: '\'' '.' Identifier '\'';

fragment
Letter: [a-zA-Z$_];

fragment
Digit: [0-9];

fragment
LetterOrDigit: [a-zA-Z0-9$_];

// Literals.   -----------------------------------------------------------------

StringLiteral:
    '\'' (EscapeSequence | ~('\'' | '\\'))* '\''
    ;

EscapeSequence:
    '\\' ('\'' | '\\')
    ;

NumericLiteral: Digit+;

OTHER: .;

// End.
