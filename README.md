# fiddle-test

A testbed for fiddle's CVE remediation loop.

It carries one real advisory: `github.com/golang-jwt/jwt/v4 v4.5.0` holds
CVE-2025-30204, fixed in v4.5.2. `main.go` signs and parses a token, so the
requirement reaches the built binary and the scanner can see it.

`scan.sh` stands in for a container scanner. It reads `/modules.txt` out of the
image it is given and reports the advisory only while the module is below the
fixed version, so a repair genuinely clears the finding and a rescan proves it.
It needs no credential.

## What this repository is for

`snowplow-identities` proves fiddle against a real scanner. This proves the
parts that need a forge and real CI rather than a scanner: event triggers, the
CI feedback loop, direction from a comment, and the attempt bound across runs.
The workflow lives on the default branch here, which is what GitHub requires
before `workflow_run` and `issue_comment` will fire at all.

## Secrets

- `LITELLM_API_KEY` — the model the agent runs on.
- `FIDDLE_GITHUB_TOKEN` — a token scoped to this repository. It cannot be
  `GITHUB_TOKEN`: GitHub suppresses workflow events from that token, so a pull
  request fiddle pushed would start no CI run and the feedback loop would have
  nothing to read.

## The policy gate

`policy.sh` fails only when `FIDDLE_TEST_POLICY_GATE` is set in the workflow. That
is how the direction path is exercised: a check fiddle cannot pass, waived by a
maintainer's review. Leave it unarmed for ordinary runs, so a green tree means
something.
