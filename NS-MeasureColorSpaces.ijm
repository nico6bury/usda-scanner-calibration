/*
 * Author: Nicholas Sixbury
 * File: NS-MeasureColorSpaces.ijm
 * Purpose: To convert each color square to a color stack and get
 * measurements on the output color of each color square.
 */
desiredIndices = newArray(18,19,20,21,22,23);
desiredIndicesCorrespondingNames = newArray("Grayscale1","Grayscale2","Grayscale3","Grayscale4","Grayscale5","Grayscale6");

// go ahead and try to get the measurements we want
rgbResults = "rgbResults";
labResults = "labResults";
hsbResults = "hsbResults";
run("Set Measurements...", "mean standard modal min median display redirect=None decimal=2");
// try and get RGB measurements first
for(i = 0; i < lengthOf(desiredIndices); i++){
	roiManager("select", desiredIndices[i]);
	run("Duplicate...", "title=" + desiredIndicesCorrespondingNames[i]);
	run("RGB Stack");
	run("Measure Stack...");
	close();
}//end looping over indices to measure
// rename results window with RGB to descriptive name
IJ.renameResults(rgbResults);
// try and get L*a*b* measurements next
for(i = 0; i < lengthOf(desiredIndices); i++){
	roiManager("select", desiredIndices[i]);
	run("Duplicate...", "title=" + desiredIndicesCorrespondingNames[i]);
	run("Lab Stack");
	run("Measure Stack...");
	close();
}//end looping over indices to measure
// rename results window with Lab to descriptive name
IJ.renameResults(labResults);
// try and get hsb measurements next
for(i = 0; i < lengthOf(desiredIndices); i++){
	roiManager("select", desiredIndices[i]);
	run("Duplicate...", "title=" + desiredIndicesCorrespondingNames[i]);
	run("HSB Stack");
	run("Measure Stack...");
	close();
}//end looping over indices to measure
// rename results window with Lab to descriptive name
IJ.renameResults(hsbResults);

//////////////////////////////////////////////////////////////////
/////////////////////// END OF MAIN FUNCTION /////////////////////
////////////////// HELPER FUNCTIONS FROM HERE ON /////////////////
//////////////////////////////////////////////////////////////////

