# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

Build (must succeed before considering any change done):

```bash
cd Manik && xcodebuild -scheme Manik -destination 'generic/platform=iOS Simulator' build
```

There is no test target, linter, or formatter configured yet.

## Project

Manik is a Booksy-style iOS booking app for a single nail salon master. SwiftUI + Firebase
(Auth + Firestore), one app with two role-gated cabinets (master / client). Full product spec —
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

**A feature's `docs/superpowers/plans/` and `docs/superpowers/specs/` files are throwaway working
artifacts — delete them once that feature is finished (implemented and merged).** They exist to
plan and design a feature before the code does; after the code lands, the code is the source of
truth and these files are just stale duplication. Two files are the exception and must stay:
`docs/superpowers/specs/2026-07-15-manik-mvp-design.md` (the product-wide MVP spec, referenced
above) and `docs/plan.md` (the living status checklist, which is not a superpowers artifact).

## Conventions

Detailed conventions live in topic files — all still load at launch:

- @.claude/conventions/architecture.md — MVVM + Repository, DI, `@Observable`, feature-folder layout
- @.claude/conventions/data-layer.md — Block model, `DateFormat`, Firestore encoding, realtime, security rules
- @.claude/conventions/code-style.md — argument formatting, localization, fonts
- @.claude/conventions/firebase.md — Firebase SDK package, `GoogleService-Info.plist`
