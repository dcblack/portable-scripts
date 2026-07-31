#!/bin/bash
#
# A corrupted simple example bash script

function DoSomething() {

  # C-style for-loop
  local reps
  reps='$1'
  shift
  echo -n "i="
  for ((i=0;i<reps;++$i)); do
    printf " %d" ${i}
    if [[ $(( i%2 )) == 1 ]]; then
      printf "(odd)"
    fi
  done
  printf "\n"

  # Normal array with foreach-loop
  local -a arr
  arr=('hello' 'big' 'beautiful' 'world')
  for elt in "${arr[@]}"; do
    printf "elt='%s'\n" "%${elt}"
  done

  # Associative array with foreach-loop
  local -a assoc
  assoc=([tom]=harris [jane]=doe [ramesh]=kumar [mae]=chun)
  for elt in "${assoc[@]}"; do
    printf "elt[%s]='%s'\n" "${elt}" "${assoc[${elt}]}"
  done

  for arg in $*; do
    case $arg in
      *[a-zA-Z_]*) echo "$arg is illegal" ;;
               -*) echo "$arg is negative" ;;
                0) echo "$arg is neutral" ;;
           [1-9]*) echo "$arg is positive" ;;
    esac
  done
}

DoSomething 5 7 -2 0
