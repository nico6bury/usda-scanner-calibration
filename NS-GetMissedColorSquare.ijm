/*
 * Author: Nicholas Sixbury
 * File: NS-GetMissedColorSquare.ijm
 * Purpose: This macro exists as a hardcoded fix for the current
 * color code and processing solution in order to add the completely
 * black color square to the roi manager, as it doesn't fit with the 
 * others otherwise.
 */


// add in the last square, the black ones
// TODO: Make this section not hardcoded and therefore less bad
selectBlackSquare = true;
if(selectBlackSquare == true){
	// get the index above the black square
	roiManager("select", 17);
	topBounds = getRoiBounds();
	// get the index to the left of the black square
	roiManager("select", 22);
	leftBounds = getRoiBounds();
	// create a selection from above bounds
	makeRectangle(topBounds[0], leftBounds[1], leftBounds[2], leftBounds[3]);
	// add this roi to the manager and name it to the right thing
	roiManager("add");
	// reset selection
	makeRectangle(0,0,0,0);
}//end if we're trying to select the black square

//////////////////////////////////////////////////////////////////
/////////////////////// END OF MAIN FUNCTION /////////////////////
////////////////// HELPER FUNCTIONS FROM HERE ON /////////////////
//////////////////////////////////////////////////////////////////

function getRoiBounds(){
	x = -1; y = -1; w = -1; h = -1;
	Roi.getBounds(x, y, w, h);
	return newArray(x,y,w,h);
}//end getRoiBounds()