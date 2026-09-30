# Training log

Single-page workout tracker for the 4-day Upper / Lower / Push / Pull programme.
Same stack as the car booking app: one `index.html`, Supabase (free tier) as the database, hosted on GitHub Pages. No backend, no build step.

## What it does

- **Today:** pick a session (the next one in the rotation is marked "Up next"). Each exercise shows its target sets, reps, rest and effort, what you did last time, and a progression call:
  - every set hit the top of the rep range last time → **Add weight** with the suggested load
  - otherwise → stay at the same weight and add reps
- Log each set with weight and reps, then tap ✓. It saves to Supabase immediately, so closing the tab mid-session loses nothing. Leaving the weight blank uses the suggested weight. Tap ✓ again to undo a set; edit a ticked set's numbers and it re-saves.
- A **rest timer** starts after every logged set, using that exercise's rest time. It vibrates when rest is over (Android; iOS Safari doesn't support vibration).
- **Return ramp** toggle: one fewer set per exercise for the first two weeks back.
- **History:** your last 40 finished sessions, with every set.
- **Progress:** estimated 1RM (Epley) trend and top set per session for any exercise.

## Setup (about 10 minutes)

### 1. Supabase

Use a new project, or add the tables to the car booking project. The free tier allows two active projects, and the table names don't clash.

1. In Supabase, open **SQL Editor → New query**, paste the contents of `schema.sql`, and click **Run**.
2. Go to **Project Settings → API** (called **API Keys** on newer dashboards) and copy:
   - the **Project URL**
   - the **anon public** key (newer projects call it the **publishable** key, starting `sb_publishable_`; either works)
3. Open `index.html` and paste them into the two constants at the top of the script:
   ```js
   const SUPABASE_URL = "https://xxxx.supabase.co";
   const SUPABASE_ANON_KEY = "your-key";
   ```

### 2. GitHub Pages

1. Create a new repository, e.g. `training-log`.
2. Upload `index.html` (and optionally this README and `schema.sql`).
3. Go to **Settings → Pages → Build and deployment**, set **Source: Deploy from a branch**, **Branch: main, / (root)**, and save.
4. After a minute the site is live at `https://<your-username>.github.io/training-log/`.
5. On your phone, open it and use **Add to Home Screen** so it opens like an app.

## Changing the programme

Edit the `PROGRAMME` object near the top of the script. For each exercise:

| Field | Meaning |
|---|---|
| `id` | Key stored in the database. Keep it unchanged if you only rename an exercise, or its history is lost. |
| `sets`, `min`, `max` | Working sets and rep range |
| `rest` | Rest timer in seconds |
| `inc` | Load jump (kg) suggested when you hit the top of the range on every set |
| `compound` | `true` = 1–2 reps in reserve, otherwise last set to failure |
| `note`, `superset` | Optional notes shown under the exercise |

The same `id` used on different days (e.g. `cable-lateral-raise`) shares history, so "last time" shows your most recent sets wherever you did them.

## Notes

- **Privacy:** like the car booking app, there's no login. Anyone with the page URL can see the key in the source and read or edit the log. Fine for a personal gym log. If you ever want it locked down, the fix is Supabase Auth plus per-user RLS policies.
- **Inactivity:** Supabase pauses free projects after about a week of no requests. Training four days a week keeps it awake. If it does pause, restore it from the dashboard.
- **Pull-ups:** log added weight only (0 for bodyweight), so the progression logic works.
