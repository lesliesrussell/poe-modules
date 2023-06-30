;;; poe-modules.el --- Emacs Lisp package for POE modules -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                         V A R I A B L E S                               ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defgroup poe-modules nil
  "Customization options for poe-modules package."
  :group 'convenience
  :prefix "poe-module-")

(defcustom poe-module-base-directory "~/poe-modules/"
  "Base directory for POE modules."
  :type 'string
  :group 'poe-modules)

(defcustom poe-module-module-list '()
  "List of POE modules to load."
  :type '(repeat symbol)
  :group 'poe-modules)

(defcustom poe-module-config-list '()
  "List of POE module configurations."
  :type '(repeat string)
  :group 'poe-modules)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                             C O D E                                     ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'cl-lib)

;;;###autoload
(defun poe-modules-expand-paths (base-directory module-list)
  "Expand each symbol in MODULE-LIST to a subdirectory path within BASE-DIRECTORY.
Validate the existence of each path and return a list of the valid paths."
  (cl-loop for module in module-list
           for subdirectory = (expand-file-name (symbol-name module) base-directory)
           when (file-directory-p subdirectory)
           collect subdirectory))

;;;###autoload
(defun poe-modules-find-config-files (directory-list)
  "Find 'config.el' files within each directory in DIRECTORY-LIST.
Validate the existence of the file in each directory and return a list
of fully expanded file paths for the valid 'config.el' files."
  (let ((valid-paths '()))
    (dolist (directory directory-list valid-paths)
      (let ((config-file (expand-file-name "config.el" directory)))
        (when (file-exists-p config-file)
          (push config-file valid-paths))))))

(defun poe-modules-load-files (file-list timing-flag)
  "Load files from FILE-LIST.
Validate the existence of each file and load it. If TIMING-FLAG is non-nil,
report the load time for each file; otherwise, load the file without reporting load times."
  (let ((loaded-files '()))
    (cl-loop for file in file-list
             unless (file-exists-p file)
             do (message "File does not exist: %s" file)
             else do (if timing-flag
                         (let ((load-time (benchmark-run (load file))))
                           (message "Loaded file: %s, Load time: %.6f seconds" file (car load-time)))
                       (load file))
             finally return (nreverse loaded-files))))

;;;###autoload
(defun poe-modules-load-modules (base-directory module-list &optional timing-flag)
  "Load configuration files for modules in MODULE-LIST under BASE-DIRECTORY.
If TIMING-FLAG is non-nil, report the load time for each file; otherwise,
load the file without reporting load times."
  ;; (setq poe-module-paths (poe-modules-expand-paths base-directory module-list) timing-flag)
  ;; (setq poe-module-configs (poe-modules-find-config-files poe-module-paths))
  ;; (poe-modules-load-files poe-module-configs timing-flag)
  (poe-modules-load-files 
   (poe-modules-find-config-files 
    (poe-modules-expand-paths base-directory module-list)) timing-flag))

(provide 'poe-modules)

;;; poe-modules.el ends here
