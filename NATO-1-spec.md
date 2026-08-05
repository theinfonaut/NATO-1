# NATO-1
## App Design Specification
**Version 0.2 — Working document** (DOS terminal direction decided; character-grid layout system established)

---

## Purpose of this document

This document is a design repository for NATO-1, a mobile-first iOS app for learning the NATO phonetic alphabet. It captures decisions made, flows designed, visual direction explored, and ideas deferred. It is intended to orient the designer across sessions and to serve as context for AI-assisted development in future phases.

Sections are marked as **[DECIDED]** (closed), or **[OPEN]** (not yet designed).

---

## 1. Concept and vision

### Core insight

The NATO phonetic alphabet is a 26-item, fully learnable set. The hard and useful skill is **production** — seeing a letter and immediately saying the correct NATO word (e.g. F → Foxtrot). Recognition (hearing Foxtrot and knowing it means F) requires no study. All learning mechanics are designed around production recall.

### Target experience

- Master the NATO alphabet in 2–4 weeks depending on pace
- Daily practice sessions of 3–5 minutes
- A clear sense of progress and eventual completion — unlike open-ended learning apps
- The skill stays fresh with minimal ongoing maintenance

### Differentiators

- Finite and completable — 26 letters, then you are done
- SRS-based drilling ensures long-term retention, not just short-term memorisation
- One-time purchase — no subscription
- Mobile-first, speech-to-text friendly (no STT built in — phone keyboard handles it)

---

## 2. Content structure

26 letters organised into 7 batches. Batch 1 is free. Batches 2–7 are unlocked via a single one-time IAP at $4.99.

| Batch | Letters | NATO words | Access |
|-------|---------|------------|--------|
| 1 | A B C D | Alpha · Bravo · Charlie · Delta | Free |
| 2 | E F G H | Echo · Foxtrot · Golf · Hotel | Paid |
| 3 | I J K L | India · Juliet · Kilo · Lima | Paid |
| 4 | M N O P | Mike · November · Oscar · Papa | Paid |
| 5 | Q R S T | Quebec · Romeo · Sierra · Tango | Paid |
| 6 | U V W | Uniform · Victor · Whiskey | Paid |
| 7 | X Y Z | X-ray · Yankee · Zulu | Paid |

Rationale: batches of 4 feel manageable in a single learning session. The final two batches are slightly smaller (3 letters each) as a gentler finish. X, Y, Z together as the final batch has a satisfying "final boss" quality.

---

## 3. Phase 1 — Learning

Each batch is introduced through a structured learning session of approximately 3–5 minutes. The session has four steps and a strict no-failure philosophy: there are no wrong answers that block progress, only wrong answers that require another attempt.

### Step 1: Meet (~60–90 seconds)

Each letter is introduced one at a time, full screen. For each letter the user sees:
- The letter, large and centred
- The NATO word below it
- An image or emoji representing the word
- A short mnemonic or imagination prompt

Mnemonics should be vivid, specific, and slightly odd — memory research consistently shows that unusual or absurd associations are more memorable than bland ones.

The user taps to advance through all letters in the batch. No input required at this stage.

### Step 2: Quiz (~2–3 minutes)

The user sees each letter and must type the correct NATO word. Rules:
- Wrong answer: the correct word is briefly shown, the card goes to the back of the deck
- Correct answer: the card is retired from this session's deck
- The session does not end until every card has been answered correctly at least once
- After all first-pass cards are complete, any cards that received a wrong answer resurface once more
- A wrong answer on resurfaced cards does not add another resurface — it just requires another correct answer to exit
- One tier penalty per card per session maximum — subsequent wrong answers on the same card carry no additional penalty

The quiz tests production only: letter → NATO word. The reverse is not tested.

### Step 3: Encode (~1–2 minutes)

