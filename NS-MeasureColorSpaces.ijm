/*
 * Author: Nicholas Sixbury
 * File: NS-MeasureColorSpaces.ijm
 * Purpose: To convert each color square to a color stack and get
 * measurements on the output color of each color square.
 * 
 * Explanation of Parameter Passing: Each serialized parameter should be
 * separated by the \r character. For each parameter, it should be the name
 * followed by the value, separated by the ? character. Parameters not given
 * will simply use the default, but it is a best practive to specify things
 * in case the default happens to change. When sending a parameter that is
 * a list, separate each list item by the \f character.
 * 
 * Pre-Execution Contract: This macro assumes that before being executed,
 * there does not exist an open window titled Results. If you want to run
 * this macro when the results window is open, it is recommended to either
 * close the window or rename it (possibly renaming it back to Results after
 * this macro has finished). It also assumes that 0-3 result windows are open
 * with names specified in the macro parameters.
 * 
 * Post-Execution Contract: When this macro exits, a new window will have
 * been created from the two input windows. It will contain the following
 * columns (unless I update something and forget to fix this comment): 
 * Scanner, ColorSquare, ColorSpace, ColorSlice, Mean, StdDev
 * 
 * Parameters that can be set in headless execution mode:
 * rgbResultsName : name of window with RGB results
 * labResultsName : name of window with L*a*b* results
 * hsbResultsName : name of window with HSB results
 * disableRGB : If true, will not process RGB
 * disableLab : If true, will not process Lab
 * disableHSB : If true, will not process HSB
 * measurementsConfig : The parameter passed to set measurements.
 * desiredIndices : An array of 0-based indices of color squares to measure.
 * desiredIndicesCorrespondingNames : A parallel array to desiredIndices which
 * holds a name for each indice. Something like Grayscale4 or Red.
 */

/// just a few useful variables for later
rgbResultsName = "rgbResults";
labResultsName = "labResults";
hsbResultsName = "hsbResults";
disableRGB = false;
disableLab = false;
disableHSB = false;
measurementsConfig = "mean standard modal min median display redirect=None decimal=2";
desiredIndices = newArray(18,19,20,21,22,23);
desiredIndicesCorrespondingNames = newArray("Grayscale1","Grayscale2","Grayscale3","Grayscale4","Grayscale5","Grayscale6");

serializedArguments = getArgument();
if(lengthOf(serializedArguments) == 0){
	exit("Dialog mode not supported. Call with arguements.");
}//end if we don't have arguments to read
else{
	// automatically set batch mode to true
	//useBatchMode = true;
	// parse out parameters from arguementSerialized
	linesToProcess = split(serializedArguments, "\r");
	for(i = 0; i < lengthOf(linesToProcess); i++){
		thisLine = split(linesToProcess[i], "?");
		if(thisLine[0] == "measurementsConfig"){
			measurementsConfig = thisLine[1];
		}//end if this line contains config for set measurements
		else if(thisLine[0] == "desiredIndices"){
			tempStrArr = split(thisLine[1], "\f");
			desiredIndices = newArray(lengthOf(tempStrArr));
			for(j = 0; j < lengthOf(tempStrArr); j++){
				desiredIndices[j] = parseInt(tempStrArr[j]);
			}//end converting each index from string to int
		}//end if this line has desiredIndices
		else if(thisLine[0] == "desiredIndicesCorrespondingNames"){
			desiredIndicesCorrespondingNames = split(thisLine[1], "\f");
		}//end if this line has desiredIndicesCorrespondingNames
		else if(thisLine[0] == "rgbResultsName"){
			rgbResultsName = thisLine[1];
		}//end if this line contains main summary name
		else if(thisLine[0] == "labResultsName"){
			labResultsName = thisLine[1];
		}//end if this line contains lab results name
		else if(thisLine[0] == "hsbResultsName"){
			hsbResultsName = thisLine[1];
		}//end if this line gives us the number of files that were processed
		else if(thisLine[0] == "disableRGB"){
			disableRGB = parseInt(thisLine[1]);
		}//end if this line tells us whether to disable RGB
		else if(thisLine[0] == "disableLab"){
			disableLab = parseInt(thisLine[1]);
		}//end if this line tells us whether to disable Lab
		else if(thisLine[0] == "disableHSB"){
			disableHSB = parseInt(thisLine[1]);
		}//end if this line tells us whether to disable HSB
	}//end looping over lines to be deserialized
}//end else we need to parse the arguments we've been given

// go ahead and try to get the measurements we want
run("Set Measurements...", measurementsConfig);
// try and get RGB measurements first
if(!disableRGB){
	for(i = 0; i < lengthOf(desiredIndices); i++){
		roiManager("select", desiredIndices[i]);
		run("Duplicate...", "title=" + desiredIndicesCorrespondingNames[i]);
		run("RGB Stack");
		run("Measure Stack...");
		close();
	}//end looping over indices to measure
	// rename results window with RGB to descriptive name
	IJ.renameResults(rgbResultsName);
}//end if we're processing RGB
// try and get L*a*b* measurements next
if(!disableLab){
	for(i = 0; i < lengthOf(desiredIndices); i++){
		roiManager("select", desiredIndices[i]);
		run("Duplicate...", "title=" + desiredIndicesCorrespondingNames[i]);
		run("Lab Stack");
		run("Measure Stack...");
		close();
	}//end looping over indices to measure
	// rename results window with Lab to descriptive name
	IJ.renameResults(labResultsName);
}//end if we're processing Lab
// try and get hsb measurements next
if(!disableHSB){
	for(i = 0; i < lengthOf(desiredIndices); i++){
		roiManager("select", desiredIndices[i]);
		run("Duplicate...", "title=" + desiredIndicesCorrespondingNames[i]);
		run("HSB Stack");
		run("Measure Stack...");
		close();
	}//end looping over indices to measure
	// rename results window with Lab to descriptive name
	IJ.renameResults(hsbResultsName);
}//end if we're processing HSB

//////////////////////////////////////////////////////////////////
/////////////////////// END OF MAIN FUNCTION /////////////////////
////////////////// HELPER FUNCTIONS FROM HERE ON /////////////////
//////////////////////////////////////////////////////////////////

