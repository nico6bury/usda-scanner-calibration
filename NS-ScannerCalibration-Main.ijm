/*
 * Author: Nicholas Sixbury
 * File: NS-ScannerCalibration-Main.ijm
 * Purpose: To serve as the main coordinator macro for all the
 * processes required doing scanner calibration stuff.
 */
desiredIndices = newArray(15,14,13,2,12,20,22);
desiredIndicesCorrespondingNames = newArray("Red","Green","Blue","Tan","Gold","Gray2","Gray4");
open(File.openDialog("Please select right-side-up image of color checker."));
// set everything to do stuff in pixels
run("Set Scale...", "distance=0 known=0 unit=pixel");
makeBackup("calibration");

// figure out size of image so we can determine sizing
imgWidth = -1; imgHeight = -1; temp = -1;
getDimensions(imgWidth, imgHeight, temp, temp, temp);
// rough percent area that a single square takes up, as decimal
singleSquarePercent = 0.025;
totalImgArea = imgWidth * imgHeight;
// set size limit slightly under expected square size to catch everything we want
sizeLimit = totalImgArea * singleSquarePercent * 0.9;

// do normal thresholding
run("8-bit");
setThreshold(60, 255);
// get all the squares in the roi manager
run("Analyze Particles...", "size=sizeLimit-Infinity exclude clear include add");

// open back original image with new rois defined
openBackup("calibration", true);
// make sure the rois show up
setOption("Show All", true);

// make sure that roi are same size
roiShrinkageAmount = 50;
for(i = 0; i < roiManager("count"); i++){
	roiManager("select", i);
	// make roi smaller by a little bit
	shrinkRoi(roiShrinkageAmount);
}//end looping over all the rois

// loop variables to help us later
roiManager("select", 0);
lastBounds = getRoiBounds();
yTolPix = 50;
curGroup = 1;
// make sure that roi on same row are at same y
for(i = 0; i < roiManager("count"); i++){
	roiManager("select", i);
	curBounds = getRoiBounds();
	// if close to last one, then set same y
	if(abs(lastBounds[1] - curBounds[1]) < yTolPix){
		makeRectangle(curBounds[0], lastBounds[1], lastBounds[2], lastBounds[3]);
		roiManager("update");
	}//end if these are on the same row
	else{
		curGroup++;
	}//end else we need to set up for next row group
	// also set group
	roiManager("select", i);
	Roi.setGroup(curGroup);
	// update loop variable
	lastBounds = getRoiBounds();
}//end looping over the indices to process

// mess around with the roi manager in order to force it to re-sort and rename the rois
roiManager("deselect");
preCount = roiManager("count");
roiManager("combine");
roiManager("split");
roiManager("select", Array.getSequence(preCount));
roiManager("delete");

// go ahead and try to get the measurements we want
rgbResults = "rgbResults";
labResults = "labResults";
hsbResults = "hsbResults";
run("Set Measurements...", "mean standard modal min median display redirect=None decimal=2");
// try and get RGB measurements first
for(i = 0; i < lengthOf(desiredIndices); i++){
	roiManager("select", desiredIndices[i]-1);
	run("Duplicate...", "title=" + desiredIndicesCorrespondingNames[i]);
	run("RGB Stack");
	run("Measure Stack...");
	close();
}//end looping over indices to measure
// rename results window with RGB to descriptive name
IJ.renameResults(rgbResults);
// try and get L*a*b* measurements next
for(i = 0; i < lengthOf(desiredIndices); i++){
	roiManager("select", desiredIndices[i]-1);
	run("Duplicate...", "title=" + desiredIndicesCorrespondingNames[i]);
	run("Lab Stack");
	run("Measure Stack...");
	close();
}//end looping over indices to measure
// rename results window with Lab to descriptive name
IJ.renameResults(labResults);
// try and get hsb measurements next
for(i = 0; i < lengthOf(desiredIndices); i++){
	roiManager("select", desiredIndices[i]-1);
	run("Duplicate...", "title=" + desiredIndicesCorrespondingNames[i]);
	run("HSB Stack");
	run("Measure Stack...");
	close();
}//end looping over indices to measure
// rename results window with Lab to descriptive name
IJ.renameResults(hsbResults);

// close everything down
close("*");
run("Close All");
roiManager("reset");
if(isOpen("ROI Manager")){selectWindow("ROI Manager"); run("Close");}

//////////////////////////////////////////////////////////////////
/////////////////////// END OF MAIN FUNCTION /////////////////////
////////////////// HELPER FUNCTIONS FROM HERE ON /////////////////
//////////////////////////////////////////////////////////////////

/*
 * Subtracts n from selected roi
 * height and weight while keeping it centered
 */
function shrinkRoi(n){
	roiBounds = getRoiBounds();
	roiBounds[0] = roiBounds[0] + (n / 2);
	roiBounds[1] = roiBounds[1] + (n / 2);
	roiBounds[2] = roiBounds[2] - n;
	roiBounds[3] = roiBounds[3] - n;
	makeRectangle(roiBounds[0],roiBounds[1],roiBounds[2],roiBounds[3]);
	roiManager("update");
}//end shrinkRoi(n)

function getRoiBounds(){
	x = -1; y = -1; w = -1; h = -1;
	Roi.getBounds(x, y, w, h);
	return newArray(x,y,w,h);
}//end getRoiBounds()

/*
 * 
 */
function makeBackup(appendation){
	// make backup in temp folder
	// figure out the folder path
	backupFolderDir = getDirectory("temp") + "imageJMacroBackup" + 
	File.separator;
	File.makeDirectory(backupFolderDir);
	backupFolderDir += "HVAC" + File.separator;
	// make sure the directory exists
	File.makeDirectory(backupFolderDir);
	// make file path
	filePath = backupFolderDir + "backupImage-" + appendation + ".tif";
	// save the image as a temporary image
	save(filePath);
}//end makeBackup()

/*
 * 
 */
function openBackup(appendation, shouldClose){
	// closes active images and opens backup
	// figure out the folder path
	backupFolderDir = getDirectory("temp") + "imageJMacroBackup" + 
	File.separator + "HVAC" + File.separator;
	// make sure the directory exists
	File.makeDirectory(backupFolderDir);
	// make file path
	filePath = backupFolderDir + "backupImage-" + appendation + ".tif";
	// close whatever's open
	if(shouldClose == true) close("*");
	// open our backup
	open(filePath);
}//end openBackup
