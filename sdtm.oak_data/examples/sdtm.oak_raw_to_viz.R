library(dplyr)
library(rlang)
library(sdtm.oak)
options("yaml.eval.expr" = TRUE) # needs for admiral -- suggest gsm ecoystem write documentation


# Prepare list of data of raw-data
lData <- list(
  dm_raw = read.csv(system.file("raw_data/dm.csv", package = "sdtm.oak")),
  vs_raw =  read.csv(system.file("raw_data/vitals_raw_data.csv", package = "sdtm.oak")),
  study_ct = read.csv(system.file("raw_data/sdtm_ct.csv", package = "sdtm.oak"))
)


SDTM_workflows <- gsm.core::MakeWorkflowList(
  strNames = c("SDTM.VS", "SDTM.DM"),
  strPath = "./sdtm.oak_data/workflows/1_RAW_TO_SDTM/",
  strPackage = NULL
)
SDTM_mapped <- gsm.core::RunWorkflows(lWorkflows = SDTM_workflows, lData = lData)

ADAM_workflows <- gsm.core::MakeWorkflowList(
  strNames = c("ADAM.ADVS"),
  strPath = "./sdtm.oak_data/workflows/2_SDTM_TO_ADAM/",
  strPackage = NULL
)
ADAM_mapped <- gsm.core::RunWorkflows(lWorkflows = ADAM_workflows, lData = SDTM_mapped)

ARS_workflows <- gsm.core::MakeWorkflowList(
  strNames = "table_mean_arterial_pressure",
  strPath = "./sdtm.oak_data/workflows/3_ADAM_TO_ARS/",
  strPackage = NULL
)
ARS_datasets <- gsm.core::RunWorkflows(lWorkflows = ARS_workflows, lData = ADAM_mapped)

TFL_workflows <- gsm.core::MakeWorkflowList(
  strNames = "WorkProduct1",
  strPath = "./sdtm.oak_data/workflows/3_ADAM_TO_TFL/",
  strPackage = NULL
)
TFLs <- gsm.core::RunWorkflows(lWorkflows = TFL_workflows, lData = ADAM_mapped)
TFLs
