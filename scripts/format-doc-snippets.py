#!/usr/bin/env python3
"""
Format Swift code blocks embedded in DocC .md and .tutorial files.

For each ```swift ... ``` block, the script:
  1. Writes the block to a temp .swift file
  2. Runs `swift format` on it
  3. Replaces the original block if formatting succeeds
  4. Leaves blocks unchanged if swift-format reports a parse error
     (most commonly: incomplete snippets that aren't standalone declarations)
"""

import re
import subprocess
import sys
from pathlib import Path

# Matches ```swift ... ``` blocks (non-greedy, across newlines)
SWIFT_BLOCK = re.compile(r"(```swift\n)(.*?)(```)", re.DOTALL)


def format_snippet(code: str, config: Path):
    """Return formatted code, or None if swift-format couldn't parse it."""
    result = subprocess.run(
        ["swift", "format", "--configuration", str(config), "-"],
        input=code,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return None
    return result.stdout


def process_file(path: Path, config: Path, dry_run: bool = False) -> bool:
    original = path.read_text()
    changed = False

    def replace_block(m: re.Match) -> str:
        nonlocal changed
        fence_open, code, fence_close = m.group(1), m.group(2), m.group(3)
        formatted = format_snippet(code, config)
        if formatted is None or formatted == code:
            return m.group(0)
        changed = True
        return fence_open + formatted + fence_close

    result = SWIFT_BLOCK.sub(replace_block, original)

    if changed:
        if dry_run:
            print(f"  would update: {path}")
        else:
            path.write_text(result)
            print(f"  updated: {path}")

    return changed


def main() -> None:
    repo = Path(__file__).parent.parent
    config = repo / ".swift-format"
    docc = repo / "Sources" / "Score" / "Documentation.docc"

    dry_run = "--dry-run" in sys.argv

    doc_files = sorted(
        list(docc.rglob("*.md")) + list(docc.rglob("*.tutorial"))
    )

    any_changed = False
    for f in doc_files:
        if process_file(f, config, dry_run=dry_run):
            any_changed = True

    if not any_changed:
        print("All Swift code blocks already match .swift-format rules.")


if __name__ == "__main__":
    main()
