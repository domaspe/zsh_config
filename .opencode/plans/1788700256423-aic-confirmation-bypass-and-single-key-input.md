# AIC Confirmation Bypass and Single-Key Input

## Goal

Add an optional `-y` flag to `aic` that skips commit confirmation, while changing the normal confirmation prompt to accept a single `y` or `n` keystroke without Enter.

## Implementation

Modify `/Users/domas/.config/zsh/functions/aic.zsh`:

1. Replace the current one-argument validation with option parsing for separate `-p` and `-y` arguments in either order.
2. Track `-y` with a local boolean and update usage to `aic [-p] [-y]`; continue returning status 2 for unknown arguments.
3. Keep generated-message display unchanged.
4. When `-y` is absent, read one character with Zsh's single-key input, print a newline after the keystroke, and commit only for `y` or `Y`; preserve cancellation status 1 for `n`, other input, or read failure.
5. When `-y` is present, bypass only the confirmation step. Preserve `-p` behavior so `aic -p -y` commits and then pushes.

## Verification

1. Run `zsh -n /Users/domas/.config/zsh/functions/aic.zsh`.
2. Run `git -C /Users/domas/.config/zsh diff --check`.
3. In a disposable Git repository with a stubbed `opencode` command, verify that `aic` commits immediately after one `y` keystroke, cancels after one `n` keystroke, and does not require Enter.
4. With the same stub, verify that `aic -y` commits without reading confirmation input.
5. Verify `aic -p -y` and `aic -y -p` both commit and invoke a stubbed `git push`, while an unknown argument prints the updated usage and returns status 2.
