function Set-TerminalConfig {
    winget install -e --id Microsoft.WindowsTerminal
    # TODO: Set a symlink in the correct spot to the repo's windows config for terminal.
}

Export-ModuleMember -Function Set-TerminalConfig
