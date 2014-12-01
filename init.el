(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (wombat)))
 '(erc-modules (quote (autojoin button completion irccontrols list match menu move-to-prompt netsplit networks noncommands readonly ring stamp track))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Set the font size
;;(set-face-attribute 'default nil :height 130)

;;(set-face-attribute 'region nil :background "#666")

(tool-bar-mode -1)

;;; Faster buffer switching
(global-set-key "\C-x\C-b" 'buffer-menu)
;;(global-set-key [(C tab)] 'buffer-menu)


(global-set-key "\C-o" 'helm-mini)
(global-set-key "\C-p" 'helm-projectile)

;;highlight matching closing brackets
(show-paren-mode 1)

;;F1 changes to the last buffer... not as robust as control-tab, but a start
(defun switch-to-previous-buffer ()
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))

(global-set-key (kbd "<f1>") 'switch-to-previous-buffer)

;; Set the color of the current mode-line
;; this is meant to easily identify the active buffer on multi window sessions
(set-face-foreground 'mode-line "white") (set-face-background 'mode-line "#44B")

;;remove scroll-bars to save space
(toggle-scroll-bar -1)

;;display line numbers
(global-linum-mode 1)


;; Bind F11 to toggle full screen. It works!!! It brings the window
;; allways back to restored state even if it was maximized before (minor issue)
(defun toggle-fullscreen ()
  "Toggle full screen on X11"
  (interactive)
  (when (eq window-system 'x)
    (set-frame-parameter
     nil 'fullscreen
     (when (not (frame-parameter nil 'fullscreen)) 'fullboth))))

(global-set-key (kbd "<f11>") 'toggle-fullscreen)

;;removing org-mode Ctrl tab so it doesn't colide with the next keybind
(eval-after-load "org"
  '(define-key org-mode-map (kbd "<C-tab>") nil)
)

;; Backspase goes one level up on dired mode
(eval-after-load 'dired
  '(define-key dired-mode-map (kbd "DEL") 'dired-up-directory))

;; Ctrl-tab goes around buffers in one direction only... not optimal but still
;;(global-set-key [(control tab)] 'bury-buffer)

;;Rotate windows works like a charm!!!
(defun rotate-windows ()
  "Rotate your windows"
  (interactive)
  (cond
   ((not (> (count-windows) 1))
    (message "You can't rotate a single window!"))
   (t
    (let ((i 0)
          (num-windows (count-windows)))
      (while  (< i (- num-windows 1))
        (let* ((w1 (elt (window-list) i))
               (w2 (elt (window-list) (% (+ i 1) num-windows)))
               (b1 (window-buffer w1))
               (b2 (window-buffer w2))
               (s1 (window-start w1))
               (s2 (window-start w2)))
          (set-window-buffer w1 b2)
          (set-window-buffer w2 b1)
          (set-window-start w1 s2)
          (set-window-start w2 s1)
          (setq i (1+ i))))))))

(global-set-key (kbd "<s-tab>") 'rotate-windows)


;; Change the buffer on the other window
(defun cycle-other-window-forward () (interactive)(switch-to-next-buffer (next-window)))
(defun cycle-other-window-backwards () (interactive) (switch-to-prev-buffer (next-window)))
(global-set-key (kbd "s-m") 'cycle-other-window-backwards)
(global-set-key (kbd "s-n") 'cycle-other-window-forward)


;; view full path names on system title bar
(setq frame-title-format
      (list (format "EMACS: %%j " (system-name))
        '(buffer-file-name "%f" (dired-directory dired-directory "%b"))))


;; view full path on mode line too
(setq-default mode-line-buffer-identification
              (list 'buffer-file-name
                    (propertized-buffer-identification "%12f")
                    (propertized-buffer-identification "%12b")))


(add-hook 'dired-mode-hook
          (lambda ()
            ;; TODO: handle (DIRECTORY FILE ...) list value for dired-directory
            (setq mode-line-buffer-identification
                  ;; emulate "%17b" (see dired-mode):
                  '(:eval
                    (propertized-buffer-identification
                     (if (< (length default-directory) 17)
                         (concat default-directory
                                 (make-string (- 17 (length default-directory))
                                              ?\s))
                       default-directory))))))

;; enabling CUA mode
(cua-mode t)
(setq cua-auto-tabify-rectangles nil) ;; Don't tabify after rectangle commands
(transient-mark-mode 1) ;; No region when it is not highlighted
(setq cua-keep-region-after-copy t) ;; Standard Windows behaviour


;; MRU Ctrl-tab using iflipbuffer
(global-set-key (kbd "<C-tab>") 'iflipb-next-buffer)
  (global-set-key
   (if (featurep 'xemacs) (kbd "<C-iso-left-tab>") (kbd "<C-S-iso-lefttab>"))
   'iflipb-previous-buffer)

;; remove the splash screen
(setq inhibit-splash-screen t)

;; skip prompt to kill buffer
(global-set-key (kbd "C-x k") (lambda ()
                              (interactive)
                              (kill-buffer (buffer-name))))

;;adding melpa repository
(require 'package)
(add-to-list 'package-archives
  '("melpa" . "http://melpa.milkbox.net/packages/") t)


;;Starting packages now instead of after reading this file
;; this way we can install them from a list defined in this file
(setq package-enable-at-startup nil)
(package-initialize)

(set 'my-packages '(auto-complete cider clojure-mode go-mode haskell-mode helm-ack helm-ag helm-ag-r helm-cmd-t helm-projectile helm iflipb php+-mode php-mode popup projectile pkg-info epl dash queue restclient reveal-in-finder s auto-complete))

;; copied from
;;  http://stackoverflow.com/questions/10092322/how-to-automatically-install-emacs-packages-by-specifying-a-list-of-package-name
(unless package-archive-contents
  (package-refresh-contents))

; install the missing packages
(dolist (package my-packages)
  (unless (package-installed-p package)
    (package-install package)))

;;TODO: this apparently doesn't do it, read here
;; http://stackoverflow.com/questions/8095715/emacs-auto-complete-mode-at-startup
(require 'auto-complete)
(global-auto-complete-mode t)
