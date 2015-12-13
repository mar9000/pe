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
package org.mar9000.pegrammar.test;

import static org.junit.Assert.*;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;

import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.ParseTreeWalker;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;
import org.mar9000.pe.PEASTListener;
import org.mar9000.pe.PELexer;
import org.mar9000.pe.PEParser;
import org.mar9000.pe.PESymbolsListener;
import org.mar9000.pe.ecore.PELanguage;
import org.stringtemplate.v4.ST;
import org.stringtemplate.v4.STGroupFile;

/**
 * Main test class for the PE grammar.
 * It reads .pe files from the test directory.
 */
@RunWith(value=Parameterized.class)
public class PEGrammarTest {
	
	private static final String TESTS_DIR = "tests";
	private static final String TEST_EXT = ".pe";
	private static final String RESULT_EXT = ".ast";
	private static final String DISABLED_EXT = ".disabled";
	private static final String ST_GROUP_FILE = "templates/pe.stg";
	private static final String ST_MAIN_TEMPLATE = "language";
	
	/**
	 * Test name comes from the name of the input file.
	 */
	@Parameters(name="{0}")
	public static Collection<String[]> getTestParameters() {
		ArrayList<String[]> inoutPairs = new ArrayList<String[]>();
		try {
			File templateDir = new File(TESTS_DIR);
			if (!templateDir.isDirectory()) {
				return null;
			}
			addTestsFrom(templateDir, inoutPairs);
		} catch (Exception e) {
			e.printStackTrace();
		}
		// Sort tests.
		Collections.sort(inoutPairs, new Comparator<String[]>() {
			@Override
			public int compare(String[] item1, String[] item2) {
				return item1[0].compareTo(item2[0]);
			}
		});
		return inoutPairs;
	}
	
	// Constructor and internal fields.
	
	private String filename;
	private String sourceInput;
	private String resultOutput;
	
	public PEGrammarTest(String filename, String sourceInput, String resultOutput) {
		this.filename = filename;
		this.sourceInput = sourceInput;
		this.resultOutput = resultOutput;
	}
	
	// Parameterized test.
	@Test
	public void testInOut() throws Exception {
		System.out.println("Test " + filename);
		
		// Construct the syntax tree and check for errors.
		ANTLRInputStream input = new ANTLRInputStream(sourceInput);
		PELexer lexer = new PELexer(input);
		CommonTokenStream tokens = new CommonTokenStream(lexer);
		PEParser parser = new PEParser(tokens);
		ParseTree tree = parser.language();
		if (parser.getNumberOfSyntaxErrors() > 0) {
			throw new Exception("Syntax error in test " + filename);
		}
		
		// Construct symbol table and scope (simple global scope).
		PESymbolsListener symbolsListener = new PESymbolsListener();
		ParseTreeWalker walker = new ParseTreeWalker();
		walker.walk(symbolsListener, tree);
		
		// Construct the AST.
		PEASTListener astListener = new PEASTListener(symbolsListener.getGlobalScope());
		walker.walk(astListener, tree);
		PELanguage languageAST = astListener.getPELanguage();
		
		// Check the result.
		STGroupFile languageStg = new STGroupFile(ST_GROUP_FILE);
		ST languageTemplate = languageStg.getInstanceOf(ST_MAIN_TEMPLATE);
		languageTemplate.add("l", languageAST);
		assertEquals(resultOutput, languageTemplate.render());
	}
	
	// Utilities.
	
	/**
	 * Add all tests from the given directory, does not consider disabled tests.
	 * Recursively add all subdirectory tests.
	 */
	private static void addTestsFrom(File templateDir, ArrayList<String[]> inoutPairs)
	throws Exception {
		File[] files = templateDir.listFiles();
		for (int f = 0; f < files.length; f++) {
			// It's a dir?
			if (files[f].isDirectory() && !files[f].getName().endsWith(DISABLED_EXT)) {
				addTestsFrom(files[f], inoutPairs);
			} else if (files[f].getName().endsWith(TEST_EXT)) {
				String filename = files[f].getName();
				/* Used to test only a smaller subset of tests.
				if (!filename.contains("abc"))
					continue;
				*/
				String path = files[f].getAbsolutePath();
				String dir = path.substring(0, path.lastIndexOf("/"));
				String ext = filename.substring(filename.lastIndexOf("."));
				// Try RESULT_EXT .
				String resultFilename = dir + "/" + filename.substring(0, filename.length()-ext.length())
						+ RESULT_EXT;
				File resultFile = new File(resultFilename);
				if (!resultFile.isFile()) {
					System.err.println(resultFilename + " not found.");
					continue;
				}
				String[] test = new String[3];
				test[0] = files[f].getName();
				test[1] = readFileAsString(files[f].getAbsolutePath()) + "\n";
				test[2] = readFileAsString(resultFile.getAbsolutePath());
				inoutPairs.add(test);
			}
		}
	}
	
	private static String readFileAsString(String filePath) throws IOException {
		StringBuffer fileData = new StringBuffer();
		BufferedReader reader = new BufferedReader(
				new FileReader(filePath));
		char[] buf = new char[1024];
		int numRead=0;
		while((numRead=reader.read(buf)) != -1){
			String readData = String.valueOf(buf, 0, numRead);
			fileData.append(readData);
		}
		reader.close();
		return fileData.toString();
	}
	
}
