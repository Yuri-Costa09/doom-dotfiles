;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Yuri"
      user-mail-address "yurircostawork@gmail.com")

;; ---------- Comportamento geral ----------
(setq +format-on-save-enabled-modes
      '(not emacs-lisp-mode
        org-mode
        sql-mode))

(setq +format-with-lsp t) ; onde LSP suportar format, use-o

;; Melhorias de busca e projeto
(setq projectile-project-search-path '("~/code" "~/work")
      projectile-auto-discover t)

;; Treemacs
(after! treemacs
  (setq treemacs-width 34
        treemacs-indentation 2))

;; ---------- LSP ----------
(after! lsp-mode
  (setq lsp-idle-delay 0.2
        lsp-completion-provider :none          ; deixa a company gerir
        lsp-enable-file-watchers t
        lsp-file-watch-threshold 2000
        lsp-log-io nil
        lsp-headerline-breadcrumb-enable t))

;; Integração company (auto-complete)
(after! company
  (setq company-idle-delay 0.05
        company-minimum-prefix-length 1
        company-tooltip-align-annotations t))

;; ---------- GIT ----------
(after! magit
  (setq magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1))

;; ======================================================================
;;                           LÍNGUAS
;; ======================================================================

;; ---- Go ----------------------------------------------------------------
(after! go-mode
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook #'gofmt-before-save)
  (add-hook 'go-mode-hook #'lsp-deferred)
  (add-hook 'go-mode-hook #'tree-sitter!))

;; Atalhos locais (SPC m …)
(after! go-mode
  (map! :map go-mode-map
        :localleader
        "r"  #'recompile
        "b"  (cmd! (compile "go build ./..."))
        "t"  (cmd! (compile "go test ./..."))
        "f"  #'gofmt
        "m"  (cmd! (compile "go mod tidy"))))

;; ---- Rust --------------------------------------------------------------
(after! rustic
  (setq rustic-lsp-server 'rust-analyzer
        rustic-format-on-save t)
  (add-hook 'rustic-mode-hook #'lsp-deferred)
  (add-hook 'rustic-mode-hook #'tree-sitter!))

(after! rustic
  (map! :map rustic-mode-map
        :localleader
        "b" #'rustic-cargo-build
        "r" #'rustic-cargo-run
        "t" #'rustic-cargo-test
        "f" #'rustic-format-buffer))

;; ---- C / C++ -----------------------------------------------------------
(after! c++-mode
  (add-hook 'c++-mode-hook #'lsp-deferred)
  (add-hook 'c++-mode-hook #'tree-sitter!))
(after! c-mode
  (add-hook 'c-mode-hook #'lsp-deferred)
  (add-hook 'c-mode-hook #'tree-sitter!))

;; clang-format on save (opcional)
(defun my-c-c++-format-buffer ()
  (when (or (derived-mode-p 'c-mode) (derived-mode-p 'c++-mode))
    (when (executable-find "clang-format")
      (call-interactively 'clang-format-buffer))))
(add-hook 'before-save-hook #'my-c-c++-format-buffer)

(after! cc-mode
  (map! :map (c-mode-map c++-mode-map)
        :localleader
        "b" (cmd! (compile "make -k"))
        "r" #'recompile
        "f" #'clang-format-buffer))

;; ---- Clojure -----------------------------------------------------------
;; LSP + CIDER
;; Requer clojure-lsp e clj-kondo instalados; para REPL, Lein/CLI/Boot conforme projeto
(after! clojure-mode
  (add-hook 'clojure-mode-hook #'lsp-deferred)
  (add-hook 'clojure-mode-hook #'tree-sitter!))

(after! cider
  (setq cider-repl-display-help-banner nil
        cider-show-error-buffer t
        cider-auto-select-error-buffer t))

(after! clojure-mode
  (map! :map clojure-mode-map
        :localleader
        "'"  #'cider-jack-in
        "b"  #'cider-load-buffer
        "e"  #'cider-eval-defun-at-point
        "r"  #'cider-refresh
        "t"  #'cider-test-run-ns-tests))

;; ---- Elixir ------------------------------------------------------------
;; Requer ElixirLS (elixir-ls); mix format
(after! elixir-mode
  (add-hook 'elixir-mode-hook #'lsp-deferred)
  (add-hook 'elixir-mode-hook #'tree-sitter!)
  (defun my-elixir-format-on-save ()
    (add-hook 'before-save-hook #'elixir-format nil t))
  (add-hook 'elixir-mode-hook #'my-elixir-format-on-save))

(after! elixir-mode
  (map! :map elixir-mode-map
        :localleader
        "b" (cmd! (compile "mix compile"))
        "t" (cmd! (compile "mix test"))
        "f" #'elixir-format))

;; ======================================================================
;;                     Atalhos gerais (Leader)
;; ======================================================================
(map! :leader
      :desc "Abrir arquivo"        "f f" #'find-file
      :desc "Projetos"             "p p" #'projectile-switch-project
      :desc "Arquivos do projeto"  "p f" #'projectile-find-file
      :desc "Buscar no projeto"    "/"   #'+default/search-project
      :desc "Terminal vterm"       "o t" #'+vterm/here
      :desc "Treemacs toggle"      "o e" #'+treemacs/toggle
      :desc "Magit status"         "g g" #'magit-status
      :desc "Formatar buffer"      "="   #'+format/buffer
      :desc "Renomear simb. (LSP)" "c r" #'lsp-rename)


;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
