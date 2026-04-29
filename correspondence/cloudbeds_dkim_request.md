# Cloudbeds Support — Custom Domain DKIM Authentication Request

**To:** support@cloudbeds.com (or via Cloudbeds in-app support / help center)
**From:** bke@rentstayable.com
**Subject:** Request to enable custom-domain (DKIM) authentication for rentstayable.com — DMARC alignment

---

Hi Cloudbeds Support,

I'm reaching out on behalf of **Stayable** (property: rentstayable.com / RISE8 Companies). We use Cloudbeds as our PMS and Cloudbeds is sending guest-facing email on our behalf as `@rentstayable.com`.

We're in the middle of an email security hardening project across our organization in response to active **business email compromise (BEC) and spoofing attempts** targeting our executives — Microsoft Defender logged 309 spoofing attempts against our tenant in a single 7-day window. As part of that hardening, we have:

- Enabled SPF with hard-fail (`-all`) on rentstayable.com
- Enabled DKIM signing in Microsoft 365
- Published a DMARC record at `p=quarantine` with strict alignment (`adkim=s; aspf=s`), with a planned move to `p=reject` once all legitimate senders are confirmed aligned

Reviewing our DMARC aggregate reports, I can see that **mail sent through Cloudbeds is currently failing DMARC** because:

- DKIM is signed with `d=cloudbeds.com` (or via SendGrid's shared `em622.cloudbeds.com` domain)
- SPF envelope return-path is on a Cloudbeds/SendGrid-owned domain
- Neither aligns with our visible `From:` domain `rentstayable.com`

Today this means recipients (Gmail, Microsoft, etc.) are quarantining that mail. Once we move to `p=reject`, those messages will be **rejected outright** — including booking confirmations, guest communications, and operational notifications going to our customers.

### What we'd like enabled

Could you please enable **custom-domain authentication** (sometimes called "Send via your domain", "domain authentication", or "white-labeled sender") for our Cloudbeds account so that outbound mail signs with `d=rentstayable.com` and aligns properly under DMARC?

Specifically:
- Provide the DKIM CNAME records we need to publish on `rentstayable.com` (typically 3× SendGrid-style records: `s1._domainkey`, `s2._domainkey`, and an `em####` link domain).
- Let us know if there are any other DNS entries (return-path/MX, custom tracking domain, etc.) we should add.
- Confirm whether this is a self-service toggle in our Cloudbeds dashboard, or whether your team needs to enable it on the back end.

### Account details

- **Property name:** [Kyle to fill in — Cloudbeds property name]
- **Account email / admin:** [Kyle to fill in]
- **Domain to authenticate:** rentstayable.com
- **Sending From addresses observed:** [list any specific addresses, e.g., reservations@rentstayable.com]

### Urgency

We'd like to complete this before flipping our DMARC policy to `p=reject` (target: within the next 7 days). Any guidance on how quickly we can get this provisioned and what we need to publish on our side would be greatly appreciated.

Happy to provide our DMARC aggregate report XML showing the current Cloudbeds rows failing alignment if that helps your team verify.

Thank you,

Kyle Estocapio
IT / Email Security Lead — Stayable / RISE8 Companies
bke@rentstayable.com

---

## Notes for Kyle before sending

- Fill in the bracketed account details (property name, account admin email, specific From addresses).
- If Cloudbeds has a customer portal ticketing system, paste the body in there rather than emailing — they tend to route faster through their portal.
- Attach one of the DMARC XML reports showing the Cloudbeds failure (e.g., `reports/email/mail_report_04-29-2026/google.com!rentstayable.com!1777334400!1777420799.zip`, record for IP `167.89.63.41`) — concrete evidence often shortcuts the support back-and-forth.
- If they say "this isn't supported on your plan," ask specifically about **SendGrid sender authentication** (Cloudbeds uses SendGrid under the hood; SendGrid supports custom-domain auth on every paid plan). That's usually the unlock.
