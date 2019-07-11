#' A Reference Class which represents a fitted MHMMR model.
#'
#' ModelMHMMR represents an estimated MHMMR model.
#'
#' @field param A [ParamMHMMR][ParamMHMMR] object. It contains the estimated
#'   values of the parameters.
#' @field stat A [StatMHMMR][StatMHMMR] object. It contains all the statistics
#'   associated to the MHMMR model.
#' @seealso [ParamMHMMR], [StatMHMMR]
#' @export
ModelMHMMR <- setRefClass(
  "ModelMHMMR",
  fields = list(
    param = "ParamMHMMR",
    stat = "StatMHMMR"
  ),
  methods = list(
    plot = function(what = c("predicted", "filtered", "smoothed", "regressors"), ...) {
      "Plot method.
      \\describe{
        \\item{\\code{what}}{The type of graph requested:
          \\itemize{
            \\item \\code{\"predicted\" = } Predicted time series and predicted
              regime probabilities (fields \\code{predicted} and
              \\code{predict_prob} of class \\link{StatMHMMR}).
            \\item \\code{\"filtered\" = } Filtered time series and filtering
              regime probabilities (fields \\code{filtered} and
              \\code{filter_prob} of class \\link{StatMHMMR}).
            \\item \\code{\"smoothed\" = } Smoothed time series, and
              segmentation (fields \\code{smoothed} and \\code{klas} of class
              \\link{StatMHMMR}).
            \\item \\code{\"regressors\" = } Polynomial regression components
              (fields \\code{regressors} and \\code{tau_tk} of class
              \\link{StatMHMMR}).
          }
        }
        \\item{\\code{\\dots}}{Other graphics parameters.}
      }
      By default, all the above graphs are produced."

      what <- match.arg(what, several.ok = TRUE)

      oldpar <- par(no.readonly = TRUE)
      on.exit(par(oldpar), add = TRUE)

      yaxislim <- c(min(param$mData$Y) - 2 * mean(sqrt(apply(param$mData$Y, 2, var))), max(param$mData$Y) + 2 * mean(sqrt(apply(param$mData$Y, 2, var))))

      colorsvec <- rainbow(param$K)

      if (any(what == "predicted")) {
        # Predicted time series and predicted regime probabilities
        par(mfrow = c(2, 1), mai = c(0.6, 1, 0.5, 0.5), mgp = c(2, 1, 0))
        matplot(param$mData$X, param$mData$Y, type = "l", ylim = yaxislim, xlab = "x", ylab = "y", col = gray.colors(param$mData$d), lty = 1, ...)
        title(main = "Original and predicted HMMR time series")

        for (d in 1:param$mData$d) {
          lines(param$mData$X, stat$predicted[, d], col = "red", lwd = 1.5, ...)
        }

        # Prediction probabilities of the hidden process (segmentation)
        plot.default(param$mData$X, stat$predict_prob[, 1], type = "l", xlab = "x", ylab = expression('P(Z'[t] == k ~ '|' ~ list(y[1],..., y[t - 1]) ~ ')'), col = colorsvec[1], lwd = 1.5, main = "Prediction probabilities", ylim = c(0, 1), ...)
        if (param$K > 1) {
          for (k in 2:param$K) {
            lines(param$mData$X, stat$predict_prob[, k], col = colorsvec[k], lwd = 1.5, ...) # Pred Probs: Pr(Z_{t}=k|y_1,\ldots,y_{t-1})
          }
        }
      }

      if (any(what == "filtered")) {
        # Filtered time series and filtering regime probabilities
        par(mfrow = c(2, 1), mai = c(0.6, 1, 0.5, 0.5), mgp = c(2, 1, 0))
        matplot(param$mData$X, param$mData$Y, type = "l", ylim = yaxislim, xlab = "x", ylab = "y", col = gray.colors(param$mData$d), lty = 1, ...)
        title(main = "Original and filtered HMMR time series")
        for (d in 1:param$mData$d) {
          lines(param$mData$X, stat$filtered[, d], col = "red", lwd = 1.5, ...)
        }

        # Filtering probabilities of the hidden process (segmentation)
        plot.default(param$mData$X, stat$filter_prob[, 1], type = "l", xlab = "x", ylab = expression('P(Z'[t] == k ~ '|' ~ list(y[1],..., y[t]) ~ ')'), col = colorsvec[1], lwd = 1.5, main = "Filtering probabilities", ylim = c(0, 1), ...)
        if (param$K > 1) {
          for (k in 2:param$K) {
            lines(param$mData$X, stat$filter_prob[, k], col = colorsvec[k], lwd = 1.5, ...) # Filter Probs: Pr(Z_{t}=k|y_1,\ldots,y_t)
          }
        }
      }

      if (any(what == "regressors")) {
        # Data, regressors, and segmentation
        par(mfrow = c(2, 1), mai = c(0.6, 1, 0.5, 0.5), mgp = c(2, 1, 0))
        matplot(param$mData$X, param$mData$Y, type = "l", ylim = yaxislim, xlab = "x", ylab = "y", col = gray.colors(param$mData$d), lty = 1, ...)
        title(main = "Time series, MHMMR regimes, and smoothing probabilites")
        for (k in 1:param$K) {

          model_k <- as.matrix(stat$regressors[, , k])

          index <- stat$klas == k
          active_model_k <- model_k[index, , drop = FALSE] # prob_model_k >= prob);
          active_period_model_k <- param$mData$X[index] # prob_model_k >= prob);

          if (length(active_model_k) != 0) {
            for (d in 1:param$mData$d) {
              lines(param$mData$X, model_k[, d], col = colorsvec[k], lty = "dotted", lwd = 1, ...)
              lines(active_period_model_k, active_model_k[, d], col = colorsvec[k], lwd = 1.5, ...)
            }
          }

        }

        # Smoothing Probablities of the hidden process (segmentation)
        plot.default(param$mData$X, stat$tau_tk[, 1], type = "l", xlab = "x", ylab = expression('P(Z'[t] == k ~ '|' ~ list(y[1],..., y[n]) ~ ')'), col = colorsvec[1], lwd = 1.5, main = "Smoothing probabilities", ylim = c(0, 1), ...)
        if (param$K > 1) {
          for (k in 2:param$K) {
            lines(param$mData$X, stat$tau_tk[, k], col = colorsvec[k], lwd = 1.5, ...) # Post Probs: Pr(Z_{t}=k|y_1,\ldots,y_n)
          }
        }
      }

      if (any(what == "smoothed")) {
        # Data, regression model, and segmentation
        par(mfrow = c(2, 1), mai = c(0.6, 1, 0.5, 0.5), mgp = c(2, 1, 0))
        matplot(param$mData$X, param$mData$Y, type = "l", ylim = yaxislim, xlab = "x", ylab = "y", col = gray.colors(param$mData$d), lty = 1, ...)
        title(main = "Original, smoothed HMMR time series, and segmentation")
        for (d in 1:param$mData$d) {
          lines(param$mData$X, stat$smoothed[, d], col = "red" , lwd = 1.5, ...)
        }

        # Transition time points
        tk <- which(diff(stat$klas) != 0)
        for (i in 1:length(tk)) {
          abline(v = param$mData$X[tk[i]], col = "red", lty = "dotted", lwd = 1.5, ...)
        }

        # Probablities of the hidden process (segmentation)
        plot.default(param$mData$X, stat$klas, type = "l", xlab = "x", ylab = "Estimated class labels", col = "red", lwd = 1.5, yaxt = "n", ...)
        axis(side = 2, at = 1:param$K)
      }
    },

    summary = function(digits = getOption("digits")) {
      "Summary method.
      \\describe{
        \\item{\\code{digits}}{The number of significant digits to use when
          printing.}
      }"

      title <- paste("Fitted MHMMR model")
      txt <- paste(rep("-", min(nchar(title) + 4, getOption("width"))), collapse = "")

      # Title
      cat(txt)
      cat("\n")
      cat(title)
      cat("\n")
      cat(txt)

      cat("\n")
      cat("\n")
      cat(paste0("MHMMR model with K = ", param$K, ifelse(param$K > 1, " regimes", " regime")))
      cat("\n")
      cat("\n")

      tab <- data.frame("log-likelihood" = stat$loglik, "nu" = param$nu, "AIC" = stat$AIC,
                        "BIC" = stat$BIC, row.names = "", check.names = FALSE)
      print(tab, digits = digits)

      cat("\nClustering table:")
      print(table(stat$klas))

      cat("\n\n")

      txt <- paste(rep("-", min(nchar(title), getOption("width"))), collapse = "")

      for (k in 1:param$K) {
        cat(txt)
        cat("\nRegime ", k, " (K = ", k, "):\n", sep = "")

        cat("\nRegression coefficients:\n\n")
        if (param$p > 0) {
          row.names = c("1", sapply(1:param$p, function(x) paste0("X^", x)))
          betas <- data.frame(param$beta[, , k], row.names = row.names)
        } else {
          row.names = "1"
          betas <- data.frame(t(param$beta[, , k]), row.names = row.names)
        }

        colnames(betas) <- sapply(1:param$mData$d, function(x) paste0("Beta(d = ", x, ")"))
        print(betas, digits = digits)

        if (param$variance_type == "heteroskedastic") {
          cat("\nCovariance matrix:\n")
          sigma2 <- data.frame(param$sigma2[, , k])
          colnames(sigma2) <- NULL
          print(sigma2, digits = digits, row.names = FALSE)
        }
      }

      if (param$variance_type == "homoskedastic") {
        cat("\n")
        txt <- paste(rep("-", min(nchar(title), getOption("width"))), collapse = "")
        cat(txt)
        cat("\nCommon covariance matrix:\n")
        cat(txt)
        sigma2 <- data.frame(param$sigma2)
        colnames(sigma2) <- NULL
        print(sigma2, digits = digits, row.names = FALSE)
      }

    }
  )
)
