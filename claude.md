# Email Security Hardening Project — RISE8 Companies

> **Project context for Claude Code.** This file documents the email security hardening work performed on `rise8companies.com` and `rentstayable.com`. Use this for follow-up work, troubleshooting, monitoring, or extension of the project.

---

## TL;DR

Locked down email security on both RISE8 domains in response to active BEC/wire fraud risk. Rob (CEO) was receiving spoofed phishing emails impersonating his own address. Defender showed **309 spoof attempts in the prior 7 days** confirming active targeting. Phase 1 (DNS hardening) and Phase 2 (Defender impersonation protection) are deployed. Final transition from DMARC `p=quarantine` to `p=reject` scheduled for Day 7 after clean monitoring.

---

## Project Owner & Stakeholders

- **Project lead:** Kyle (bke@rentstayable.com)
- **CEO / approver:** Rob Beyer (rb@rise8companies.com)
- **Procurement:** Kate (kate@rentstayable.com)
- **Hosting / DNS:** SiteGround (both domains)
- **Email platform:** Microsoft 365 (Outlook / Exchange Online)
- **Region:** US-based business; project lead currently in PH

---

## Core Domains in Scope

1. **rise8companies.com** — RISE8 Companies parent / corporate
2. **rentstayable.com** — Stayable extended-stay hotel brand

Both use Microsoft 365 for primary mail flow with separate transactional senders.

---

## Phase 1 — DNS-Level Hardening (Complete)

### Audit findings (pre-fix)

| Issue | Domain | Severity |
|---|---|---|
| SPF syntax broken (`one.zoho.com-all` glued together, no space) | rise8companies | Critical |
| Two conflicting root SPF records (RFC 7208 permerror) | rentstayable | Critical |
| DMARC at `p=none` (no enforcement) | both | Critical |
| DKIM CNAMEs published but signing not enabled in M365 | both | High |
| Stale Zoho CRM/Desk records (unused services) | both | Medium |

### Fixes applied

#### DKIM
Enabled in **security.microsoft.com → Email & collaboration → Policies & rules → Threat policies → Email authentication settings → DKIM**. CNAMEs were already published; only the toggle needed flipping.

#### Final SPF records

**rise8companies.com (root TXT):**
```
v=spf1 include:spf.protection.outlook.com include:adobesign.com -all
```

**rentstayable.com (root TXT):**
```
v=spf1 include:spf.protection.outlook.com include:amazonses.com -all
```

Both use `-all` (hard fail) — required for DMARC enforcement to actually reject spoofs.

**rise8companies.com also has a separate subdomain SPF for Resend (investor portal):**
- Host: `send.rise8companies.com`
- Value: `v=spf1 include:amazonses.com ~all`
- This is the envelope return-path domain for Resend; intentional and correct.

#### Final DMARC records

**rise8companies.com (`_dmarc.rise8companies.com` TXT):**
```
v=DMARC1; p=quarantine; sp=quarantine; adkim=s; aspf=s; pct=100; rua=mailto:dmarc-reports@rise8companies.com; fo=1
```

**rentstayable.com (`_dmarc.rentstayable.com` TXT):**
```
v=DMARC1; p=quarantine; sp=quarantine; adkim=s; aspf=s; pct=100; rua=mailto:mail-reports@rentstayable.com; fo=1
```

Tag meanings:
- `p=quarantine` — failed mail goes to junk folder (Phase 1 setting; will move to `p=reject` after 7 clean days)
- `sp=quarantine` — same enforcement on subdomains
- `adkim=s; aspf=s` — strict alignment
- `pct=100` — apply to 100% of mail
- `fo=1` — failure reports on any auth failure

**Final hardened DMARC values (scheduled for Day 7 after clean monitoring):**
```
v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s; pct=100; rua=mailto:dmarc-reports@rise8companies.com; fo=1
v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s; pct=100; rua=mailto:mail-reports@rentstayable.com; fo=1
```

#### DKIM CNAMEs (M365 reference)

**rise8companies.com:**
- `selector1._domainkey` → `selector1-rise8companies-com._domainkey.leadmanagement.onmicrosoft.com`
- `selector2._domainkey` → `selector2-rise8companies-com._domainkey.leadmanagement.onmicrosoft.com`

**rentstayable.com:**
- `selector1._domainkey` → `selector1-rentstayable-com._domainkey.leadmanagement.onmicrosoft.com`
- `selector2._domainkey` → `selector2-rentstayable-com._domainkey.leadmanagement.onmicrosoft.com`

#### Zoho records removed

Confirmed Zoho CRM and Zoho Desk no longer in use. Deleted:

- rise8companies.com: TXT `zoho-verification=zb47114910...`
- rentstayable.com: TXT `zoho-verification=zb76426612...`
- rentstayable.com: CNAME `support.rentstayable.com` → `desk.cs.zohohost.com`
- rentstayable.com: CNAME `zd8ead512ca9c7029aaf0e344f9eeba069...` → `desk.cs.zohohost.com`

