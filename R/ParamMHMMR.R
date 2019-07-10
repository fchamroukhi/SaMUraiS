#' A Reference Class which contains parameters of a MHMMR model.
#'
#' ParamMHMMR contains all the parameters of a MHMMR model.
#'
#' @field mData [MData][MData] object representing the sample (covariates/inputs
#'   `X` and observed multivariate responses/outputs `Y`).
#' @field K The number of regimes (MHMMR components).
#' @field p The order of the polynomial regression.
#' @field variance_type Character indicating if the model is homoskedastic
#'   (`variance_type = "homoskedastic"`) or heteroskedastic (`variance_type =
#'   "heteroskedastic"`). By default the model is heteroskedastic.
#' @field prior The prior probabilities of the Markov chain. `prior` is a row
#'   matrix of dimension \eqn{(1, K)}.
#' @field trans_mat The transition matrix of the Markov chain. `trans_mat` is a
#'   matrix of dimension \eqn{(K, K)}.
#' @field mask Mask applied to the transition matrices `trans_mat`. By default,
#'   a mask of order one is applied.
#' @field beta Parameters of the polynomial regressions. \eqn{\boldsymbol{\beta}
#'   = (\boldsymbol{\beta}_{1},\dots,\boldsymbol{\beta}_{K})}{\beta =
#'   (\beta_{1},\dots,\beta_{K})} is an array of dimension \eqn{(p + 1, d, K)},
#'   with `p` the order of the polynomial regression. `p` is fixed to 3 by
#'   default.
#' @field sigma2 The variances for the `K` regimes. If MRHLP model is
#'   heteroskedastic (`variance_type = "heteroskedastic"`) then `sigma2` is an
#'   array of size \eqn{(d, d, K)} (otherwise MRHLP model is homoskedastic
#'   (`variance_type = "homoskedastic"`) and `sigma2` is a matrix of size
#'   \eqn{(d, d)}).
#' @field nu The degree of freedom of the MHMMR model representing the
#'   complexity of the model.
#' @field phi A list giving the regression design matrices for the polynomial
#'   and the logistic regressions.
#' @export
#' @importFrom MASS ginv
ParamMHMMR <- setRefClass(
  "ParamMHMMR",
  fields = list(
    mData = "MData",
    phi = "matrix",

    K = "numeric", # Number of regimes
    p = "numeric", # Dimension of beta (order of polynomial regression)
    variance_type = "character",
    nu = "numeric", # Degree of freedom

    prior = "matrix",
    trans_mat = "matrix",
    beta = "array",
    sigma2 = "array",
    mask = "matrix"
  ),
  methods = list(
    initialize = function(mData = MData(numeric(1), matrix(1)), K = 2, p = 3, variance_type = "heteroskedastic") {
      mData <<- mData

      phi <<- designmatrix(x = mData$X, p = p)$XBeta

      K <<- K
      p <<- p
      variance_type <<- variance_type

      if (variance_type == "homoskedastic") {
        nu <<- K - 1 + K * (K - 1) + mData$d * (p + 1) * K + mData$d * (mData$d + 1) / 2
      } else {
        nu <<- K - 1 + K * (K - 1) + mData$d * (p + 1) * K + K * mData$d * (mData$d + 1) / 2
      }

      prior <<- matrix(NA, ncol = K)
      trans_mat <<- matrix(NA, K, K)
      beta <<- array(NA, dim = c(p + 1, mData$d, K))
      if (variance_type == "homoskedastic") {
        sigma2 <<- matrix(NA, mData$d, mData$d)
      } else {
        sigma2 <<- array(NA, dim = c(mData$d, mData$d, K))
      }
      mask <<- matrix(NA, K, K)

    },

    initParam = function(try_algo = 1) {
      "Method to initialize parameters \\code{prior}, \\code{trans_mat},
      \\code{beta} and \\code{sigma2}.

      If \\code{try_algo = 1} then \\code{beta} and \\code{sigma2} are
      initialized by segmenting  the time series \\code{Y} uniformly into
      \\code{K} contiguous segments. Otherwise, \\code{beta} and
      \\code{sigma2} are initialized by segmenting randomly the time series
      \\code{Y} into \\code{K} segments."

      # Initialization taking into account the constraint:

      # Initialization of the transition matrix
      maskM <- 0.5 * diag(K) # Mask of order 1

      if (K > 1) {
        for (k in 1:(K - 1)) {
          ind <- which(maskM[k,] != 0)
          maskM[k, ind + 1] <- 0.5
        }
      }
      trans_mat <<- maskM
      mask <<- maskM

      # Initialization of the initial distribution
      prior <<- matrix(c(1, rep(0, K - 1)))

      # Initialization of regression coefficients and variances
      if (try_algo == 1) { # Uniform segmentation into K contiguous segments, and then a regression

        zi <- round(mData$m / K) - 1

        s <- 0 # If homoskedastic
        for (k in 1:K) {
          yk <- mData$Y[((k - 1) * zi + 1):(k * zi),]
          Xk <- phi[((k - 1) * zi + 1):(k * zi), , drop = FALSE]

          beta[, , k] <<- solve(t(Xk) %*% Xk + (10 ^ -4) * diag(p + 1)) %*% t(Xk) %*% yk # regress(yk,Xk); # for a use in octave, where regress doesnt exist

          muk <- Xk %*% beta[, , k]
          sk <- t(yk - muk) %*% (yk - muk)
          if (variance_type == "homoskedastic") {
            s <- (s + sk)
            sigma2 <<- s / mData$m
          } else {
            sigma2[, , k] <<- sk / length(yk)
          }
        }
      } else {# Random segmentation into contiguous segments, and then a regression

        Lmin <- p + 1 + 1 # Minimum length of a segment
        tk_init <- rep(0, K)
        tk_init <- t(tk_init)
        tk_init[1] <- 0
        K_1 <- K
        for (k in 2:K) {
          K_1 <- K_1 - 1
          temp <- seq(tk_init[k - 1] + Lmin, mData$m - K_1 * Lmin)
          ind <- sample(length(temp))
          tk_init[k] <- temp[ind[1]]
        }
        tk_init[K + 1] <- mData$m

        s <- 0
        for (k in 1:K) {
          i <- tk_init[k] + 1
          j <- tk_init[k + 1]
          yk <- mData$Y[i:j,]
          Xk <- phi[i:j, ,  drop = FALSE]
          beta[, , k] <<- solve(t(Xk) %*% Xk + 1e-4 * diag(p + 1)) %*% t(Xk) %*% yk #regress(yk,Xk); # for a use in octave, where regress doesnt exist
          muk <- Xk %*% beta[, , k]
          sk <- t(yk - muk) %*% (yk - muk)

          if (variance_type == "homoskedastic") {
            s <- s + sk
            sigma2[1] <<- s / mData$m

          } else {
            sigma2[, , k] <<- sk / length(yk)
          }
        }
      }

    },

    MStep = function(statMHMMR) {
      "Method which implements the M-step of the EM algorithm to learn the
      parameters of the MHMMR model based on statistics provided by the object
      \\code{statMHMMR} of class \\link{StatMHMMR} (which contains the
      E-step)."

      # Updates of the Markov chain parameters
      # Initial states prob: P(Z_1 = k)
      prior <<- matrix(normalize(statMHMMR$tau_tk[1,])$M)

      # Transition matrix: P(Zt=i|Zt-1=j) (A_{k\ell})
      trans_mat <<- mkStochastic(apply(statMHMMR$xi_tkl, c(1, 2), sum))

      # For segmental HMMR: p(z_t = k| z_{t-1} = \ell) = zero if k<\ell (no back) of if k >= \ell+2 (no jumps)
      trans_mat <<- mkStochastic(mask * trans_mat)
      # Update of the regressors (reg coefficients betak and the variance(s) sigma2k)

      s <- 0 # If homoskedastic
      for (k in 1:K) {
        weights <- statMHMMR$tau_tk[, k]

        nk <- sum(weights) # Expected cardinal number of state k
        Xk <- phi * (sqrt(weights) %*% matrix(1, 1, p + 1)) # [n*(p+1)]
        yk <- mData$Y * (sqrt(weights) %*% ones(1, mData$d)) # dimension :(nxd).*(nxd) = (nxd)

        # Regression coefficients
        lambda <- 1e-5 # If a bayesian prior on the beta's


        # bk <- (solve(t(Xk) %*% Xk + lambda * diag(p + 1)) %*% t(Xk)) %*% y
        bk <- (ginv(t(Xk) %*% Xk) %*% t(Xk)) %*% yk

        beta[, , k] <<- bk

        # Variance(s)
        z <- (mData$Y - phi %*% bk) * (sqrt(weights) %*% ones(1, mData$d))
        sk <- t(z) %*% z
        if (variance_type == "homoskedastic") {
          s <- (s + sk)
          sigma2 <<- s / mData$m
        } else {
          sigma2[, , k] <<- sk / nk + lambda * diag(x = 1, mData$d)
        }
      }

    }
  )
)
