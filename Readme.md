# test-result-viewer.el

This emacs package provides a utility that can:

- parse a maven surefire xml report
- scan for testcases
- print the testcases to the buffer \*test_results\*
- print '[o] before succeeded test cases
- print '[x] before failed test cases, no matter if it failed or had an error

# setup and installation

The test-result-viewer requires the xml package to parse the surefire xml report.
Apart from that there are no additional dependencies.
Basically you just evaluate the file test-result-viewer.el and the functions
will be available.

You have to tell the package which report file you want to check for test cases.
For this you have to set the variable _test-result-viewer-reportfile_ e.g. with:

(setq test-result-viewer-reportfile "path/to/reportfile")

The package will create a buffer named '\*test-results\*' when loading. This 
buffer will hold the parsed report results. It will be erased before a scan 
on the report file to make sure all data is populated from the latest scan.
It relies on the buffer being available.

# how to run

After evaluating the package and setting the reportfile variable, you should
be able to call the function _print-and-show-testcases-in-buffer_.
This will parse the xml file you have set and show the contained test cases
from the file in the buffer _\*test-results\*_.
The buffer will be opened at the right side in a side window.

