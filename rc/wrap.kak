# Code to create wrapping
# For example:
#     Some |pretty| text -> Some |(pretty)| text

define-command wrapify-wrap-add-pair -hidden -params 2 %{
    execute-keys "i%arg{1}<esc>a%arg{2}<esc>"
    execute-keys "<a-;>H<a-;>"
}

define-command wrapify-wrap-add-pair-based-on -hidden -params 1 %{
    evaluate-commands %sh{
        case $1 in
            '('|')')       echo wrapify-wrap-add-pair '(' ')' ;;
            "{"|"}")       echo wrapify-wrap-add-pair '{' '}' ;;
            '<lt>'|'<gt>') echo wrapify-wrap-add-pair '<lt>' '<gt>' ;;
            '['|']')       echo wrapify-wrap-add-pair '[' ']' ;;
            '"')           echo wrapify-wrap-add-pair '\"' '\"' ;;
            "'")           echo wrapify-wrap-add-pair "\'" "\'" ;;
            *)             echo wrapify-wrap-add-pair "$1" "$1" ;;

        esac
    }
}

declare-option -hidden str wrapify_opt_wrap_resolve_char_hotkey
define-command wrapify-wrap-exec -hidden %{
    wrapify-info action_wrap
    on-key %{
        wrapify-check-cancel-with-user-position-restore %val{key}
        wrapify-resolve-char-hotkey %val{key} wrapify_opt_wrap_resolve_char_hotkey
        wrapify-wrap-add-pair-based-on %opt{wrapify_opt_wrap_resolve_char_hotkey}
        wrapify-undo-save
    }
}

define-command wrapify-wrap -docstring 'Wrap the current selection with a chosen character' %{
    wrapify-position-save-user
    wrapify-wrap-exec
}
