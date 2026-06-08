#!/usr/bin/env bash
# Self-host retarget for clawsweeper (dallascrilley fork).
# Applies the App-dependent + owner replacements that could not be baked in at
# fork-prep time. Idempotent. Run AFTER you have created your GitHub App and
# know its client id.
#
#   CLAWSWEEPER_APP_CLIENT_ID=Iv23xxxxxxxx ./self-host.sh
#
# Config retarget (config/target-repositories.json owners, config/automation-limits.json
# workers.max, action owner defaults) is ALREADY committed — this only handles the
# values that depend on your GitHub App.
set -euo pipefail

OWNER="${CLAWSWEEPER_OWNER:-dallascrilley}"
OLD_CLIENT_ID="Iv23liOECG0slfuhz093"
NEW_CLIENT_ID="${CLAWSWEEPER_APP_CLIENT_ID:-}"

if [ -z "$NEW_CLIENT_ID" ]; then
  echo "ERROR: set CLAWSWEEPER_APP_CLIENT_ID to your GitHub App's client id first." >&2
  echo "  CLAWSWEEPER_APP_CLIENT_ID=Iv23xxxx ./self-host.sh" >&2
  exit 1
fi

cd "$(dirname "$0")"

echo "==> Replacing App client id ($OLD_CLIENT_ID -> $NEW_CLIENT_ID)"
grep -rl "$OLD_CLIENT_ID" --include="*.yml" --include="*.yaml" --include="*.md" . \
  | while read -r f; do
      sed -i '' "s/$OLD_CLIENT_ID/$NEW_CLIENT_ID/g" "$f"
      echo "    patched $f"
    done

echo "==> Repointing 'owner: openclaw' -> 'owner: $OWNER' in workflows/actions"
grep -rl "owner: openclaw" --include="*.yml" --include="*.yaml" .github \
  | while read -r f; do
      sed -i '' "s/owner: openclaw/owner: $OWNER/g" "$f"
      echo "    patched $f"
    done

echo "==> Done. Review 'git diff', then commit and push to your fork."
echo "    Remaining manual steps are in SELF-HOST.md (secrets, repo var, crons, dispatcher, enable Actions)."
