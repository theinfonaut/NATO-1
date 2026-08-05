# SESSION-BRIEF — NATO-1 (volatile)

Paste this as the first message of the next chat. It's the in-flight state only;
durable context is in NATO-1-spec.md and HANDOFF.md, which you should read too.

## Where we are

Mid-build on the **SYS / system settings dialog** (the DOS TUI box). The Learn
tab is done and pushed. Everything about the dialog's design is in the spec; this
brief is just the live state.

## Last decision (and why)

Scroll model for the dialog: **fixed header + scrolling document**. The top
border line with the title and `[EXIT]` stays pinned (so EXIT is always
reachable); below it the content scrolls as one long bordered sheet, left/right
borders scrolling with it, bottom border appearing only at the end. Chose this
because the human wanted a document-like scroll but also wanted EXIT to stay put —
this satisfies both.

## Exact next action

Confirm the fix I last sent to Claude Code:
1. Force-wrap any specimen row or label wider than the box's inner column count
   so nothing crosses the borders (rules truncate to inner width; labels wrap).
2. Left/right alignment: consistent 2-column left inset on every row, nothing
   past the right inner margin. Likely partly caused by the unwrapped oversized
   rows — wrapping was to be fixed first, then alignment rechecked.

Look at the resulting screenshot for: nothing crossing the frame, even left
inset, single-shade borders (a border-color flicker bug was already fixed —
watch it stayed fixed).

## Open threads

- The dialog's content is a **temporary specimen sheet of 95 divider styles** the
  human is browsing to pick from. Standouts noticed: section marker, ticker tape.
  Picks NOT finalized. Once the box is clean, narrow the 95 down to a shortlist.
- After the dialog: the **status line** on the Learn tab is the highest-leverage
  next design item (see spec — resolves several undesigned states at once).
- The Batch 1 explainer needs re-designing against the column grid (copy + spec).

## Watch-outs (also in HANDOFF.md)

- Claude Code's xcodebuild can time out and falsely report "clean build" — trust
  Xcode's title bar.
- Test on device, not just Canvas (width differs).
- One visual change at a time; revert to known-good if Code iterates blind.
