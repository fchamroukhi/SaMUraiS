#' A Reference Class which represents a fitted HMMR model.
#'
#' ModelHMMR represents an estimated HMMR model.
#'
#' @field param An object of class [ParamHMMR][ParamHMMR]. It contains the
#'   estimated values of the parameters.
#' @field stat An object of class [StatHMMR][StatHMMR]. It contains all the
#'   statistics associated to the HMMR model.
#' @seealso [ParamHMMR], [StatHMMR]
#' @export
#'
#' @examples
#' data(univtoydataset)
#'
#' hmmr <- emHMMR(univtoydataset$x, univtoydataset$y, K = 5, p = 1, verbose = TRUE)
#'
#' # hmmr is a ModelHMMR object. It contains some methods such as 'summary' and 'plot'
#' hmmr$summary()
#' hmmr$plot()
#'
#' # hmmr has also two fields, stat and param which are reference classes as well
#'
#' # Log-likelihood:
#' hmmr$stat$loglik
#'
#' # Parameters of the polynomial regressions:
#' hmmr$param$beta
ModelHMMR <- setRefClass(
  "ModelHMMR",
  fields = list(
    param = "ParamHMMR",
    stat = "StatHMMR"
  ),
  methods = list(
    plot = function(what = c("predicted", "filtered", "smoothed", "regressors", "loglikelihood"), ...) {
      "Plot method.
      \\describe{
        \\item{\\code{what}}{The type of graph requested:
          \\itemize{
            \\item \\code{\"predicted\" = } Predicted time series and predicted
              regime probabilities (fields \\code{predicted} and
              \\code{predict_prob} of class \\link{StatHMMR}).
            \\item \\code{\"filtered\" = } Filtered time series and filtering
              regime probabilities (fields \\code{filtered} and
              \\code{filter_prob} of class \\link{StatHMMR}).
            \\item \\code{\"smoothed\" = } Smoothed time series, and
              segmentation (fields \\code{smoothed} and \\code{klas} of the
              class {StatHMMR}).
            \\item \\code{\"regressors\" = } Polynomial regression components
              (fields \\code{regressors} and \\code{tau_tk} of class
            \\link{StatHMMR}).
            \\item \\code{\"loglikelihood\" = } Value of the log-likelihood for
              each iteration (field \\code{stored_loglik} of class
              \\link{StatHMMR}).
          }
        }
        \\item{\\code{\\dots}}{Other graphics parameters.}
      }
      By default, all the graphs mentioned above are produced."

      what <- match.arg(what, several.ok = TRUE)

      oldpar <- par(no.readonly = TRUE)
      on.exit(par(oldpar), add = TRUE)

      yaxislim <- c(mean(param$Y) - 2 * sd(param$Y), mean(param$Y) + 2 * sd(param$Y))

      colorsvec <- rainbow(param$K)

      if (any(what == "predicted")) {
        # Predicted time series and predicted regime probabilities
        par(mfrow = c(2, 1), mai = c(0.6, 1, 0.5, 0.5), mgp = c(2, 1, 0))
        plot.default(param$X, param$Y, type = "l", ylim = yaxislim, xlab = "x", ylab = "y", ...)
        lines(param$X, stat$predicted, type = "l", col = "red", lwd = 1.5, ...)
        title(main = "Original and predicted HMMR time series")

        # Prediction probabilities of the hidden process
        plot.default(param$X, stat$predict_prob[, 1], type = "l", xlab = "x", ylab = expression('P(Z'[t] == k ~ '|' ~ list(y[1],..., y[t - 1]) ~ ')'), col = colorsvec[1], lwd = 1.5, main = "Prediction probabilities", ylim = c(0, 1), ...)
        if (param$K > 1) {
          for (k in 2:param$K) {
            lines(param$X, stat$predict_prob[, k], col = colorsvec[k], lwd = 1.5, ...) # Pred Probs: Pr(Z_{t}=k|y_1,\ldots,y_{t-1})
          }
        }
      }

      if (any(what == "filtered")) {
        # Filtered time series and filtering regime probabilities
        par(mfrow = c(2, 1), mai = c(0.6, 1, 0.5, 0.5), mgp = c(2, 1, 0))
        plot.default(param$X, param$Y, type = "l", ylim = yaxislim, xlab = "x", ylab = "y", ...)
        title(main = "Original and filtered HMMR time series")
        lines(param$X, stat$filtered, col = "red", lwd = 1.5, ...)

        # Filtering probabilities of the hidden process
        plot.default(param$X, stat$filter_prob[, 1], type = "l", xlab = "x", ylab = expression('P(Z'[t] == k ~ '|' ~ list(y[1],..., y[t]) ~ ')'), col = colorsvec[1], lwd = 1.5, ylim = c(0, 1), ...)
        title(main = "Filtering probabilities")
        if (param$K > 1) {
          for (k in 2:param$K) {
            lines(param$X, stat$filter_prob[, k], col = colorsvec[k], lwd = 1.5, ...) # Filter Probs: Pr(Z_{t}=k|y_1,\ldots,y_t)
          }
        }
      }

      if (any(what == "regressors")) {
        # Data, regressors, and segmentation
        par(mfrow = c(2, 1), mai = c(0.6, 1, 0.5, 0.5), mgp = c(2, 1, 0))
        plot.default(param$X, param$Y, type = "l", ylim = yaxislim, xlab = "x", ylab = "y", ...)
        title(main = "Time series, HMMR regimes, and smoothing probabilites")
        for (k in 1:param$K) {
          model_k <- stat$regressors[, k]
          #prob_model_k = HMMR$param$piik[,k]

          index <- stat$klas == k
          active_model_k <- model_k[index] # prob_model_k >= prob);
          active_period_model_k <- param$X[index] # prob_model_k >= prob);

          if (length(active_model_k) != 0) {
            lines(param$X, model_k, col = colorsvec[k], lty = "dotted", lwd = 1.5, ...)
            lines(active_period_model_k, active_model_k, col = colorsvec[k], lwd = 1.5, ...)
          }
        }

        # Smoothing probabilities of the hidden process (segmentation)
        plot.default(param$X, stat$tau_tk[, 1], type = "l", xlab = "x", ylab = expression('P(Z'[t] == k ~ '|' ~ list(y[1],..., y[n]) ~ ')'), col = colorsvec[1], lwd = 1.5, ylim = c(0, 1), ...)
        title(main = "Smoothing probabilities")
        if (param$K > 1) {
          for (k in 2:param$K) {
            lines(param$X, stat$tau_tk[, k], col = colorsvec[k], lwd = 1.5, ...) # Post Probs: Pr(Z_{t}=k|y_1,\ldots,y_n)
          }
        }
      }

      if (any(what == "smoothed")) {
        # Data, regression model, and segmentation
        par(mfrow = c(2, 1), mai = c(0.6, 1, 0.5, 0.5), mgp = c(2, 1, 0))
        plot.default(param$X, param$Y, type = "l", ylim = yaxislim, xlab = "x", ylab = "y", ...)
        title(main = "Original and smoothed HMMR time series, and segmentation")
        lines(param$X, stat$smoothed, col = "red", lwd = 1.5, ...)

        # Transition time points
        tk <- which(diff(stat$klas) != 0)
        for (i in 1:length(tk)) {
          abline(v = param$X[tk[i]], col = "red", lty = "dotted", lwd = 2, ...)
        }

        # Probablities of the hidden process (segmentation)
        plot.default(param$X, stat$klas, type = "l", xlab = "x", ylab = "Estimated class labels", col = "red", lwd = 1.5, yaxt = "n", ...)
        axis(side = 2, at = 1:param$K, ...)
      }

      if (any(what == "loglikelihood")) {
        par(mfrow = c(1, 1))
        plot.default(1:length(stat$stored_loglik), stat$stored_loglik, type = "l", col = "blue", xlab = "EM iteration number", ylab = "Log-likelihood", ...)
        title(main = "Log-likelihood")
      }
    },

    summary = function(digits = getOption("digits")) {
      "Summary method.
      \\describe{
      \\item{\\code{digits}}{The number of significant digits to use when
      printing.}
      }"

      title <- paste("Fitted HMMR model")
      txt <- paste(rep("-", min(nchar(title) + 4, getOption("width"))), collapse = "")

      # Title
      cat(txt)
      cat("\n")
      cat(title)
      cat("\n")
      cat(txt)

      cat("\n")
      cat("\n")
      cat(paste0("HMMR model with K = ", param$K, ifelse(param$K > 1, " components", " component"), ":"))
      cat("\n")
      cat("\n")

      tab <- data.frame("log-likelihood" = stat$loglik, "nu" = param$nu, "AIC" = stat$AIC,
                        "BIC" = stat$BIC, row.names = "", check.names = FALSE)
      print(tab, digits = digits)

      cat("\nClustering table (Number of observations in each regimes):\n")
      print(table(stat$klas))

      cat("\nRegression coefficients:\n\n")
      if (param$p > 0) {
        row.names = c("1", sapply(1:param$p, function(x) paste0("X^", x)))
      } else {
        row.names = "1"
      }

      betas <- data.frame(param$beta, row.names = row.names)
      colnames(betas) <- sapply(1:param$K, function(x) paste0("Beta(K = ", x, ")"))
      print(betas, digits = digits)

      cat(paste0(ifelse(param$variance_type == "homoskedastic", "\n\n",
                        "\nVariances:\n\n")))
      sigma2 = data.frame(t(param$sigma2), row.names = NULL)
      if (param$variance_type == "homoskedastic") {
        colnames(sigma2) = "Sigma2"
        print(sigma2, digits = digits, row.names = FALSE)
      } else {
        colnames(sigma2) = sapply(1:param$K, function(x) paste0("Sigma2(K = ", x, ")"))
        print(sigma2, digits = digits, row.names = FALSE)
      }

    }
  )
)
