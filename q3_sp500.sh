#!/usr/bin/env bash
#
# Question 3: S&P 500 Companies Sorter
# Usage: ./q3_sp500.sh <csv_url>

set -euo pipefail

# ============================================================================
# 1. VALIDATE INPUT
# ============================================================================

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <csv_url>" >&2
    echo "Example: $0 https://raw.githubusercontent.com/datasets/s-and-p-500-companies/refs/heads/main/data/constituents.csv" >&2
    exit 1
fi

CSV_URL="$1"

# ============================================================================
# 2. DOWNLOAD CSV
# ============================================================================

TMP_CSV=$(mktemp)
trap 'rm -f "$TMP_CSV"' EXIT

if ! curl -fsSL "$CSV_URL" -o "$TMP_CSV"; then
    echo "Error: Could not download CSV from $CSV_URL" >&2
    exit 1
fi

if [ ! -s "$TMP_CSV" ]; then
    echo "Error: Downloaded file is empty." >&2
    exit 1
fi

# ============================================================================
# 3. PARSE CSV AND SORT
# ============================================================================

python3 - "$TMP_CSV" <<'PYTHON_SCRIPT'
import csv
import re
import sys

csv_file = sys.argv[1]

rows = []

with open(csv_file, newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)

    for row in reader:
        company = row["Security"].strip()
        headquarters = row["Headquarters Location"].strip()
        founded = row["Founded"].strip()

        match = re.search(r"\d{4}", founded)
        year = int(match.group()) if match else None

        rows.append((year, company, headquarters, founded))

# Companies without a valid year appear at the end
rows.sort(key=lambda x: (x[0] is None, x[0]))

print(f"{'Company Name':50} | {'Headquarters':42} | Founded")
print("-" * 110)

for year, company, headquarters, founded in rows:
    print(f"{company:50.50} | {headquarters:42.42} | {founded}")

print("-" * 110)
print(f"Total companies processed: {len(rows)}")

PYTHON_SCRIPT