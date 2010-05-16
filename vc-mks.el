(eval-when-compile
  (require 'cl)
  (require 'vc))

(defgroup vc-mks nil
  "VC mks backend."
  :version "22.2"
  :group 'vc)

;;;
;;; Customization options
;;;

(defcustom vc-mks-program "mks"
  "Name of the MKS executable."
  :type 'string
  :group 'vc)

(defcustom vc-mks-global-switches nil
  "Global switches to pass to any mks command."
  :type '(choice (const :tag "None" nil)
                 (string :tag "Argument String")
                 (repeat :tag "Argument List" :value ("") string))
  :version "22.2"
  :group 'vc)

(defcustom vc-mks-register-switches nil
  "Switches for registering a file into MKS.
A string or list of strings passed to the checkin program by
\\[vc-register].  If nil, use the value of `vc-register-switches'.
If t, use no switches."
  :type '(choice (const :tag "Unspecified" nil)
		 (const :tag "None" t)
		 (string :tag "Argument String")
		 (repeat :tag "Argument List" :value ("") string))
  :version "22.2"
  :group 'vc)

(defcustom vc-mks-diff-switches nil
  "String or list of strings specifying switches for MKS diff under VC.
If nil, use the value of `vc-diff-switches'.  If t, use no switches."
  :type '(choice (const :tag "Unspecified" nil)
                 (const :tag "None" t)
		 (string :tag "Argument String")
		 (repeat :tag "Argument List" :value ("") string))
  :version "21.1"
  :group 'vc)

(defcustom vc-mks-header (or (cdr (assoc 'MKS vc-header-alist)) '("\$Id\$"))
  "Header keywords to be inserted by `vc-insert-headers'."
  :type '(repeat string)
  :version "21.1"
  :group 'vc)

(defcustom vc-mksdiff-knows-brief nil
  ;; TODO
  "Indicates whether mksdiff understands the --brief option.
The value is either `yes', `no', or nil.  If it is nil, VC tries
to use --brief and sets this variable to remember whether it worked."
  :type '(choice (const :tag "Work out" nil) (const yes) (const no))
  :group 'vc)

(defcustom vc-mks-master-templates
  '("%s%s.pj")
  "Where to look for MKS master files.
For a description of possible values, see `vc-check-master-templates'."
  :type '(choice (const :tag "Use standard MKS file names"
			'("%s%s.pj"))
		 (repeat :tag "User-specified"
			 (choice string
				 function)))
  :version "21.1"
  :group 'vc)

;;; Properties of the backend

(defun vc-mks-revision-granularity () 'file)

;; The autoload cookie below places vc-mks-registered directly into
;; loaddefs.el, so that vc-mks.el does not need to be loaded for
;; every file that is visited.
;;;###autoload
(progn
(defun vc-mks-registered (f) (vc-default-registered 'MKS f)))


;;;
;;; Internal functions
;;;

(defun vc-mks-command (buffer okstatus file-or-list &rest flags)
  "A wrapper around `vc-do-command' for use in vc-mks.el.
The difference to vc-do-command is that this function always invokes `mks',
and that it passes `vc-mks-global-switches' to it before FLAGS."
  (apply 'vc-do-command (or buffer "*vc*") okstatus vc-mks-program file-or-list
         (if (stringp vc-mks-global-switches)
             (cons vc-mks-global-switches flags)
           (append vc-mks-global-switches
                   flags))))