#### DMARC reporting mailboxes

Free shared mailboxes provisioned in M365 (no license cost, up to 50 GB):

- `dmarc-reports@rise8companies.com`
- `mail-reports@rentstayable.com` *(named differently — `dmarc-reports@rentstayable.com` was already taken in tenant)*

Members: Kyle (bke@). Rob can be added on request.

---

## Phase 2 — Defender Impersonation Protection (Complete)

### Microsoft Defender for Office 365 Plan 1

Procured by Kate for 4 protected users at $2.00/user/month (~$8/month, ~$96/year billed annually).

**Important licensing notes:**
- Plan 1 is licensed **per protected user**, not tenant-wide.
- Microsoft is bundling Plan 1 into Microsoft 365 Business Standard on **July 1, 2026** (with corresponding ~$3/user/month base price increase). The current Plan 1 add-on folds into the suite at next renewal.
- Reference: https://www.microsoft.com/en-us/licensing/news/2026-M365-Packaging-Pricing-Updates

### Plan 1 vs Plan 2 decision

Chose **Plan 1** (prevention focus) over Plan 2 (~$5/user/month for SOC tooling like Threat Explorer, Attack Simulation Training, Advanced Hunting, AIR automation). Plan 2 is overkill at RISE8's size with no dedicated security operations team. Revisit Plan 2 if/when:
- IT/security lead is hired
- Defender for Endpoint is added (XDR cross-correlation becomes valuable)
- Cyber insurance requires phishing simulation training
- Headcount exceeds ~50

### Protected User List — Core 4 (Deployed)

| Display Name | Email | Role / Why |
|---|---|---|
| Rob Beyer | rb@rise8companies.com | CEO; primary impersonation target |
| Crystal Johnson | cj@rentstayable.com | VP Operations; payment authority |
| Allysa Vicente | allysa@rentstayable.com | Accounting; executes wires/ACH |
| Jefferson Gomez | jefferson@rentstayable.com | Purchaser; vendor relationships |

**Rationale:** These four form the complete BEC kill chain. Attackers impersonate executive authority (Rob/Crystal) → direct purchasing action (Jefferson) → trigger funds movement (Allysa). Protecting all four breaks the chain at every stage.

**Note on Allysa's email:** address is `allysa@` (one S) — confirmed correct; not a typo.

### Future Expansion Candidates (Not Currently Licensed)

Adds ~$8/mo to extend to all 8 users (~$16/mo total):

| Name | Email | Add If... |
|---|---|---|
| Kate | kate@rentstayable.com | Has payment authority on asset transactions or lender comms |
| Monica | monica@rentstayable.com | Has cash management / bank reconciliation duties |
| Bea | bea@rentstayable.com | Handles vendor master data or invoice intake |
| Kyle | bke@rentstayable.com | Sysadmin (impersonation risk for credential reset requests) |

### Deployed Anti-Phishing Policy Configuration

Editing the **default Office365 AntiPhish policy** in `security.microsoft.com → Email & collaboration → Policies & rules → Threat policies → Anti-phishing`.

