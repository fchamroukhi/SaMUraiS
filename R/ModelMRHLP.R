#' A Reference Class which represents a fitted MRHLP model.
#'
#' ModelMRHLP represents an estimated MRHLP model.
#'
#' @field param A [ParamMRHLP][ParamMRHLP] object. It contains the estimated
#'   values of the parameters.
#' @field stat A [StatMRHLP][StatMRHLP] object. It contains all the statistics
#'   associated to the MRHLP model.
#' @seealso [ParamMRHLP], [StatMRHLP]
#' @export
#'
#' @examples
#' data(multivtoydataset)
#'
#' mrhlp <- emMRHLP(multivtoydataset$x, multivtoydataset[,c("y1", "y2", "y3")],
#'                  K = 5, p = 1, verbose = TRUE)
#'
#' # mrhlp is a ModelMRHLP object. It contains some methods such as 'summary' and 'plot'
#' mrhlp$summary()
#' mrhlp$plot()
#'
#' # mrhlp has also two fields, stat and param which are reference classes as well
#'
#' # Log-likelihood:
#' mrhlp$stat$loglik
#'
#' # Parameters of the polynomial regressions:
#' mrhlp$param$beta
ModelMRHLP <- setRefClass(
  "ModelMRHLP",
  fields = list(
    param = "ParamMRHLP",
    stat = "StatMRHLP"
  ),
  methods = list(

    plot = function(what = c("regressors", "estimatedsignal", "loglikelihood"), ...) {
      "Plot method.
      \\describe{
        \\item{\\code{what}}{The type of graph requested:
          \\itemize{
            \\item \\code{\"regressors\" = } Polynomial regression components
              (fields \\code{polynomials} and \\code{pi_ik} of class
              \\link{StatMRHLP}).
            \\item \\code{\"estimatedsignal\" = } Estimated signal (fields
              \\code{Ex} and \\code{klas} of class \\link{StatMRHLP}).
            \\item \\code{\"loglikelihood\" = } Value of the log-likelihood for
              each iteration (field \\code{stored_loglik} of class
              \\link{StatMRHLP}).
          }
        }
        \\item{\\code{\\dots}}{Other graphics parameters.}
      }
      By default, all the graphs mentioned above are produced."

      what <- match.arg(what, several.ok = TRUE)

      oldpar <- par(no.readonly = TRUE)
      on.exit(par(oldpar), add = TRUE)

      yaxislim <- c(min(param$mData$Y) - 2 * mean(sqrt(apply(param$mData$Y, 2, var))), max(param$mData$Y) + 2 * mean(sqrt(apply(param$mData$Y, 2, var))))

      if (any(what == "regressors")) {
        # Data, regressors, and segmentation
        par(mfrow = c(2, 1), mai = c(0.6, 1, 0.5, 0.5), mgp = c(2, 1, 0))
        matplot(param$mData$X, param$mData$Y, type = "l", ylim = yaxislim, xlab = "x", ylab = "y", col = gray.colors(param$mData$d), lty = 1, ...)
        title(main = "Time series, MRHLP regimes, and process probabilites")
        colorsvec <- rainbow(param$K)
        for (k in 1:param$K) {
          index <- (stat$klas == k)
          for (d in 1:param$mData$d) {
            polynomials <- stat$polynomials[index, d, k]
            lines(param$mData$X, stat$polynomials[, d, k], col = colorsvec[k], lty = "dotted", lwd = 1, ...)
            lines(param$mData$X[index], polynomials, col = colorsvec[k], lwd = 1.5, ...)
          }
        }

        # Probablities of the hidden process (segmentation)
        plot.default(param$mData$X, stat$pi_ik[, 1], type = "l", xlab = "x", ylab = expression('Probability ' ~ pi [k] (t, w)), col = colorsvec[1], lwd = 1.5, ...)
        if (param$K > 1) {
          for (k in 2:param$K) {
            lines(param$mData$X, stat$pi_ik[, k], col = colorsvec[k], lwd = 1.5, ylim = c(0, 1), ...)
          }
        }
      }

      if (any(what == "estimatedsignal")) {
        # Data, regression model, and segmentation
        par(mfrow = c(2, 1), mai = c(0.6, 1, 0.5, 0.5), mgp = c(2, 1, 0))
        matplot(param$mData$X, param$mData$Y, type = "l", ylim = yaxislim, xlab = "x", ylab = "y", col = gray.colors(param$mData$d), lty = 1, ...)
        title(main = "Time series, estimated MRHLP model, and segmentation")
        for (d in 1:param$mData$d) {
          lines(param$mData$X, stat$Ex[, d], col = "red", lwd = 1.5, ...)
        }

        # Transition time points
        tk = which(diff(stat$klas) != 0)
        for (i in 1:length(tk)) {
          abline(v = param$mData$X[tk[i]], col = "red", lty = "dotted", lwd = 1.5, ...)
        }

        # Probablities of the hidden process (segmentation)
        plot.default(param$mData$X, stat$klas, type = "l", xlab = "", ylab = "Estimated class labels", col = "red", lwd = 1.5, yaxt = "n", ...)
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

      title <- paste("Fitted MRHLP model")
      txt <- paste(rep("-", min(nchar(title) + 4, getOption("width"))), collapse = "")

      # Title
      cat(txt)
      cat("\n")
      cat(title)
      cat("\n")
      cat(txt)

      cat("\n")
      cat("\n")
      cat(paste0("MRHLP model with K = ", param$K, ifelse(param$K > 1, " regimes", " regime")))
      cat("\n")
      cat("\n")

      tab <- data.frame("log-likelihood" = stat$loglik, "nu" = param$nu,
                        "AIC" = stat$AIC,"BIC" = stat$BIC, "ICL" = stat$ICL,
                        row.names = "", check.names = FALSE)
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
        } else {
          row.names = "1"
        }

        betas <- data.frame(param$beta[, , k, drop = FALSE], row.names = row.names)
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
