#' A Reference Class which contains the parameters of a MRHLP model.
#'
#' ParamMRHLP contains all the parameters of a MRHLP model. The parameters are
#' calculated by the initialization Method and then updated by the Method
#' implementing the M-Step of the EM algorithm.
#'
#' @field mData [MData][MData] object representing the sample (covariates/inputs
#'   `X` and observed responses/outputs `Y`).
#' @field K The number of regimes (MRHLP components).
#' @field p The order of the polynomial regression.
#' @field q The dimension of the logistic regression. For the purpose of
#'   segmentation, it must be set to 1.
#' @field variance_type Character indicating if the model is homoskedastic
#'   (`variance_type = "homoskedastic"`) or heteroskedastic (`variance_type =
#'   "heteroskedastic"`). By default the model is heteroskedastic.
#' @field W Parameters of the logistic process. \eqn{\boldsymbol{W} =
#'   (\boldsymbol{w}_{1},\dots,\boldsymbol{w}_{K-1})}{W = (w_{1},\dots,w_{K-1})}
#'   is a matrix of dimension \eqn{(q + 1, K - 1)}, with `q` the order of the
#'   logistic regression. `q` is fixed to 1 by default.
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
#' @field nu The degree of freedom of the MRHLP model representing the
#'   complexity of the model.
#' @field phi A list giving the regression design matrices for the polynomial
#'   and the logistic regressions.
#' @export
ParamMRHLP <- setRefClass(
  "ParamMRHLP",
  fields = list(
    mData = "MData",
    phi = "list",

    K = "numeric", # Number of regimes
    p = "numeric", # Dimension of beta (order of polynomial regression)
    q = "numeric", # Dimension of w (order of logistic regression)
    variance_type = "character",
    nu = "numeric", # Degree of freedom

    W = "matrix",
    beta = "array",
    sigma2 = "array"
  ),
  methods = list(
    initialize = function(mData = MData(numeric(1), matrix(1)), K = 1, p = 3, q = 1, variance_type = "heteroskedastic") {
      mData <<- mData

      phi <<- designmatrix(x = mData$X, p = p, q = q)

      K <<- K
      p <<- p
      q <<- q
      variance_type <<- variance_type

      if (variance_type == "homoskedastic") {
        nu <<- (q + 1) * (K - 1) + mData$d * (p + 1) * K + mData$d * (mData$d + 1) / 2
      } else {
        nu <<- (q + 1) * (K - 1) + mData$d * (p + 1) * K + K * mData$d * (mData$d + 1) / 2
      }

      W <<- matrix(0, q + 1, K - 1)
      beta <<- array(NA, dim = c(p + 1, mData$d, K))
      if (variance_type == "homoskedastic") {
        sigma2 <<- matrix(NA, mData$d, mData$d)
      } else {
        sigma2 <<- array(NA, dim = c(mData$d, mData$d, K))
      }
    },

    initParam = function(try_algo = 1) {
      "Method to initialize parameters \\code{W}, \\code{beta} and
      \\code{sigma2}.

      If \\code{try_algo = 1} then \\code{beta} and \\code{sigma2} are
      initialized by segmenting  the time series \\code{Y} uniformly into
      \\code{K} contiguous segments. Otherwise, \\code{W}, \\code{beta} and
      \\code{sigma2} are initialized by segmenting randomly the time series
      \\code{Y} into \\code{K} segments."

      if (try_algo == 1) { # Uniform segmentation into K contiguous segments, and then a regression

        # Initialization of W
        W <<- zeros(q + 1, K - 1)

        zi <- round(mData$m / K) - 1

        s <- 0

        for (k in 1:K) {
          i <- (k - 1) * zi + 1
          j <- k * zi

          yk <- mData$Y[i:j,]
          Xk <- phi$XBeta[i:j, , drop = FALSE]

          beta[, , k] <<- solve(t(Xk) %*% Xk, tol = 0) %*% t(Xk) %*% yk

          muk <- Xk %*% beta[, , k]
          sk <- t(yk - muk) %*% (yk - muk)
          if (variance_type == "homoskedastic") {
            s <- s + sk
            sigma2 <<- s / mData$m
          } else{
            sigma2[, , k] <<- sk / length(yk)
          }
        }

      }
      else{# Random segmentation into K contiguous segments, and then a regression on each segment

        # Initialization of W
        W <<- rand(q + 1, K - 1)

        Lmin <- 2 # Minimum number of points in a segment
        tk_init <- zeros(K + 1, 1)
        K_1 <- K
        for (k in 2:K) {
          K_1 <- K_1 - 1

          temp <- tk_init[k - 1] + Lmin:(mData$m - (K_1 * Lmin) - tk_init[k - 1])

          ind <- sample(length(temp))

          tk_init[k] <- temp[ind[1]]
        }
        tk_init[K + 1] <- mData$m

        s <- 0
        for (k in 1:K) {
          i <- tk_init[k] + 1
          j <- tk_init[k + 1]

          yk <- mData$Y[i:j,]
          Xk <- phi$XBeta[i:j, ,  drop = FALSE]

          beta[, , k] <<- solve(t(Xk) %*% Xk, tol = 0) %*% t(Xk) %*% yk

          muk <- Xk %*% beta[, , k]
          sk <- t(yk - muk) %*% (yk - muk)

          if (variance_type == "homoskedastic") {
            s <- s + sk
            sigma2 <<- s / mData$m
          }
          else{
            sigma2[, , k] <<- sk / length(yk)
          }
        }
      }
    },

    MStep = function(statMRHLP, verbose_IRLS) {
      "Method which implements the M-step of the EM algorithm to learn the
      parameters of the MRHLP model based on statistics provided by the object
      \\code{statMRHLP} of class \\link{StatMRHLP} (which contains the
      E-step)."

      # Maximization w.r.t betak and sigmak (the variances)
      if (variance_type == "homoskedastic") {
        s = 0
      }
      for (k in 1:K) {
        weights <- statMRHLP$tau_ik[, k] # Post probabilities of each component k (dimension nx1)
        nk <- sum(weights) # Expected cardinal numnber of class k

        Xk <- phi$XBeta * (sqrt(weights) %*% ones(1, p + 1)) # [m*(p+1)]
        yk <- mData$Y * (sqrt(weights) %*% ones(1, mData$d))

        M <- t(Xk) %*% Xk
        epps <- 1e-9
        M <- M + epps * diag(p + 1)

        beta[, , k] <<- solve(M, tol = FALSE) %*% t(Xk) %*% yk # Maximization w.r.t betak
        z <- (mData$Y - phi$XBeta %*% beta[, , k]) * (sqrt(weights) %*% ones(1, mData$d))

        # Maximisation w.r.t sigmak (the variances)
        sk <- t(z) %*% z

        if (variance_type == "homoskedastic") {
          s <- s + sk
          sigma2 <<- s / mData$m
        } else {
          sigma2[, , k] <<- sk / nk
        }
      }

      # Maximization w.r.t W
      #  IRLS : Iteratively Reweighted Least Squares (for IRLS, see our IJCNN 2009 paper for example)
      res_irls <- IRLS(phi$Xw, statMRHLP$tau_ik, ones(nrow(statMRHLP$tau_ik), 1), W, verbose_IRLS)

      W <<- res_irls$W
      piik <- res_irls$piik
      reg_irls <- res_irls$reg_irls
    }
  )
)
