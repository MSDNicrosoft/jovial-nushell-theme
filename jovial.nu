# Jovial Nushell Theme
# https://github.com/MSDNicrosoft/jovial-nushell-theme

def get-user-color [] {
    let user_color = {
        attr: b,
        fg: (if (is-admin) { "#ff5f5f" } else { "#dadada" }),
    }

    return $user_color
}

def is-windows [] {
    let is_windows = (uname | get kernel-name) == 'Windows_NT'
    return $is_windows
}

export def prompt-command [] {
    let user_color = get-user-color
    let $is_windows = is-windows

    let as_prep = $"(ansi '#878787')as(ansi reset)"
    let in_prep = $"(ansi '#878787')in(ansi reset)"
    let on_prep = $"(ansi '#878787')on(ansi reset)"

    let current_time = (date now | format date '%H:%M:%S')

    let corner = $"(ansi '#d0d0d0')╭──[($current_time)]─"

    let host  = $"(ansi '#afffaf')(uname | get nodename)(ansi reset)"
    let user = $"(ansi $user_color)(whoami)(ansi reset)"

    let user_directory_color = { fg: "#ffff87", attr: b }
    let home_directory = if ($is_windows) { $env.USERPROFILE } else { $env.HOME }
    let directory = $"(ansi $user_directory_color)(pwd | str replace ($home_directory) "~")(ansi reset)"

    let git_line = (try {
        let git_branch = (do -i { git branch --show-current } | complete | $in.stdout | str trim)
        let git_dirty = (do -i { git status --porcelain=v1 } | complete | $in.stdout | str length | into int) > 0

        $"($git_branch)(if $git_dirty { "*" } else { "" })"
    } catch {
        ""
    })

    let vcs_color = { fg: yellow }
    # This is a bit unnecessary, but if I decide to support other VCSs in the future
    # it should be relatively easy to tack on
    let vcs_line = (if $git_line != "" { $git_line } else { "" })
    let vcs_line = (if $vcs_line != "" {
        $"($on_prep) (ansi $vcs_color)‹($vcs_line)› (ansi reset)"
    } else {
        ""
    })

    let host_prefix = $"(ansi '#d0d0d0')[(ansi reset)"
    let host_suffix = $"(ansi '#d0d0d0')](ansi reset)"

    return $"($corner)($host_prefix)($host)($host_suffix) ($as_prep) ($user) ($in_prep) ($directory) ($vcs_line)\n\n"
}

export def prompt-command-right [] {
    return (if $env.LAST_EXIT_CODE == 0 {
        ""
    } else {
        $"(ansi { fg: red, attr: b })($env.LAST_EXIT_CODE)(ansi reset)"
    })
}

export def prompt-indicator [] {
    let user_color = get-user-color

    let corner = $"(ansi '#d0d0d0')╰──➤"

    return $"($corner)(ansi reset) "
}

export def multiline-indicator [] { return "" }

