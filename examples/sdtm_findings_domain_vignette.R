library(dplyr)
library(sdtm.oak)

# Prepare list of data of raw-data
lData <- list(
  vs_raw =  read.csv(system.file("raw_data/vitals_raw_data.csv", package = "sdtm.oak")),
  study_ct = read.csv(system.file("raw_data/sdtm_ct.csv", package = "sdtm.oak"))
)


SDTM_workflows <- gsm.core::MakeWorkflowList(
  strNames = c("SDTM.VS"),
  strPath = "./ABC123/workflows/1_RAW_TO_SDTM/",
  strPackage = NULL
)
SDTM_mapped <- gsm.core::RunWorkflows(lWorkflows = SDTM_workflows, lData = lData)
