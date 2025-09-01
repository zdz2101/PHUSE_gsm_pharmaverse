library(gsm.core)
library(dplyr)
library(admiral)
library(sdtm.oak)
library(cards)
library(gtsummary)

# Prepare list of data of raw-data
lData <- list(
    Raw_DM = read_parquet("./ABC123/RAWDATA/dm.parquet"),
    Raw_VS = read_parquet("./ABC123/RAWDATA/vs.parquet")
)

# Parse and read in raw data to do any(?) necessary SDTM data
SDTM_workflows <- gsm.core::MakeWorkflowList(
  strNames = c("DM", "VS"),
  strPath = "./ABC123/workflows/1_RAW_TO_SDTM/",
  strPackage = NULL
)
SDTM_mapped <- gsm.core::RunWorkflows(lWorkflows = SDTM_workflows, lData = lData)
map2(SDTM_mapped, names(SDTM_mapped), function(x,y) arrow::write_parquet(x, paste0("./ABC123/SDTM/",y)))

# Use admiral to create a basic ADSL
options("yaml.eval.expr" = TRUE) # needs for admiral
ADAM_workflows <- gsm.core::MakeWorkflowList(
  strNames = "ADSL",
  strPath = "./ABC123/workflows/2_SDTM_TO_ADAM/",
  strPackage = NULL
)
ADAM_mapped <- gsm.core::RunWorkflows(lWorkflows = ADAM_workflows, lData = SDTM_mapped)
map2(ADAM_mapped, names(ADAM_mapped), function(x,y) arrow::write_parquet(x, paste0("./ABC123/ADaM/",y)))

# Turn ADSL into Table 1
TFL_workflows <- gsm.core::MakeWorkflowList(
  strNames = "TABLE1",
  strPath = "./ABC123/workflows/3_ADAM_TO_TFL/",
  strPackage = NULL
)
TFLs <- gsm.core::RunWorkflows(lWorkflows = TFL_workflows, lData = ADAM_mapped)
TFLs

# Use ADAM to create RDS
ARS_workflows <- gsm.core::MakeWorkflowList(
  strNames = "table1_ars",
  strPath = "./ABC123/workflows/3_ADAM_TO_ARS/",
  strPackage = NULL
)
ARS_datasets <- gsm.core::RunWorkflows(lWorkflows = ARS_workflows, lData = ADAM_mapped)
map2(ARS_datasets, names(ARS_datasets), function(x,y) saveRDS(x, paste0("./ABC123/ARS/", y))) # parquet may not be good export

