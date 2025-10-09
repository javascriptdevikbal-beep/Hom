#!/usr/bin/env sh
# scripts/ch01_verify.sh
# POSIX-compliant verification script for Homeonix Ch-01 docs
set -eu

REPORT="verification-report.txt"
STATUS="PASS"

# Initialize associative-like records via plain variables (POSIX)
DOCS_PASS="PASS"
HEADINGS_PASS="PASS"
MANIFEST_PASS="PASS"

# Helper to mark overall FAIL
mark_fail() {
  STATUS="FAIL"
}

# Start checks
# 1) Required docs exist & non-empty
required_docs="
docs/ch01_purpose_principles.md
docs/ch01_acceptance_checklist.md
docs/privacy_statement.md
docs/ch01_handoff_checklist.md
"

docs_results=""
for f in $required_docs; do
  if [ -s "$f" ]; then
    docs_results="$docs_results\n  - $f: PASS"
  else
    docs_results="$docs_results\n  - $f: FAIL"
    mark_fail
    DOCS_PASS="FAIL"
  fi
done

# 2) Required headings in docs/ch01_purpose_principles.md
headings_results=""
if [ -s "docs/ch01_purpose_principles.md" ]; then
  # Check each heading; presence required (order not enforced here)
  if grep -q "^# Homeonix — Ch-01: Purpose & Principles" docs/ch01_purpose_principles.md; then
    headings_results="$headings_results\n  - # Homeonix — Ch-01: Purpose & Principles: PASS"
  else
    headings_results="$headings_results\n  - # Homeonix — Ch-01: Purpose & Principles: FAIL"
    mark_fail
    HEADINGS_PASS="FAIL"
  fi

  if grep -q "^## Overview (EN)" docs/ch01_purpose_principles.md; then
    headings_results="$headings_results\n  - ## Overview (EN): PASS"
  else
    headings_results="$headings_results\n  - ## Overview (EN): FAIL"
    mark_fail
    HEADINGS_PASS="FAIL"
  fi

  if grep -q "^## Overview (BN)" docs/ch01_purpose_principles.md; then
    headings_results="$headings_results\n  - ## Overview (BN): PASS"
  else
    headings_results="$headings_results\n  - ## Overview (BN): FAIL"
    mark_fail
    HEADINGS_PASS="FAIL"
  fi

  if grep -q "^## Goals" docs/ch01_purpose_principles.md; then
    headings_results="$headings_results\n  - ## Goals: PASS"
  else
    headings_results="$headings_results\n  - ## Goals: FAIL"
    mark_fail
    HEADINGS_PASS="FAIL"
  fi

  if grep -q "^## Non-Goals" docs/ch01_purpose_principles.md; then
    headings_results="$headings_results\n  - ## Non-Goals: PASS"
  else
    headings_results="$headings_results\n  - ## Non-Goals: FAIL"
    mark_fail
    HEADINGS_PASS="FAIL"
  fi

  if grep -q "^## Principles" docs/ch01_purpose_principles.md; then
    headings_results="$headings_results\n  - ## Principles: PASS"
  else
    headings_results="$headings_results\n  - ## Principles: FAIL"
    mark_fail
    HEADINGS_PASS="FAIL"
  fi

  if grep -q "^## Scope boundaries" docs/ch01_purpose_principles.md; then
    headings_results="$headings_results\n  - ## Scope boundaries: PASS"
  else
    headings_results="$headings_results\n  - ## Scope boundaries: FAIL"
    mark_fail
    HEADINGS_PASS="FAIL"
  fi

  if grep -q "^## Glossary" docs/ch01_purpose_principles.md; then
    headings_results="$headings_results\n  - ## Glossary: PASS"
  else
    headings_results="$headings_results\n  - ## Glossary: FAIL"
    mark_fail
    HEADINGS_PASS="FAIL"
  fi
else
  headings_results="$headings_results\n  - docs/ch01_purpose_principles.md: MISSING (cannot check headings)"
  mark_fail
  HEADINGS_PASS="FAIL"
fi

# 3) Manifest INTERNET check (if manifest exists)
manifest_result="  - manifest_no_internet: PASS"
if [ -f "app/src/main/AndroidManifest.xml" ]; then
  if grep -q "android.permission.INTERNET" app/src/main/AndroidManifest.xml; then
    manifest_result="  - manifest_no_internet: FAIL (android.permission.INTERNET present)"
    mark_fail
    MANIFEST_PASS="FAIL"
  fi
fi

# 4) Produce verification-report.txt
{
  printf 'STATUS: %s\n' "$STATUS"
  printf 'CHECKS:\n'
  # Docs results
  printf '  - docs_present:\n'
  # Print each doc result line by line
  # Using echo -e is not POSIX; use printf to handle \n sequences
  # Remove leading newline from docs_results
  printf "%b\n" "$docs_results" | sed 's/^\\n//g' | sed 's/^/    /'
  # Headings summary
  printf '  - headings:\n'
  printf "%b\n" "$headings_results" | sed 's/^\\n//g' | sed 's/^/    /'
  # Manifest check
  printf "%s\n" "$manifest_result"
  printf 'TIMESTAMP: %s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
} > "$REPORT"

# 5) Exit accordingly
if [ "$STATUS" = "PASS" ]; then
  exit 0
else
  exit 1
fi