The user is shown words built from letters in all unlocked batches so far. They must type the full NATO spelling. Same rules as Quiz:
- Wrong answers resurface once at end of first pass
- Hint (letter-by-letter breakdown) shown briefly after a wrong answer, then cleared before next attempt
- Batch 1 has 4 encode words (all short, given constrained letter set)
- All other batches have 3 encode words
- Words use only letters from unlocked batches

### Step 4: Batch complete

A celebration screen confirms the batch is done. All letters from the batch enter the SRS queue at Tier 1. The user is shown when their first drill review will be (4 hours).

### Session rules

- Target duration: 3–5 minutes
- No failure state — the session cannot be failed, only extended by wrong answers
- No scoring or grade — the learning phase is introduction, not assessment

---

## 4. Phase 2 — Drilling (SRS)

### SRS system

Each letter has an independent SRS tier that advances or drops based on drill performance.

| Tier | Name | Interval | Wrong answer |
|------|------|----------|--------------|
| 1 | Learning | 4 hours | Reset timer, stay at Tier 1 |
| 2 | Familiar | 1 day | Drop to Tier 1, reset timer |
| 3 | Confident | 3 days | Drop to Tier 2, reset timer |
| 4 | Mastered | 7 days | Drop to Tier 3, reset timer |

### Session rules

- A daily session pulls all letters currently due for review
- Two card types: Letter cards (letter → NATO word) and Encode cards (word → full NATO spelling)
- Encode cards appear roughly 1 per 4–5 letter cards
- Encode cards use only words buildable from the user's unlocked letters
- Encode cards are not SRS-tracked — they are a bonus mechanic for variety
- If new cards become due while a session is in progress, they are added to the current session
- Wrong answers: tier drops once per card per session (or resets timer at Tier 1), card resurfaces until answered correctly
- Subsequent wrong answers on the same card in the same session carry no further tier penalty
- Session ends when all due cards have been answered correctly
- Interval timer starts from the moment of correct answer, not from when the card was due
- Missed sessions: cards queue up and wait — no additional penalty beyond delay

### Drill home screen

The Drill tab shows:
- Count of cards due now
- Estimated session duration
- Number of unlocked letters
- Which letters are due (shown as letter chips)

If 0 cards are due, the screen shows an "All clear" state with the time until next review, and offers Encode practice as an optional activity.

### Encode practice (zero-due state)

When no cards are due, the user can choose to do Encode practice:
- 5 words per round, randomly drawn from all unlocked letters
- Same wrong-answer / resurface mechanic as drill sessions
- Hint shown briefly after wrong answer, cleared before next attempt — never pre-loaded on resurface
- At round end: correct/missed count shown, option to do another round or exit
- Words are random each round

---

## 5. Phase 3 — Mastery

When all 26 letters reach Tier 4 (Mastered), a one-time celebration screen is shown. This is a graduation moment — it should feel earned and special. Design TBD.

After mastery, the app transitions to maintenance mode: a weekly drill session using the standard SRS (Mastered letters resurface every 7 days). Letters that are answered wrong during maintenance drop back to Tier 3 (Confident) and return to the normal SRS cadence.

Mini-games are unlocked at mastery and live in the maintenance phase. Mini-game design is TBD.

---

## 6. Codebook

A tab accessible from the main navigation. Shows all 26 letters and their current SRS tier. Letters from unlearned batches are shown but greyed out.

The Codebook is a progress view — watching letters climb toward Mastered is a core motivational mechanic. Detailed design TBD.

---

## 7. Visual direction — DOS terminal [DECIDED]

The visual direction is decided: a monochrome green-phosphor **DOS terminal** aesthetic. Monospace type on a near-black green background, character-grid layout throughout. This is a restyle of the original card-based design — navigation structure, screen layouts, content, and copy are unchanged; the palette, font, and grid are applied on top. (Codebook is renamed Codex.)

The earlier exploration of tool/aviation/instrument directions (warm off-white, dark/amber, pure monochrome) is retained below for history but is superseded by the terminal direction.

