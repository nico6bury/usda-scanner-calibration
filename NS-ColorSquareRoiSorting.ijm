/*
 * Author: Nicholas Sixbury
 * File: NS-ColorSquareRoiSorting.ijm
 * Purpose: To process and sort the current color square rois such
 * that they are in order according to their left to right, top to
 * bottom indexing. This is vital for figuring out which square is
 * supposed to be which.
 */


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