#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""Sample plasmashell CPU and RSS while manually exercising Alveus Dock.

This measures the whole plasmashell process, not the applet in isolation.
Compare otherwise similar runs with the dock disabled and enabled.
"""

import argparse
import csv
import datetime as dt
import os
import pathlib
import sys
import time

CLK_TCK = os.sysconf("SC_CLK_TCK")
PAGE_SIZE = os.sysconf("SC_PAGE_SIZE")
PROC_ROOT = pathlib.Path("/proc")


def read_process(pid):
    """Return process CPU ticks and resident memory, or None if it exited."""
    proc = PROC_ROOT / str(pid)
    try:
        stat_text = (proc / "stat").read_text(encoding="utf-8")
        close_paren = stat_text.rfind(")")
        fields = stat_text[close_paren + 2 :].split()
        cpu_ticks = int(fields[11]) + int(fields[12])
        rss_pages = int(fields[21])
        comm = (proc / "comm").read_text(encoding="utf-8").strip()
        return comm, cpu_ticks, rss_pages * PAGE_SIZE
    except (FileNotFoundError, ProcessLookupError, PermissionError, IndexError, ValueError):
        return None


def find_plasmashell_pids():
    pids = []
    try:
        entries = PROC_ROOT.iterdir()
    except OSError:
        return pids
    for entry in entries:
        if not entry.name.isdigit():
            continue
        try:
            comm = (entry / "comm").read_text(encoding="utf-8").strip()
        except (FileNotFoundError, ProcessLookupError, PermissionError):
            continue
        if comm == "plasmashell" and read_process(int(entry.name)):
            pids.append(int(entry.name))
    return sorted(pids)


def main():
    parser = argparse.ArgumentParser(
        description="Sample whole-process plasmashell CPU and resident memory."
    )
    parser.add_argument("--seconds", type=int, default=60, help="sampling duration (default: 60)")
    parser.add_argument("--interval", type=float, default=1.0, help="sample interval (default: 1s)")
    parser.add_argument("--output", type=pathlib.Path, help="CSV output path (default: stdout)")
    args = parser.parse_args()

    if args.seconds < 1 or args.interval <= 0:
        parser.error("--seconds must be >= 1 and --interval must be > 0")

    pids = find_plasmashell_pids()
    if not pids:
        print("No running plasmashell process found.", file=sys.stderr)
        return 2

    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        output = args.output.open("w", newline="", encoding="utf-8")
    else:
        output = sys.stdout
    close_output = args.output is not None
    writer = csv.writer(output)
    writer.writerow(["timestamp", "pid", "process", "cpu_percent", "rss_mib"])

    previous = {}
    for pid in pids:
        current = read_process(pid)
        if current:
            previous[pid] = (current[1], time.monotonic())

    deadline = time.monotonic() + args.seconds
    try:
        while time.monotonic() < deadline:
            time.sleep(min(args.interval, max(0.0, deadline - time.monotonic())))
            now = time.monotonic()
            timestamp = dt.datetime.now().astimezone().isoformat(timespec="seconds")
            for pid in find_plasmashell_pids():
                current = read_process(pid)
                if not current:
                    continue
                cpu_ticks = current[1]
                if pid in previous:
                    old_ticks, old_time = previous[pid]
                    elapsed = max(now - old_time, 0.000001)
                    cpu_percent = max(0.0, (cpu_ticks - old_ticks) / CLK_TCK / elapsed * 100.0)
                else:
                    cpu_percent = 0.0
                previous[pid] = (cpu_ticks, now)
                writer.writerow([
                    timestamp,
                    pid,
                    current[0],
                    f"{cpu_percent:.2f}",
                    f"{current[2] / (1024 * 1024):.2f}",
                ])
            output.flush()
    finally:
        if close_output:
            output.close()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
