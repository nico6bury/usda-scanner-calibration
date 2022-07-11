/*
 * Author: Nicholas Sixbury
 * File: NS-ScannerCalibration-Main.ijm
 * Purpose: To serve as the main coordinator macro for all the
 * processes required doing scanner calibration stuff.
 */
desiredIndices = newArray(13,14,15,2,12,20,22);
desiredIndicesCorrespondingNames = newArray("Blue","Green","Red","Tan","Gold","Gray2","Gray4");
open("C:\\Users\\nicholas.sixbury/Desktop\\Samples\\Calibration Stuff\\2022-July-NS-ColorCalibration\\2022-June-FlourScanSettings\\V600\\ColorCheckerClassic001.tif");
// set everything to do stuff in pixels
run("Set Scale...", "distance=0 known=0 unit=pixel");
makeBackup("calibration");

// do normal thresholding
run("8-bit");
setThreshold(60, 255);
// get all the squares in the roi manager
run("Analyze Particles...", "size=100000-Infinity exclude clear include add");

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
run("Set Measurements...", "mean standard modal min median display redirect=None decimal=2");
// try and get RGB measurements first
for(i = 0; i < lengthOf(desiredIndices); i++){
	roiManager("select", desiredIndices[i]-1);
	run("Duplicate...", "title=" + desiredIndicesCorrespondingNames[i]);
	run("RGB Stack");
	run("Measure Stack...");
	close();
}//end looping over indices to measure

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

function getStats(){
	area = -1;
	mean = -1;
	min = -1;
	max = -1;
	std = -1;
	histogram = -1;
	getStatistics(area, mean, min, max, std, histogram);
}//end getStats()

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
