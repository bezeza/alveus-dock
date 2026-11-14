# Performance testing

Alveus Dock runs inside the Plasma shell process. A process-level sample therefore measures **all of plasmashell**, not the dock alone. The sampler is useful for before/after comparisons, but it cannot attribute CPU or memory to one applet.

## Repeatable manual comparison

1. Log into the same Plasma session and wait until startup activity settles.
2. Close unrelated applications and keep the same panel widgets in both runs.
3. Run a 60-second baseline with Alveus Dock removed or disabled.
4. Add Alveus Dock, wait for startup activity to settle, and repeat the same workload.
5. Repeat with approximately 5, 10 and 30 visible windows/tasks.
6. During each sample, exercise hover scaling, switching windows, opening the context menu and dragging icons.
7. Compare median CPU and RSS values between the baseline and dock-enabled runs. Do not treat one short spike as a regression.

## Collect a sample

The script uses only Python's standard library and /proc:

~~~bash
python3 scripts/profile-plasmashell.py \
  --seconds 60 \
  --interval 1 \
  --output "$HOME/.local/state/alveus-dock/performance/plasmashell.csv"
~~~

The output contains timestamp, PID, process name, CPU percentage and resident memory in MiB. CPU percentage is per-process and can exceed 100% when a process uses multiple cores.

## Interpretation

- Compare like-for-like runs on the same machine and Plasma session.
- A difference in whole-shell RSS is not the dock's exact memory footprint.
- If the enabled run is consistently worse, repeat the test and inspect journal logs before changing animations or model behavior.
- No hard CPU/RAM release threshold is set yet. Establish a baseline on real supported hardware before defining one.

## Runtime checks still required

CI can lint QML and build an RPM, but only a live KDE Plasma session can verify animation smoothness, task model behavior, Wayland interactions and actual desktop resource use.