### Aesthetic direction — earlier exploration (superseded)

The working aesthetic direction draws from tools, aviation, and navigation instruments. Think cockpit displays, nautical charts, field radios, topographic maps, and precision measuring equipment. UI elements should feel like physical controls — stamped, labelled, purposeful. This is conceptually appropriate given the NATO phonetic alphabet's origins in radio communication and aviation.

Key references explored: Teenage Engineering product design, Dieter Rams / Braun industrial design. Both share restraint, confidence, and a design language where every element earns its place.

### Prototype directions explored (superseded by the terminal direction)

- **Direction A — warm off-white / burnt orange:** Braun-inspired palette, monospaced type, progress meter as segmented pips. Name treatment: AlphaBravoCharlie.
- **Direction B — dark header / amber accent:** black header band with large wordmark, warm gray body, amber accent on active states and badges. Name treatment: NATO-1.
- **Direction C — pure monochrome:** full black background, white text and lines only, no accent colour. Emoji retain natural colour as the only chromatic element. Currently the most developed in prototype.

### Visual inspiration references

- Cargo Delivery UI Design — https://dribbble.com/shots/25542084-Cargo-Delivery-UI-Design
- Logistics Mobile App — https://dribbble.com/shots/25158792-Logistics-Mobile-App
- World Time Mobile App UI — https://dribbble.com/shots/26376023-World-Time-Mobile-App-UI
- Cargo Shipment App — https://dribbble.com/shots/25358376-Cargo-Shipment-App
- Cargo Shipment App UI — https://dribbble.com/shots/25784159-Cargo-Shipment-App-UI

### Shared principles across all directions

- Monospaced or semi-monospaced typography throughout
- Labels in uppercase with tight letter-spacing
- Hard corners or very subtle radius — nothing pill-shaped or bubbly
- Grid-aligned, mechanical spacing
- Progress indicators as hairline rules or minimal segmented elements
- No decorative elements — every element earns its place
- Type feels stamped or silkscreened, not typeset

### Name — not decided

Working name: NATO-1. Final name requires App Store strategy and naming research. Candidates considered: NATO-1, AlphaBravoCharlie, Foxtrot, Callsign, LEARN NATO. Note: Callsign is already used in the App Store.

### Terminal visual system [DECIDED]

**Color**
- Background: `#041302`
- Tappable (bright): `#12F6A1`
- Untappable (dim): `#1C835B`

Core rule: **brightness encodes affordance.** Bright means tappable now; dim means not. This governs every color choice. Under iOS Increase Contrast, both greens shift up together, preserving a visible gap — never collapse dim up to bright. A red family (brick / orange / brown) is reserved for errors and corrections only.

**Typography**
- Font: Intel One Mono (bundled, all weights in repo; Regular + Bold in use).
- Interface text is all caps, ~0.08em tracking.
- Bold is used only for title emphasis, never as an affordance signal — brightness alone carries tappability.

**Motion**
- Cursor blink: ~530ms per phase (1.06s cycle), step timing not fade. Only the `>` advance glyph blinks. Holds solid under Reduce Motion.

**Control grammar (system-wide)**
- `[BRACKETED]` chips = discrete controls (tabs, actions).
- A bright line with a trailing blinking `>` = advance/continue, and the line itself is the tap target.
- `!` = locked, tappable (opens the paywall / unlock explanation).

**App identity line.** Every top-level screen carries an app identity line as its top line: `NATO-1 --------------------- [SYS]`. App name dim and left-aligned, `[SYS]` bright and right-aligned, hyphens filling between via the column math. App-level (identical on all tabs); the entry point to system settings.

### Layout Rules

The interface uses a character-grid model: available width is measured, divided
by the width of one monospace column, and floored to a whole number of columns.
Content is composed in characters, not points.

