# TRAP LOGGER home-screen app on your .in domain

Time: about 30 minutes, plus up to 24 hours for the domain to go live. Cost: the domain only. Hosting is free.

## What you get
- A web page on your own address, for example **https://traplogger.in**.
- Shooters add it to the iPhone home screen. It opens full screen like an app and **works with no signal**.
- Each phone keeps its own accounts and rounds. Nothing is sent to a server.

## Files to upload (7)
`index.html`, `sw.js`, `manifest.webmanifest`, `apple-touch-icon.png`, `icon-192.png`, `icon-512.png`, `icon-maskable-512.png`

## 1. Buy the domain
1. Pick a registrar that sells **.in** domains. GoDaddy, BigRock, Hostinger and Namecheap do.
2. Search a name, for example **traplogger.in**. Buy it.
3. Check the **renewal price** at checkout. It is often higher than the first year.
4. Turn on **auto-renew**.

## 2. Put the files on GitHub
1. On **github.com**, create a repository named **trap-logger**. Set it to **Public**.
2. Tap **uploading an existing file**. Add all 7 files. Tap **Commit changes**.
3. Open **Settings**, then **Pages**. Source: **Deploy from a branch**. Branch **main**, folder **/ (root)**. Tap **Save**.

## 3. Connect your domain
1. In **Settings, Pages, Custom domain**, type your domain (for example `traplogger.in`). Tap **Save**. Do this before the DNS step.
2. At your registrar, open **DNS settings**. Delete any default "parking" records for `@` and `www`.
3. Add four **A** records. Name `@`. Values:
   - `185.199.108.153`
   - `185.199.109.153`
   - `185.199.110.153`
   - `185.199.111.153`
4. Add one **CNAME** record. Name `www`. Value `YOURNAME.github.io` (your GitHub username, no repo name).
5. Wait. It can take up to **24 hours**. Usually under an hour.
6. Back in **Settings, Pages**, tick **Enforce HTTPS**. The box can take a while to appear. The app needs HTTPS to install and work offline.

## 4. Install on the iPhone
1. Open your domain in **Safari**.
2. Tap **Share**, then **Add to Home Screen**, then **Add**.
3. Open the app **from the home screen icon**.
4. Tap **Create account** there.

Safari and the home-screen icon keep **separate data**. Create the account inside the icon, not in Safari.

Android: open the domain in Chrome. Tap the menu, then **Install app**.

## 5. Protect your data
- Rounds live **only on that phone**. Deleting the app or clearing its data erases them.
- Open **Rounds**, then **Export all rounds CSV**, after each session or each week. Save the file to Files or email it to yourself.
- Capri Studio cannot see shooters' rounds in this version. Shooters send you their CSV if they want you to analyse it.

## 6. Update the app later
Upload the new `index.html` and `sw.js` to the same repo. Phones pick up the update the next time they open the app with signal. Close and reopen the app once if the old version shows.
