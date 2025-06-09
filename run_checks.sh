#!/bin/bash

set +e  # Continue on errors

declare -A results
failures=()

run_step() {
  local name=$1
  local cmd=$2

  echo
  echo "--- $name ---"
  eval "$cmd"
  local rc=$?
  results["$name"]=$rc
  if [ $rc -ne 0 ]; then
    failures+=("$name")
  fi
}

echo "============================"
echo " Running Simplified Test Suite"
echo "============================"

run_step "Unit Tests" "pytest -v test_main.py"
run_step "Formatting Check (black)" "black --line-length 120 --check ."
run_step "Security Check (bandit)" "bandit -r . --exclude ./venv -lll"
run_step "Dependency Audit (pip-audit)" "pip-audit -r requirements.txt"

echo
echo "============================"
echo " Summary"
echo "============================"

for name in "${!results[@]}"; do
  status="[FAIL]"
  [ "${results[$name]}" -eq 0 ] && status="[PASS]"
  printf "%s %s\n" "$status" "$name"
done

if [ ${#failures[@]} -gt 0 ]; then
  echo
  echo "Failures:"
  for step in "${failures[@]}"; do
    echo " - $step"
  done
  exit 1
else
  echo
  echo "All checks passed successfully."
  exit 0
fi
