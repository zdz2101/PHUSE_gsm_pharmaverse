library(tibble)
library(arrow)

# ---- DM ----
dm <- tribble(
  ~STUDYID, ~SITEID, ~SUBJID, ~USUBJID,           ~DMDAT,      ~BRTHDTC,     ~AGE, ~AGEU,  ~SEX,      ~ETHNIC,                 ~RACEOTH, ~RFSTDTC,
  "ABC123", "101",   "001",   "ABC123-101-001",   "2025-07-15","1985-03-12", 40,  "Years", "Male",    "Not Hispanic or Latino", NA,       "2025-07-20",
  "ABC123", "101",   "002",   "ABC123-101-002",   "2025-07-16","1992-11-05", 32,  "Years", "Female",  "Hispanic or Latino",     NA,       "2025-07-21",
  "ABC123", "101",   "003",   "ABC123-101-003",   "2025-07-20","1978-06-22", 47,  "Years", "Unknown", "Not Reported",           NA,       "2025-07-22",
  "ABC123", "102",   "001",   "ABC123-102-001",   "2025-08-01","1969-09-14", 55,  "Years", "Male",    "Not Hispanic or Latino", NA,       "2025-08-05",
  "ABC123", "102",   "002",   "ABC123-102-002",   "2025-08-04","1988-12-02", 36,  "Years", "Female",  "Not Hispanic or Latino", NA,       "2025-08-07",
  "ABC123", "103",   "001",   "ABC123-103-001",   "2025-08-10","1972-02-27", 53,  "Years", "Male",    "Not Hispanic or Latino", NA,       "2025-08-12"
)

# ---- VS ----
vs <- tribble(
  ~STUDYID, ~SITEID, ~SUBJID, ~USUBJID,           ~VISITNUM, ~VISIT,      ~VSTESTCD, ~VSTEST,  ~VSORRES, ~VSORRESU, ~VSSTDTC,
  # 101-001
  "ABC123", "101",   "001",   "ABC123-101-001",    1, "Screening", "HEIGHT", "Height", 175, "cm", "2025-07-10",
  "ABC123", "101",   "001",   "ABC123-101-001",    1, "Screening", "WEIGHT", "Weight", 72,  "kg", "2025-07-10",
  "ABC123", "101",   "001",   "ABC123-101-001",    2, "Baseline",  "HEIGHT", "Height", 175, "cm", "2025-07-17",
  "ABC123", "101",   "001",   "ABC123-101-001",    2, "Baseline",  "WEIGHT", "Weight", 71.5,"kg", "2025-07-17",

  # 101-002
  "ABC123", "101",   "002",   "ABC123-101-002",    1, "Screening", "HEIGHT", "Height", 162, "cm", "2025-07-11",
  "ABC123", "101",   "002",   "ABC123-101-002",    1, "Screening", "WEIGHT", "Weight", 60,  "kg", "2025-07-11",
  "ABC123", "101",   "002",   "ABC123-101-002",    2, "Baseline",  "HEIGHT", "Height", 162, "cm", "2025-07-18",
  "ABC123", "101",   "002",   "ABC123-101-002",    2, "Baseline",  "WEIGHT", "Weight", 59.8,"kg", "2025-07-18",

  # 101-003
  "ABC123", "101",   "003",   "ABC123-101-003",    1, "Screening", "HEIGHT", "Height", 180, "cm", "2025-07-12",
  "ABC123", "101",   "003",   "ABC123-101-003",    1, "Screening", "WEIGHT", "Weight", 80,  "kg", "2025-07-12",
  "ABC123", "101",   "003",   "ABC123-101-003",    2, "Baseline",  "HEIGHT", "Height", 180, "cm", "2025-07-19",
  "ABC123", "101",   "003",   "ABC123-101-003",    2, "Baseline",  "WEIGHT", "Weight", 79.5,"kg", "2025-07-19",

  # 102-001
  "ABC123", "102",   "001",   "ABC123-102-001",    1, "Screening", "HEIGHT", "Height", 170, "cm", "2025-08-01",
  "ABC123", "102",   "001",   "ABC123-102-001",    1, "Screening", "WEIGHT", "Weight", 68,  "kg", "2025-08-01",
  "ABC123", "102",   "001",   "ABC123-102-001",    2, "Baseline",  "HEIGHT", "Height", 170, "cm", "2025-08-08",
  "ABC123", "102",   "001",   "ABC123-102-001",    2, "Baseline",  "WEIGHT", "Weight", 67.5,"kg", "2025-08-08",

  # 102-002
  "ABC123", "102",   "002",   "ABC123-102-002",    1, "Screening", "HEIGHT", "Height", 165, "cm", "2025-08-02",
  "ABC123", "102",   "002",   "ABC123-102-002",    1, "Screening", "WEIGHT", "Weight", 64,  "kg", "2025-08-02",
  "ABC123", "102",   "002",   "ABC123-102-002",    2, "Baseline",  "HEIGHT", "Height", 165, "cm", "2025-08-09",
  "ABC123", "102",   "002",   "ABC123-102-002",    2, "Baseline",  "WEIGHT", "Weight", 63.5,"kg", "2025-08-09",

  # 103-001
  "ABC123", "103",   "001",   "ABC123-103-001",    1, "Screening", "HEIGHT", "Height", 178, "cm", "2025-08-10",
  "ABC123", "103",   "001",   "ABC123-103-001",    1, "Screening", "WEIGHT", "Weight", 82,  "kg", "2025-08-10",
  "ABC123", "103",   "001",   "ABC123-103-001",    2, "Baseline",  "HEIGHT", "Height", 178, "cm", "2025-08-17",
  "ABC123", "103",   "001",   "ABC123-103-001",    2, "Baseline",  "WEIGHT", "Weight", 81.2,"kg", "2025-08-17"
)


# Write to parquet if needed
write_parquet(dm, "./ABC123/RAWDATA/dm.parquet", compression = "zstd")
write_parquet(vs, "./ABC123/RAWDATA/vs.parquet", compression = "zstd")
