rem create gnu_regex distribution.
deltree gnu_regex_dist
mkdir gnu_regex_dist
rem copy documentation
copy gnu_regex.html gnu_regex_dist
copy regex.doc gnu_regex_dist
rem copy binaries and test files
copy Release\gnu_regex.lib gnu_regex_dist
copy Release\gnu_regex.dll gnu_regex_dist
copy Release\test_gnu_regex.exe gnu_regex_dist
copy regex_test.txt gnu_regex_dist
rem copy sources
copy regex.h gnu_regex_dist
copy regex_test.c gnu_regex_dist
copy regex.c gnu_regex_dist
copy gnu_regex.def gnu_regex_dist
rem copy build and maint files
copy test_gnu_regex.mak gnu_regex_dist
copy release.bat gnu_regex_dist
copy install.bat gnu_regex_dist
rem end of file copy
\zip\zip -r \Distribute\gnu_regex gnu_regex_dist

