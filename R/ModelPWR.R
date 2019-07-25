#' A Reference Class which represents a fitted PWR model.
#'
#' ModelPWR represents an estimated PWR model.
#'
#' @field param A [ParamPWR][ParamPWR] object. It contains the estimated values
#'   of the parameters.
#' @field stat A [StatPWR][StatPWR] object. It contains all the statistics
#'   associated to the PWR model.
#' @seealso [ParamPWR], [StatPWR]
#' @export
#'
#' @examples
#' data(univtoydataset)
#'
#' pwr <- fitPWRFisher(univtoydataset$x, univtoydataset$y, K = 5, p = 1)
#'
#' # pwr is a ModelPWR object. It contains some methods such as 'summary' and 'plot'
#' pwr$summary()
#' pwr$plot()
#'
#' # pwr has also two fields, stat and param which are reference classes as well
#'
#' # Value of the objective function:
#' pwr$stat$objective
#'
#' # Parameters of the polynomial regressions:
#' pwr$param$beta
ModelPWR <- setRefClass(
  "ModelPWR",
  fields = list(
    param = "ParamPWR",
    stat = "StatPWR"
  ),
  methods = list(

    plot = function(what = c("regressors", "segmentation"), ...) {
      "Plot method.
      \\describe{
        \\item{\\code{what}}{The type of graph requested:
          \\itemize{
            \\item \\code{\"regressors\" = } Polynomial regression components
              (field \\code{regressors} of class \\link{StatPWR}).
            \\item \\code{\"segmentation\" = } Estimated signal
              (field \\code{mean_function} of class \\link{StatPWR}).
          }
        }
        \\item{\\code{\\dots}}{Other graphics parameters.}
      }
      By default, all the graphs mentioned above are produced."

      what <- match.arg(what, several.ok = TRUE)

      oldpar <- par(no.readonly = TRUE)
      on.exit(par(oldpar), add = TRUE)

      yaxislim <- c(mean(param$Y) - 2 * sqrt(var(param$Y)), mean(param$Y) + 2 * sqrt(var(param$Y)))

      colorsvec <- rainbow(param$K)

      if (any(what == "regressors")) {
        # Time series, regressors, and segmentation
        par(mai = c(0.6, 1, 0.5, 0.5), mgp = c(2, 1, 0))
        plot.default(param$X, param$Y, type = "l", ylim = yaxislim, xlab = "x", ylab = "y", ...)
        title(main = "Time series, PWR regimes, and segmentation")
        for (k in 1:param$K) {
          model_k <- stat$regressors[, k]

          index <- stat$klas == k
          active_model_k <- model_k[index]
          active_period_model_k <- param$X[index]

          if (length(active_model_k) != 0) {
            lines(param$X, model_k, col = colorsvec[k], lty = "dotted", lwd = 1.5, ...)
            lines(active_period_model_k, active_model_k, type = "l", col = colorsvec[k], lwd = 1.5, ...)
          }
        }
      }

      if (any(what == "segmentation")) {
        # Time series, estimated regression function, and optimal segmentation
        plot.default(param$X, param$Y, type = "l", ylim = yaxislim, xlab = "x", ylab = "y", ...)
        title(main = "Time series, PWR function, and segmentation")

        for (k in 1:param$K) {
          Ik = param$gamma[k] + 1:(param$gamma[k + 1] - param$gamma[k])
          segmentk = stat$mean_function[Ik]
          lines(param$X[t(Ik)], segmentk, type = "l", col = colorsvec[k], lwd = 1.5, ...)
        }

        for (i in 1:length(param$gamma)) {
          abline(v = param$X[param$gamma[i]], col = "red", lty = "dotted", lwd = 1.5, ...)
        }
      }
    },

    summary = function(digits = getOption("digits")) {
      "Summary method.
      \\describe{
        \\item{\\code{digits}}{The number of significant digits to use when
          printing.}
      }"

      title <- paste("Fitted PWR model")
      txt <- paste(rep("-", min(nchar(title) + 4, getOption("width"))), collapse = "")

      # Title
      cat(txt)
      cat("\n")
      cat(title)
      cat("\n")
      cat(txt)

      cat("\n")
      cat("\n")
      cat(paste0("PWR model with K = ", param$K, ifelse(param$K > 1, " components", " component"), ":"))
      cat("\n")

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

      cat("\nVariances:\n\n")
      sigma2 = data.frame(t(param$sigma2), row.names = NULL)
      colnames(sigma2) = sapply(1:param$K, function(x) paste0("Sigma2(K = ", x, ")"))
      print(sigma2, digits = digits, row.names = FALSE)

    }
  )
)
