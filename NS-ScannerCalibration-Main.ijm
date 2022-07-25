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
resultsFormatPath = thisMacroDir + "NS-ResultsFormatter.ijm";
// some surprise variables that will help us later
measurementsConfig = "mean standard modal min median display redirect=None decimal=2";
desiredIndices = newArray(18,19,20,21,22,23);
desiredIndicesCorrespondingNames = newArray("Grayscale1","Grayscale2","Grayscale3","Grayscale4","Grayscale5","Grayscale6");

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
measureColorParams = String.join(newArray(
String.join(newArray("measurementsConfig", measurementsConfig), "?"),
String.join(newArray("desiredIndices", String.join(desiredIndices, "\f")), "?"),
String.join(newArray("desiredIndicesCorrespondingNames", String.join(desiredIndicesCorrespondingNames, "\f")), "?"),
String.join(newArray("rgbResultsName", "rgbResults"), "?"),
String.join(newArray("labResultsName", "labResults"), "?"),
String.join(newArray("hsbResultsName", "hsbResults"), "?"),
String.join(newArray("disableRGB", "0"), "?"),
String.join(newArray("disableLab", "0"), "?"),
String.join(newArray("disableHSB", "1"), "?")
), "\r");
runMacro(measureColorPath, measureColorParams);

// run the results formatter
resultsFormatParams = String.join(newArray(
String.join(newArray("fullResultsName","fullResultsName"), "?"),
String.join(newArray("rgbResultsName", "rgbResults"), "?"),
String.join(newArray("labResultsName", "labResults"), "?"),
String.join(newArray("hsbResultsName", "hsbResults"), "?"),
String.join(newArray("scannerName", "v600"), "?"),
String.join(newArray("disableRGB", "0"), "?"),
String.join(newArray("disableLab", "0"), "?"),
String.join(newArray("disableHSB", "1"), "?"),
String.join(newArray("nColorSquares", "6"), "?")
), "\r");
runMacro(resultsFormatPath, resultsFormatParams);

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
