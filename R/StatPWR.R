#' A Reference Class which contains statistics of a PWR model.
#'
#' StatPWR contains all the statistics associated to a [PWR][ParamPWR] model.
#'
#' @field z_ik Logical matrix of dimension \eqn{(m, K)} giving the class vector.
#' @field klas Column matrix of the labels issued from `z_ik`. Its elements are
#'   \eqn{klas(i) = k}, \eqn{k = 1,\dots,K}.
#' @field mean_function Approximation of the time series given the estimated
#'   parameters. `mean_function` is a matrix of size \eqn{(m, 1)}.
#' @field regressors Matrix of size \eqn{(m, K)} giving the values of the
#'   estimated polynomial regression components.
#' @field objective Numeric. Value of the objective function.
#' @seealso [ParamPWR]
#' @export
StatPWR <- setRefClass(
  "StatPWR",
  fields = list(
    z_ik = "matrix",
    klas = "matrix",
    mean_function = "matrix",
    regressors = "matrix",
    objective = "numeric"
  ),
  methods = list(
    initialize = function(paramPWR = ParamPWR()) {
      z_ik <<- matrix(0, paramPWR$m, paramPWR$K)
      klas <<- matrix(NA, paramPWR$m, 1)
      mean_function <<- matrix(NA, nrow = paramPWR$m , ncol = 1)
      regressors <<- matrix(NA, paramPWR$m, paramPWR$K)
      objective <<- -Inf

    },

    computeStats = function(paramPWR) {
      "Method used at the end of the dynamic programming algorithm to compute
      statistics based on parameters provided by \\code{paramPWR}."

      # Regressors
      regressors <<- paramPWR$phi %*% paramPWR$beta

      # Estimated classes and mean function
      for (k in 1:paramPWR$K)  {

        i <- paramPWR$gamma[k] + 1
        j <- paramPWR$gamma[k + 1]

        klas[i:j] <<- k
        z_ik[i:j, k] <<- 1

        X_ij <- paramPWR$phi[i:j, ]
        if (paramPWR$p == 0) {
          mean_function[i:j, ] <<- X_ij * paramPWR$beta[, k]
        } else {
          mean_function[i:j, ] <<- X_ij %*% paramPWR$beta[, k]
        }
      }
    }
  )
)
