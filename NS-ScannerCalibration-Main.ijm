/*
 * Author: Nicholas Sixbury
 * File: NS-ScannerCalibration-Main.ijm
 * Purpose: To serve as the main coordinator macro for all the
 * processes required doing scanner calibration stuff.
 */

open(File.openDialog("Please select right-side-up image of color checker."));
// note down the paths of all the supporter macros
thisMacroDir = fixDirectory(getDirectory("macros"));
thisMacroDir = thisMacroDir + "usda-scanner-calibration" + File.separator;
roiCreationPath = thisMacroDir + "NS-ColorSquareRoiCreation.ijm";
roiSortingPath = thisMacroDir + "NS-ColorSquareRoiSorting.ijm";
missedRoiPath = thisMacroDir + "NS-GetMissedColorSquare.ijm";
measureColorPath = thisMacroDir + "NS-MeasureColorSpaces.ijm";

// put all the color squares into the roi manager
roiCreationParams = "";
runMacro(roiCreationPath, roiCreationParams);

// pre-process and sort all the rois
roiSortingParams = "";
runMacro(roiSortingPath, roiSortingParams);

// get that last black square that we missed earlier
missedRoiParams = "";
runMacro(missedRoiPath, missedRoiParams);

// get measurements on the different color spaces
measureColorParams = "";
runMacro(measureColorPath, measureColorParams);

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

function serializationDirectory(){
	// generates a directory for serialization
	macrDir = fixDirectory(getDirectory("macros"));
	macrDir += "Macro-Configuration/";
	File.makeDirectory(macrDir);
	macrDir += "FlourScanMacroConfig.txt";
	return macrDir;
}//end serializationDirectory()

/*
 * Fixes the directory issues present with all the directory
 * functions other than getDirectory("home"), which seems to
 * be inexplicably untouched and therefore used as a basis
 * for other directories.
 */
function fixDirectory(directory){
	homeDirectory = getDirectory("home");
	homeDirectory = substring(homeDirectory, 0, lengthOf(homeDirectory) - 1);
	username = substring(homeDirectory, lastIndexOf(homeDirectory, File.separator)+1);
	userStartIndex = indexOf(homeDirectory, username);
	userEndIndex = lengthOf(homeDirectory);
	
	firstDirPart = substring(directory, 0, userStartIndex);
	//print(firstDirPart);
	thirdDirPart = substring(directory, indexOf(directory, File.separator, lengthOf(firstDirPart)));
	//print(thirdDirPart);
	
	fullDirectory = firstDirPart + username + thirdDirPart;
	return fullDirectory;
}//end fixDirectory(directory)
