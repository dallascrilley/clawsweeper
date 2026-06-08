# Self-hosting this clawsweeper fork (dallascrilley)

Retargeted from `openclaw/*` to `dallascrilley/*` + `dallascrilleymartech/*`. Full spec:
`~/Code/openclaw-projects/docs/specs/openclaw-chief-of-staff-spec.md` §5.

## Already done in this fork (committed)

- `config/target-repositories.json` — owners → `dallascrilley`, `dallascrilleymartech`;
  conservative **review-only** (`apply_close_rules` empty); `core_target_overrides` cleared;
  `target_inventory.owners` retargeted; state repo + `.github` denied.
- `config/automation-limits.json` — `workers.max` 57 → **6** (personal scale).
- `.github/actions/create-state-token/action.yml` — owner default → `dallascrilley`.
- `.github/actions/setup-state/action.yml` — state-repository default → `dallascrilley/clawsweeper-state`.

## Remaining steps (human-gated)

1. **Create the GitHub App** (`clawsweeper-dc` or similar). Permissions: Contents r/w, Issues r/w,
   Pull requests r/w, Workflows write, Actions r/w (this repo), Checks write (targets, optional).
   Install on: this fork, `dallascrilley/clawsweeper-state`, and every target repo. Note the
   **client id**; download the **private key**.
2. **Run `CLAWSWEEPER_APP_CLIENT_ID=Iv23xxxx ./self-host.sh`** — rewrites the hardcoded client id
   (21 files) and `owner: openclaw` (workflows/actions). Review `git diff`, commit, push.
3. **Secrets**: on this fork set Actions secrets `OPENAI_API_KEY` and `CLAWSWEEPER_APP_PRIVATE_KEY`.
   Add `CLAWSWEEPER_APP_PRIVATE_KEY` as an **org secret** (or per-target-repo) so target-repo
   dispatchers can mint tokens.
4. **Repo var**: set `CLAWSWEEPER_ALLOWED_OWNER=dallascrilley` (and add `dallascrilleymartech` flow
   if used) — otherwise `src/repair/lib.ts` blocks all repair.
5. **Trim the schedule**: `.github/workflows/sweep.yml` has 17 `cron:` entries tuned for openclaw's
   3 repos. Trim to a sane personal cadence (or rely on the dispatcher + `workflow_dispatch`) before
   enabling Actions.
6. **Install the dispatcher** in each target repo as `.github/workflows/clawsweeper-dispatch.yml`
   (template: `docs/target-dispatcher.md`), with receiver `repos/dallascrilley/clawsweeper/dispatches`
   and your client id.
7. **Enable Actions** (forks start disabled), then first run:
   `gh workflow run sweep.yml --repo dallascrilley/clawsweeper --ref main -f target_repo=dallascrilley/<repo> -f hot_intake=true`

## Notes

- Codex runs inside `ubuntu-latest` runners via a credential-stripped Responses proxy — the raw
  `OPENAI_API_KEY` never reaches Codex subprocesses. No proxy changes needed.
- `clawsweeper-state` (your fork) inherited upstream's `state` branch, which already satisfies the
  hydrator's `GENERATED_PATHS` check. Optional clean start (rewrites that branch's history — your
  fork only):
  `git checkout --orphan state && git rm -rf . && mkdir -p records && touch records/.gitkeep && git add records/.gitkeep && git commit -m "seed clean state" && git push -f origin state`
