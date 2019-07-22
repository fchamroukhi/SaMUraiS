#' A Reference Class which contains parameters of a RHLP model.
#'
#' ParamRHLP contains all the parameters of a RHLP model. The parameters are
#' calculated by the initialization Method and then updated by the Method
#' implementing the M-Step of the EM algorithm.
#'
#' @field X Numeric vector of length \emph{m} representing the covariates/inputs
#'   \eqn{x_{1},\dots,x_{m}}.
#' @field Y Numeric vector of length \emph{m} representing the observed
#'   response/output \eqn{y_{1},\dots,y_{m}}.
#' @field m Numeric. Length of the response/output vector `Y`.
#' @field K The number of regimes (RHLP components).
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
#'   (\beta_{1},\dots,\beta_{K})} is a matrix of dimension \eqn{(p + 1, K)},
#'   with `p` the order of the polynomial regression. `p` is fixed to 3 by
#'   default.
#' @field sigma2 The variances for the `K` regimes. If RHLP model is
#'   heteroskedastic (`variance_type = "heteroskedastic"`) then `sigma2` is a
#'   matrix of size \eqn{(K, 1)} (otherwise RHLP model is homoskedastic
#'   (`variance_type = "homoskedastic"`) and `sigma2` is a matrix of size
#'   \eqn{(1, 1)}).
#' @field nu The degree of freedom of the RHLP model representing the complexity
#'   of the model.
#' @field phi A list giving the regression design matrices for the polynomial
#'   and the logistic regressions.
#' @export
ParamRHLP <- setRefClass(
  "ParamRHLP",
  fields = list(
    X = "numeric",
    Y = "numeric",
    m = "numeric",
    phi = "list",

    K = "numeric",
    p = "numeric",
    q = "numeric",
    variance_type = "character",
    nu = "numeric",

    W = "matrix",
    beta = "matrix",
    sigma2 = "matrix"
  ),
  methods = list(

    initialize = function(X = numeric(), Y = numeric(), K = 1, p = 3, q = 1, variance_type = "heteroskedastic") {

      X <<- X
      Y <<- Y
      m <<- length(Y)
      phi <<- designmatrix(x = X, p = p, q = q)

      K <<- K
      p <<- p
      q <<- q
      variance_type <<- variance_type

      if (variance_type == "homoskedastic") {
        nu <<- (q + 1) * (K - 1) + (p + 1) * K + 1
      } else {
        nu <<- (q + 1) * (K - 1) + (p + 1) * K + K
      }

      W <<- matrix(0, p + 1, K - 1)
      beta <<- matrix(NA, p + 1, K)

      if (variance_type == "homoskedastic") {
        sigma2 <<- matrix(NA)
      }
      else {
        sigma2 <<- matrix(NA, K)
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

        zi <- round(m / K) - 1

        beta <<- matrix(NA, p + 1, K)

        for (k in 1:K) {
          i <- (k - 1) * zi + 1
          j <- k * zi
          yij <- Y[i:j]

          Phi_ij <- phi$XBeta[i:j, ]

          bk <-  solve(t(Phi_ij) %*% Phi_ij, tol = 0) %*% t(Phi_ij) %*% yij
          beta[, k] <<- bk

          if (variance_type == "homoskedastic") {
            sigma2 <<- matrix(1)
          }
          else {
            sigma2[k] <<- var(yij)
          }
        }
      } else {# Random segmentation into K contiguous segments, and then a regression

        # Initialization of W
        W <<- rand(q + 1, K - 1)

        Lmin <- round(m / (K + 1)) # Minimum number of points in a segment
        tk_init <- zeros(K, 1)
        if (K == 1) {
          tk_init[2] = m
        } else {
          K_1 <- K
          for (k in 2:K) {
            K_1 <- (K_1 - 1)
            temp <-
              (tk_init[k - 1] + Lmin):(m - (K_1 * Lmin))

            ind <- sample(length(temp))

            tk_init[k] <- temp[ind[1]]
          }
          tk_init[K + 1] <- m
        }

        beta <<- matrix(NA, p + 1, K)
        for (k in 1:K) {
          i <- tk_init[k] + 1
          j <- tk_init[k + 1]
          yij <- Y[i:j]
          Phi_ij <- phi$XBeta[i:j, ]
          bk <- solve(t(Phi_ij) %*% Phi_ij) %*% t(Phi_ij) %*% yij
          beta[, k] <<- bk

          if (variance_type == "homoskedastic") {
            sigma2 <<- var(Y)
          }
          else {
            sigma2[k] <<- 1
          }
        }
      }
    },

    MStep = function(statRHLP, verbose_IRLS) {
      "Method which implements the M-step of the EM algorithm to learn the
      parameters of the RHLP model based on statistics provided by the object
      \\code{statRHLP} of class \\link{StatRHLP} (which contains the E-step)."

      # Maximization w.r.t betak and sigmak (the variances)
      if (variance_type == "homoskedastic") {
        s = 0
      }
      for (k in 1:K) {
        weights <- statRHLP$tau_ik[, k] # Post prob of each component k (dimension nx1)
        nk <- sum(weights) # Expected cardinal number of class k

        Xk <- phi$XBeta * (sqrt(weights) %*% ones(1, p + 1)) # [m*(p+1)]
        yk <- Y * (sqrt(weights)) # Dimension: (nx1).*(nx1) = (nx1)

        M <- t(Xk) %*% Xk
        epps <- 1e-9
        M <- M + epps * diag(p + 1)

        beta[, k] <<- solve(M, tol = 0) %*% t(Xk) %*% yk # Maximization w.r.t betak
        z <- sqrt(weights) * (Y - phi$XBeta %*% beta[, k])

        # Maximisation w.r.t sigmak (the variances)
        sk <- t(z) %*% z

        if (variance_type == "homoskedastic") {
          s <- s + sk
          sigma2 <<- s / m
        } else {
          sigma2[k] <<- sk / nk
        }
      }

      # Maximization w.r.t W
      #  IRLS : Iteratively Reweighted Least Squares (for IRLS, see the IJCNN 2009 paper)
      res_irls <- IRLS(phi$Xw, statRHLP$tau_ik, ones(nrow(statRHLP$tau_ik), 1), W, verbose_IRLS)

      W <<- res_irls$W
      pi_ik <- res_irls$piik
      reg_irls <- res_irls$reg_irls
    }
  )
)
