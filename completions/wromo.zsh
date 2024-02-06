if [[ ! -o interactive ]]; then
    return
fi

compctl -K _wromo wromo

_wromo() {
  local word words completions
  read -cA words
  word="${words[2]}"

  if [ "${#words}" -eq 2 ]; then
    completions="$(wromo commands)"
  else
    completions="$(wromo completions "${word}")"
  fi

  reply=("${(ps:\n:)completions}")
}
