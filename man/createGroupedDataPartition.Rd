% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/split_by_group.R
\name{createGroupedDataPartition}
\alias{createGroupedDataPartition}
\title{Split into train and test set while splitting by group}
\usage{
createGroupedDataPartition(group, p)
}
\arguments{
\item{group}{vector of groups whose length matches the number of rows in the dataset}

\item{p}{maximum percentage of data that goes to training (maybe less depending on group sizes)}
}
\value{
row position integers corresponding to the training data
}
\description{
Split into train and test set while splitting by group
}
\examples{
group <- c("A", "B", "A", "B", "C", "C", "A", "A", "D")
set.seed(0)
train_ind <- createGroupedDataPartition(group, 0.8)
}
