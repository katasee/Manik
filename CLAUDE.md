# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

Build (must succeed before considering any change done):

```bash
cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build
```

When Xcode is open on the project, add `-derivedDataPath <a scratch folder>` to that command:
sharing Xcode's DerivedData makes both builds fail ("database is locked", then Xcode's "invalid
reuse after initialization failure" until Clean Build Folder).

There is no test target, linter, or formatter configured yet.

## Project

Manik is an iOS calendar for nail masters: each master signs up and gets an independent cabinet
(her data under `users/{uid}/`) with her client base, free windows, bookings and personal plans;
clients never use the app (they write to her in Instagram and she books them). SwiftUI + Firebase
(Auth + Firestore). It was a two-cabinet booking app (one master / clients) until the 2026-10-09
pivot; the code moves over PRs M-30…M-38 (`docs/plan.md`, item 9) — since M-30 the client cabinet
is gone; since M-33.1 the Schedule is a day list of `slots`, and only Статистика still reads the
old `blocks` model, until M-38. Full product spec —
data model, screen flows, out-of-scope list — lives in
`docs/superpowers/specs/2026-07-15-manik-mvp-design.md`; keep it in sync with any product decision
that changes scope, not just this file.

**Current implementation status and the ordered next-steps checklist live in `docs/plan.md`.**
Check it at the start of a session to see what's done and what's next, and update it (check off /
add / reorder steps) whenever that changes — it's what lets work resume consistently from any
machine or terminal, not just this conversation.

**Don't edit `docs/plan.md` or a feature's `docs/superpowers/specs/`/`docs/superpowers/plans/`
files after every small back-and-forth while a feature is still being worked on** (e.g. a follow-up
tweak, a rename, a "why do we need this file" question mid-implementation). Batch those doc
sync-ups to once, at the end, when the feature itself is actually settled — editing docs on every
turn multiplies unrelated diff churn and burns time out of proportion to keeping the doc
turn-by-turn current.

**All project documentation is written in English** — `docs/plan.md`, spec and plan files, commit
messages, code comments if any are ever added. This holds regardless of the language the working
session is being held in, which is what caused the drift it replaces: `docs/plan.md`'s "Done"
entries are English through PR10 and Ukrainian from PR11 on, because each was written in whatever
language that day's conversation used, while the structural sections stayed English throughout.
Ukrainian survives only where it is *data* rather than prose — quoted UI strings ("Мої послуги",
"+ Додати вільний час"), which must stay verbatim so they can be grepped against the String
Catalog. Pre-PR11 entries were **not** retro-translated: that would be a thousand-line diff over
history that is read rarely and changed never, and it would blur the record of decisions the file
exists to preserve. So expect to read Ukrainian in older entries; just don't write any new.

**A feature's `docs/superpowers/plans/` and `docs/superpowers/specs/` files are throwaway working
artifacts — delete them once that feature is finished (implemented and merged).** They exist to
plan and design a feature before the code does; after the code lands, the code is the source of
truth and these files are just stale duplication. Two files are the exception and must stay:
`docs/superpowers/specs/2026-07-15-manik-mvp-design.md` (the product-wide MVP spec, referenced
above) and `docs/plan.md` (the living status checklist, which is not a superpowers artifact).

## Feature workflow

Every new feature (or PR from `docs/plan.md`) goes through the same pipeline without the user
having to ask for it:

1. `superpowers:brainstorming` — agree on the design, unless the feature's spec already settles it.
2. `superpowers:writing-plans` — write the plan to `docs/superpowers/plans/`.
3. `swiftui-pro` — review the Swift code in the plan, and fold the accepted fixes into the plan
   before any implementation starts.
4. Implementation — **Claude writes the code, the user reads** (user decision, M-33.1, replacing
   M-32.5's "the user writes, Claude coaches": writing every gap with dosed hints was slow and
   still did not stick). Claude implements the plan task by task and runs its check (a throwaway
   `swiftc` script in the scratchpad, or the build). After each task Claude explains the one or two
   decisions in it worth remembering — briefly, not a lesson — then asks 2–3 questions about it and
   waits for all the answers before the next task.

## Git

**The user creates branches, commits and pushes themselves.** Don't run `git switch -c`/`git branch`,
`git commit` (including `--amend`) or `git push`, and don't merge or cherry-pick into `main` —
leave the changes in the working tree and say what is ready to commit. Read-only git (`status`,
`diff`, `log`) is fine. If a skill's workflow says to commit after a step, skip that step and
mention it instead.

**At the end of every PR, give the user a short PR description, entirely in English** — including
screen and button names ("Reschedule", "Send schedule", "Schedule"), which are translated here
rather than quoted in Ukrainian as in `docs/plan.md`: the description is read on GitHub, not
grepped against the String Catalog. A Markdown block ready to paste: a one-line title, what the
user gets, the key changes as bullets, how it was verified. No attribution line.

## Conventions

Detailed conventions live in topic files — all still load at launch:

- @.claude/conventions/architecture.md — MVVM + Repository, DI, `@Observable`, feature-folder layout
- @.claude/conventions/data-layer.md — Block model, `DateFormat`, Firestore encoding, realtime, security rules
- @.claude/conventions/code-style.md — argument formatting, localization, fonts
- @.claude/conventions/firebase.md — Firebase SDK package, `GoogleService-Info.plist`
