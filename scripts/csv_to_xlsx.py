#!/usr/bin/env python3
"""Simple CSV -> XLSX converter for Alert_Triage.csv"""
import sys
import pandas as pd

if len(sys.argv) < 2:
    print("Usage: csv_to_xlsx.py input.csv [output.xlsx]")
    sys.exit(2)

infile = sys.argv[1]
outfile = sys.argv[2] if len(sys.argv) > 2 else infile.rsplit('.',1)[0] + '.xlsx'

df = pd.read_csv(infile)
df.to_excel(outfile, index=False)
print(f"Wrote {outfile}")