**Rule 1 — Grid owns content, points own margins.**
Compute the column count from available width minus a minimum margin, multiply
back out to get the block's exact width, and center that block on screen. The
leftover fractional space splits evenly into the left and right margins, where
it's invisible, rather than accumulating on one edge where it clips content.
All screen content — rules, rows, titles, tab bar — shares one block and one
set of margins.

**Rule 2 — Odd remainders always favor the same side.**
When a centered element's leftover characters don't split evenly, the extra one
goes right. Everywhere, always. Consistency reads as intentional; alternating
reads as a bug.

**Rule 3 — Fixed content beats flexible fill.**
Labels, letters, and glyphs never compress or clip. Leaders and rules absorb all
variation and may shrink to zero characters. If something must be sacrificed,
it's always the fill. No truncation, no ellipsis characters, anywhere.

**Rule 4 — Below the floor, change layout instead of degrading.**
If fixed content alone exceeds the available columns, do not clip and do not
shrink type. Wrap onto multiple lines. Applies to batch rows, the header title
(drop flanking dashes first, then wrap), and the tab bar (stack vertically).
When a row wraps, drop its leader dots — a leader connects a label to a value
across a line, and once they're on separate lines it connects nothing.

**Measurement and rendering must always agree.** Column width is measured using
the same scaled font and tracking used to render, recomputed whenever Dynamic
Type changes. A cached or unscaled measurement produces a layout that silently
disagrees with what's on screen.

#### Known limitation — very large accessibility text sizes

At the largest Dynamic Type settings, rows wrap onto two lines. This is
functional but not elegant. A better approach is progressive abbreviation
(BATCH 1 → B1), which keeps rows on a single line and reads as more
terminal-authentic. Deferred because abbreviation is content-specific and must
be decided per screen, whereas wrapping is content-agnostic and works
system-wide. Revisit once Meet, Quiz, and Codex layouts are designed.

#### Header variation (idea, not yet designed)

Each top-level screen should have its own header treatment rather than all three
using the identical dashed-rule-and-centered-title pattern. The variation is
meant to make moving between screens feel more alive, and reflects how real
terminal programs each had their own banner style rather than a shared chrome.

Constraints: all headers stay on the character grid, use only the two greens,
and occupy roughly the same vertical space so the content below starts at a
consistent position. Variation is in the pattern, not the size.

Not yet designed. Revisit when Drill and Codex get real layouts.

#### Learn tab layout [DECIDED]

Top to bottom: app identity line; screen header (dashed rule, bold centered `LEARNING PROTOCOL` with flanking dashes to the edges, dashed rule); seven batch rows; tab bar.

Batch row: `BATCH N` + dim dotted leader + letters (unspaced, e.g. `ABCD`) + trailing glyph. Active batch is bright with a blinking `>`; locked batches are dim with a bright `!`. Leader dots are always dim, period + single space, and stay phase-aligned across rows (remainder padding trails; the leader ends on a period).

Tab bar: `[LEARN] [DRILL] [CODEX]` distributed edge to edge. The active tab is a dim-fill chip with no horizontal padding (fill hugs the character cells exactly, like inverse video). All-caps chips need slightly more top than bottom vertical padding for optical centering, scaled with type size. Light haptic on tab switch.

#### System settings dialog (SYS) [DECIDED]

App-wide settings, reached via `[SYS]` in the app identity line. Presented as a DOS TUI dialog box — a bordered box with a drop shadow, in the style of Turbo Pascal / Norton Commander. While open, the three tab chips are hidden (it's a layer you're inside of, not a peer destination) and `[SYS]` becomes `[EXIT]`.

