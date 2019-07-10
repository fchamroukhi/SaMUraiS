#' A Reference Class which represents a fitted RHLP model.
#'
#' ModelRHLP represents an estimated RHLP model.
#'
#' @field param A [ParamRHLP][ParamRHLP] object. It contains the estimated
#'   values of the parameters.
#' @field stat A [StatRHLP][StatRHLP] object. It contains all the
#'   statistics associated to the RHLP model.
#' @seealso [ParamRHLP], [StatRHLP]
#' @export
ModelRHLP <- setRefClass(
  "ModelRHLP",
  fields = list(
    param = "ParamRHLP",
    stat = "StatRHLP"
  ),
  methods = list(

    plot = function(what = c("regressors", "estimatedsignal"), ...) {
      "Plot method.
      \\describe{
        \\item{\\code{what}}{The type of graph requested:
          \\itemize{
            \\item \\code{\"regressors\" = } Polynomial regression components
              (fields \\code{polynomials} and \\code{pi_ik} of class
              \\link{StatRHLP}).
            \\item \\code{\"estimatedsignal\" = } Estimated signal (fields
            \\code{Ex} and \\code{klas} of class \\link{StatRHLP}).
          }
        }
        \\item{\\code{\\dots}}{Other graphics parameters.}
      }
      By default, all the above graphs are produced."

      what <- match.arg(what, several.ok = TRUE)

      oldpar <- par(no.readonly = TRUE)
      on.exit(par(oldpar), add = TRUE)

      yaxislim <- c(mean(param$Y) - 2 * sd(param$Y), mean(param$Y) + 2 * sd(param$Y))

      if (any(what == "regressors")) {
        # Data, regressors, and segmentation
        par(mfrow = c(2, 1), mai = c(0.6, 1, 0.5, 0.5), mgp = c(2, 1, 0))
        plot.default(param$X, param$Y, type = "l", ylim = yaxislim, xlab = "x", ylab = "y", ...)
        title(main = "Time series, RHLP regimes and process probabilities")
        colorsvec = rainbow(param$K)
        for (k in 1:param$K) {
          index <- (stat$klas == k)
          polynomials <- stat$polynomials[index, k]
          lines(param$X, stat$polynomials[, k], col = colorsvec[k], lty = "dotted", lwd = 1.5, ...)
          lines(param$X[index], col = colorsvec[k], polynomials, lwd = 1.5, ...)
        }

        # Probablities of the hidden process (segmentation)
        plot.default(param$X, stat$pi_ik[, 1], type = "l", xlab = "x", ylab = expression('Probability ' ~ pi [k] (t, w)), col = colorsvec[1], lwd = 1.5, ylim = c(0, 1), ...)
        if (param$K > 1) {
          for (k in 2:param$K) {
            lines(param$X, stat$pi_ik[, k], col = colorsvec[k], lwd = 1.5, ylim = c(0, 1), ...)
          }
        }
      }

      if (any(what == "estimatedsignal")) {
        # Data, regression model, and segmentation
        par(mfrow = c(2, 1), mai = c(0.6, 1, 0.5, 0.5), mgp = c(2, 1, 0))
        plot.default(param$X, param$Y, type = "l", ylim = yaxislim, xlab = "x", ylab = "y", ...)
        lines(param$X, stat$Ex, col = "red", lwd = 1.5, ...)
        title(main = "Time series, estimated RHLP model, and segmentation")

        # Transition time points
        tk <- which(diff(stat$klas) != 0)
        for (i in 1:length(tk)) {
          abline(v = param$X[tk[i]], col = "red", lty = "dotted", lwd = 1.5, ...)
        }

        # Probablities of the hidden process (segmentation)
        plot.default(param$X, stat$klas, type = "l", xlab = "x", ylab = "Estimated class labels", col = "red", lwd = 1.5, yaxt = "n", ...)
        axis(side = 2, at = 1:param$K, ...)
      }
    },

    summary = function(digits = getOption("digits")) {
      "Summary method.
      \\describe{
        \\item{\\code{digits}}{The number of significant digits to use when
          printing.}
      }"

      title <- paste("Fitted RHLP model")
      txt <- paste(rep("-", min(nchar(title) + 4, getOption("width"))), collapse = "")

      # Title
      cat(txt)
      cat("\n")
      cat(title)
      cat("\n")
      cat(txt)

      cat("\n")
      cat("\n")
      cat(paste0("RHLP model with K = ", param$K, ifelse(param$K > 1, " components", " component"), ":"))
      cat("\n")
      cat("\n")

      tab <- data.frame("log-likelihood" = stat$loglik, "nu" = param$nu, "AIC" = stat$AIC,
                        "BIC" = stat$BIC, "ICL" = stat$ICL, row.names = "", check.names = FALSE)
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
