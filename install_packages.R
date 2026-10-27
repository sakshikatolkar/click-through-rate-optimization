# R packages used by the notebooks in notebooks/r/ (tested with R 4.5.2).
# The notebooks also need the IRkernel Jupyter kernel.
pkgs <- c(
  "IRkernel", "tidyverse", "tidymodels", "glmnet", "xgboost", "pROC",
  "ggrepel", "viridis", "hexbin", "rpart", "rpart.plot", "reshape2", "fs", "scales"
)
missing <- setdiff(pkgs, rownames(installed.packages()))
if (length(missing) > 0) install.packages(missing, repos = "https://cloud.r-project.org")
IRkernel::installspec()
