#!/usr/bin/env python3
"""Execute every downloadable lab in a fresh R process and temporary directory."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import tempfile
import time

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--log-dir', required=True, type=Path)
parser.add_argument('--timeout', type=int, default=600)
args = parser.parse_args()
args.log_dir.mkdir(parents=True, exist_ok=True)
results = []
environment = os.environ.copy()
# Resolve the activated project's library before moving to an empty directory.
# --vanilla then prevents a user's startup files from altering individual labs.
libraries = subprocess.check_output(
    ['Rscript', '-e', 'cat(paste(.libPaths(), collapse = .Platform$path.sep))'],
    cwd=ROOT, text=True).strip()
environment['R_LIBS_USER'] = libraries
for path in sorted(ROOT.glob('course*/code/*.R')):
    key = path.parts[-3] + '__' + path.stem
    started = time.monotonic()
    with tempfile.TemporaryDirectory(prefix='courses-lab-') as work, (args.log_dir / (key + '.log')).open('w') as log:
        try:
            result = subprocess.run(['Rscript', '--vanilla', str(path)], cwd=work,
                                    stdout=log, stderr=subprocess.STDOUT, timeout=args.timeout,
                                    env=environment)
            status = result.returncode
        except subprocess.TimeoutExpired:
            status = 'timeout'
    results.append({'script': str(path.relative_to(ROOT)), 'status': status,
                    'seconds': round(time.monotonic() - started, 2)})
    (args.log_dir / 'results.json').write_text(json.dumps(results, indent=2))
    print(f'{len(results):02}/80 {key}: {status}', flush=True)
if len(results) != 80 or any(r['status'] != 0 for r in results):
    raise SystemExit(1)
