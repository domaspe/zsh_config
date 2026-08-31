aic() {
    setopt localoptions pipefail

    if (( $# > 1 )) || { (( $# == 1 )) && [[ "$1" != "-p" ]] }; then
        print -u2 -- "Usage: aic [-p]"
        return 2
    fi

    local push_after_commit=0
    local prompt message confirmation backend
    local exit_status
    local -a generate_command

    if [[ "$1" == "-p" ]]; then
        push_after_commit=1
    fi

    prompt='Generate a git commit message for these staged changes.
Use only the staged diff provided via stdin. Do not use tools, inspect files, or ask follow-up questions.
Use conventional commit format (feat/fix/refactor/etc). Subject line, blank line, then a short body.
Lead with what changed and why. Describe intent and outcome, not file-by-file or symbol-by-symbol edits.
Call out behavior changes that affect existing code paths or data; these are more important than new feature details.
Keep similar-sounding identifiers distinct and preserve technical terms verbatim.
Only include bullets when they add information the lead does not imply. Prefer no bullets over repetition.
Use plain English, complete sentences, and no filler, hedging, or idioms.
Output ONLY the commit message text, without quotes or backticks.'

    backend="${AIC_BACKEND:-opencode}"

    case "$backend" in
        opencode)
            generate_command=(opencode run --model deepseek/deepseek-v4-flash "$prompt")
            ;;
        claude)
            generate_command=(
                claude --print
                --model haiku
                --safe-mode
                --no-session-persistence
                --tools ""
                --system-prompt 'You write git commit messages. Output only the commit message.'
                -- "$prompt"
            )
            ;;
        *)
            print -u2 -- "Unknown AIC_BACKEND: $backend (expected 'claude' or 'opencode')."
            return 2
            ;;
    esac

    git rev-parse --show-toplevel >/dev/null 2>&1
    exit_status=$?

    if (( exit_status != 0 )); then
        print -u2 -- "Not inside a Git worktree."
        return "$exit_status"
    fi

    git diff --cached --quiet --
    exit_status=$?

    if (( exit_status == 0 )); then
        print -u2 -- "No staged changes."
        return 1
    fi

    if (( exit_status != 1 )); then
        print -u2 -- "Could not inspect staged changes."
        return "$exit_status"
    fi

    message="$(git diff --cached -- | "${generate_command[@]}")"
    exit_status=$?

    if (( exit_status != 0 )); then
        print -u2 -- "Could not generate a commit message."
        return "$exit_status"
    fi

    if [[ -z "${message//[[:space:]]/}" ]]; then
        print -u2 -- "$backend returned an empty commit message."
        return 1
    fi

    print
    print -r -- "$message"
    print

    if ! read -r "confirmation?Commit this message? [y/N] "; then
        print -- "Commit cancelled."
        return 1
    fi

    if [[ "$confirmation" != [yY] ]]; then
        print -- "Commit cancelled."
        return 1
    fi

    git commit --file=- --cleanup=verbatim <<< "$message"
    exit_status=$?

    if (( exit_status != 0 )); then
        return "$exit_status"
    fi

    if (( push_after_commit )); then
        git push
        return $?
    fi

    return 0
}
