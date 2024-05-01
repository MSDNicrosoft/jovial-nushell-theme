# Jovial Nushell Theme
# https://github.com/MSDNicrosoft/jovial-nushell-theme

const prep = {
    _as: $"(ansi '#878787')as(ansi reset)"
    _in: $"(ansi '#878787')in(ansi reset)"
    _on: $"(ansi '#878787')on(ansi reset)"
}

def get-user-color [] {
    let user_color = {
        attr: b,
        fg: (if (is-admin) { "#ff5f5f" } else { "#dadada" }),
    }

    return $user_color
}

export def prompt-command [] {
    let term_columns = (term size).columns
    let user_color = get-user-color
    let corner = $"(ansi '#d0d0d0')╭──"

    let host  = (uname | get nodename)
    let user = whoami

    let user_directory_color = { fg: "#ffff87", attr: b }
    let directory = $"(pwd | str replace ($nu.home-path) "~")"

    let git_line = (
        if (".git" | path exists) {
            try {
                let git_branch = (do -i { git branch --show-current } | complete | $in.stdout | str trim)
                let git_dirty = (do -i { git status --porcelain=v1 } | complete | $in.stdout | str length) > 0

                $"($git_branch)(if $git_dirty { "*" } else { "" })"
            } catch { "" }
        } else { "" }
    )

    let vcs_color = { fg: yellow }
    # This is a bit unnecessary, but if I decide to support other VCSs in the future
    # it should be relatively easy to tack on
    let vcs_line = (if $git_line != "" { $git_line } else { "" })
    let vcs_line = (if $vcs_line != "" {
        $" ($prep._on) (ansi $vcs_color)<($vcs_line)> (ansi reset)"
    } else {
        ""
    })

    let host = $"(ansi '#d0d0d0')[(ansi reset)(ansi '#afffaf')($host)(ansi '#d0d0d0')](ansi reset)"
    let user = $" ($prep._as) (ansi $user_color)($user)(ansi reset)"
    let directory = $" ($prep._in) (ansi $user_directory_color)($directory)(ansi reset)"

    mut prompt_is_empty = true
    mut result = $"($corner)"
    for prompt in [$host, $user, $directory, $vcs_line] {
        if ((($"($result)($prompt)" | ansi strip | str length) > $term_columns) and (not $prompt_is_empty)) {
            break
        }
        $prompt_is_empty = false
        $result += $prompt
    }

    return $"($result)\n\n"
}

export def prompt-command-right [] {
    let current_time = (date now | format date '%H:%M:%S')
    return (if $env.LAST_EXIT_CODE == 0 {
        $"(ansi '#d0d0d0')($current_time)"
    } else {
        $"(ansi '#878787')exit:(ansi { fg: red, attr: b })($env.LAST_EXIT_CODE)(ansi reset) (ansi '#d0d0d0')($current_time)"
    })
}

export def prompt-indicator [] {
    let corner = $"(ansi '#d0d0d0')╰──➤"

    return $"($corner)(ansi reset) "
}

export def multiline-indicator [] { return "" }
