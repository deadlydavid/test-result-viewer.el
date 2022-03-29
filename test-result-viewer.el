;;; test-result-viewer.el --- show maven test results in an emacs buffer  -*- lexical-binding: t; -*-

;; Copyright (C) 2022  David Dionis

;; Author: David Dionis <david.dionis@gmail.com>
;; Keywords: lisp, maven, test
;; Version: 0.0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This Package can parse an xml maven test result and shows the result of
;; each test case in an emacs buffer *test-results*. The file is specified
;; in the variable test-result-viewer-reportfile.

;;; Code:

(require 'xml)

(setq test-result-viewer-buffer-name "*test-results*")

(get-buffer-create test-result-viewer-buffer-name)

(defun print-testcase (testcase)
  "prints a testcase into the test-results buffer"
    (with-current-buffer (get-buffer test-result-viewer-buffer-name)
      (goto-char (point-max))
      (if (or (xml-get-children testcase 'failure)
	      (xml-get-children testcase 'error))
	  (insert "[ FAIL ] ") (insert (propertize "[ OK ]  "
						 'font-lock-face
						 '(:foreground "forest green"))))
      (insert (substring (prin1-to-string (dom-attr testcase 'name)) 1 -1)) (insert " (")
      (insert (substring (prin1-to-string (dom-attr testcase 'time)) 1 -1)) (insert " sec)\n")))

(defun print-all-testcases (list-of-testcases)
  "prints all testcases contained in the given list"
  (progn ;(with-current-buffer "*test-results*" (erase-buffer))
	 (let (value) (dolist (elt list-of-testcases) (print-testcase elt)))))

(defun print-all-testcases-from-file (filename)
  "prints all testcases from the report file into the buffer *test-results*"
  (progn (with-current-buffer (get-buffer test-result-viewer-buffer-name) (insert (concat filename "\n")))
	 (print-all-testcases (xml-get-children (assq 'testsuite (xml-parse-file filename)) 'testcase))))

(defun list-files-in-test-folder () (interactive)
       (directory-files-recursively (projectile-project-root) "TEST-.*\.xml"))

(defun print-and-show-testcases-in-buffer () (interactive)
 (progn (dolist (elt (list-files-in-test-folder)) (print-all-testcases-from-file elt))
	(display-buffer-in-side-window (get-buffer test-result-viewer-buffer-name) '((side . right)))))

(defun show-test-results (process signal)
  (when (memq (process-status process) '(exit signal))
    (print-and-show-testcases-in-buffer)
    (shell-command-sentinel process signal)))

(defun execute-project-tests () (interactive)
       (let* ((output-buffer (get-buffer-create "*test-runner*"))
	      (default-directory (projectile-project-root))
	      (proc (progn (with-current-buffer test-result-viewer-buffer-name
			     (erase-buffer) (insert (concat "running tests... - "
							    (format-time-string "%H:%M:%S"
										(current-time)) "\n")))
			   (async-shell-command "mvn -B test" output-buffer 0)
			   (get-buffer-process output-buffer))))
	 (if (process-live-p proc)
	     (set-process-sentinel proc #'show-test-results)
	   (message "No process running"))))

(provide 'test-result-viewer)
;;; test-result-viewer.el ends here
