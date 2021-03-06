
#' Get feature importance using permutation method
#'
#' @param trained_model trained model from caret
#' @param train_data training data: dataframe of outcome and features
#' @param test_data held out test data: dataframe of outcome and features
#' @inheritParams run_ml
#'
#' @return dataframe with aucs when each feature is permuted, and differences between test auc and permuted auc
#' @export
#' @author Begüm Topçuoğlu, \email{topcuoglu.begum@@gmail.com}
#' @author Zena Lapp, \email{zenalapp@@umich.edu}
#'
get_feature_importance <- function(trained_model, train_data, test_data, outcome_colname, outcome_value, corr_thresh = 1) {

  # get outcome and features
  split_dat <- split_outcome_features(train_data, outcome_colname)
  outcome <- split_dat$outcome
  features <- split_dat$features

  corr_mat <- get_corr_feats(features, corr_thresh = corr_thresh)
  corr_mat <- dplyr::select_if(corr_mat, !(names(corr_mat) %in% c("corr")))

  grps <- group_correlated_features(corr_mat, features)

  lapply_fn <- select_apply("lapply")
  imps <- do.call("rbind", lapply_fn(grps, function(feat) {
    return(find_permuted_auc(trained_model, test_data, outcome_colname, feat, outcome_value))
  }))

  return(as.data.frame(imps) %>%
    dplyr::mutate(names = factor(grps)))
}



#' Get permuted AUROC difference for a single feature (or group of features)
#'
#' @param feat feature or group of correlated features to permute
#' @inheritParams run_ml
#' @inheritParams get_feature_importance
#'
#' @return vector of mean permuted auc and mean difference between test and permuted auc
#' @export
#' @author Begüm Topçuoğlu, \email{topcuoglu.begum@@gmail.com}
#' @author Zena Lapp, \email{zenalapp@@umich.edu}
#'
find_permuted_auc <- function(method, test_data, outcome_colname, feat, outcome_value) {
  # -----------Get the original testAUC from held-out test data--------->
  # Calculate the test-auc for the actual pre-processed held-out data
  test_auc <- calc_aucs(method, test_data, outcome_colname, outcome_value)$auroc
  # permute grouped features together
  fs <- strsplit(feat, "\\|")[[1]]
  # only include ones in the test data split
  fs <- fs[fs %in% colnames(test_data)]
  # get the new AUC and AUC differences
  sapply_fn <- select_apply(fun = "sapply")
  auc_diffs <- sapply_fn(0:99, function(s) {
    set.seed(s)
    full_permuted <- test_data
    if (length(fs) == 1) {
      full_permuted[, fs] <- sample(full_permuted[, fs])
    } else {
      full_permuted[, fs] <- t(sample(data.frame(t(full_permuted[, fs]))))
    }

    # Calculate the new auc
    new_auc <- calc_aucs(method, full_permuted, outcome_colname, outcome_value)$auroc
    # Return how does this feature being permuted effect the auc
    return(c(new_auc = new_auc, diff = (test_auc - new_auc)))
  })
  auc <- mean(auc_diffs["new_auc", ])
  auc_diff <- mean(auc_diffs["diff", ])
  return(c(auc = auc, auc_diff = auc_diff))
}
