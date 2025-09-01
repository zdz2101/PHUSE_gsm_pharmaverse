library(arrow)
library(tibble)

# ---- DM (6 subjects) ----
dm <- tibble::tribble(
  ~STUDYID, ~SITEID, ~SUBJID, ~USUBJID,           ~DMDAT,      ~BRTHDTC,     ~AGE, ~AGEU,  ~SEX,      ~ETHNIC,                 ~RACEOTH,
  "ABC123", "101",   "001",   "ABC123-101-001",   "2025-07-15","1985-03-12", 40,  "Years", "Male",    "Not Hispanic or Latino", NA,
  "ABC123", "101",   "002",   "ABC123-101-002",   "2025-07-16","1992-11-05", 32,  "Years", "Female",  "Hispanic or Latino",     NA,
  "ABC123", "101",   "003",   "ABC123-101-003",   "2025-07-20","1978-06-22", 47,  "Years", "Unknown", "Not Reported",           NA,
  "ABC123", "102",   "001",   "ABC123-102-001",   "2025-08-01","1969-09-14", 55,  "Years", "Male",    "Not Hispanic or Latino", NA,
  "ABC123", "102",   "002",   "ABC123-102-002",   "2025-08-04","1988-12-02", 36,  "Years", "Female",  "Not Hispanic or Latino", NA,
  "ABC123", "103",   "001",   "ABC123-103-001",   "2025-08-10","1972-02-27", 53,  "Years", "Male",    "Not Hispanic or Latino", NA
)

# ---- VS (2 visits: Screening + Baseline; only Height/Weight) ----
vs <- tibble::tribble(
  ~STUDYID, ~SITEID, ~SUBJID, ~USUBJID,          ~VISITNUM, ~VISIT,      ~VSDTC,        ~VSTESTCD, ~VSTEST,  ~VSORRES, ~VSORRESU,
  # 101-001
  "ABC123", "101",   "001",   "ABC123-101-001",  1, "Screening", "2025-07-10", "HEIGHT", "Height", 175, "cm",
  "ABC123", "101",   "001",   "ABC123-101-001",  1, "Screening", "2025-07-10", "WEIGHT", "Weight", 72,  "kg",
  "ABC123", "101",   "001",   "ABC123-101-001",  2, "Baseline",  "2025-07-17", "HEIGHT", "Height", 175, "cm",
  "ABC123", "101",   "001",   "ABC123-101-001",  2, "Baseline",  "2025-07-17", "WEIGHT", "Weight", 71.5,"kg",
  # 101-002
  "ABC123", "101",   "002",   "ABC123-101-002",  1, "Screening", "2025-07-11", "HEIGHT", "Height", 162, "cm",
  "ABC123", "101",   "002",   "ABC123-101-002",  1, "Screening", "2025-07-11", "WEIGHT", "Weight", 60,  "kg",
  "ABC123", "101",   "002",   "ABC123-101-002",  2, "Baseline",  "2025-07-18", "HEIGHT", "Height", 162, "cm",
  "ABC123", "101",   "002",   "ABC123-101-002",  2, "Baseline",  "2025-07-18", "WEIGHT", "Weight", 59.8,"kg",
  # 101-003
  "ABC123", "101",   "003",   "ABC123-101-003",  1, "Screening", "2025-07-12", "HEIGHT", "Height", 180, "cm",
  "ABC123", "101",   "003",   "ABC123-101-003",  1, "Screening", "2025-07-12", "WEIGHT", "Weight", 80,  "kg",
  "ABC123", "101",   "003",   "ABC123-101-003",  2, "Baseline",  "2025-07-19", "HEIGHT", "Height", 180, "cm",
  "ABC123", "101",   "003",   "ABC123-101-003",  2, "Baseline",  "2025-07-19", "WEIGHT", "Weight", 79.5,"kg",
  # 102-001
  "ABC123", "102",   "001",   "ABC123-102-001",  1, "Screening", "2025-08-01", "HEIGHT", "Height", 170, "cm",
  "ABC123", "102",   "001",   "ABC123-102-001",  1, "Screening", "2025-08-01", "WEIGHT", "Weight", 68,  "kg",
  "ABC123", "102",   "001",   "ABC123-102-001",  2, "Baseline",  "2025-08-08", "HEIGHT", "Height", 170, "cm",
  "ABC123", "102",   "001",   "ABC123-102-001",  2, "Baseline",  "2025-08-08", "WEIGHT", "Weight", 67.5,"kg",
  # 102-002
  "ABC123", "102",   "002",   "ABC123-102-002",  1, "Screening", "2025-08-02", "HEIGHT", "Height", 165, "cm",
  "ABC123", "102",   "002",   "ABC123-102-002",  1, "Screening", "2025-08-02", "WEIGHT", "Weight", 64,  "kg",
  "ABC123", "102",   "002",   "ABC123-102-002",  2, "Baseline",  "2025-08-09", "HEIGHT", "Height", 165, "cm",
  "ABC123", "102",   "002",   "ABC123-102-002",  2, "Baseline",  "2025-08-09", "WEIGHT", "Weight", 63.5,"kg",
  # 103-001
  "ABC123", "103",   "001",   "ABC123-103-001",  1, "Screening", "2025-08-10", "HEIGHT", "Height", 178, "cm",
  "ABC123", "103",   "001",   "ABC123-103-001",  1, "Screening", "2025-08-10", "WEIGHT", "Weight", 82,  "kg",
  "ABC123", "103",   "001",   "ABC123-103-001",  2, "Baseline",  "2025-08-17", "HEIGHT", "Height", 178, "cm",
  "ABC123", "103",   "001",   "ABC123-103-001",  2, "Baseline",  "2025-08-17", "WEIGHT", "Weight", 81.2,"kg"
)

# ---- Write to Parquet ----
write_parquet(dm, "./ABC123/RAWDATA/dm.parquet")
write_parquet(vs, "./ABC123/RAWDATA/vs.parquet")
