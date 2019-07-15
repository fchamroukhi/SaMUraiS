#' A Reference Class which contains statistics of a MRHLP model.
#'
#' StatMRHLP contains all the statistics associated to a [MRHLP][ParamMRHLP]
#' model. It mainly includes the E-Step of the EM algorithm calculating the
#' posterior distribution of the hidden variables, as well as the calculation of
#' the log-likelhood at each step of the algorithm and the obtained values of
#' model selection criteria..
#'
#' @field pi_ik Matrix of size \eqn{(m, K)} representing the prior/logistic
#'   probabilities \eqn{\pi_{k}(x_{i}; \boldsymbol{\Psi}) = P(z_{i} = k |
#'   \boldsymbol{x}; \Psi)}{\pi_{k}(x_{i}; \Psi) = P(z_{i} = k | x; \Psi)} of
#'   the latent variable \eqn{z_{i}, i = 1,\dots,m}.
#' @field z_ik Hard segmentation logical matrix of dimension \eqn{(m, K)}
#'   obtained by the Maximum a posteriori (MAP) rule: \eqn{z\_ik = 1 \
#'   \textrm{if} \ z\_ik = \textrm{arg} \ \textrm{max}_{s} \ \pi_{s}(x_{i};
#'   \boldsymbol{\Psi});\ 0 \ \textrm{otherwise}}{z_ik = 1 if z_ik = arg max_s
#'   \pi_{s}(x_{i}; \Psi); 0 otherwise}, \eqn{k = 1,\dots,K}.
#' @field klas Column matrix of the labels issued from `z_ik`. Its elements are
#'   \eqn{klas(i) = k}, \eqn{k = 1,\dots,K}.
#' @field tau_ik Matrix of size \eqn{(m, K)} giving the posterior probability
#'   that the observation \eqn{Y_{i}} originates from the \eqn{k}-th regression
#'   model.
#' @field polynomials Array of size \eqn{(m, d, K)} giving the values of the
#'   estimated polynomial regression components.
#' @field weighted_polynomials Array of size \eqn{(m, d, K)} giving the values
#'   of the estimated polynomial regression components weighted by the prior
#'   probabilities `pi_ik`.
#' @field Ex Matrix of size \emph{(m, d)}. `Ex` is the curve expectation
#'   (estimated signal): sum of the polynomial components weighted by the
#'   logistic probabilities `pi_ik`.
#' @field loglik Numeric. Observed-data log-likelihood of the MRHLP model.
#' @field com_loglik Numeric. Complete-data log-likelihood of the MRHLP model.
#' @field stored_loglik Numeric vector. Stored values of the log-likelihood at
#'   each EM iteration.
#' @field stored_com_loglik Numeric vector. Stored values of the Complete
#'   log-likelihood at each EM iteration.
#' @field BIC Numeric. Value of BIC (Bayesian Information Criterion).
#' @field ICL Numeric. Value of ICL (Integrated Completed Likelihood).
#' @field AIC Numeric. Value of AIC (Akaike Information Criterion).
#' @field log_piik_fik Matrix of size \eqn{(m, K)} giving the values of the
#'   logarithm of the joint probability \eqn{P(y_{i}, \ z_{i} = k |
#'   \boldsymbol{x}, \boldsymbol{\Psi})}{P(y_{i}, z_{i} = k | x, \Psi)}, \eqn{i
#'   = 1,\dots,m}.
#' @field log_sum_piik_fik Column matrix of size \emph{m} giving the values of
#'   \eqn{\textrm{log} \sum_{k = 1}^{K} P(y_{i}, \ z_{i} = k | \boldsymbol{x},
#'   \boldsymbol{\Psi})}{log \sum_{k = 1}^{K} P(y_{i}, z_{i} = k | x, \Psi)},
#'   \eqn{i = 1,\dots,m}.
#' @seealso [ParamMRHLP]
#' @export
StatMRHLP <- setRefClass(
  "StatMRHLP",
  fields = list(
    pi_ik = "matrix",
    z_ik = "matrix",
    klas = "matrix",
    Ex = "matrix",
    loglik = "numeric",
    com_loglik = "numeric",
    stored_loglik = "numeric",
    stored_com_loglik = "numeric",
    BIC = "numeric",
    ICL = "numeric",
    AIC = "numeric",
    log_piik_fik = "matrix",
    log_sum_piik_fik = "matrix",
    tau_ik = "matrix",
    polynomials = "array",
    weighted_polynomials = "array"
  ),
  methods = list(
    initialize = function(paramMRHLP = ParamMRHLP()) {
      pi_ik <<- matrix(NA, paramMRHLP$mData$m, paramMRHLP$K)
      z_ik <<- matrix(NA, paramMRHLP$mData$m, paramMRHLP$K)
      klas <<- matrix(NA, paramMRHLP$mData$m, 1)
      Ex <<- matrix(NA, paramMRHLP$mData$m, paramMRHLP$mData$d)
      loglik <<- -Inf
      com_loglik <<- -Inf
      stored_loglik <<- numeric()
      stored_com_loglik <<- numeric()
      BIC <<- -Inf
      ICL <<- -Inf
      AIC <<- -Inf
      log_piik_fik <<- matrix(0, paramMRHLP$mData$m, paramMRHLP$K)
      log_sum_piik_fik <<- matrix(NA, paramMRHLP$mData$m, 1)
      tau_ik <<- matrix(0, paramMRHLP$mData$m, paramMRHLP$K)
      polynomials <<- array(NA, dim = c(paramMRHLP$mData$m, paramMRHLP$mData$d, paramMRHLP$K))
      weighted_polynomials <<- array(NA, dim = c(paramMRHLP$mData$m, paramMRHLP$mData$d, paramMRHLP$K))
    },

    MAP = function() {
      "MAP calculates values of the fields \\code{z_ik} and \\code{klas}
      by applying the Maximum A Posteriori Bayes allocation rule.

      \\eqn{z_{ik} = 1 \\ \\textrm{if} \\ k = \\textrm{arg} \\ \\textrm{max}_{s}
      \\ \\pi_{s}(x_{i}; \\boldsymbol{\\Psi});\\ 0 \\ \\textrm{otherwise}}{
      z_{ik} = 1 if z_ik = arg max_{s} \\pi_{k}(x_{i}; \\Psi); 0 otherwise}"

      N <- nrow(pi_ik)
      K <- ncol(pi_ik)
      ikmax <- max.col(pi_ik)
      ikmax <- matrix(ikmax, ncol = 1)
      z_ik <<- ikmax %*% ones(1, K) == ones(N, 1) %*% (1:K) # partition_MAP
      klas <<- ones(N, 1)
      for (k in 1:K) {
        klas[z_ik[, k] == 1] <<- k
      }
    },

    computeLikelihood = function(reg_irls) {
      "Method to compute the log-likelihood. \\code{reg_irls} is the value of
      the regularization part in the IRLS algorithm."

      loglik <<- sum(log_sum_piik_fik) + reg_irls

    },

    computeStats = function(paramMRHLP) {
      "Method used in the EM algorithm to compute statistics based on
      parameters provided by the object \\code{paramMRHLP} of class
      \\link{ParamMRHLP}."

      for (k in 1:paramMRHLP$K) {
        polynomials[, , k] <<- paramMRHLP$phi$XBeta %*% paramMRHLP$beta[, , k]
        weighted_polynomials[, , k] <<- (pi_ik[, k] %*% ones(1, paramMRHLP$mData$d)) * polynomials[, , k]
      }

      Ex <<- apply(weighted_polynomials, c(1, 2), sum)

      BIC <<- loglik - (paramMRHLP$nu * log(paramMRHLP$mData$m) / 2)
      AIC <<- loglik - paramMRHLP$nu

      zik_log_alphag_fg_xij <- (z_ik) * (log_piik_fik)

      com_loglik <<- sum(rowSums(zik_log_alphag_fg_xij))


      ICL <<- com_loglik - paramMRHLP$nu * log(paramMRHLP$mData$m) / 2
    },

    EStep = function(paramMRHLP) {
      "Method used in the EM algorithm to update statistics based on parameters
      provided by the object \\code{paramMRHLP} of class \\link{ParamMRHLP}
      (prior and posterior probabilities)."

      pi_ik <<- multinomialLogit(paramMRHLP$W, paramMRHLP$phi$Xw, ones(paramMRHLP$mData$m, paramMRHLP$K), ones(paramMRHLP$mData$m, 1))$piik

      for (k in 1:paramMRHLP$K) {
        muk <- paramMRHLP$phi$XBeta %*% paramMRHLP$beta[, , k]
        if (paramMRHLP$variance_type == "homoskedastic") {
          sigma2k <- paramMRHLP$sigma2
        } else {
          sigma2k <- paramMRHLP$sigma2[, , k]
        }

        z <- ((paramMRHLP$mData$Y - muk) %*% solve(sigma2k, tol = 0)) * (paramMRHLP$mData$Y - muk)

        mahalanobis <- matrix(rowSums(z))

        denom <- (2 * pi) ^ (paramMRHLP$mData$d / 2) * (det(as.matrix(sigma2k))) ^ 0.5

        log_piik_fik[, k] <<- log(pi_ik[, k]) - ones(paramMRHLP$mData$m, 1) %*% log(denom) - 0.5 * mahalanobis
      }

      log_piik_fik <<- pmax(log_piik_fik, log(.Machine$double.xmin))
      piik_fik <- exp(log_piik_fik)
      log_sum_piik_fik <<- matrix(log(rowSums(piik_fik)))

      log_tauik <- log_piik_fik - log_sum_piik_fik %*% ones(1, paramMRHLP$K)
      tau_ik <<- normalize(exp(log_tauik), 2)$M
    }
  )
)
