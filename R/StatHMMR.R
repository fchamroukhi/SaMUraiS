#' A Reference Class which contains statistics of a HMMR model.
#'
#' StatHMMR contains all the statistics associated to a [HMMR][ParamHMMR] model.
#' It mainly includes the E-Step of the EM algorithm calculating the posterior
#' distribution of the hidden variables (ie the smoothing probabilities), as
#' well as the calculation of the prediction and filtering probabilities, the
#' log-likelhood at each step of the algorithm and the obtained values of model
#' selection criteria..
#'
#' @field tau_tk Matrix of size \eqn{(m, K)} giving the posterior probability
#'   that the observation \eqn{Y_{i}} originates from the \eqn{k}-th regression
#'   model.
#' @field alpha_tk Matrix of size \eqn{(m, K)} giving the forwards
#'   probabilities: \eqn{P(Y_{1},\dots,Y_{t}, z_{t} = k)}{P(Y_{1},\dots,Y_{t},
#'   z_{t} = k)}.
#' @field beta_tk Matrix of size \eqn{(m, K)}, giving the backwards
#'   probabilities: \eqn{P(Y_{t+1},\dots,Y_{m} | z_{t} =
#'   k)}{P(Y_{t+1},\dots,Y_{m} | z_{t} = k)}.
#' @field xi_tkl Array of size \eqn{(m - 1, K, K)} giving the joint post
#'   probabilities: \eqn{xi_tk[t, k, l] = P(z_{t} = k, z_{t-1} = l |
#'   \boldsymbol{Y})}{xi_tk[t, k, l] = P(z_{t} = k, z_{t-1} = l | Y)} for \eqn{t
#'   = 2,\dots,m}.
#' @field f_tk Matrix of size \eqn{(m, K)} giving the cumulative distribution
#'   function \eqn{f(y_{t} | z{_t} = k)}{f(y_{t} | z_{t} = k)}.
#' @field log_f_tk Matrix of size \eqn{(m, K)} giving the logarithm of the
#'   cumulative distribution `f_tk`.
#' @field loglik Numeric. Log-likelihood of the HMMR model.
#' @field stored_loglik Numeric vector. Stored values of the log-likelihood at
#'   each iteration of the EM algorithm.
#' @field klas Column matrix of the labels issued from `z_ik`. Its elements are
#'   \eqn{klas(i) = k}, \eqn{k = 1,\dots,K}.
#' @field z_ik Hard segmentation logical matrix of dimension \eqn{(m, K)}
#'   obtained by the Maximum a posteriori (MAP) rule: \eqn{z\_ik = 1 \
#'   \textrm{if} \ z\_ik = \textrm{arg} \ \textrm{max}_{s} \ P(z_{i} = s |
#'   \boldsymbol{Y})  = tau\_tk;\ 0 \ \textrm{otherwise}}{z_ik = 1 if z_ik = arg
#'   max_s P(z_{i} = s | Y) = tau_tk; 0 otherwise}, \eqn{k = 1,\dots,K}.
#' @field state_probs Matrix of size \eqn{(m, K)} giving the distribution of the
#'   Markov chain.
#'   \eqn{P(z_{1},\dots,z_{m};\pi,\boldsymbol{A})}{P(z_{1},\dots,z_{m};\pi,A)}
#'   with \eqn{\pi} the prior probabilities (field `prior` of the class
#'   [ParamHMMR][ParamHMMR]) and \eqn{\boldsymbol{A}}{A} the transition matrix
#'   (field `trans_mat` of the class [ParamHMMR][ParamHMMR]) of the Markov
#'   chain.
#' @field BIC Numeric. Value of BIC (Bayesian Information Criterion).
#' @field AIC Numeric. Value of AIC (Akaike Information Criterion).
#' @field regressors Matrix of size \eqn{(m, K)} giving the values of the
#'   estimated polynomial regression components.
#' @field predict_prob Matrix of size \eqn{(m, K)} giving the prediction
#'   probabilities: \eqn{P(z_{t} = k | y_{1},\dots,y_{t-1})}{P(z_{t} = k |
#'   y_{1},\dots,y_{t-1})}.
#' @field predicted Row matrix of size \eqn{(m, 1)} giving the sum of the
#'   polynomial components weighted by the prediction probabilities
#'   `predict_prob`.
#' @field filter_prob Matrix of size \eqn{(m, K)} giving the filtering
#'   probabilities \eqn{Pr(z_{t} = k | y_{1},\dots,y_{t})}{Pr(z_{t} = k |
#'   y_{1},\dots,y_{t})}.
#' @field filtered Row matrix of size \eqn{(m, 1)} giving the sum of the
#'   polynomial components weighted by the filtering probabilities.
#' @field smoothed_regressors Matrix of size \eqn{(m, K)} giving the polynomial
#'   components weighted by the posterior probability `tau_tk`.
#' @field smoothed Row matrix of size \eqn{(m, 1)} giving the sum of the
#'   polynomial components weighted by the posterior probability `tau_tk`.
#' @seealso [ParamHMMR]
#' @export
StatHMMR <- setRefClass(
  "StatHMMR",
  fields = list(
    tau_tk = "matrix", # tau_tk: smoothing probs: [nxK], tau_tk(t,k) = Pr(z_i=k | y1...yn)
    alpha_tk = "matrix", # alpha_tk: [nxK], forwards probs: Pr(y1...yt,zt=k)
    beta_tk = "matrix", # beta_tk: [nxK], backwards probs: Pr(yt+1...yn|zt=k)
    xi_tkl = "array", # xi_tkl: [(n-1)xKxK], joint post probs : xi_tk\elll(t,k,\ell)  = Pr(z_t=k, z_{t-1}=\ell | Y) t =2,..,n
    f_tk = "matrix", # f_tk: [nxK] f(yt|zt=k)
    log_f_tk = "matrix", # log_f_tk: [nxK] log(f(yt|zt=k))
    loglik = "numeric", # loglik: log-likelihood at convergence
    stored_loglik = "numeric", # stored_loglik: stored log-likelihood values during EM
    klas = "matrix", # klas: [nx1 double]
    z_ik = "matrix", # z_ik: [nxK]
    state_probs = "matrix", # state_probs: [nxK]
    BIC = "numeric", # BIC
    AIC = "numeric", # AIC
    regressors = "matrix", # regressors: [nxK]
    predict_prob = "matrix", # predict_prob: [nxK]: Pr(zt=k|y1...y_{t-1})
    predicted = "matrix", # predicted: [nx1]
    filter_prob = "matrix", # filter_prob: [nxK]: Pr(zt=k|y1...y_t)
    filtered = "matrix", # filtered: [nx1]
    smoothed_regressors = "matrix", # smoothed_regressors: [nxK]
    smoothed = "matrix" # smoothed: [nx1]
  ),
  methods = list(

    initialize = function(paramHMMR = ParamHMMR()) {

      tau_tk <<- matrix(NA, paramHMMR$m, paramHMMR$K) # tau_tk: smoothing probs: [nxK], tau_tk(t,k) = Pr(z_i=k | y1...yn)
      alpha_tk <<- matrix(NA, paramHMMR$m, ncol = paramHMMR$K) # alpha_tk: [nxK], forwards probs: Pr(y1...yt,zt=k)
      beta_tk <<- matrix(NA, paramHMMR$m, paramHMMR$K) # beta_tk: [nxK], backwards probs: Pr(yt+1...yn|zt=k)
      xi_tkl <<- array(NA, c(paramHMMR$m - 1, paramHMMR$K, paramHMMR$K)) # xi_tkl: [(n-1)xKxK], joint post probs : xi_tk\elll(t,k,\ell)  = Pr(z_t=k, z_{t-1}=\ell | Y) t =2,..,n
      f_tk <<- matrix(NA, paramHMMR$m, paramHMMR$K) # f_tk: [nxK] f(yt|zt=k)
      log_f_tk <<- matrix(NA, paramHMMR$m, paramHMMR$K) # log_f_tk: [nxK] log(f(yt|zt=k))
      loglik <<- -Inf # loglik: log-likelihood at convergence
      stored_loglik <<- numeric() # stored_loglik: stored log-likelihood values during EM
      klas <<- matrix(NA, paramHMMR$m, 1) # klas: [nx1 double]
      z_ik <<- matrix(NA, paramHMMR$m, paramHMMR$K) # z_ik: [nxK]
      state_probs <<- matrix(NA, paramHMMR$m, paramHMMR$K) # state_probs: [nxK]
      BIC <<- -Inf # BIC
      AIC <<- -Inf # AIC
      regressors <<- matrix(NA, paramHMMR$m, paramHMMR$K) # regressors: [nxK]
      predict_prob <<- matrix(NA, paramHMMR$m, paramHMMR$K) # predict_prob: [nxK]: Pr(zt=k|y1...y_{t-1})
      predicted <<- matrix(NA, paramHMMR$m, 1) # predicted: [nx1]
      filter_prob <<- matrix(NA, paramHMMR$m, paramHMMR$K) # filter_prob: [nxK]: Pr(zt=k|y1...y_t)
      filtered <<- matrix(NA, paramHMMR$m, 1) # filtered: [nx1]
      smoothed_regressors <<- matrix(NA, paramHMMR$m, paramHMMR$K) # smoothed_regressors: [nxK]
      smoothed <<- matrix(NA, paramHMMR$m, 1) # smoothed: [nx1]

    },

    MAP = function() {
      "MAP calculates values of the fields \\code{z_ik} and \\code{klas}
      by applying the Maximum A Posteriori Bayes allocation rule.

      \\eqn{z\\_ik = 1 \\ \\textrm{if} \\ z\\_ik = \\textrm{arg} \\
      \\textrm{max}_{s} \\ P(z_{i} = s | \\boldsymbol{Y})  = tau\\_tk;\\ 0 \\
      \\textrm{otherwise}}{z_ik = 1 if z_ik = arg max_s P(z_{i} = s | Y) =
      tau_tk; 0 otherwise}"

      N <- nrow(tau_tk)
      K <- ncol(tau_tk)
      ikmax <- max.col(tau_tk)
      ikmax <- matrix(ikmax, ncol = 1)
      z_ik <<- ikmax %*% ones(1, K) == ones(N, 1) %*% (1:K) # partition_MAP
      klas <<- ones(N, 1)
      for (k in 1:K) {
        klas[z_ik[, k] == 1] <<- k
      }
    },

    computeLikelihood = function(paramHMMR) {
      "Method to compute the log-likelihood based on some parameters given by
      the object \\code{paramHMMR} of class \\link{ParamHMMR}."

      fb <- forwardsBackwards(paramHMMR$prior, paramHMMR$trans_mat, t(f_tk))
      loglik <<- fb$loglik

    },

    computeStats = function(paramHMMR) {
      "Method used in the EM algorithm to compute statistics based on
      parameters provided by the object \\code{paramHMMR} of class
      \\link{ParamHMMR}."

      # State sequence prob p(z_1,...,z_n;\pi,A)
      state_probs <<- hmmProcess(paramHMMR$prior, paramHMMR$trans_mat, paramHMMR$m)

      # BIC, AIC, ICL
      BIC <<- loglik - paramHMMR$nu * log(paramHMMR$m) / 2
      AIC <<- loglik - paramHMMR$nu

      # # CL(theta) : Completed-data loglikelihood
      # sum_t_log_Pz_ftk = sum(hmmr.stats.Zik.*log(state_probs.*hmmr.stats.f_tk), 2);
      # comp_loglik = sum(sum_t_log_Pz_ftk(K:end));
      # hmmr.stats.comp_loglik = comp_loglik;
      # hmmr.stats.ICL = comp_loglik - (nu*log(m)/2);

      # Predicted, filtered, and smoothed time series
      regressors <<- paramHMMR$phi %*% paramHMMR$beta

      # Prediction probabilities = Pr(z_t|y_1,...,y_{t-1})
      predict_prob[1, ] <<- paramHMMR$prior # t=1 p (z_1)

      predict_prob[2:paramHMMR$m, ] <<- (alpha_tk[(1:(paramHMMR$m - 1)), ] %*% paramHMMR$trans_mat) / (apply(as.matrix(alpha_tk[(1:(paramHMMR$m - 1)), ]), 1, sum) %*% matrix(1, 1, paramHMMR$K)) # t = 2,...,n

      # Predicted observations
      predicted <<- matrix(apply(predict_prob * regressors, 1, sum)) # Weighted by prediction probabilities

      # Filtering probabilities = Pr(z_t|y_1,...,y_t)
      filter_prob <<- alpha_tk / (apply(alpha_tk, 1, sum) %*% matrix(1, 1, paramHMMR$K)) # Normalize(alpha_tk,2);

      # Filetered observations
      filtered <<- as.matrix(apply(filter_prob * regressors, 1, sum)) # Weighted by filtering probabilities

      # Smoothed observations
      smoothed_regressors <<- tau_tk * regressors
      smoothed <<- as.matrix(apply(smoothed_regressors, 1, sum))

    },

    EStep = function(paramHMMR) {
      "Method used in the EM algorithm to update statistics based on parameters
      provided by the object \\code{paramHMMR} of class \\link{ParamHMMR}
      (prior and posterior probabilities)."

      muk <- matrix(0, paramHMMR$m, paramHMMR$K)

      # Observation likelihoods
      for (k in 1:paramHMMR$K) {
        mk <- paramHMMR$phi %*% paramHMMR$beta[, k]
        muk[, k] <- mk
        # The regressors means
        if (paramHMMR$variance_type == "homoskedastic") {
          sk <- paramHMMR$sigma2[1]
        }
        else{
          sk <- paramHMMR$sigma2[k]
        }
        z <- ((paramHMMR$Y - mk) ^ 2) / sk
        log_f_tk[, k] <<- -0.5 * matrix(1, paramHMMR$m, 1) %*% (log(2 * pi) + log(sk)) - 0.5 * z # log(gaussienne)

      }

      log_f_tk <<- pmin(log_f_tk, log(.Machine$double.xmax))
      log_f_tk <<- pmax(log_f_tk, log(.Machine$double.xmin))

      f_tk <<- exp(log_f_tk)

      fb <- forwardsBackwards(paramHMMR$prior, paramHMMR$trans_mat, t(f_tk))
      tau_tk <<- t(fb$tau_tk)
      xi_tkl <<- fb$xi_tkl
      alpha_tk <<- t(fb$alpha_tk)
      beta_tk <<- t(fb$beta_tk)
      loglik <<- fb$loglik

    }
  )
)
