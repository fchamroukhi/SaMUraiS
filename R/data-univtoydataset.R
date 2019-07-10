#' A simulated non-stationary time series with regime changes.
#'
#' A simulated non-stationary time series with regime changes.
#' This time series is used for illustration.
#'
#' @format A data frame with 670 rows and 2 variables:
#' \describe{
#'   \item{x}{The covariate variable which is the time in that case.}
#'   \item{y}{The time series. The latter has been generated as follows:
#'     \itemize{
#'       \item  First regime: 100 values of Normally distributed random numbers.
#'       \item Second regime: 120 values of Normally distributed random numbers
#'         with mean 7.
#'       \item Third regime: 200 values of Normally distributed random numbers
#'         with mean 4.
#'       \item Fourth regime: 100 values of Normally distributed random numbers
#'         with mean -2.
#'       \item Fifth regime: 150 values of Normally distributed random numbers
#'         with mean 3.5.
#'     }
#'   }
#' }
#'
"univtoydataset"
