# Manik — Product Spec

First approved: 2026-07-15 (two cabinets: master + client).
Rewritten: 2026-10-09 for the **master-only pivot** (independent cabinets, one per master). The two-cabinet version lives in git history;
the full pivot design (alternatives, data model detail, open points) is
`docs/superpowers/specs/2026-10-09-master-only-pivot-design.md`. Until PRs M-31…M-38 land
(`docs/plan.md`, item 9), the code is partway there: since M-30 there is no client side and every
account is an independent master, but the Schedule still runs on the old `blocks` model until M-33.

## Goal

An iOS app for nail masters. Each master signs up and gets an independent cabinet: her client base,
her free windows, her bookings and her personal plans in one calendar. It replaces the Notes list she keeps today and the screenshot she posts to
Instagram. Clients never use the app — they write to the master in Instagram (or by phone), and
the master books them herself.

## Scope

- One SwiftUI app; every user is a master. Sign-up and sign-in (email + password), forgot password,
  change password, delete account (App Store requires in-app deletion). No roles, no salons.
- Firebase Auth + Cloud Firestore; all of a master's data lives under `users/{uid}/`, readable and
  writable only by her.
  Kept behind repository protocols so it can be swapped for SwiftData + CloudKit later.
- No push notifications, no reminders, no payments, nothing sent automatically to Instagram.
- Light and dark themes (System / Light / Dark, per device, from a round button next to the
  "Статистика" title).

## Data model (Firestore)

```
users/{uid}              name, email                                       — created at sign-up
… and under it:
clients/{autoId}         name?, instagram? (lowercased, no "@"), phone? (+48 + 9 digits),
                         createdAt, lastBookedAt?          — name or instagram required
slots/{yyyy-MM-dd_HHmm}  date, time, clientId?, serviceId?, serviceName?, servicePrice?
                         — no client = free window; id from date+time, so no duplicates
events/{autoId}          title, startTime, endTime, date? | weekdays[] + fromDate, skippedDates[]
eventTemplates/{autoId}  title, startTime, endTime, weekdays[]            — "Мої справи"
services/{autoId}        name, price (whole PLN), isFavorite?
```

A slot is a **date + start time**; visits have no duration. Booking sets `clientId` and a snapshot
of the service; cancelling clears them (the window is free again); rescheduling moves the booking
to another date/time in one batch and frees the old window.

## Navigation

Three tabs: **Розклад / Клієнтки / Статистика**. "Мої послуги" and "Мої справи" are entries inside
Статистика ("set up once" screens), "Мої справи" also from the personal-plan sheet.

## Flows

1. **Clients** — add a client by Instagram handle and/or name (+ optional phone). Search by name,
   handle or phone. The card opens the Instagram DM (`https://ig.me/m/<handle>`) or, without a
   handle, calls / texts the phone.
2. **Free windows** — "+" → "Вільні вікна на місяць": select several days on a month grid, pick
   hours, add them all at once. Repeat for days with other hours.
3. **Publish** — "Надіслати графік": the free windows from today as a 9:16 image for stories
   (list layout, one line per day: `1.10 Чт 10:00 · 13:00 · 16:00`) and as text for DMs/SMS.
   "Надіслати прайс" does the same for the price list.
4. **Book** — tap a free window → search focused, recent clients first; if nobody matches,
   "Додати @…" creates the client and books her in one tap; the service is optional (favourites
   first).
5. **Booking actions** — tap a booked slot → Перенести (to a free window or own time), Написати,
   Скасувати запис. Where the recipient is known, "Надіслати @нік" copies the message and opens her
   chat; the master pastes and sends.
6. **Personal plans** — "Своя справа" (boxing, gym): title, start–end, one date or weekly on chosen
   days, filled from the "Мої справи" list in one tap. A free window that overlaps a plan (assuming
   a 60-minute visit) is flagged and left out of what is published; it is not deleted.

## Statistics (calendar month, navigable back)

- **Revenue** — sum of `servicePrice` over booked slots that already happened.
- **Expected** — the same over all booked slots of the month, past and future; hidden for a
  finished month.
- **Visits** — booked slots that already happened. **Clients** — distinct `clientId` among them.
- **Free windows** — in the current month the ones still ahead; in a past month the unbooked ones.
- **Comparison with the previous month** — money (percent) and clients (count), full calendar
  months; hidden when the previous month earned nothing.
- No "hours worked": visits have no duration.

## Out of scope

Client accounts or a client app; salons or data shared between masters; automatic sending to Instagram; WhatsApp; push notifications and
reminders; payments; service durations; reviews, portfolio; price ranges;
no-show status; per-service statistics; a client-facing web page (possible later).