- Implemented as a standalone view that *depicts* a floating box (background fills around it), not a composited overlay.
- Box and shadow are one monospaced character grid. The shadow is an L offset one cell down and one cell right (a column down the right edge, a row along the bottom), drawn as characters.
- Scroll model: fixed header + scrolling document. The top border line (`+=== SYSTEM SETTINGS ===...===[EXIT]===+`) stays pinned so `[EXIT]` is always reachable; below it the content scrolls as one long bordered sheet with the left/right borders scrolling with it and the bottom border appearing only at the end. The document's top edge aligns seamlessly under the fixed header.
- Border characters are always the single dim frame color; never inherit the color of an adjacent content row.
- (In progress at time of writing: the dialog's content is a temporary specimen sheet of ~95 divider styles being browsed to choose from.)

#### Status line [OPEN — highest-leverage next item]

A single bright line under the Learn header showing the ONE most important next action, and it is the primary tap target. Priority: resume an interrupted session → reviews due → start the next batch. Examples: `> RESUME BATCH 1 — MEET`, `> 12 DUE FOR DRILL`, `> START BATCH 2`. Replaces both the Resume card and the progress bar. Resolves several undesigned states at once.

#### Undesigned Learn-tab states [OPEN]

States the status line and a new row state must cover: session in progress; batch complete → next unlocked (needs a "done" row state + glyph — rows are currently only active or locked); reviews due; paywall; all complete; the old settings gear and progress indicator.

#### Batch 1 explainer (first run) [OPEN]

Shown once ever (UserDefaults flag). Needs designing against the column grid (body wraps at the column count and prints character-by-character across wrapped lines). Sequence: header prints → block cursor blinks alone ~1.5s → body prints ~30 char/sec → pause → closing line appears bright with a blinking `>`, and that line is the tap target to advance to Meet. Reduce Motion shows the full text at once. Copy:

    INITIATING LEARNING PROTOCOL
    BATCH 1: A B C D

    MEET EACH LETTER AND ITS CODE WORD. AN ASSOCIATION STORY WRITES IT TO MEMORY FASTER. THEN QUIZ YOUR NEW MEMORY....

    RECALL IS THE MISSION >

#### Landing tab changes over time [OPEN]

Learn is the landing tab during learning; once all batches are complete, Drill should probably become the landing tab. Revisit with the "all complete" state.

#### Migration note (prototype → real app)

The restyled Learn tab currently lives in `DesignPreview.swift` with hardcoded data, deliberately separate from the real `LearnHomeView` so layout bugs couldn't hide behind data/logic bugs. SwiftUI has no CSS-style separation of structure from style — appearance is the view code — so migration means moving the restyled structure into `LearnHomeView`, swapping `PreviewData` for the real AppState/NATOData, and extracting shared components (TerminalBatchRow, DashedRule, tab bar, dialog) into their own file so the preview and real views share one copy. Now that layout is solid, this is mostly mechanical.

---

## 8. Monetisation

- Batch 1 (A B C D) is free forever — enough to experience the full loop
- Batches 2–7 unlocked via a single one-time IAP at **$4.99**
- No subscription, no ads

### App Store positioning

The core value proposition: you pay once for a skill you keep forever. The SRS system should be explained in plain language — something like "learns what you know and what you don't, so you never forget." The finite, completable nature of the content is a key differentiator vs open-ended subscription apps.

App Store copy and screenshots should acknowledge the indie developer context. A note that the app is made by one person and that the purchase supports them directly builds trust with buyers who actively seek out indie software.

### App Store screenshot strategy — open

Screenshot content and order TBD. Likely themes: the learning flow, the SRS progress mechanic, the "master it forever" positioning, and the indie developer note.

---

## 9. Content — all 26 letters

All mnemonic content and encode word lists are confirmed. Mnemonics are vivid, specific, and slightly odd — unusual associations are more memorable than bland ones.

### Letter mnemonics and emoji

#### Batch 1 — A B C D

| Letter | Word | Emoji | Mnemonic |
|--------|------|-------|----------|
| A | Alpha | 🔺 | The first letter of the Greek alphabet — picture the letter A as a giant stone arch, the entrance to something ancient and important. Alpha. The beginning of everything. |
| B | Bravo | 👏 | A crowd on their feet, yelling "Bravo! Bravo!" — a single performer on stage, flowers raining down. The roar is deafening. B is Bravo. |
| C | Charlie | 🎩 | Charlie Chaplin — the tiny bowler hat, the twirling cane, the toothbrush mustache. The most famous Charlie who ever lived. C is Charlie. |
| D | Delta | ✈️ | A river delta spreading into the sea like a triangle — the Greek letter Δ stamped on the land from above. Or a Delta jet banking hard over the Mississippi. D is Delta. |

#### Batch 2 — E F G H

| Letter | Word | Emoji | Mnemonic |
|--------|------|-------|----------|
| E | Echo | 🏔️ | You shout into a canyon — your own voice comes bouncing back a second later, slightly ghostly. Echo. E is Echo. |
| F | Foxtrot | 🦊 | A fox in a tuxedo, doing a ballroom dance — the foxtrot. Perfectly dressed, gliding across the floor, ears perked. F is Foxtrot. |
| G | Golf | ⛳ | A lone golfer on an impossibly green course, squinting into the distance at a tiny flag. The satisfying thwack of the club. G is Golf. |
| H | Hotel | 🏨 | A grand hotel lobby — marble floors, a revolving door, a bellhop in a red uniform carrying a towering stack of luggage. H is Hotel. |

#### Batch 3 — I J K L

| Letter | Word | Emoji | Mnemonic |
|--------|------|-------|----------|
| I | India | 🐘 | A decorated elephant in a grand procession, moving through a city of colour and noise — the smell of spices, the sound of bells. I is India. |
| J | Juliet | 🌹 | Juliet on the balcony, moonlight, a single red rose, Romeo below in the shadows. The most famous J in all of literature. J is Juliet. |
| K | Kilo | ⚖️ | A perfect 1-kilogram weight sitting on a scale — dense, cold, precise. The kind of weight used to calibrate other weights. K is Kilo. |
| L | Lima | 🫘 | A bowl of lima beans — pale, flat, slightly waxy. The bean nobody asked for but everyone knows. Or Lima, Peru, high in the mountains above the clouds. L is Lima. |

#### Batch 4 — M N O P

| Letter | Word | Emoji | Mnemonic |
|--------|------|-------|----------|
| M | Mike | 🎤 | A stand-up microphone on a bare stage — one spotlight, nobody on stage yet. Or just Mike, the most average name for the most average guy, except he's holding a grenade. M is Mike. |
| N | November | 🍂 | November — grey skies, bare trees, the last of the leaves coming down. The month that feels like the world is exhaling before winter. N is November. |
| O | Oscar | 🏆 | The Oscar statuette — gold, bald, arms at its sides, staring blankly forward. A room full of people pretending not to care if they win. O is Oscar. |
| P | Papa | 👨 | Papa — your father, or someone else's, sitting in a big chair with a newspaper. Or the Papa in "Papa, can you hear me?" called across a field. P is Papa. |

#### Batch 5 — Q R S T

| Letter | Word | Emoji | Mnemonic |
|--------|------|-------|----------|
| Q | Quebec | 🍁 | Quebec City in winter — stone walls, snow, a French sign above a café door. The sound of French spoken with a Canadian lilt. Q is Quebec. |
| R | Romeo | 🗡️ | Romeo below the balcony — dramatic, lovesick, probably about to do something stupid. R is Romeo. (He and Juliet are in different batches on purpose.) |
| S | Sierra | 🏔️ | The Sierra Nevada — jagged granite peaks, pine forests, the smell of cold air at altitude. Sierra. The mountains that divide California from everything east of it. S is Sierra. |
| T | Tango | 💃 | Two dancers locked together, moving across a wooden floor in Buenos Aires — precise, slow, electric. The tango. T is Tango. |

#### Batch 6 — U V W

| Letter | Word | Emoji | Mnemonic |
|--------|------|-------|----------|
| U | Uniform | 👮 | A perfectly pressed uniform — brass buttons, creased trousers, polished shoes. The kind worn by someone who takes pride in looking exactly right. U is Uniform. |
| V | Victor | 🏅 | Victor on the podium — arms raised, gold medal swinging, the crowd going wild. The name means winner. V is Victor. |
| W | Whiskey | 🥃 | A glass of whiskey on a wooden bar — amber, still, a single ice cube slowly melting. The smell of peat and oak. W is Whiskey. |

#### Batch 7 — X Y Z

| Letter | Word | Emoji | Mnemonic |
|--------|------|-------|----------|
| X | X-ray | 🦴 | An X-ray clipped to a light box — your own skeleton staring back at you. Ribs, vertebrae, the ghostly outline of everything hidden inside. X is X-ray. |
| Y | Yankee | ⚾ | A Yankees cap — pinstripes, the interlocking NY, the smell of a baseball stadium on a warm evening. Or just a loud American tourist. Y is Yankee. |
| Z | Zulu | 🛡️ | A Zulu warrior in full ceremonial dress — cowhide shield, assegai spear, the deep thrum of voices. Or Zulu time — UTC, the clock all aviators use. Z is Zulu. |

---

### Encode words by batch

Words use only letters from unlocked batches. All spellings verified. Batch 1 has 4 words (all 3 letters, constrained set). All other batches have 3 words. Words are themed around military, aviation, maritime, and radio contexts where possible.

| Batch | Word | NATO spelling |
|-------|------|---------------|
| 1 — A B C D | CAD | Charlie · Alpha · Delta |
| | BAD | Bravo · Alpha · Delta |
| | CAB | Charlie · Alpha · Bravo |
| | DAB | Delta · Alpha · Bravo |
| 2 — + E F G H | BEACH | Bravo · Echo · Alpha · Charlie · Hotel |
| | BADGE | Bravo · Alpha · Delta · Golf · Echo |
| | CABBAGE | Charlie · Alpha · Bravo · Bravo · Alpha · Golf · Echo |
| 3 — + I J K L | FLAK | Foxtrot · Lima · Alpha · Kilo |
| | BLACK | Bravo · Lima · Alpha · Charlie · Kilo |
| | HIJACK | Hotel · India · Juliet · Alpha · Charlie · Kilo |
| 4 — + M N O P | FLANK | Foxtrot · Lima · Alpha · November · Kilo |
| | PHONE | Papa · Hotel · Oscar · November · Echo |
| | PINHOLE | Papa · India · November · Hotel · Oscar · Lima · Echo |
| 5 — + Q R S T | STORM | Sierra · Tango · Oscar · Romeo · Mike |
| | RECON | Romeo · Echo · Charlie · Oscar · November |
| | SORTIE | Sierra · Oscar · Romeo · Tango · India · Echo |
| 6 — + U V W | OUTPOST | Oscar · Uniform · Tango · Papa · Oscar · Sierra · Tango |
| | GUNWALE | Golf · Uniform · November · Whiskey · Alpha · Lima · Echo |
| | VECTORS | Victor · Echo · Charlie · Tango · Oscar · Romeo · Sierra |
| 7 — + X Y Z | MAYDAY | Mike · Alpha · Yankee · Delta · Alpha · Yankee |
| | FOXHOLE | Foxtrot · Oscar · X-ray · Hotel · Oscar · Lima · Echo |
| | BLIZZARD | Bravo · Lima · India · Zulu · Zulu · Alpha · Romeo · Delta |

---

## 10. Open questions and deferred decisions

### Saved for later — not yet designed

- **Login and account flow** [OPEN] — Not designed. Needed for cross-device sync. iCloud is the likely solution for v1.
- **Custom words** [OPEN] — User can add their name or personal words to the drill queue. Stored locally on device, validated against unlocked letters. Potential premium feature.
- **Mini-games** [OPEN] — Live in maintenance phase, unlocked at full mastery. Design TBD.
- **Mastery celebration screen** [OPEN] — One-time special screen when all 26 letters hit Mastered. Design TBD.
- **Onboarding** [OPEN] — First-launch experience not yet designed.
- **Paywall and IAP flow** [OPEN] — Locked batch experience and purchase flow not yet designed.
- **Codex design** [OPEN] — Renamed from Codebook. DOS-terminal visual pass TBD; the dotted-leader directory row format is a candidate.
- **App Store strategy and name** [OPEN] — Naming, positioning, screenshot strategy, and search strategy TBD.
- **Visual direction** [DECIDED] — DOS terminal. See section 7.
- **Listening practice** [OPEN] — Future version: user hears a NATO word spoken aloud and identifies the letter. The reverse skill — easier than production but useful for comprehension.
- **Microphone input button** [OPEN] — Future version: a large prominent microphone button allows spoken responses via phone STT, making the app feel closer to real radio/voice practice.
- **App Store screenshot strategy** [OPEN] — Content and order TBD.

### Interrupted session behaviour — deferred

The following edge cases are unresolved and need decisions before build:
- If user stops mid-Meet: restart the whole step or resume from the last letter seen?
- If user stops mid-Quiz or mid-Encode: save partial progress or restart the step?
- Do tier drops that occurred mid-session stand if the session is abandoned?
- What constitutes an abandoned session vs a deliberate quit?
- App crash vs deliberate quit — should these be handled differently?

### Decided — not open

- **Production-only testing** [DECIDED] — The app tests letter → NATO word only. Recognition is trivially easy and not worth training.
- **No failure state in learning phase** [DECIDED] — Wrong answers resurface but do not fail the session.
- **One tier penalty per card per session** [DECIDED] — Multiple wrong answers on the same card carry no additional penalty beyond the first.
- **Resurfacing mechanics** [DECIDED] — Wrong answers resurface once at the end of the first pass. Getting it right in the same session does not restore the tier drop.
- **Encode not SRS-tracked** [DECIDED] — Encode cards are a bonus mechanic. Only letter cards affect SRS tiers.
- **Interval starts on correct answer** [DECIDED] — Timer starts from the moment of the correct answer, not from when the card was due.
- **Missed sessions carry no penalty** [DECIDED] — Cards queue up and wait. No additional punishment for missing a day.
- **Encode practice rounds** [DECIDED] — 5 words per round, random from unlocked letters, option to repeat.
- **Hint behaviour** [DECIDED] — Hint shown briefly after wrong answer, then cleared before next attempt — not pre-loaded on resurface.
- **Batch structure** [DECIDED] — 5 batches of 4 letters, 2 batches of 3 letters. Total 7 batches, 26 letters.
- **Free batch** [DECIDED] — Batch 1 (A B C D) is free. All others require IAP.
- **One-time IAP** [DECIDED] — No subscription. Single purchase at $4.99 unlocks all remaining batches.
- **Mnemonic and image content** [DECIDED] — All 26 letters have confirmed mnemonics and emoji. See section 9.
- **Encode word lists** [DECIDED] — All 7 batches have confirmed encode words. Batch 1 has 4 words, all others have 3. See section 9.

---

## 11. Technical notes

- **Platform:** iOS (iPhone), distributed via the App Store
- **Framework:** SwiftUI / Swift
- **Repository:** https://github.com/theinfonaut/NATO-1 (private)
- **Prototype:** Web-based React prototype built in Claude chat for flow validation
- **Speech-to-text:** Not built into the app. The phone keyboard's microphone input handles this natively.
- **Data persistence:** SRS state, batch progress, and tier levels stored on-device. iCloud sync TBD for cross-device support.
- **IAP:** Single one-time purchase at $4.99 via Apple's StoreKit. Apple takes 30% (15% under Small Business Program).
- **No server required for v1** — all data is local to the device.

---

*NATO-1 Design Specification — working document — update as decisions are made*
