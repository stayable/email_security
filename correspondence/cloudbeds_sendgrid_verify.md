# Cloudbeds Support — Verify SendGrid Sender Authentication Request

**To:** Cloudbeds Support (reply on the original support thread)
**From:** bke@rentstayable.com
**Subject:** Verifying SendGrid Sender Authentication request for rentstayable.com

---

Hi Cloudbeds Support,

Following up on our request to enable custom-domain authentication for `rentstayable.com` (DMARC alignment for outbound mail sent through your platform).

We've just received an email from SendGrid titled "Sender Authentication" asking us to publish DNS records on our domain. Before we publish anything, I want to confirm this request was initiated by your team on our behalf and not received in error.

Could you please confirm:

1. That Cloudbeds initiated a Sender Authentication request for `rentstayable.com` against SendGrid domain ID **30810472** (visible in the verification link).
2. That the four records SendGrid listed are the expected ones for our setup (3 CNAMEs for `em2511`, `s1._domainkey`, `s2._domainkey`, plus a DMARC reference).

For your reference, the verification link from the SendGrid email is:

https://app.sendgrid.com/public/sender_auth/verification?d=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkb21haW5faWQiOjMwODEwNDcyLCJleHAiOjE3Nzg1MzUwMjMsImlwX2lkIjowLCJsaW5rX2lkIjowfQ.yLK_ulzgSISwMt5lUx6tt0l-BjNYDhR2QK7DcuvI3_Y

Once you confirm, I'll publish the CNAMEs at our DNS host and click "I'm Done" so SendGrid can auto-verify. We'll skip the DMARC TXT since we already have a DMARC record published for `rentstayable.com` — duplicating it would create a permerror.

Appreciate the quick turnaround on the original request.

Thanks,
Kyle Estocapio
bke@rentstayable.com

---

## Records to publish at SiteGround (post-verification)

| Type | Host | Value |
|---|---|---|
| CNAME | `em2511.rentstayable.com` | `u2234072.wl073.sendgrid.net` |
| CNAME | `s1._domainkey.rentstayable.com` | `s1.domainkey.u2234072.wl073.sendgrid.net` |
| CNAME | `s2._domainkey.rentstayable.com` | `s2.domainkey.u2234072.wl073.sendgrid.net` |

**DO NOT** add the 4th record SendGrid showed (TXT `_dmarc.rentstayable.com`) — we already have an identical DMARC record published. Two DMARC records on the same host is a permerror per RFC 7489 and would silently disable DMARC for the domain.

## Post-publish verification steps

1. Wait ~15-30 min for DNS propagation.
2. Click "I'm Done" in the SendGrid Sender Authentication wizard — auto-verifies via DNS.
3. Independently verify at https://mxtoolbox.com/dkim.aspx — domain `rentstayable.com`, selectors `s1` and `s2` should both return SendGrid public keys.
4. Pull next day's DMARC reports via sync.bat and confirm Cloudbeds rows now show `dkim=pass` aligned with `rentstayable.com`.
5. Once 2-3 days of clean reports, proceed to `p=reject` flip.
