Date:       May 5th, 2014

Description:  This package contains the files for the Iterative 
Digital Volume Correlation algorithm 

Bar-Kochba E., Toyjanova J., Andrews E., Kim K., Franck C. (2014) A fast 
iterative digital volume correlation algorithm for large deformations. 
Experimental Mechanics. doi: 10.1007/s11340-014-9874-2

The main example file to see how the package runs is exampleRunFile.m.

NOTE: To run you need a compatible C compiler. Please see
(http://www.mathworks.com/support/compilers/R2014a/index.html)

Files: 

Main files:
addDisplacements.m
checkConvergenceSSD.m
DVC.m
filterDisplacements.m
funIDVC.m
IDVC.m
removeOutliers.m
volumeMapping.m

Example run files:
exampleRunFile.m
vol00.mat
vol01.mat 

File from the MATLAB file exchange:
gridfit.m
inpaint_nans.m
inpaint_nans3.m
mirt3D_mexinterp.cpp
mirt3D_mexinterp.m
mirt3D_mexinterp.mexw64

History:    1.00 - Release

Bugs:       For Mac computers users ( resolved by Dan Midgett -  doctorate student in Mechanical Engineering at Johns Hopkins University in Dr. Vicky Nguyen's lab. ).

Error 1:

After the first waitbar had nearly finished I got this error when matlab tried to run the mex() command in mirt3D_mexinterp.m:

-------
Current file: vol01.mat
xcodebuild: error: SDK "macosx10.7" cannot be located.
xcrun: error: unable to find utility "clang++", not a developer tool or in PATH

    mex: compile of ' "/Users/dmidgett3/Documents/MATLAB/z Matlab DVC Codes/FIDVC/mirt3D_mexinterp.cpp"' failed.

Unable to complete successfully.

Error in mirt3D_mexinterp (line 37)
mex(pathtofile,'-outdir',pathstr);?
-------

This I was able to circumvent by manually editing: edit([matlabroot '/bin/mexopts.sh']). The mac matlab version currently has an issue with the mex() commands if you are running 10.8 or 10.9 the latest versions of the OSX, though the exact definition of the issue varies with the version of matlab, Xcode, and OSX being used. Mine was fixed by manually changing all the 'macosx10.7' lines to 'macosx10.9' (I have mavericks) and importing the new file with mex -setup. If any other user has this issue this workaround might work for them as well so I was letting you know. Older versions of OS or a different compiler might not have this issue, it mainly seemed to be a problem with Mavericks, the newest OSX as the shell file is not automatically formatted correctly. 

Error 2: 

Came from the mirt3D_mexinterp.cpp, the second line. 
--------
Current file: vol01.mat
In file included from /Users/dmidgett3/Documents/MATLAB/z Matlab DVC Codes/FIDVC/mirt3D_mexinterp.cpp:32:
In file included from /Applications/MATLAB_R2013b.app/extern/include/mex.h:58:
In file included from /Applications/MATLAB_R2013b.app/extern/include/matrix.h:252:
/Applications/MATLAB_R2013b.app/extern/include/tmwtypes.h:831:9: error: 
      unknown type name 'char16_t'
typedef char16_t CHAR16_T;
        ^
1 error generated. 

    mex: compile of ' "/Users/dmidgett3/Documents/MATLAB/z Matlab DVC Codes/FIDVC/mirt3D_mexinterp.cpp"' failed.
---------

For some reason it had a problem including mex.h and complained about a type definition it didn't understand: 'char16_t'. The following 2 lines added before the #include lines fixed this problem by telling the file how to treat char16_t: 

#include <stdint.h>
typedef uint16_t char16_t;



