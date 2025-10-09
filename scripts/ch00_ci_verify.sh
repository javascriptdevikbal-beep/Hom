#!/usr/bin/env sh
# File: scripts/ch00_ci_verify.sh
# Purpose: Run Ch-00 verification: exact Gradle build/test and produce verification-report.txt.
# Non-technical: Run this locally to reproduce CI checks: chmod +x scripts/ch00_ci_verify.sh && ./scripts/ch00_ci_verify.sh

set -eu

LOG_FILE="ch00_ci_build.log"
REPORT_FILE="verification-report.txt"
APK_REL_PATH="app/build/outputs/apk/debug/app-debug.apk"

# Timestamp helpers (ISO 8601 UTC)
START_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
START_SEC="$(date +%s)"

# Clean up any prior report/log (avoid leaking previous state)
: > "$LOG_FILE" || true
: > "$REPORT_FILE" || true

# 1) Ensure gradlew exists and is executable
if [ ! -f ./gradlew ]; then
  echo "gradlew not found in repository root." > "$LOG_FILE"
  echo "FAIL" > "$REPORT_FILE"
  echo "reason: gradlew not found in repository root." >> "$REPORT_FILE"
  echo "log: $(pwd)/$LOG_FILE" >> "$REPORT_FILE"
  exit 1
fi

chmod +x ./gradlew

# 2) Run the documented Gradle command and capture all output to a log file
#    (Exact documented command for Ch-00: ./gradlew clean test assembleDebug)
GRADLE_EXIT=0
if ./gradlew clean test assembleDebug > "$LOG_FILE" 2>&1; then
  GRADLE_EXIT=0
else
  GRADLE_EXIT=$?
fi

# 3) Compute end time and duration
END_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
END_SEC="$(date +%s)"
DURATION_SEC=$((END_SEC - START_SEC))

# Helper: write fail report with log excerpt
_write_fail_report() {
  echo "FAIL" > "$REPORT_FILE"
  echo "start: $START_TS" >> "$REPORT_FILE"
  echo "end:   $END_TS" >> "$REPORT_FILE"
  echo "duration_seconds: $DURATION_SEC" >> "$REPORT_FILE"
  echo "log: $(pwd)/$LOG_FILE" >> "$REPORT_FILE"
  echo "artifact_present: no" >> "$REPORT_FILE"
  echo "reason: $1" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo "=== Last 200 lines of build log ===" >> "$REPORT_FILE"
  tail -n 200 "$LOG_FILE" >> "$REPORT_FILE" || true
}

# If Gradle failed, produce FAIL report and exit non-zero.
if [ "${GRADLE_EXIT}" -ne 0 ]; then
  _write_fail_report "Gradle build/test failed (exit code ${GRADLE_EXIT})."
  exit 1
fi

# 4) Verify artifact presence
ARTIFACT_PRESENT="no"
if [ -f "$APK_REL_PATH" ]; then
  ARTIFACT_PRESENT="yes"
  ARTIFACT_ABS_PATH="$(pwd)/$APK_REL_PATH"
else
  ARTIFACT_PRESENT="no"
fi

# 5) Final PASS report (only if Gradle succeeded)
if [ "$ARTIFACT_PRESENT" = "yes" ]; then
  echo "PASS" > "$REPORT_FILE"
  echo "start: $START_TS" >> "$REPORT_FILE"
  echo "end:   $END_TS" >> "$REPORT_FILE"
  echo "duration_seconds: $DURATION_SEC" >> "$REPORT_FILE"
  echo "log: $(pwd)/$LOG_FILE" >> "$REPORT_FILE"
  echo "artifact_present: yes" >> "$REPORT_FILE"
  echo "artifact_path: $ARTIFACT_ABS_PATH" >> "$REPORT_FILE"
  echo "summary: Gradle build & tests succeeded; debug APK produced." >> "$REPORT_FILE"
  exit 0
else
  _write_fail_report "Gradle succeeded but artifact not found at $APK_REL_PATH."
  exit 1
fi
