; .mg

meta-key-mode 0
auto-execute *.c c-mode
make-backup-files 0

global-set-key "\eg" goto-line

; F2
global-set-key "\eOQ" save-buffer
; F2 on linux console
global-set-key "\e[[B" save-buffer
; F2 on rxvt-unicode
global-set-key "\e[12~" save-buffer

; F4
global-set-key "\eOS" switch-to-buffer
global-set-key "\e[14~" switch-to-buffer

; F8
global-set-key "\e[19~" call-last-kbd-macro

; F11
global-set-key "\e[23~" save-buffers-kill-emacs
; F12
global-set-key "\e[24~" delete-other-windows

; delete
global-set-key "\e[3~" delete-char

; Segmentation fault: if define C-\ using:  global-set-key "\^\" undo
; so must use octal notation: C-\ == \034
global-set-key "\034" undo


; set-default-mode fill
; set-fill-column 72
; ---EOF---
