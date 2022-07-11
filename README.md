# usda-scanner-calibration
An attempt to use ImageJ for calibration of EPSON scanners. 

## Directory Requirements

Requires the macro file to be in directory ~/Fiji.app/macros/usda-scanner-calibration/.
This is required in order to locate sub macros due to current language limitations of the imagej macro language. Also, Fiji.app needs to be in the home directory of the current user.

## How to Run

In order to run this macro the conventional way, open ImageJ. Then, navigate in the menus Plugins > Macros > Edit. From here, you'll want to open NS-ScannerCalibration-Main.ijm in order to run the main program.
When running the macro, you will immediately be asked to select a file. Select a scanned image of a color checker classic (CCC) which is right side up, such that the grayscale squares are at the bottom.
