#' A Reference Class which represents multivariate data.
#'
#' MData is a reference class which represents multivariate objects. The data
#' can be ordered by time (multivariate time series). In the last case, the
#' field `X` represents the time.
#'
#' @field X Numeric vector of length \emph{m}.
#' @field Y Matrix of size \eqn{(m, d)} representing a \eqn{d} dimension
#'   function of `X` observed at points \eqn{1,\dots,m}.
#' @export
MData <- setRefClass(
  "MData",
  fields = list(
    X = "numeric", # Covariates
    Y = "matrix", # Response
    m = "numeric",
    d = "numeric",
    vecY = "matrix"
  ),
  methods = list(

    initialize = function(X = numeric(1), Y = matrix(1)) {

      X <<- X
      Y <<- as.matrix(Y)

      m <<- nrow(Y)
      d <<- ncol(Y)

      vecY <<- matrix(t(Y), ncol = 1)

    }
  )
)
