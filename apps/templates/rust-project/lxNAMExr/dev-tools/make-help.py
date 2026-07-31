#!/usr/bin/env python3

from __future__ import annotations

import argparse
import re
from pathlib import Path


TARGET_WIDTH = 24
TARGET_PATTERN = re.compile(r"^\s*\*\s+([-_A-Za-z0-9]+)\s+-\s+(.*)$")
TABLE_ROW_PATTERN = re.compile(r"^\s*\|\s*(.*?)\s*\|\s*(.*)$")
RULE_PATTERN = re.compile(r"^([-_A-Za-z0-9]+):")
TEST_CALL_PATTERN = re.compile(r"\$\(call Test,(.*)\)")


def emit_tagged_lines(path: Path, tag: str) -> None:
    prefix = f"#{tag}"
    with path.open(encoding="utf-8") as handle:
        for line in handle:
            if line.startswith(prefix):
                print(line[2:].rstrip("\n"))


def format_target_rows(path: Path) -> set[str]:
    targets: set[str] = set()
    with path.open(encoding="utf-8") as handle:
        for raw_line in handle:
            if not raw_line.startswith("#|"):
                continue

            line = raw_line[2:].rstrip("\n")
            match = TARGET_PATTERN.match(line)
            if match is not None:
                target, description = match.groups()
                targets.add(target)
                print(f"| {target:<{TARGET_WIDTH}} | {description}")
                continue

            match = TABLE_ROW_PATTERN.match(line)
            if match is not None:
                target, description = match.groups()
                print(f"| {target:<{TARGET_WIDTH}} | {description}")
                continue

            print(line)

    return targets


def format_test_rows(path: Path, skip_targets: set[str] | None = None) -> None:
    skip_targets = skip_targets or set()
    current_target = ""
    with path.open(encoding="utf-8") as handle:
        for raw_line in handle:
            rule_match = RULE_PATTERN.match(raw_line)
            if rule_match is not None:
                current_target = rule_match.group(1)

            test_match = TEST_CALL_PATTERN.search(raw_line)
            if test_match is None:
                continue

            if current_target in skip_targets:
                continue

            description = test_match.group(1).replace(")", "").strip()
            print(f"| {current_target:<{TARGET_WIDTH}} | Test {description}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Render make help output as markdown.")
    parser.add_argument("makefile", type=Path)
    parser.add_argument("tests", type=Path)
    args = parser.parse_args()

    emit_tagged_lines(args.makefile, "<")
    if args.tests.is_file():
        emit_tagged_lines(args.tests, "<")

    format_target_rows(args.makefile)
    if args.tests.is_file():
        documented_targets = format_target_rows(args.tests)
        format_test_rows(args.tests, skip_targets=documented_targets)
        emit_tagged_lines(args.tests, ">")

    emit_tagged_lines(args.makefile, ">")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())