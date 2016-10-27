term_tree() {
  sig=$1
  children=$(jobs -p)
  echo ".. caught $sig, sending TERM to $children"
  [[ "$children" ]] || return 0
  kill -TERM $children
  ret=$?
  if [ $ret != 0 ]; then
    echo "!! failed to kill children ($ret)"
    return $ret
  fi
  echo ">> killed children"
}

end_with_term() {
  for sig in INT TERM QUIT; do
    trap term_tree $sig
  done
}
