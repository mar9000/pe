# PE
Grammar and tools to describe a parser-based language with respect to projectional editing.

## Setup

With *Eclipse Luna SR2 for DSL developers* one should be able to import the project into Eclipse without problems.

## Introduction

Implementing languages can be repetitive with or without projectional editor.
PE aims to help implementing parser-based languages that one needs even when working with a language workbench
usually after the last model to model transformation. The last generated model are often relative to
concrete programming language and are translated to text.

When an AST is projected over the *text dimension* one has a set of possible results. PE describes only one
possible implementation of code formatting. I plan to introduce *styles* to generalize a little bit this point.

I tried to maintain PE not related to any particular language workbench but at the moment PE is utilized
only by [PE4MPS](https://github.com/mar9000/pe4mps "PE4MPS project") to import the generated AST into
[MPS](http://www.jetbrains.com/mps "MPS project").

## Getting started

Once the project has been imported into Eclipse you can:

  * run the test cases and learn how to parse `.pe` files, see *PEGrammarTest* launch.
  * recompile the lexer with *PE-compile-lexer* launch.
  * recompile the parser with *PE-compile-parser* launch.

Grammar files are under `grammars` and launch configurations generate code under `src-gen`.

Test cases are under `tests`, here one can find examples of the PE grammar. At the moment the `DOT.pe` is probably
the most complete one.

The parser parses PE files and generates AST described by the *ecore* model under `ecore`.

## Available features

In this first version is possible to describe:

  * the structure of the language AST, references are missing.
  * the projection of the AST over the *text dimension* from which to derive syntax, code completion and text generation.

Next language I'll probably implement will be Javascript and next aspect will be scopes handling.
