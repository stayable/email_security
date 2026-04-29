# Email / Message Reports

Drop individual email artifacts here for analysis (suspicious messages, quarantine exports, headers, phishing samples).

## Expected file types

- `.eml` — exported message (preferred; preserves headers + body)
- `.msg` — Outlook message export
- `.txt` — pasted full headers (use when only headers are available)
- `.png` / `.pdf` — screenshots of suspect mail (last resort; cannot be auth-analyzed)

## Naming convention

```
YYYY-MM-DD_<recipient>_<short-description>.eml
```
Examples:
- `2026-04-29_rb_fake-wire-request.eml`
- `2026-04-29_allysa_vendor-bank-change.eml`

## Organization (optional)

```
reports/email/
├── quarantine/      # exports from security.microsoft.com → Quarantine
├── phishing/        # confirmed phishing / impersonation samples
├── false-positives/ # legit mail that got quarantined incorrectly
└── headers-only/    # pasted header dumps
```

## What to capture for each suspicious email

- Full message source (File → Save As → .eml in Outlook, or "View source" in OWA)
- Authentication-Results header (shows SPF / DKIM / DMARC / compauth verdicts)
- Received chain (true sending IP)
- Return-Path / envelope sender vs. visible From
- Any links/attachments (do **not** click; record URLs only)

## Analysis checklist

1. Did SPF / DKIM / DMARC pass or fail? (Authentication-Results header)
2. Is the From domain spoofed, look-alike (e.g. `rise8compaines.com`), or display-name only?
3. Did the Defender impersonation policy fire? (`X-Forefront-Antispam-Report`, `X-Microsoft-Antispam`)
4. Was it correctly routed to Quarantine / Junk / Inbox?
5. Action: release, report as phishing, block sender, or tune policy
