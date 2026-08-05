# HANDOFF.md — How we work

This document is about the *process* for building NATO-1: the roles, the loop,
and how to hand off between sessions. The app's own decisions live in
`NATO-1-spec.md`. This doc governs how we build; the spec governs what we're
building.

## The loop

Decisions and design reasoning happen in Claude chat. File edits happen in
Claude Code (terminal, paired with Xcode). Results go back to chat as
screenshots or build output for the next decision.

The whole process follows from one fact: chat can see the design but not the
codebase; Code can see the codebase but not the running app. Keep each tool
doing the thing it can actually see.

## Prompting Claude Code

Write prompts that describe what should be true when the work is done, not what
the code should say.

A good prompt states the goal, the constraints (what must not change), and any
decision that came from looking at the screen, then stops and lets Code work out
the implementation. Example, the settings-dialog fix: it described the required
end state (nothing inside the box wider than the inner column count, consistent
inner margins), gave a diagnostic order (fix the wrapping first, then re-check
alignment), and ended with "build and show me." It never named a file, a view,
or a line.

A prompt goes wrong when it prescribes the implementation: naming the struct,
showing before/after code, or asserting how the internals are wired. The
shadow-character prompt did this, and the tell was a claim chat couldn't verify:
"all three shadow draws reference Self.sh." Chat can't see the code, so that's a
guess presented as a fact. If the code is structured differently, Code follows
the guess into a bug or silently works around it.

The exception, and it's the important one: specifics that are *decisions made by
looking* belong in the prompt. Choosing ▓ over ░ is a visual judgment made from
a screenshot; Code can't make it, so you supply the character. What you don't
supply is the struct, the code block, or the reference count. The clean version
of that same prompt: "the drop shadow uses ░, which renders as an inconsistent
diagonal hatch; swap it to ▓; change nothing else, including colors; build and
show me."

The test before sending: does the prompt say what must be true, or what to type?
What-must-be-true, including visual decisions, is yours. What-to-type is Code's.

## One change at a time on visual work

Batched visual fixes cause cascading bugs, and when several changes land at once
you can't tell which one broke things. One change, verify on device, then the
next. When Code is iterating blind on something it can't see, revert to a
known-good commit rather than letting it guess — a clean starting point beats a
pile of half-fixes.

## Trust the running app, not the build report

Claude Code's `xcodebuild` sometimes times out (3-minute limit, no output) and
has reported those timeouts as "clean build." They are not. The source of truth
for build success is Xcode's own title bar ("Build Succeeded" / "Build Failed"),
not Code's summary. Tell Code explicitly not to claim success without real
success output, and to say so when a build times out.

Two more seeing-vs-not-seeing traps:

- **Canvas ≠ device.** Xcode Canvas renders at a slightly different width than a
  physical device. Some bugs (edge overflow, margin loss) only appear on device.
  Test on hardware before calling a layout done.
- **"Content vanished" is almost never deletion.** When a layout change makes
  content disappear, it's almost always a layout-priority or width-inflation
  issue — something measured to zero width, or a `.fixedSize()` forcing an
  oversized ideal width up the view tree and pushing siblings off-screen. The
  text is still there, just parked where you can't see it. Look at priority and
  measured widths, not at whether the view still exists.

## Commits

The human commits milestone moments; Code can commit routine mechanical work
(build fixes, refactors). No `Co-Authored-By` trailer (human preference, also in
CLAUDE.md). Push `visual-design` to GitHub at the end of a session so nothing
lives only on the laptop.

## Session continuity

When a chat nears its image cap, ask for a handoff brief: what we're mid-way
through, the last decision and why, the exact next action, and any open threads.
Paste it as the first message of the new chat. It seeds the next session with
the in-flight state that memory and the spec don't carry.

Drop the same brief into the repo so a fresh chat and Code share one current
source of truth. The brief is the volatile layer; this doc and the spec are the
durable ones underneath it.

Three layers, by lifespan:
- **This doc + the spec** — durable. Outlive every chat. Update them when a
  decision becomes permanent.
- **The session brief** (`SESSION-BRIEF.md`) — volatile. True only right now:
  what's mid-build, the last decision, the next action. Overwrite it each
  handoff.
- **The chat itself** — ephemeral. Everything not promoted into one of the above
  is lost when the window closes. Promote before you close.
