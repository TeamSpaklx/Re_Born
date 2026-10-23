@echo off
set "RE_BORN_ROOT=%~dp0.."
set "JAVA_HOME=%RE_BORN_ROOT%\.tools\Java21\jdk-21.0.12.1+1"
set "PATH=%JAVA_HOME%\bin;%PATH%"
call "%RE_BORN_ROOT%\.tools\Apache\apache-maven-3.9.11\bin\mvn.cmd" %*
