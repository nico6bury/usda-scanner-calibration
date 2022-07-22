/*
 * Author: Nicholas Sixbury
 * File: NS-ResultsFormatter.ijm
 * Purpose: To post-process results tables 
 * in order to make things easier to display 
 * and/or export to excel.
 * 
 * Explanation of Parameter Passing: Each serialized parameter should be
 * separated by the \r character. For each parameter, it should be the name
 * followed by the value, separated by the ? character. Parameters not given
 * will simply use the default, but it is a best practive to specify things
 * in case the default happens to change.
 * 
 * Pre-Execution Contract: This macro assumes that before being executed,
 * there does not exist an open window titled Results. If you want to run
 * this macro when the results window is open, it is recommended to either
 * close the window or rename it (possibly renaming it back to Results after
 * this macro has finished). It also assumes that two result windows are open
 * with names specified in the macro parameters.
 * 
 * Post-Execution Contract: When this macro exits, a new window will have
 * been created from the two input windows. It will contain the following
 * columns (unless I update something and forget to fix this comment): 
 * Scanner, ColorSquare, ColorSpace, ColorSlice, Mean, StdDev
 * 
 * Parameters that can be set in headless execution mode:
 * fullResultsName : the name we'll call the window with all final results
 * rgbResultsName : name of window with RGB results
 * labResultsName : name of window with L*a*b* results
 * hsbResultsName : name of window with HSB results
 * scannerName : the name of the scanner that processed image for results
 * disableRGB : If true, will not process RGB
 * disableLab : If true, will not process Lab
 * disableHSB : If true, will not process HSB
 * nColorSquares : The number of Color Squares processed for the data
 */

/// just a few useful variables for later
fullResultsName = "fullResults";
rgbResultsName = "rgbResults";
labResultsName = "labResults";
hsbResultsName = "hsbResults";
scannerName = "NameNotSet";
disableRGB = false;
disableLab = false;
disableHSB = false;
nColorSquares = 0;

serializedArguments = getArgument();
if(lengthOf(serializedArguments) == 0){
	exit("Dialog mode not supported. Call with arguements.");
	/*
	Dialog.create(" Macro Options ???");
	Dialog.addString("Main Summary Name", mainSummaryName, 15);
	Dialog.addString("L*a*b* Results Name", labResultsName, 15);
	Dialog.addNumber("Number of Files Processed", nFilesProcessed);
	Dialog.addCheckbox("Separate Samples", separateRows);
	Dialog.show();
	mainSummaryName = Dialog.getString();
	labResultsName = Dialog.getString();
	nFilesProcessed = Dialog.getNumber();
	*/
}//end if we don't have arguments to read
else{
	// automatically set batch mode to true
	//useBatchMode = true;
	// parse out parameters from arguementSerialized
	linesToProcess = split(serializedArguments, "\r");
	for(i = 0; i < lengthOf(linesToProcess); i++){
		thisLine = split(linesToProcess[i], "?");
		if(thisLine[0] == "rgbResultsName"){
			rgbResultsName = thisLine[1];
		}//end if this line contains main summary name
		else if(thisLine[0] == "labResultsName"){
			labResultsName = thisLine[1];
		}//end if this line contains lab results name
		else if(thisLine[0] == "hsbResultsName"){
			hsbResultsName = thisLine[1];
		}//end if this line gives us the number of files that were processed
		else if(thisLine[0] == "separateRows"){
			separateRows = parseInt(thisLine[1]);
		}//end if this line tells us whether we should separate certain rows
		else if(thisLine[0] == "columnSplit"){
			//columnSplit = thisLine[1];
		}//end if this line tells us what column we should separate by
		else if(thisLine[0] == "disableRGB"){
			disableRGB = parseInt(thisLine[1]);
		}//end if this line tells us whether to disable RGB
		else if(thisLine[0] == "disableLab"){
			disableLab = parseInt(thisLine[1]);
		}//end if this line tells us whether to disable Lab
		else if(thisLine[0] == "disableHSB"){
			disableHSB = parseInt(thisLine[1]);
		}//end if this line tells us whether to disable HSB
		else if(thisLine[0] == "fullResultsName"){
			fullResultsName = thisLine[1];
		}//end if this line contains the name for full results window
		else if(thisLine[0] == "scannerName"){
			scannerName = thisLine[1];
		}//end if this line contains the name of the scanner
		else if(thisLine[0] == "nColorSquares"){
			nColorSquares = parseInt(thisLine[1]);
		}//end if this line contains the number of color squares processed
	}//end looping over lines to be deserialized
}//end else we need to parse the arguments we've been given

