cls
@echo off
title MKM: April Fools 2024 - Library Installer and Setup
echo.
echo This batch file will automatically setup all the libraries and whatnot for you.
echo If it can't automatically do something, it'll point you in the direction.
echo.
set /p menu="Install libraries? [Y/N/C]"
       if %menu%==Y goto CheckLibraries
       if %menu%==y goto CheckLibraries
       if %menu%==N goto CancelLibraries
       if %menu%==n goto CancelLibraries
       if %menu%==C goto Credits
       if %menu%==c goto Credits
       cls
	   
:CancelLibraries
cls
echo.
echo Library installation cancelled.
echo.
echo Press any key to continue.
pause>nul
exit

:CheckLibraries
title MKM: April Fools 2024 - Library Installer and Setup (Active)
cls
echo.
haxe -version >nul 2>&1 && (
	echo "haxe has been installed"
	haxe -version
) || (
	echo "haxe is not installed"
	set /p menu="Do you want to install 64bit? [Y/N]"
       if %menu%==Y start https://haxe.org/download/file/4.2.4/haxe-4.2.4-win64.exe/
       if %menu%==y start https://haxe.org/download/file/4.2.4/haxe-4.2.4-win64.exe/
       if %menu%==N start https://haxe.org/download/file/4.2.4/haxe-4.2.4-win.exe/
       if %menu%==n start https://haxe.org/download/file/4.2.4/haxe-4.2.4-win.exe/
       cls

	echo.
	echo Please run this file.
	echo One it is done installing, press any key to continue.
	pause>nul
)

::lime -version >nul 2>&1 && (
::	echo "lime has been installed"
::	lime -version
::) || (
::	echo "lime is not installed"
::)

::lime 
haxelib install lime 8.0.0
haxelib run lime setup

:: openfl
haxelib install openfl 9.1.0

:: flixel
haxelib install flixel 5.2.1
haxelib run lime setup flixel

:: flixel-tools
haxelib install flixel-tools 1.5.1
haxelib run flixel-tools setup

:: new libs
haxelib install asepriteatlas 1.0.0
haxelib install flixel-addons 3.0.2
haxelib install flixel-ui 2.5.0
haxelib install hxCodec 2.5.1
haxelib install hxcpp-debug-server 1.2.4
haxelib install hxcpp 4.2.1
haxelib install linc_luajit 0.0.4
haxelib install newgrounds 2.0.0

echo Press any key to continue.
pause>nul
goto FinishLibraries

:FinishLibraries
cls
title MKM: April Fools 2024 - Library Installer and Setup (Done)
echo.
echo All libraries have been installed; you can now use "build.bat" or "build html.bat".
echo.
echo Press any key to continue.
pause>nul
exit


:Credits
cls
title MKM: April Fools 2024 - Credits
echo MKM: April Fools 2024
echo.
echo Dev links:
echo https://www.github.com/DillyzThe1
echo https://www.youtube.com/channel/UC5VLnoYgJ-Cxd2KWlc9LN6w
echo https://github.com/impostor5875
echo https://www.youtube.com/channel/UClNue2iaeFaK-Jbqo4E8c1g/about
echo.
echo.
echo Press any key to continue.
pause>nul
exit