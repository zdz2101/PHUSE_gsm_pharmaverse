# this should be all the libraries need to run this as is
# devtools::install_github("Gilead-BioStats/gsm.core")
# install.packages(c("dplyr", "admiral", "sdtm.oak", "cards", "gtsummary", "arrow", "purrr"))
library(gsm.core)
library(dplyr)
library(admiral)
library(sdtm.oak)
library(cards)
library(gtsummary)
library(arrow)
library(purrr)
library(here)
# setwd("path to /PHUSE_gsm_pharmaverse/")

# Prepare list of data of raw-data
lData <- list(
    Raw_DM = read_parquet("./ABC123/data/RAWDATA/dm.parquet"),
    Raw_VS = read_parquet("./ABC123/data/RAWDATA/vs.parquet")
)

# ------------------------------------------------------------------------------
## FOR SDTM
# Parse and read in raw data to necessary transforms of SDTM data using sdtm.oak
SDTM_workflows <- gsm.core::MakeWorkflowList(
  strNames = c("DM", "VS"),
  strPath = "./ABC123/workflows/1_RAW_TO_SDTM/",
  strPackage = NULL
)
SDTM_mapped <- gsm.core::RunWorkflows(lWorkflows = SDTM_workflows, lData = lData)
# Take Results and save them as parquets in a SDTM folder
map2(
  SDTM_mapped,
  names(SDTM_mapped),
  function(x,y) arrow::write_parquet(x, paste0("./ABC123/data/SDTM/",y))
)
# ------------------------------------------------------------------------------




# ------------------------------------------------------------------------------
## FOR ADaM

# Use admiral to create a basic ADSL
options("yaml.eval.expr" = TRUE) # needs for admiral -- suggest gsm ecoystem write documentation
ADAM_workflows <- gsm.core::MakeWorkflowList(
  strNames = "ADSL",
  strPath = "./ABC123/workflows/2_SDTM_TO_ADAM/",
  strPackage = NULL
)
ADAM_mapped <- gsm.core::RunWorkflows(lWorkflows = ADAM_workflows, lData = SDTM_mapped)
# Take Results and save them as parquets in a ADaM Folder
map2(ADAM_mapped, names(ADAM_mapped), function(x,y) arrow::write_parquet(x, paste0("./ABC123/data/ADaM/",y)))
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
## FOR TFL
TFL_workflows <- gsm.core::MakeWorkflowList(
  strNames = "WorkProduct1",
  strPath = "./ABC123/workflows/3_ADAM_TO_TFL/",
  strPackage = NULL
)
TFLs <- gsm.core::RunWorkflows(lWorkflows = TFL_workflows, lData = ADAM_mapped)
TFLs
# ------------------------------------------------------------------------------




# ------------------------------------------------------------------------------
## FOR ARS

ARS_workflows <- gsm.core::MakeWorkflowList(
  strNames = "table1_ars",
  strPath = "./ABC123/workflows/3_ADAM_TO_ARS/",
  strPackage = NULL
)
ARS_datasets <- gsm.core::RunWorkflows(lWorkflows = ARS_workflows, lData = ADAM_mapped)
map2(ARS_datasets, names(ARS_datasets), function(x,y) saveRDS(x, paste0("./ABC123/data/ARS/", y))) # parquet may not be good export
# ------------------------------------------------------------------------------

