#' A Reference Class which contains statistics of a RHLP model.
#'
#' StatRHLP contains all the statistics associated to a [RHLP][ParamRHLP] model.
#' It mainly includes the E-Step of the EM algorithm calculating the posterior
#' distribution of the hidden variables, as well as the calculation of the
#' log-likelhood at each step of the algorithm and the obtained values of model
#' selection criteria..
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
#' @field polynomials Matrix of size \eqn{(m, K)} giving the values of the
#'   estimated polynomial regression components.
#' @field Ex Column matrix of dimension \emph{m}. `Ex` is the curve expectation
#'   (estimated signal): sum of the polynomial components weighted by the
#'   logistic probabilities `pi_ik`.
#' @field loglik Numeric. Observed-data log-likelihood of the RHLP model.
#' @field com_loglik Numeric. Complete-data log-likelihood of the RHLP model.
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
#' @seealso [ParamRHLP]
#' @export
StatRHLP <- setRefClass(
  "StatRHLP",
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
    polynomials = "matrix"
  ),
  methods = list(

    initialize = function(paramRHLP = ParamRHLP()) {

      pi_ik <<- matrix(NA, paramRHLP$m, paramRHLP$K)
      z_ik <<- matrix(NA, paramRHLP$m, paramRHLP$K)
      klas <<- matrix(NA, paramRHLP$m, 1)
      Ex <<- matrix(NA, paramRHLP$m, 1)
      loglik <<- -Inf
      com_loglik <<- -Inf
      stored_loglik <<- numeric()
      stored_com_loglik <<- numeric()
      BIC <<- -Inf
      ICL <<- -Inf
      AIC <<- -Inf
      log_piik_fik <<- matrix(0, paramRHLP$m, paramRHLP$K)
      log_sum_piik_fik <<- matrix(NA, paramRHLP$m, 1)
      tau_ik <<- matrix(0, paramRHLP$m, paramRHLP$K)
      polynomials <<- matrix(NA, paramRHLP$m, paramRHLP$K)

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
      z_ik <<- ikmax %*% ones(1, K) == ones(N, 1) %*% (1:K)
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

    computeStats = function(paramRHLP) {
      "Method used in the EM algorithm to compute statistics based on
      parameters provided by the object \\code{paramRHLP} of class
      \\link{ParamRHLP}."

      polynomials <<- paramRHLP$phi$XBeta %*% paramRHLP$beta
      Ex <<- matrix(rowSums(pi_ik * polynomials))

      BIC <<- loglik - (paramRHLP$nu * log(paramRHLP$m) / 2)
      AIC <<- loglik - paramRHLP$nu

      zik_log_alphag_fg_xij <- (z_ik) * (log_piik_fik)
      com_loglik <<- sum(rowSums(zik_log_alphag_fg_xij))
      ICL <<- com_loglik - paramRHLP$nu * log(paramRHLP$m) / 2

    },

    EStep = function(paramRHLP) {
      "Method used in the EM algorithm to update statistics based on parameters
      provided by the object \\code{paramRHLP} of class \\link{ParamRHLP}
      (prior and posterior probabilities)."

      pi_ik <<- multinomialLogit(paramRHLP$W, paramRHLP$phi$Xw, ones(paramRHLP$m, paramRHLP$K), ones(paramRHLP$m, 1))$piik

      for (k in (1:paramRHLP$K)) {
        muk <- paramRHLP$phi$XBeta %*% paramRHLP$beta[, k]

        if (paramRHLP$variance_type == "homoskedastic") {
          sigmak <- paramRHLP$sigma2[1]
        } else {
          sigmak <- paramRHLP$sigma2[k]
        }
        z <- ((paramRHLP$Y - muk) ^ 2) / sigmak
        log_piik_fik[, k] <<- log(pi_ik[, k]) - (0.5 * ones(paramRHLP$m, 1) * (log(2 * pi) + log(sigmak))) - (0.5 * z)
      }

      log_piik_fik <<- pmax(log_piik_fik, log(.Machine$double.xmin))
      piik_fik <- exp(log_piik_fik)
      fxi <- rowSums(piik_fik)
      log_fxi <- log(fxi)
      log_sum_piik_fik <<- matrix(log(rowSums(piik_fik)))
      log_tik <- log_piik_fik - log_sum_piik_fik %*% ones(1, paramRHLP$K)
      tau_ik <<- normalize(exp(log_tik), 2)$M
    }
  )
)
