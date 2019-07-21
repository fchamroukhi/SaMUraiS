#' A Reference Class which contains the parameters of a PWR model.
#'
#' ParamPWR contains all the parameters of a PWR model. The parameters are
#' calculated by the initialization Method and then updated by the Method
#' dynamic programming (here dynamic programming)
#'
#' @field X Numeric vector of length \emph{m} representing the covariates/inputs
#'   \eqn{x_{1},\dots,x_{m}}.
#' @field Y Numeric vector of length \emph{m} representing the observed
#'   response/output \eqn{y_{1},\dots,y_{m}}.
#' @field m Numeric. Length of the response/output vector `Y`.
#' @field K The number of regimes (PWR components).
#' @field p The order of the polynomial regression. `p` is fixed to 3 by
#'   default.
#' @field gamma Set of transition points. `gamma` is a column matrix of size
#'   \eqn{(K + 1, 1)}.
#' @field beta Parameters of the polynomial regressions. `beta` is a matrix of
#'   dimension \eqn{(p + 1, K)}, with `p` the order of the polynomial
#'   regression. `p` is fixed to 3 by default.
#' @field sigma2 The variances for the `K` regimes. `sigma2` is a matrix of size
#'   \eqn{(K, 1)}.
#' @field phi A list giving the regression design matrices for the polynomial
#'   and the logistic regressions.
#' @export
ParamPWR <- setRefClass(
  "ParamPWR",
  fields = list(
    X = "numeric",
    Y = "numeric",
    m = "numeric",
    phi = "matrix",

    K = "numeric", # Number of regimes
    p = "numeric", # Dimension of beta (order of polynomial regression)

    gamma = "matrix",
    beta = "matrix",
    sigma2 = "matrix"
  ),
  methods = list(
    initialize = function(X = numeric(), Y = numeric(1), K = 2, p = 3) {
      X <<- X
      Y <<- Y
      m <<- length(Y)
      phi <<- designmatrix(X, p)$XBeta

      K <<- K
      p <<- p

      gamma <<- matrix(NA, K + 1)
      beta <<- matrix(NA, p + 1, K)
      sigma2 <<- matrix(NA, K)

    },

    computeDynamicProgram = function(C1, K) {
      "Method which implements the dynamic programming based on the cost matrix
      \\code{C1} and the number of regimes/segments \\code{K}."

      # Dynamic programming
      solution <- dynamicProg(C1, K)
      Ck <- solution$J
      gamma <<- matrix(c(0, solution$t_est[nrow(solution$t_est),]))  # Change points
      return(Ck)
    },

    computeParam = function() {
      "Method which estimates the parameters \\code{beta} and \\code{sigma2}
      knowing the transition points \\code{gamma}."

      for (k in 1:K) {
        i <- gamma[k] + 1
        j <- gamma[k + 1]
        nk <- j - i + 1
        yij <- Y[i:j]
        X_ij <- phi[i:j, , drop = FALSE]
        beta[, k] <<- solve(t(X_ij) %*% X_ij, tol = 0) %*% t(X_ij) %*% yij

        if (p == 0) {
          z <- yij - X_ij * beta[, k]
        } else {
          z <- yij - X_ij %*% beta[, k]
        }
        sigma2[k] <<- t(z) %*% z / nk # Variances
      }
    }
  )
)
