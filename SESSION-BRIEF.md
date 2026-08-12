# SESSION-BRIEF — NATO-1 (volatile)

Paste this as the first message of the next chat. It's the in-flight state only;
durable context is in NATO-1-spec.md and HANDOFF.md, which you should read too.

## Where we are

The Learn tab visual prototype is now feature-complete for its static/design
phase. Just finished and banked this session: the batch-row status system, the
next-step prompt box, and a unified caret-blink system. The remaining Learn-tab
work is no longer *design* — it's integration.

## Next session: the port, framed as a deliberate spike

Next session is porting the Learn-tab visuals into the functional app — but the
real deliverable is **learning the porting process**, not just a ported tab. Do
it as a spike: smallest complete payload (the Learn tab), integrated end-to-end,
so we understand how visual→functional integration actually works before Drill,
Codex, and the rest are designed. The working integrated Learn tab is the happy
byproduct; the *playbook* is the point.

Rationale for doing it now: the Learn tab is a contained, finished set of
visuals, so this is the easiest port we'll ever do — the right time to learn the
pattern is on a small, low-stakes merge, not after three more sections are built
in isolation. Git makes the unification revertible if it goes badly.

Intended workflow to validate: unify the finished Learn work onto a main-ish
branch, then branch OFF that for each remaining section's design work, porting
each back as done. This first port teaches whether that approach is viable and
how costly it is.

## The key complication: divergences, not just styling

The prototype has diverged from how the original functional app works in several
spots (the briefing interstitial is new; row states are richer than the original;
the prompt box is new logic). So this is a *reconciliation*, not a pure restyle.

Approach the spike in two separate passes — do NOT resolve divergences ad hoc
during the merge:
1. INVENTORY first. Walk the Learn tab and list every spot where the prototype
   does something the functional app doesn't — new screens, changed states,
   different flows — without deciding anything yet.
2. DECIDE each. For every divergence, make a conscious restyle-vs-redesign call:
   is the prototype just *dressed differently* (restyle — functional behavior
   wins) or *actually better* (redesign — port the behavior too)?

Refined principle for this spike: "restyle, not redesign" was the original rule,
but the prototype added real behavior, so the honest version is **restyle by
default, redesign only where we consciously decide the prototype's behavior is
the keeper.** Naming which is which up front is the whole game. Separating "find
all differences" from "decide each" keeps product decisions clean and the merge
mechanical.

## Expected friction points (walk in expecting these)

- Stubbed things becoming real: preview-only navigation, hardcoded/faked row
  states, cycle-on-tap on the prompt box (currently throwaway test scaffolding).
- Anywhere the prototype's layout assumed something the functional app does
  differently.
- The first-run "seen" flag logic for the briefing (in the prototype it's
  ignored so the briefing can be reviewed repeatedly — real app is once-ever).

## Open threads (design work, deferred until porting is understood)

