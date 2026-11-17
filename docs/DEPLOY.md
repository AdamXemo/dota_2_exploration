# Deploying the dashboard (optional)

The app runs fine locally (`shiny::runApp("app")`). To get a URL you can open on your phone
between games, the free option is **shinyapps.io** (Posit's Shiny hosting).

## shinyapps.io (free tier, ~25 active hours/month)
1. Create an account at https://www.shinyapps.io and copy the token from *Account → Tokens*.
2. In R (once):
   ```r
   install.packages("rsconnect")
   rsconnect::setAccountInfo(name = "<account>", token = "<token>", secret = "<secret>")
   ```
3. Deploy from the repo root. The app reads `../data`, so deploy the **whole repo** and point
   the app to `app/`:
   ```r
   rsconnect::deployApp(appDir = ".", appPrimaryDoc = "app/app.R", appName = "dota-carry-lab")
   ```
   If shinyapps.io rejects the layout, the simple fallback is to copy `data/` into `app/data/`
   before deploying. `config.R` checks for a `data/` folder next to the app first.
4. `rsconnect/` (deploy metadata) is already in `.gitignore`.

## Notes
- **My Stats** calls OpenDota from the server. Your account id goes in the box, or as an
  environment variable `DOTA_ACCOUNT_ID` in the shinyapps.io dashboard (never commit `.Renviron`).
- The free OpenDota tier is rate-limited (~60 req/min); the item-timing check uses 8 requests.
- The deployed app shows the committed snapshot. Redeploy after refreshing the data.
