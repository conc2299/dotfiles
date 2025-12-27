compare_semver() {
  awk -v a="$1" -v b="$2" '
  BEGIN {
    # split into fields by dot
    nA = split(a, A, "\\.")
    nB = split(b, B, "\\.")
    max = (nA > nB ? nA : nB)

    for (i = 1; i <= max; i++) {
      pa = (i in A ? A[i] : "0")
      pb = (i in B ? B[i] : "0")

      # if entirely digits -> numeric value, else treat as 0
      if (pa ~ /^[0-9]+$/) pa_num = pa + 0
      else pa_num = 0

      if (pb ~ /^[0-9]+$/) pb_num = pb + 0
      else pb_num = 0

      if (pa_num < pb_num) { print -1; exit 0 }
      if (pa_num > pb_num) { print 1; exit 0 }
      # otherwise equal, continue
    }
    print 0
  }'
}
if [ $(compare_semver "$(getconf GNU_LIBC_VERSION | cut -d' ' -f2)" "2.39") -lt 0 ]; then
    mihomo-tui() {
        LD_LIBRARY_PATH=$HOME/.local/bin/mihomo-tui $HOME/.local/bin/mihomo-tui/mihomo-tui "$@"
    }
else
    PATH=$HOME/.local/bin/mihomo-tui:$PATH
    unset -f mihomo-tui
fi
unset -f compare_semver