// strip results from given windows in order to use it in processing.
rgbResults = false;
labResults = false;
hsbResults = false;
if(!disableRGB){
	selectWindow(rgbResultsName);
	IJ.renameResults(rgbResultsName,"Results");
	String.copyResults;
	// note: lines separated by \n, columns by \t, first column is space
	rgbResults = split(String.paste, "\n");
	run("Close");
}//end if we're doing RGB stuff
if(!disableLab){
	selectWindow(labResultsName);
	IJ.renameResults(labResultsName,"Results");
	String.copyResults;
	labResults = split(String.paste, "\n");
	run("Close");
}//end if we're doing Lab stuff
if(!disableHSB){
	selectWindow(hsbResultsName);
	IJ.renameResults(hsbResultsName,"Results");
	String.copyResults;
	hsbResults = split(String.paste, "\n");
	run("Close");
}//end if we're doing HSB stuff

// create the table we'll use for displaying everything
Table.create(fullResultsName);

// figure out column indices before we start iteration

rgbColumns = false;
labColumns = false;
hsbColumns = false;

ttiv = 0; // next index in table to put stuff in

// add all the non-disabled results to the full table we're making

if(!disableRGB){
	rgbColumns = split(rgbResults[0], "\t");
	meanIndex = arrayIndexOf(rgbColumns, "Mean");
	sdevIndex = arrayIndexOf(rgbColumns, "StdDev");
	// make sure we have the right window selected
	selectWindow(fullResultsName);
	for(i = 0; i < (nColorSquares * 3); i++){
		// get lines from this table split up for east use
		thisLine = split(rgbResults[i+1], "\t");
		// add the scanner to this line
		Table.set("Scanner", ttiv, scannerName);
		// figure out color square and color slice
		slicedSquare = split(thisLine[1], ":");
		colorSquare = slicedSquare[0];
		colorSlice = slicedSquare[1];
		// do color columns
		Table.set("ColorSquare", ttiv, colorSquare);
		Table.set("ColorSpace", ttiv, "RGB");
		Table.set("ColorSlice", ttiv, colorSlice);
		// add normal data columns
		Table.set("Mean", ttiv, thisLine[meanIndex]);
		Table.set("StdDev", ttiv, thisLine[sdevIndex]);
		// update table index variable
		ttiv++;
	}//end adding all RGB results to full table
}//end if we're doing RGB
if(!disableLab){
	labColumns = split(labResults[0], "\t");
	meanIndex = arrayIndexOf(labColumns, "Mean");
	sdevIndex = arrayIndexOf(labColumns, "StdDev");
	// make sure we have the right window selected
	selectWindow(fullResultsName);
	for(i = 0; i < (nColorSquares * 3); i++){
		// get lines from this table split up for east use
		thisLine = split(labResults[i+1], "\t");
		// add the scanner to this line
		Table.set("Scanner", ttiv, scannerName);
		// figure out color square and color slice
		slicedSquare = split(thisLine[1], ":");
		colorSquare = slicedSquare[0];
		colorSlice = slicedSquare[1];
		// do color columns
		Table.set("ColorSquare", ttiv, colorSquare);
		Table.set("ColorSpace", ttiv, "Lab");
		Table.set("ColorSlice", ttiv, colorSlice);
		// add normal data columns
		Table.set("Mean", ttiv, thisLine[meanIndex]);
		Table.set("StdDev", ttiv, thisLine[sdevIndex]);
		// update table index variable
		ttiv++;
	}//end adding all Lab results to full table
}//end if we're doing Lab
if(!disableHSB){
	hsbColumns = split(hsbResults[0], "\t");
	meanIndex = arrayIndexOf(hsbColumns, "Mean");
	sdevIndex = arrayIndexOf(hsbColumns, "StdDev");
	// make sure we have the right window selected
	selectWindow(fullResultsName);
	for(i = 0; i < (nColorSquares * 3); i++){
		// get lines from this table split up for east use
		thisLine = split(hsbResults[i+1], "\t");
		// add the scanner to this line
		Table.set("Scanner", ttiv, scannerName);
		// figure out color square and color slice
		slicedSquare = split(thisLine[1], ":");
		colorSquare = slicedSquare[0];
		colorSlice = slicedSquare[1];
		// do color columns
		Table.set("ColorSquare", ttiv, colorSquare);
		Table.set("ColorSpace", ttiv, "HSB");
		Table.set("ColorSlice", ttiv, colorSlice);
		// add normal data columns
		Table.set("Mean", ttiv, thisLine[meanIndex]);
		Table.set("StdDev", ttiv, thisLine[sdevIndex]);
		// update table index variable
		ttiv++;
	}//end adding all HSB results to full table
}//end if we're doing HSB


function arrayIndexOf(array, value){
	
	for(i = 0; i < lengthOf(array); i++){
		if(array[i] == value){
			return i;
		}
	}
	return -1;
}
