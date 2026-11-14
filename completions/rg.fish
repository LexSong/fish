# fish ships no `rg` completion, and scoop does not install the one that
# ripgrep ships. So we ask rg for it when fish first completes an `rg` command.
#
# rg is a native exe, so its lines end with CRLF. The CR breaks every line that
# ends with `\`, so we remove it.
rg --generate complete-fish | string replace -r '\r$' '' | source
