import csv

CANDIDATE_FILE = 'raw_fuzzymap.csv'
MAPPING_FILE = 'gl_code_mappings.csv'
OUTPUT_FILE = 'cleaned_fuzzymap_import.csv'

# Load mapping
gl_map = {}
with open(MAPPING_FILE, newline='', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        old = row['old_gl_account_code'].strip().strip('"')
        new = row['new_gl_account_code'].strip().strip('"')
        gl_map[old] = new

with open(CANDIDATE_FILE, newline='', encoding='utf-8') as fin, \
     open(OUTPUT_FILE, 'w', newline='', encoding='utf-8') as fout:
    reader = csv.DictReader(fin)
    writer = csv.writer(fout)
    writer.writerow(['keyword', 'gl_account_code'])
    for row in reader:
        keyword = row['keyword'].strip().strip('"')
        old_gl = row['gl_account_code'].strip().strip('"')
        new_gl = gl_map.get(old_gl, 'TODO')
        if new_gl == 'TODO':
            print(f"TODO: Add mapping for old GL code '{old_gl}' (keyword '{keyword}')")
        writer.writerow([keyword, new_gl])