**Edit protection settings:**
- Phishing email threshold: **3 - More Aggressive**
- Enable users to protect: **ON** (4/350 users)
- Enable domains to protect: **ON**
  - Include domains I own: **ON** (auto-protects rise8companies.com + rentstayable.com)
  - Include custom domains: empty (vendor list pending Rob's input)
- Enable mailbox intelligence: **ON**
- Enable Intelligence for impersonation protection: **ON**
- Enable spoof intelligence: **ON**

**Edit actions — all message actions set to Quarantine with `DefaultFullAccessPolicy`:**
- If a message is detected as user impersonation: **Quarantine the message**
- If a message is detected as domain impersonation: **Quarantine the message**
- If Mailbox Intelligence detects an impersonated user: **Quarantine the message**
- If detected as spoof and DMARC `p=quarantine`: **Quarantine the message**
- If detected as spoof and DMARC `p=reject`: **Reject the message**
- If detected as spoof by spoof intelligence: **Quarantine the message**
- Honor DMARC record policy: **Checked**

**Safety tips & indicators (all enabled):**
- Show first contact safety tip ✓
- Show user impersonation safety tip ✓
- Show domain impersonation safety tip ✓
- Show user impersonation unusual characters safety tip ✓
- Show (?) for unauthenticated senders for spoof ✓
- Show "via" tag ✓

### Quarantine Policy Choice

Using `DefaultFullAccessPolicy` — users can see their own quarantined messages and request release. Less aggressive than `AdminOnlyAccessPolicy`. Switch to `AdminOnlyAccessPolicy` later if false-positive rate is low and tighter control is desired.

---

## Exchange Transport Rule (Complete)

External-sender warning banner. Catches what Defender misses (e.g., legitimate-looking external mail with internal-style addresses).

**Location:** `admin.exchange.microsoft.com → Mail flow → Rules`

**Rule name:** External sender claiming internal domain

**Conditions:**
- Sender is located: **Outside the organization**
- AND sender address matches text patterns:
  - `rise8companies\.com$`
  - `rentstayable\.com$`

**Action:** Apply a disclaimer → Prepend a disclaimer with this HTML:

```html
<div style="background-color:#FFF3CD; border-left:4px solid #FFC107; padding:10px; margin-bottom:10px; font-family:Arial,sans-serif; color:#856404;">
<strong>⚠ EXTERNAL SENDER — Verify before acting.</strong><br>
This email arrived from outside the organization but appears to use an internal-looking address. <strong>Do not act on payment, wire, or credential requests without verifying by phone using a known-good number.</strong>
</div>
```

**Settings:**
- Fallback action: **Wrap**
- Mode: **Enforce**
- Severity: **Medium**
- Match sender address in message: **Header or envelope** (catches both display and SMTP-level spoofs)

---

## Verification: Resend / Investor Portal Flow

The investor portal sends as `ir@rise8companies.com` via **Resend** (which uses Amazon SES infrastructure). Verified that this flow continues to work under DMARC enforcement.

**Architecture:**
- Visible From: `ir@rise8companies.com` (root domain)
- Envelope Return-Path: lives on `send.rise8companies.com` subdomain
- DKIM: signs with `d=rise8companies.com` using the `resend` selector
- MX for `send.rise8companies.com`: `feedback-smtp.us-east-1.amazonses.com` (for bounce handling)

**Why DMARC passes:**
- SPF won't strictly align (envelope is on `send.` subdomain, From is on root)
- DKIM strictly aligns because `d=rise8companies.com` matches the From domain
- DMARC requires only one of SPF or DKIM to pass with alignment
- Result: DMARC passes via DKIM alone

**Verified DNS:**
- `resend._domainkey.rise8companies.com` TXT — public RSA key published
- `send.rise8companies.com` MX — Resend feedback handler
- `send.rise8companies.com` TXT — `v=spf1 include:amazonses.com ~all`

No changes needed for investor portal.

---

## Pending / Next Steps

### Immediate (within current 7-day monitoring window)

1. **End-to-end test of impersonation Quarantine routing.**
   - Use a personal Gmail; edit "Send mail as" name to "Rob Beyer"; send a normal-looking email to `bke@rentstayable.com`.
   - Wait 1-2 minutes.
   - Check `security.microsoft.com → Email & collaboration → Quarantine`.
   - Expected: message appears in Quarantine with reason "Impersonation".
   - If lands in Junk → action wasn't set to Quarantine.
   - If lands in Inbox → policy hasn't propagated yet (wait 30 min) or a setting wasn't saved.

2. **DMARC report parser setup.**
   - Currently on hold due to Valimail accessibility issues from PH location.
   - **Recommended:** try `https://dmarc.postmarkapp.com/` (simplest, weekly digest emails, free, no domain limit).
   - **Alternatives:** Valimail (`https://www.valimail.com/try-monitor-free/`), dmarcian, EasyDMARC, PowerDMARC trial.
   - Once active: add the parser's `rua@` address as a second comma-separated `rua=` in both DMARC records (keep the original shared mailbox as backup).

3. **Service audit — pending Rob's confirmation.**
   Confirm whether each of these is still in active use. If dormant, remove DNS records and rotate/cancel credentials (forgotten-sender attack surface):
   - **Amazon SES** (rentstayable.com) — HIGH risk if unused; SES creds get leaked frequently. Records: 3× long-name `_domainkey` CNAMEs + `amazonses.com` in SPF.
   - **Mandrill / Mailchimp Transactional** (rentstayable.com) — Records: `mte1._domainkey`, `mte2._domainkey`, `mandrill_verify` TXT.
   - **Sendinblue / Brevo** (rentstayable.com) — Records: `sendinblue-site-verification` TXT.
   - **Adobe Sign** (rise8companies.com) — Remove `adobesign.com` from SPF if unused.

### Day 7 — Flip to p=reject

If monitoring is clean (no legitimate senders failing alignment, no missing-email complaints):

```
v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s; pct=100; rua=mailto:dmarc-reports@rise8companies.com; fo=1
v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s; pct=100; rua=mailto:mail-reports@rentstayable.com; fo=1
```

**Pre-flip checklist:**
- ✅ Parser dashboard: every legitimate sender in "Aligned/Compliant" bucket (M365, Resend, etc.)
- ✅ No help-desk complaints about missing email over 7 days
- ✅ Service audit decisions made (any "no" services have records removed BEFORE flipping)

**Post-flip monitoring (48 hours):**
- Watch parser dashboard daily for "Rejected" entries
- Any user reports of bounced outgoing email → immediately revert to `p=quarantine` while diagnosing
- 48 hours clean → done; set calendar reminder for ~12 month annual re-audit

---

## Monitoring Playbook

### What to watch for

- User reports of missing emails — check junk/Quarantine folders first
- Any property/operations system stops sending emails (booking confirmations, vendor PO acknowledgments)
- Bounce-backs from Microsoft mentioning DMARC or 550
- DMARC reports showing unrecognized senders passing both SPF and DKIM (forgotten legit service)
- Volumes outside expectation (zero reports after 3 days, or 1000+/day)

### What NOT to do during the monitoring window

- Don't change SPF or DMARC again — every change resets the monitoring window
- Don't add new email services without setting up SPF/DKIM first
- Don't worry about lots of failed attempts in reports — that's bots probing; system working

---

## Reference Tools

### DNS verification
- **mxtoolbox.com/spf.aspx** — SPF lookup
- **mxtoolbox.com/dmarc.aspx** — DMARC lookup
- **mxtoolbox.com/dkim.aspx** — DKIM lookup (use selector1 or selector2)
- **dmarcian.com/dmarc-inspector** — full DMARC parser

### Pricing references (Defender for Office 365)
- 2026 Packaging announcement: https://www.microsoft.com/en-us/licensing/news/2026-M365-Packaging-Pricing-Updates
- SMB Security pricing: https://www.microsoft.com/en-us/security/pricing/small-medium-business
- Defender for Office 365 product page: https://www.microsoft.com/en-us/security/business/siem-and-xdr/microsoft-defender-office-365
- In tenant: `admin.microsoft.com → Billing → Purchase services → search "Defender for Office 365 Plan 1"`

### Mailbox locations (Outlook shared mailboxes)
- `dmarc-reports@rise8companies.com`
- `mail-reports@rentstayable.com`

---

## Key Decisions & Rationale (For Future Reference)

- **DMARC strict alignment (`adkim=s; aspf=s`):** Closes loopholes where attackers use related domains. Costs nothing at runtime; tightens security materially.
- **Quarantine over Junk:** Junk is too easy to recover from accidentally. Quarantine requires admin or self-service release with explicit confirmation.
- **`DefaultFullAccessPolicy` over `AdminOnlyAccessPolicy`:** During the initial weeks, false positives are likely. Letting users self-service-release reduces friction. Re-evaluate to `AdminOnly` after FP rate is known.
- **Phishing threshold = 3 (not 4):** 4 (Most Aggressive) produces meaningful false positives on legitimate marketing email. 3 is the sweet spot.
- **Editing default policy vs creating new:** Default policy applies to whole tenant. Creating a new strict policy with priority would let us scope to specific users, but the default-with-tightened-settings approach gives uniform protection across the org with less management overhead.
- **`p=quarantine` first, then `p=reject`:** Going straight to reject risks blocking legitimate forgotten senders. 7-day quarantine window provides safety net to identify and fix any aligned-sender issues.
- **Per-user Plan 1 licensing (not tenant-wide):** Microsoft licenses Plan 1 only for users who need impersonation protection. Started with the BEC kill chain (4 users); can expand to 8 for ~$8/mo more if expansion candidates' roles touch payment workflows.

---

## Threat Pattern Detected

Microsoft Defender's spoof intelligence dashboard recorded **309 spoofed emails** targeting the tenant in the 7 days preceding deployment. This confirms active, ongoing targeting — not isolated incidents. The full layered defense is justified by this volume.

---

## Project Files

- **Summary doc:** `email-security-summary.docx` — comprehensive project status, attached to Smartsheet project record
- **This file:** `claude.md` — context for Claude Code

---

## Glossary (for future helpers)

- **BEC** — Business Email Compromise; fraud where attackers impersonate executives or vendors to redirect wire transfers
- **DMARC** — Domain-based Message Authentication, Reporting & Conformance; tells receivers what to do with mail that fails SPF/DKIM
- **DKIM** — DomainKeys Identified Mail; cryptographic signature on outbound mail to prove origin
- **SPF** — Sender Policy Framework; DNS record listing authorized sending IPs/domains for a domain
- **`rua`** — DMARC aggregate report destination (daily summaries)
- **`ruf`** — DMARC failure report destination (per-message; rarely used today, dropped from final config)
- **Alignment** — DMARC requirement that the SPF/DKIM domain match the visible From domain
- **Strict alignment** — exact domain match required (`s`); relaxed alignment (`r`) allows organizational/parent domain
- **Quarantine** — message held in `security.microsoft.com → Quarantine` for review/release
- **Mailbox Intelligence** — Defender feature that auto-learns each user's communication contacts to detect impersonation of regular senders
