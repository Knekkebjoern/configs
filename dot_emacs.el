(setq inhibit-startup-message t)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)
(menu-bar-mode -1)
(setq visible-bell nil)
(setq ring-bell-function 'ignore)
(setq make-backup-files nil)

(set-face-attribute 'default nil :font "Fira Code Retina" :height 120)

(load-theme 'wombat)

(mac-auto-operator-composition-mode)

;; Initialize package resources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)

;; Initialize use-package in non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; (column-number-mode)
(global-display-line-numbers-mode t)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
		shell-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)	
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

;; NOTE: The first time you load your configuration on a new machine, you'll
;; need to run the following command interactively so that mode line icons
;; display correctly:
;;
;; M-x all-the-icons-install-fonts

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 10)))

(use-package doom-themes
  :init (load-theme 'doom-gruvbox t))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-b" . counsel-switch-buffer)
         ("C-x C-f" . counsel-find-file)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history)))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

;; (use-package general
;;   :config
;;   (general-create-definer rune/leader-keys
;;     :keymaps '(normal insert visual emacs)
;;     :prefix "SPC"
;;     :global-prefix "C-SPC")
;;   (rune/leader-keys
;;     "t"  '(:ignore t :which-key "toggles")
;;     "tt" '(counsel-load-theme :which-key "choose theme")))

(use-package hydra)
(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

;; (use-package projectile
;;   :diminish projectile-mode
;;   :config (projectile-mode)
;;   :custom ((projectile-completion-system 'ivy))
;;   :bind-keymap
;;   ("C-c p" . projectile-command-map)
;;   :init
;;   ;; NOTE: Set this to the folder where you keep your Git repos!
;;   (when (file-directory-p "~/src")
;;     (setq projectile-project-search-path '("~/src")))
;;   (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))


;; Org Mode Configuration ------------------------------------------------------

(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(defun efs/org-font-setup ()
  ;; Replace list hyphen with dot
  ;;(font-lock-add-keywords 'org-mode
  ;;                        '(("^ *\\([-]\\) "
  ;;                           (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))


  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . (1.2 . "Green"))
                  (org-level-2 . (1.1 . "Yellow"))
                  (org-level-3 . (1.05 . "Orange"))
                  (org-level-4 . (1.0 . "Light Blue"))
                  (org-level-5 . (1.1 . "Green"))
                  (org-level-6 . (1.1 . "Yellow"))
                  (org-level-7 . (1.1 . "Orange"))
                  (org-level-8 . (1.1 . "Light Blue"))))
    (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (car (cdr face)) :foreground (cdr (cdr face))))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))


(use-package org
  :hook (org-mode . efs/org-mode-setup)
  :config
;;  (setq org-ellipsis " ▾")
  (setq org-agenda-files '("~/Dropbox/Hiya/Tasks.org"
			   "~/Dropbox/Hiya/Archive.org"))
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  (setq org-todo-keywords
	'((sequence "TODO(t)" "NEXT(n)" "IN PROGRESS(i)" "BLOCKED(b)" "|" "DONE(d!)")))
  (setq org-todo-keyword-faces
	'(("TODO" . "white")
	  ("NEXT" . "blue")
	  ("STARTED" . "yellow")
	  ("BLOCKED" . "red")
          ("CANCELED" . (:foreground "blue" :weight bold))))
  
  (setq org-refile-targets
    '(("Archive.org" :maxlevel . 1)
      ("Tasks.org" :maxlevel . 1)))

  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-refile-targets
    '(("Archive.org" :maxlevel . 1)
      ("Tasks.org" :maxlevel . 1)))

  (setq org-capture-templates
    `(("t" "Tasks / Projects")
      ("tt" "Task" entry (file+olp "~/Dropbox/Hiya/Tasks.org" "INBOX")
       "* TODO %?\n  %U\n  %i" :empty-lines 1)))
  
  (define-key global-map (kbd "C-c t")
    (lambda () (interactive) (org-capture nil "tt")))
  
  (efs/org-font-setup))

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory (file-truename "~/Dropbox/org-roam"))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ;; Dailies
         ("C-c n j" . org-roam-dailies-capture-today))
  :config
  (org-roam-db-autosync-mode)
  ;; If using org-roam-protocol
  (require 'org-roam-protocol))

(setq org-roam-v2-ack t)
(setq ivy-use-selectable-prompt t)
;; (use-package org-bullets
;;   :after org
;;   :hook (org-mode . org-bullets-mode)
;;   :custom
;;   (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

;; (defun efs/org-mode-visual-fill ()
;;   (setq visual-fill-column-width 100
;;         visual-fill-column-center-text t)
;;   (visual-fill-column-mode 1))

;; (use-package visual-fill-column
;;   :hook (org-mode . efs/org-mode-visual-fill))

(use-package paredit
  :init
  (add-hook 'clojure-mode-hook 'paredit-mode))

;; Clojure
(use-package clojure-mode
  :ensure t
  :init
  (defconst clojure--prettify-symbols-alist
    '(("fn"   . ?λ)
      ("__"   . ?⁈)))

  :config
  (add-hook 'clojure-mode-hook 'global-prettify-symbols-mode)
  :bind (("C-c d f" . cider-code)
         ("C-c d g" . cider-grimoire)
         ("C-c d w" . cider-grimoire-web)
         ("C-c d c" . clojure-cheatsheet)
         ("C-c d d" . dash-at-point)))

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(defun cider-send-and-evaluate-sexp ()
  "Sends the s-expression located before the point or the active
  region to the REPL and evaluates it. Then the Clojure buffer is
  activated as if nothing happened."
  (interactive)
  (if (not (region-active-p))
      (cider-insert-last-sexp-in-repl)
    (cider-insert-in-repl
     (buffer-substring (region-beginning) (region-end)) nil))
  (cider-switch-to-repl-buffer)
  (cider-repl-closing-return)
  (cider-switch-to-last-clojure-buffer)
  (message ""))


(use-package cider
  :ensure t
  :commands (cider cider-connect cider-jack-in)

  :init
  (setq cider-auto-select-error-buffer t
        cider-repl-pop-to-buffer-on-connect nil
        cider-repl-use-clojure-font-lock t
        cider-repl-wrap-history t
        cider-repl-history-size 1000
        cider-show-error-buffer t
        nrepl-hide-special-buffers t
        ;; Stop error buffer from popping up while working in buffers other than the REPL:
        nrepl-popup-stacktraces nil)

  ;; (add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)
  (add-hook 'cider-mode-hook 'company-mode)

  (add-hook 'cider-repl-mode-hook 'paredit-mode)
  (add-hook 'cider-repl-mode-hook 'superword-mode)
  (add-hook 'cider-repl-mode-hook 'company-mode)
  (add-hook 'cider-test-report-mode 'jcf-soft-wrap)

  :bind (:map cider-mode-map
         ("C-c C-v C-c" . cider-send-and-evaluate-sexp)
         ("C-c C-p"     . cider-eval-print-last-sexp)))

(defun cider-append-comment ()
  (when (null (nth 8 (syntax-ppss)))
    (insert " ; ")))

(advice-add 'cider-eval-print-last-sexp :before #'cider-append-comment)
