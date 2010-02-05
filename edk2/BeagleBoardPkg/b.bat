@REM Copyright (c) 2008 - 2010, Apple, Inc.  All rights reserved.
@REM All rights reserved. This program and the accompanying materials
@REM are licensed and made available under the terms and conditions of the BSD License
@REM which accompanies this distribution.  The full text of the license may be found at
@REM http://opensource.org/licenses/bsd-license.php
@REM
@REM THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
@REM WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.
@REM

@REM Example usage of this script. default is a DEBUG build
@REM b
@REM b clean
@REM b release 
@REM b release clean
@REM b -v -y build.log


CALL ..\edksetup.bat
SET TARGET_TOOLS=RVCT31
SET TARGET=DEBUG

@if /I "%1"=="RELEASE" (
  SET TARGET=RELEASE
  shift /1
)

SET BUILD_ROOT=%WORKSPACE%\Build\BeagleBoard\%TARGET%_%TARGET_TOOLS%
BUILD_ROOT=$WORKSPACE/Build/BeagleBoard/"$TARGET"_"$TARGET_TOOLS"

CALL build -p BeagleBoardPkg\BeagleBoardPkg.dsc -a ARM -t RVCT31 -b %TARGET% %1 %2 %3 %4 %5 %6 %7 %8

@if /I "%1"=="CLEAN" goto Clean

@REM
@REM Ram starts at 0x80000000
@REM OMAP 3530 TRM defines 0x80008208 as the entry point
@REM The reset vector is caught by the mask ROM in the OMAP 3530 so that is why this entry 
@REM point looks so strange. 
@REM OMAP 3430 TRM section 26.4.8 has Image header information. (missing in OMAP 3530 TRM)
@REM
cd Tools

ECHO Building tools...
CALL nmake 

ECHO Patching image with ConfigurationHeader.dat
CALL GenerateImage -D ConfigurationHeader.dat -E 0x80008208 -I ../../Build/FV/BEAGLEBOARD_EFI.fd -O ../../Build/FV/BeagleBoard_EFI_flashboot.fd

ECHO Patching ..\Debugger_scripts ...
SET DEBUGGER_SCRIPT=..\Debugger_scripts
for /f %%a IN ('dir /b %DEBUGGER_SCRIPT%\*.inc %DEBUGGER_SCRIPT%\*.cmm') do (
  CALL replace %DEBUGGER_SCRIPT%\%%a %BUILD_ROOT%\%%a ZZZZZZ %BUILD_ROOT% WWWWWW  %WORKSPACE%
)

cd ..
EXIT /B

:Clean
cd Tools
CALL nmake clean
cd ..
