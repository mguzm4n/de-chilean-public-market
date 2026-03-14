from __future__ import annotations
import argparse
import csv
import json
from pathlib import Path
from typing import List, Dict

def csv_headers_to_bq_schema(csv_path: Path) -> List[Dict[str, str]]:
    with csv_path.open("r", newline="", encoding="latin-1") as f:
        reader = csv.reader(f, delimiter=";")
        try:
            headers = next(reader)
        except StopIteration:
            raise ValueError("CSV file is empty; no headers found.")

    headers = [h.strip() for h in headers if h is not None and h.strip() != ""]
    if not headers:
        raise ValueError("No non-empty headers found in the first row.")

    return [
        {
            "name": header,
            "type": "STRING",
            "mode": "NULLABLE",
            "description": "",
        }
        for header in headers
    ]


def main() -> None:
    parser = argparse.ArgumentParser(description="Create BigQuery schema JSON from CSV headers.")
    parser.add_argument("csv_file", type=Path, help="Path to the input .csv file")
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=None,
        help="Path to output .json file (defaults to <csv_file_stem>_schema.json)",
    )
    args = parser.parse_args()

    csv_path: Path = args.csv_file
    if not csv_path.exists() or not csv_path.is_file():
        raise FileNotFoundError(f"CSV file not found: {csv_path}")

    out_path = args.output or csv_path.with_name(f"{csv_path.stem}_schema.json")

    schema = csv_headers_to_bq_schema(csv_path)

    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", encoding="utf-8") as f:
        json.dump(schema, f, ensure_ascii=False, indent=2)

    print(f"Wrote schema with {len(schema)} fields to: {out_path}")


if __name__ == "__main__":
    main()