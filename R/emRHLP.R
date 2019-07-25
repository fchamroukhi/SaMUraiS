#' emRHLP implements the EM algorithm to fit a RHLP model.
#'
#' emRHLP implements the maximum-likelihood parameter estimation of the RHLP
#' model by the Expectation-Maximization (EM) algorithm.
#'
#' @details emRHLP function implements the EM algorithm for the RHLP model. This
#'   function starts with an initialization of the parameters done by the method
#'   `initParam` of the class [ParamRHLP][ParamRHLP], then it alternates between
#'   the E-Step (method of the class [StatRHLP][StatRHLP]) and the M-Step
#'   (method of the class [ParamRHLP][ParamRHLP]) until convergence (until the
#'   relative variation of log-likelihood between two steps of the EM algorithm
#'   is less than the `threshold` parameter).
#'
#' @param X Numeric vector of length \emph{m} representing the covariates/inputs
#'   \eqn{x_{1},\dots,x_{m}}.
#' @param Y Numeric vector of length \emph{m} representing the observed
#'   response/output \eqn{y_{1},\dots,y_{m}}.
#' @param K The number of regimes (RHLP components).
#' @param p Optional. The order of the polynomial regression. By default, `p` is
#'   set at 3.
#' @param q Optional. The dimension of the logistic regression. For the purpose
#'   of segmentation, it must be set to 1 (which is the default value).
#' @param variance_type Optional character indicating if the model is
#'   "homoskedastic" or "heteroskedastic". By default the model is
#'   "heteroskedastic".
#' @param n_tries Optional. Number of runs of the EM algorithm. The solution
#'   providing the highest log-likelihood will be returned.
#'
#'   If `n_tries` > 1, then for the first run, parameters are initialized by
#'   uniformly segmenting the data into K segments, and for the next runs,
#'   parameters are initialized by randomly segmenting the data into K
#'   contiguous segments.
#' @param max_iter Optional. The maximum number of iterations for the EM
#'   algorithm.
#' @param threshold Optional. A numeric value specifying the threshold for the
#'   relative difference of log-likelihood between two steps of the EM as
#'   stopping criteria.
#' @param verbose Optional. A logical value indicating whether or not values of
#'   the log-likelihood should be printed during EM iterations.
#' @param verbose_IRLS Optional. A logical value indicating whether or not
#'   values of the criterion optimized by IRLS should be printed at each step of
#'   the EM algorithm.
#' @return EM returns an object of class [ModelRHLP][ModelRHLP].
#' @seealso [ModelRHLP], [ParamRHLP], [StatRHLP]
#' @export
#'
#' @examples
#' data(univtoydataset)
#'
#' rhlp <- emRHLP(univtoydataset$x, univtoydataset$y, K = 3, p = 1, verbose = TRUE)
#'
#' rhlp$summary()
#'
#' rhlp$plot()
emRHLP <- function(X, Y, K, p = 3, q = 1, variance_type = c("heteroskedastic", "homoskedastic"), n_tries = 1, max_iter = 1500, threshold = 1e-6, verbose = FALSE, verbose_IRLS = FALSE) {

  top <- 0
  try_EM <- 0
  best_loglik <- -Inf

  while (try_EM < n_tries) {
    try_EM <- try_EM + 1

    if (n_tries > 1 && verbose) {
      cat(paste0("EM try number: ", try_EM, "\n\n"))
    }

    # Initialization
    variance_type <- match.arg(variance_type)
    param <- ParamRHLP$new(X = X, Y = Y, K = K, p = p, q = q, variance_type = variance_type)
    param$initParam(try_EM)
    iter <- 0
    converge <- FALSE
    prev_loglik <- -Inf

    stat <- StatRHLP(paramRHLP = param)

    while (!converge && (iter <= max_iter)) {
      stat$EStep(param)

      reg_irls <- param$MStep(stat, verbose_IRLS)
      stat$computeLikelihood(reg_irls)

      iter <- iter + 1
      if (verbose) {
        cat(paste0("EM: Iteration : ", iter, " || log-likelihood : "  , stat$loglik, "\n"))
      }
      if (prev_loglik - stat$loglik > 1e-5) {
        if (verbose) {
          warning(paste0("EM log-likelihood is decreasing from ", prev_loglik, "to ", stat$loglik, " !"))
        }
        top <- top + 1
        if (top > 20)
          break
      }

      # Test of convergence
      converge <- abs((stat$loglik - prev_loglik) / prev_loglik) <= threshold
      if (is.na(converge)) {
        converge <- FALSE
      } # Basically for the first iteration when prev_loglik is Inf

      prev_loglik <- stat$loglik
      stat$stored_loglik <- c(stat$stored_loglik, stat$loglik)
    } # End of the EM loop

    if (stat$loglik > best_loglik) {
      statSolution <- stat$copy()
      paramSolution <- param$copy()

      best_loglik <- stat$loglik
    }
    if (n_tries > 1 && verbose) {
      cat(paste0("Max value of the log-likelihood: ", stat$loglik, "\n\n"))
    }
  }

  # Computation of Z_ik the hard partition of the curves and klas (the estimated segment labels z_i)
  statSolution$MAP()

  if (n_tries > 1 && verbose) {
    cat(paste0("Max value of the log-likelihood: ", statSolution$loglik, "\n"))
  }

  # End of the computation of the model statistics
  statSolution$computeStats(paramSolution)

  return(ModelRHLP$new(param = paramSolution, stat = statSolution))
}