- The two locked-row pop-overs (sequence-lock vs. unpaid-lock) — copy + design.
- Paywall screen design (copy is banked: "$4.99. ONCE. FOREVER. / NO ADS. / NO
  SUBSCRIPTION."; screen layout not designed).
- Welcome / onboarding experience (lives before the Learn screen; a way to
  re-trigger it from SYS and/or dev tools, TBD).
- Prompt-box motion polish: a character-cycling caret (spinner-style) as a
  possible upgrade over the plain dim/bright pulse; letter-sweep as a possible
  state-arrival transition. Both deferred; both must respect Reduce Motion.
- Still-to-design sections: Learn sub-pages, Drill pages, Codex.
- Push a new TestFlight build once the port lands. NOTE THE DEPENDENCY: the
  redesign lives in DesignPreview.swift, separate from the functional app, so a
  TestFlight build only carries the new visuals AFTER the port integrates them
  into the real app. Sequence is port → TestFlight, not parallel. The TestFlight
  push is the payoff/validation at the end of the porting work — real devices,
  real testers — not a standalone task.

## Integration mechanics (how the port actually happens)

Two branches off main, OPPOSITE roles — this is the crux:
- The DESIGN branch (DesignPreview.swift etc.) is a LOOKBOOK / implementation
  reference. It is NEVER merged. It just shows the target. Keep it alive (and
  pushed to GitHub) until ALL porting is done, then delete it. It's the reference
  for every screen, not just Learn.
- A new INTEGRATION branch, branched FROM main (e.g. `git checkout main` then
  `git checkout -b redesign-integration`), is where real work happens. Main stays
  safe and working the whole time. Merge integration BACK to main only when a
  piece is genuinely done — this merge is clean because the branch is just main
  plus finished work, not the divergent design branch.

Do NOT merge the design branch into main. It's a reference you read from, not a
set of changes to apply. Merging it wholesale would drag all the stubbed state /
missing logic into main at once (the half-broken-app state to avoid).

How Claude Code reads the prototype while working on integration: use
`git show design-branch:path/to/File.swift` to print the prototype's real,
already-debugged implementation WITHOUT leaving the integration branch. No file
copying (goes stale), no re-describing from prose (lossy telephone — re-derives
solved problems, reintroduces fixed bugs like the leader parity / reflow / caret
sync). Code ports the proven implementation directly.

Division of reference: SPEC = intent (what's decided and why, what's open — keeps
Code from reopening settled decisions). DESIGN-BRANCH CODE = implementation (how
it was actually built). Code uses both.

## Three-screen framing (shapes sequencing)

Each screen has a different job, so they are NOT the same restyle x3:
- LEARN = the launchpad. Where you go to know what to do next and start. Job:
  orientation + low-friction initiation. A status-driven list of available next
  steps + the prompt box surfacing the single top one. Restyle + small logic
  reconciliation. DO FIRST — designed, establishes the primitives/patterns.
- DRILL = the metronome. System-initiated (app feeds the right card at the right
  time); user is responsive, not choosing. Structurally rhymes with Learn so it
  reuses Learn's primitives; the new work is the paced/responsive FEEL. DO SECOND.
- CODEX = the trophy room. Not utilitarian — emotional. What's possible →
  progress → motivation → celebration. Per-letter mastery across the 4 tiers
  (Learning/Familiar/Confident/Mastered), a different information shape than
  Learn's next-steps list. NOT YET DESIGNED. This is a from-scratch DESIGN task,
  not a restyle — sequence it with design work, give it room. DO LAST of the three.

So: Learn + Drill are restyles (port look onto working logic, app stays usable);
Codex is a ground-up design. Restyles first (prove the process, keep app
shippable), the Codex design when it can get full attention.

## First concrete move next session (before any building)

Read-only question to Claude Code: does the working app already have a styling
layer (a colors file, a theme, shared components), or is each screen styled ad
hoc inline? This one fact decides whether "primitives first" is an easy afternoon
(drop values into existing theme slots) or a foundation-building session (create
the theme layer that never existed). Ask before building anything.

## Learn-page restyle: six incremental steps (one commit + check each)

Do this incrementally, NOT all at once. With real-state wiring involved something
will break; small steps keep each failure isolated and describable. Foundation
first so nothing gets re-touched. Each step is a commit and a verify.

1. PRIMITIVES, INVISIBLE. Land color tokens, Intel One Mono, grid helpers, caret
   clock into the working app. Nothing looks different yet. Verify: still builds,
   runs, looks identical. Safest possible first step — pure addition.
2. BACKGROUND + TYPE on the Learn screen's existing structure. Will look
   half-transformed (old layout, new colors/font) — fine, it's a checkpoint on
   the integration branch, not shippable yet. Verify: colors/font right, no crash.
3. HEADERS. The NATO-1 ─── [SYS] / LEARNING PROTOCOL block. Verify: matches
   prototype.
4. BATCH ROWS, wired to REAL batch data. Row layout + markers + dot leader,
   showing real states. First step that touches live state = where restyle meets
   reconciliation. Likely splits into two sub-checkpoints: (a) wire the states
   the app already has, (b) add the states the design introduced (the
   inventory-then-decide moment — each divergence gets a conscious
   restyle-vs-redesign call). Verify with dev tools: reset to different states,
   confirm each row shows the right marker for real data.
5. PROMPT BOX, wired to real next-step logic. Verify with dev tools: shows the
   correct single next action across the real app states.
6. INTERACTIONS / POLISH. Shared-clock caret blink, taps deep-linking into the
   right flow, Reduce Motion. Verify on device.

Order rationale: steps 1–3 are pure restyle (no logic, low risk, proves the
foundation). Steps 4–5 are the real wiring/reconciliation, but by then styling is
proven — so any bug there is LOGIC not style, which makes it describable ("row
shows LOCKED when it should show RESUME" vs. "something looks off"). The two kinds
of failure are separated into different steps.

## Watch-outs (also in HANDOFF.md)

- Claude Code's xcodebuild can time out and falsely report "clean build" — trust
  Xcode's title bar.
- Test on device, not just Canvas (width differs).
- One visual change at a time; revert to known-good if Code iterates blind.
- Don't over-specify implementation to Claude Code — describe what must be true.
