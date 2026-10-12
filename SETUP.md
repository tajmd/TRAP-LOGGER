# TRAP LOGGER Ver 6.1 setup

One database serves the GitHub web page and the Apple app. An account made on one works on the other.

## What changed in Ver 6.1

| Change | Result |
|---|---|
| Bigger, bolder text | Base size 17 px. Bold labels, buttons and tables. |
| One database | Accounts and rounds live in Supabase. GitHub, iPhone and Mac read the same data. |
| Forgot password | Email sends a code. Type it in the app and set a new password. |
| Data kept | Every target saves on the phone first. It uploads when you are online. The app opens with no signal. |
| Round summary | After target 25 the page scrolls to **1st Hit**, **2nd Hit** and **Miss** counts. |
| Weather | Fills from your location when a round starts. Type values yourself at any time. |
| Analysis tab | Every user sees analysis of their own rounds. |

**Old accounts do not move.** Accounts made in earlier builds lived only on one phone. Create them again. Export old rounds to CSV first.

## A. Supabase (one time, free, 20 minutes)

1. Go to **supabase.com**. Sign up. Tap **New project**.
2. Name **trap-logger**. Region **South Asia (Mumbai)**. Plan **Free**. Save the database password.
3. Wait 2 minutes.
4. Open **SQL Editor > New query**. Paste all of `schema.sql`. Tap **Run**. You see "Success".
5. Open **Authentication > Sign In / Providers > Email**. Turn **Confirm email** OFF.
6. Open **Authentication > Email Templates > Reset Password**. Replace the body with:

```html
<h2>Reset your TRAP LOGGER password</h2>
<p>Your code: <b>{{ .Token }}</b></p>
<p>The code works for 1 hour.</p>
<p>Or <a href="{{ .ConfirmationURL }}">open this link</a> on the same phone.</p>
```

Tap **Save**. The code line is the part the app needs.

7. Open **Authentication > URL Configuration**. Set **Site URL** to your GitHub link. Add the same link under **Redirect URLs**.
8. Open **Project Settings > API**. Copy the **Project URL** and the **anon public key** (starts with `eyJ`, or `sb_publishable_`).

## B. Edit config.js (one time)

Open `config.js` in any text editor. Replace the three values. Keep the quote marks.

```js
window.TRAP_CONFIG = {
  url: "https://abcdxyz.supabase.co",
  key: "eyJ...your key...",
  site: "https://YOURNAME.github.io/trap-logger/"
};
```

**Use this same edited file for GitHub and for the Apple app.**

## C. Upload to GitHub

1. Open your repository on **github.com**.
2. Tap **Add file > Upload files**.
3. Drag in **all files** from this folder, except `SETUP.md` and `schema.sql` (optional). Include your edited `config.js`.
4. Tap **Commit changes**. Same names replace the old files.
5. Wait 1 minute. Open your link. Close the page fully, then open it again to load the new version.

On an iPhone with the old home-screen icon: open the link in Safari once. Close Safari. Open the icon.

## D. Make yourself the owner

1. Open the page. Tap **Create account** with **taj@tajmahalgp.com**.
2. In Supabase **SQL Editor**, run once:

```sql
insert into public.admins (user_id)
select id from auth.users where email = 'taj@tajmahalgp.com'
on conflict do nothing;
```

3. Reload. The **Admin** tab shows all shooters, rounds, analysis and CSV export.

## E. Email delivery

Supabase sends 2 emails per hour on the free built-in sender. That is too low for a club.

1. Create a free account at **brevo.com** or **resend.com**.
2. In Supabase open **Authentication > Emails > SMTP Settings**.
3. Enter the SMTP details from that service.

## Good to know

- **Public key:** the anon key is public by design. Database rules keep each shooter's data private.
- **Owner access:** owners read every shooter's data. They cannot edit or delete it.
- **Free plan pause:** Supabase pauses a free project after a week of no use. Open the dashboard and tap **Restore**.
- **Delete account:** shooters delete their account and rounds from the Profile tab.
- **Weather:** the page uses the free Open-Meteo service. It needs a connection and location permission.
- **Update later:** upload a new `index.html`. Keep your `config.js`.
