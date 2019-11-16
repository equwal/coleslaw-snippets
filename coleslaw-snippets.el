;;; coleslaw-snippets.el --- Yasnippets for Coleslaw markup files. -*- lexical-binding: t; -*-
;; Copyright (C) 2019 Spenser Truex
;; Author: Spenser Truex <web@spensertruex.com>
;; Created: 2019-06-22
;; Version: 0.0.1
;; Package-Requires: ((emacs "24.4") (yasnippet "0.13.0"))
;; Keywords: coleslaw wp convenience docs
;; URL: https://spensertruex.com/coleslaw-snippets
;; Homepage: https://spensertruex.com/coleslaw-snippets
;; This file is not part of GNU Emacs.
;; This file is free software.
;; License:
;; Licensed with the GNU GPL v3 see:
;; <https://www.gnu.org/licenses/>.

;;; Commentary:
(require 'cl-lib)
(require 'autoinsert)

(defvar coleslaw-snippets-separator ";;;;;"
  "The string used between the coleslaw headers as in the example:
;;;;;
title: Example
format: cl-who
date: 2019-06-15
;;;;;
Where the separator is \";;;;;\".")

(defvar coleslaw-snippets-formats '("md" "cl-who" "rst" "html" "org")
  "The format header values that coleslaw will allow to be auto-inserted.")

(defun coleslaw-snippets--valid-format (str)
  "Determine if the STR is permissible for a format: header in Coleslaw."
  (when (stringp str)
    (cl-some (lambda (x) (string-equal x str)) coleslaw-snippets-formats)))


(defun coleslaw-snippets--bufftype (type)
  "Determine if the file type of the current buffer is TYPE."
  (string-equal type (cl-subseq buffer-file-name (- (length buffer-file-name) 5))))

(defun coleslaw-snippets--insist-format (first-prompt &optional second-prompt)
  "Insist that the format inserted be a valid coleslaw format.
Add formats to the `coleslaw-snippets-formats' list for new features or
nonstandard formats.  FIRST-PROMPT and SECOND-PROMPT are used to
prompt the user at the minibuffer.  The FIRST-PROMPT is for the
first, and SECOND-PROMPT is used in subsequent requests.  If
FIRST-PROMPT is NIL, the second-prompt is only used."
  (let ((res (read-from-minibuffer (if first-prompt
                                       first-prompt
                                     second-prompt))))
    (if (coleslaw-snippets--valid-format res)
        res
      (coleslaw-snippets--insist-format nil second-prompt))))

;;;###autoload
(defun coleslaw-snippets-insert-header ()
  "Insert the skeleton for as specified by default for a coleslaw file type."
  (interactive)
  (skeleton-insert '(nil str
                         "\ntitle: "
                         (skeleton-read "title: ")
                         "\nformat: "
                         (progn (setq v1
                                      (coleslaw-snippets--insist-format
                                       "format: "
                                       "Bad format, try another format: "))
                                (coleslaw-dispatch-format v1)
                                v1)
                         (if (coleslaw-snippets--bufftype ".page")
                             (concat "\nurl: " (skeleton-read "url: "))
                           "")
                         (if (coleslaw-snippets--bufftype ".post")
                             (if (y-or-n-p "Insert excerpt? ")
                                 (concat "\nexcerpt: "
                                         (skeleton-read "excerpt: "))
                               "")
                           "")
                         "\ndate: "
                         (format-time-string "%Y-%m-%d" (current-time))
			 "\n" str)
		               0 (regexp-quote coleslaw-snippets-separator)))

(provide 'coleslaw-snippets)
;;; coleslaw-snippets.el ends here
