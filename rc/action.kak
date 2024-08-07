#####################
# Select inner
#####################
define-command wrapify-action-select-inner -hidden %{
    wrapify-position-restore-last-search
    execute-keys "H<a-;>L<a-;>"
}

#####################
# Select outer
#####################
define-command wrapify-action-select-outer -hidden %{
    wrapify-position-restore-last-search
}

#####################
# Delete
#####################
define-command wrapify-action-delete -hidden %{
    execute-keys "d"
    wrapify-undo-save
    wrapify-position-restore-user
}


#####################
# Replace
#####################
define-command wrapify-action-replace-with -hidden -params 1 %{
    # eval here to perform only one history_id change
    evaluate-commands %{
        wrapify-position-restore-last-search
        wrapify-wrap-add-pair-based-on %arg{1}
        wrapify-position-restore-last-search
        wrapify-highlight-wrapping
        execute-keys "d"
    }
    wrapify-undo-save
    wrapify-position-restore-user
}

define-command wrapify-action-replace -hidden %{
    wrapify-info action_replace
    on-key %{
        wrapify-check-cancel-with-user-position-restore %val{key}
        wrapify-action-replace-with %val{key}
    }
}

declare-option -hidden str wrapify_opt_quick_replace_resolve_char_hotkey
define-command wrapify-action-quick-replace -hidden %{
    wrapify-resolve-char-hotkey %val{key} wrapify_opt_quick_replace_resolve_char_hotkey
    wrapify-action-replace-with %opt{wrapify_opt_quick_replace_resolve_char_hotkey}
}

#####################
# Iterate
#####################
declare-option -hidden str wrapify_iterate_current_search

define-command wrapify-iterate -hidden %{
    wrapify-position-restore-last-search
    wrapify-action-select
}

#####################
# Wrapify wrap wrappers
#####################
define-command wrapify-wrap-around-action-shortcut -hidden %{
    wrapify-action-select-outer
    wrapify-wrap-exec
}

define-command wrapify-wrap-within-action-shortcut -hidden %{
    wrapify-action-select-inner
    wrapify-wrap-exec
}

#####################
# Action switch
#####################
define-command wrapify-action-switch -params 1 -hidden %{
    wrapify-info action_switch
    on-key %{
        wrapify-check-cancel-with-user-position-restore %val{key}
        %sh{
            case $kak_key in
                $kak_opt_wrapify_mapping_action_select_inner)         echo wrapify-action-select-inner ;;
                $kak_opt_wrapify_mapping_action_select_outer)         echo wrapify-action-select-outer ;;
                $kak_opt_wrapify_mapping_action_delete)               echo wrapify-action-delete ;;
                $kak_opt_wrapify_mapping_action_replace)              echo wrapify-action-replace ;;
                $kak_opt_wrapify_mapping_action_wrap_within_shortcut) echo wrapify-wrap-within-action-shortcut ;;
                $kak_opt_wrapify_mapping_action_wrap_around_shortcut) echo wrapify-wrap-around-action-shortcut ;;
                $kak_opt_wrapify_iterate_current_search)              echo wrapify-iterate ;;
                *)                                                    echo wrapify-action-quick-replace
            esac
        }
    }
}

define-command wrapify-action-select -hidden %{
    wrapify-check-cancel-with-user-position-restore %val{key}
    try %{
        wrapify-search-pair "%val{key}"
    } catch %{
        wrapify-position-restore-user
        fail "%val{error}"
    }
    wrapify-highlight-wrapping
    wrapify-action-switch "%val{key}" # async
}

define-command wrapify-action -docstring 'Search for a wrapping and perform an action on it' %{
    wrapify-info action
    on-key %{
        wrapify-position-save-user
        try %{
            evaluate-commands %sh{
                [[ $kak_key == $kak_opt_wrapify_mapping_wrap_shortcut ]] && echo nop || echo fail
            }
            wrapify-wrap-exec # async
        } catch %{
            set-option window wrapify_iterate_current_search "%val{key}"
            wrapify-action-select
        }
    }
}
