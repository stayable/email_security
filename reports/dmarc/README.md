# DMARC Aggregate Reports (`rua`)

Drop DMARC aggregate reports from the `rua` mailboxes here for analysis.

## Sources

- `dmarc-reports@rise8companies.com`
- `mail-reports@rentstayable.com`

## Expected file types

- `.xml` — uncompressed DMARC aggregate report
- `.xml.gz` / `.zip` — compressed aggregate report (most common; from Google, Microsoft, Yahoo, etc.)

## Naming convention

Save reports as received; typical format:
```
<reporter>!<our-domain>!<begin-epoch>!<end-epoch>.xml[.gz|.zip]
```
Example: `google.com!rise8companies.com!1714003200!1714089600.xml.gz`

## Organization

Optionally subfolder by domain to keep things tidy:
```
reports/dmarc/
├── rise8companies.com/
└── rentstayable.com/
```

## What to look for when analyzing

- Every legitimate sender should land in the **aligned/compliant** bucket (DKIM or SPF passing with alignment)
- Unrecognized source IPs passing both SPF and DKIM → forgotten legitimate service (investigate before flipping to `p=reject`)
- High volume of `dispositioned: quarantine|reject` from unknown IPs → expected attacker noise
- Misaligned legitimate mail (e.g., a SaaS sending as `@rise8companies.com` without DKIM) → must fix before `p=reject`
