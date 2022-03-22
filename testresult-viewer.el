(require 'xml)

(get-buffer-create "*test-results*")
(with-current-buffer "*test-results*" (erase-buffer))

(defun print-testcase (testcase)
  "prints a testcase into the test-results buffer"
    (with-current-buffer "*test-results*"
      (goto-char (point-max))
      (if (or (xml-get-children testcase 'failure)
	      (xml-get-children testcase 'error))
	  (insert "[x] ") (insert "[o] "))
      (insert (substring (prin1-to-string (dom-attr testcase 'name)) 1 -1)) (insert " (")
      (insert (substring (prin1-to-string (dom-attr testcase 'time)) 1 -1)) (insert " sec)\n")))

(defun print-all-testcases (list-of-testcases)
  "prints all testcases contained in the given list"
  (progn (with-current-buffer "*test-results*" (erase-buffer))
	 (let (value)
	   (dolist (elt list-of-testcases)
	     (print-testcase elt)))))

(defun print-all-testcases-from-file (filename)
  "prints all testcases from the report file into the buffer *test-results*"
  (print-all-testcases (xml-get-children (assq 'testsuite (xml-parse-file filename)) 'testcase)))

(print-all-testcases-from-file test-result-viewer-reportfile)
(defun print-challenge-testcases () (interactive)
    (progn (print-all-testcases-from-file test-result-viewer-reportfile)
	   (display-buffer-in-side-window (get-buffer "*test-results*") '((side . right)))))

(print-challenge-testcases)
(global-set-key [f9] 'print-challenge-testcases)

