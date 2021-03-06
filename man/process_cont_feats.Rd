% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/preprocess_data.R
\name{process_cont_feats}
\alias{process_cont_feats}
\title{Preprocess continuous features}
\usage{
process_cont_feats(features, method)
}
\arguments{
\item{features}{dataframe of features for machine learning}

\item{method}{methods to preprocess the data, described in \code{caret::preProcess} (defaut: \code{c("center","scale")})}
}
\value{
dataframe of preprocessed features
}
\description{
Preprocess continuous features
}
\examples{
process_cont_feats(mikRopML::otu_small[, 2:ncol(otu_small)], c("center", "scale"))
}
\author{
Zena Lapp, \email{zenalapp@umich.edu}
}
