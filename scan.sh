#!/usr/bin/env bash
set -euo pipefail

report=""
image=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --json-output-file) report="${2:-}"; shift 2 ;;
    --*) shift ;;
    *) image="$1"; shift ;;
  esac
done

if [ -z "$report" ]; then
  echo "scan.sh: --json-output-file <path> was not passed" >&2
  exit 2
fi
if [ -z "$image" ]; then
  echo "scan.sh: no image was named" >&2
  exit 2
fi

echo "fiddle-test scanner 1.0.0"

modules=$(docker run --rm --entrypoint /bin/cat "$image" /modules.txt) || {
  echo "scan.sh: $image carries no /modules.txt, so nothing can be read from it" >&2
  exit 2
}
digest=$(docker image inspect --format '{{.Id}}' "$image")

MODULES="$modules" DIGEST="$digest" REPORT="$report" IMAGE="$image" python3 - <<'PY'
import json, os, re

modules = os.environ["MODULES"]
package = "github.com/golang-jwt/jwt/v4"
fixed = "4.5.2"

found = None
for line in modules.splitlines():
    parts = line.split()
    if len(parts) == 2 and parts[0] == package:
        found = parts[1].lstrip("v")

def below(version, target):
    order = lambda it: [int(n) for n in re.findall(r"\d+", it)]
    return order(version) < order(target)

libraries = None
if found is not None and below(found, fixed):
    libraries = [
        {
            "name": package,
            "version": found,
            "vulnerabilities": [
                {
                    "name": "CVE-2025-30204",
                    "severity": "HIGH",
                    "fixedVersion": fixed,
                    "hasExploit": False,
                }
            ],
        }
    ]

document = {
    "extraInfo": {"clientName": "fiddle-test", "clientVersion": "1.0.0"},
    "scanOriginResource": {
        "__typename": "CICDScanOriginContainerImage",
        "name": os.environ["IMAGE"],
        "id": os.environ["DIGEST"],
        "digest": None,
        "imageLabels": None,
    },
    "status": {"state": "SUCCESS", "verdict": "PASSED_BY_POLICY"},
    "result": {"libraries": libraries, "osPackages": None},
}

with open(os.environ["REPORT"], "w") as out:
    json.dump(document, out, indent=2)
    out.write("\n")

print(f"scanned {os.environ['IMAGE']}: {package} {found}, libraries "
      f"{'reported' if libraries else 'null'}")
PY
