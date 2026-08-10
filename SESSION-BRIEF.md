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

## Watch-outs (also in HANDOFF.md)

- Claude Code's xcodebuild can time out and falsely report "clean build" — trust
  Xcode's title bar.
- Test on device, not just Canvas (width differs).
- One visual change at a time; revert to known-good if Code iterates blind.
- Don't over-specify implementation to Claude Code — describe what must be true.
