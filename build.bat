@echo off
rem Build the Nuklear static library into lib\nuklear.lib.
rem Usage: build.bat [debug]
rem Set the CC environment variable to select the compiler (default: clang).
setlocal enabledelayedexpansion

set DEBUG=0

:args
if "%~1"=="" goto args_done
if /i "%~1"=="debug" (set DEBUG=1& shift & goto args)
echo build.bat: unknown option "%~1". Use debug. 1>&2
exit /b 1
:args_done

if not defined CC set CC=clang

if not exist nuklear\nuklear.h (
	echo build.bat: nuklear is empty. Run "git submodule update --init". 1>&2
	exit /b 1
)

set CFLAGS=-std=c99 -Wall -Wno-unused-function -D_CRT_SECURE_NO_WARNINGS
if %DEBUG%==1 (set CFLAGS=!CFLAGS! -O0 -g) else (set CFLAGS=!CFLAGS! -O3 -DNDEBUG)

if exist build rmdir /s /q build
mkdir build\obj

%CC% %CFLAGS% -c nuklear.c -o build\obj\nuklear.obj || exit /b 1

if not exist lib mkdir lib
if exist lib\nuklear.lib del lib\nuklear.lib
llvm-lib /nologo /out:lib\nuklear.lib build\obj\nuklear.obj || exit /b 1

echo Built lib\nuklear.lib
