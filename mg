; .mg

meta-key-mode 0
auto-execute *.c c-mode
make-backup-files 0

global-set-key "\eg" goto-line

; F2
global-set-key "\eOQ" save-buffer    ; xterm
global-set-key "\e[[B" save-buffer   ; linux console
global-set-key "\e[12~" save-buffer  ; rxvt-unicode

; F4
global-set-key "\eOS" switch-to-buffer   ; xterm
global-set-key "\e[14~" switch-to-buffer ; rxvt-unicode

; F8
global-set-key "\e[19~" call-last-kbd-macro

; F11
global-set-key "\e[23~" save-buffers-kill-emacs   ; rxvt-unicode
global-set-key "\e[1;2P" save-buffers-kill-emacs  ; tmux

; F12
global-set-key "\e[24~" delete-other-windows      ; rxvt-unicode
global-set-key "\e[1;2Q" delete-other-windows     ; tmux

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
