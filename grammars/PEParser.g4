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
parser grammar PEParser;

/*
 * Grammar for parsing Projectional Editor descriptions.
 * It defines both an AST and its projection over the "text" dimension.
 * From this a projectional editor should get essential informations that permits
 * to edit an instance of AST of the described language.
 */

options {
	tokenVocab=PELexer;
}

/* Root rule to indicate extension and root nodes.   */
language:
    LANGUAGE name=qualifiedName USES
    (extensions+=extension)+ SEMICOLON
    declarations+=declaration+
    ;

qualifiedName:
    Identifier (DOT Identifier)*
    ;

extension:
    EXTENSION extensionName=ExtensionName FOR rootNodes+=Identifier (COMMA rootNodes+=Identifier)*
    ;

/* Super rule for all declarations.   */
declaration:
      nodeType
    | primitiveType
    | keywordsDecl
    | fragmentDecl
    ;

/* *** Rules for nodeType.   *** */

/* Named node type composed eventually by several alternatives/subnodes.   */
nodeType:
    name=Identifier COLON
    subnodesList
    SEMICOLON
    ;

/* One or more alternatives each one eventually labeled.   */
subnodesList:
    subnodes+=labeledNodeTypeContent (PIPE subnodes+=labeledNodeTypeContent)*
    ;

labeledNodeTypeContent:
    nodeTypeContent (POUND name=Identifier)?
    ;

/* A node type is a list of element types that can be static (keywords) or not.   */
nodeTypeContent:
    (elements+=element)+
    ;

/* A single cell of information.   */
element:
    ((elementAttributes | name=Identifier elementAttributes?) EQUAL)?
    elemenType
    cardinality=elementCardinality?
    ;

elemenType:
      literal                // This can be a flag or a constant cell depending on element setup.
    | declarationName        // This can be a child, a property, a flag or constant or a subtype.
    | anonymousEnumType
    | group
    | multipleSubtype
    ;

declarationName: Identifier;

anonymousEnumType:
    LPAREN
    values+=enumItem (PIPE values+=enumItem)+
    RPAREN
    ;

elementCardinality: QUESTION | STAR | PLUS;

group:
    LPAREN
    (elements+=element)+
    RPAREN
    ;

multipleSubtype:
    LPAREN
    subtypes+=declarationName (PIPE subtypes+=declarationName)+
    RPAREN
    ;

// --- Attributes used for instance to specify the editor aspect.   ---
elementAttributes:
    LT
    attributes+=elementAttribute (COMMA attributes+=elementAttribute)*
    GT
    ;

/* An attribute can have only a value, only an identifier or both.   */
elementAttribute:
      value=staticContent
    | name=Identifier (
        EQUAL value=staticContent
        | LPAREN parameters+=staticContent? (',' parameters+=staticContent)* RPAREN (EQUAL value=staticContent)?
      )
    ;

/* *** Rules for primitiveType.   *** */

primitiveType:
      builtinType
    | enumType
    | datatypeDecl
    ;

builtinType:
    PRIMITIVE name=Identifier SEMICOLON
    ;

// --- Enumerations.   ---
enumType:
    ENUM name=Identifier COLON values+=enumItem (PIPE values+=enumItem)+
    SEMICOLON
    ;

enumItem:
    key=Identifier EQUAL value=staticContent
    ;

// --- Constrained type.   ---
/* Regular expression that is composed from lexer-like rules.   */
datatypeDecl:
    DATATYPE name=datatypeName COLON
    constrainedString
    ;

datatypeName: Identifier;

/* *** Rules for keywords declaration, just aliases for static strings.   *** */

keywordsDecl:
    KEYWORDS name=Identifier COLON keyword (COMMA keyword)*
    SEMICOLON
    ;

keyword:
    name=keywordName EQUAL value=literal
    ;

keywordName:
    Identifier
    ;

/* *** Rules for fragment declaration, used by datatypeDecl.   *** */

/* Regular expression fragment referenced by datatypeDecl.   */
fragmentDecl:
    FRAGMENT fragmentName COLON
    constrainedString
    ;

fragmentName:
    name=Identifier
    ;

constrainedString:
    alternatives+=fragmentAlt (PIPE alternatives+=fragmentAlt)*
    SEMICOLON
    ;

fragmentAlt:
    elements+=fragmentElement*
    ;

fragmentElement:
      fragmentAtom ebnfSuffix?
    | fragmentBlock ebnfSuffix?
    ;

fragmentBlock:
    LPAREN
    alternatives+=fragmentAlt (PIPE alternatives+=fragmentAlt)*
    RPAREN
    ;

fragmentAtom:
      staticContent
    | datatypeName
    | charSet
    | DOT
    ;

charSet:
    LSBRACKET (~(']' | '\\') | '\\' .)+ RSBRACKET
    ;

ebnfSuffix
	:	QUESTION QUESTION?
  	|	STAR QUESTION?
   	|	PLUS QUESTION?
	;

/* *** Utility rules.   *** */

literal:
      StringLiteral
    | NumericLiteral
    ;

staticContent:
    literal | keywordName
    ;

// End.
