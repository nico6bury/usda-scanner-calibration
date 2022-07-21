/*
 * Author: Nicholas Sixbury
 * File: NS-ColorSquareRoiCreation.ijm
 * Purpose: To use thresholding and particle analysis to find the location of
 * all (or most) of the color squares present on the current image of a color card.
 */


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

//////////////////////////////////////////////////////////////////
/////////////////////// END OF MAIN FUNCTION /////////////////////
////////////////// HELPER FUNCTIONS FROM HERE ON /////////////////
//////////////////////////////////////////////////////////////////

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
