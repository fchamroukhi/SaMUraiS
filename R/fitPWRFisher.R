#' fitPWRFisher implements an optimized dynamic programming algorithm to fit a
#' PWR model.
#'
#' fitPWRFisher is used to fit a Piecewise Regression (PWR) model by
#' maximum-likelihood via an optimized dynamic programming algorithm. The
#' estimation performed by the dynamic programming algorithm provides an optimal
#' segmentation of the time series.
#'
#' @details fitPWRFisher function implements an optimized dynamic programming
#'   algorithm of the PWR model. This function starts with the calculation of
#'   the "cost matrix" then it estimates the transition points given `K` the
#'   number of regimes thanks to the method `computeDynamicProgram` (method of
#'   the class [ParamPWR][ParamPWR]).
#'
#' @param X Numeric vector of length \emph{m} representing the covariates/inputs
#'   \eqn{x_{1},\dots,x_{m}}.
#' @param Y Numeric vector of length \emph{m} representing the observed
#'   response/output \eqn{y_{1},\dots,y_{m}}.
#' @param K The number of regimes/segments (PWR components).
#' @param p Optional. The order of the polynomial regression. By default, `p` is
#'   set at 3.
#' @return fitPWRFisher returns an object of class [ModelPWR][ModelPWR].
#' @seealso [ModelPWR], [ParamPWR], [StatPWR]
#' @export
#'
#' @examples
#' data(univtoydataset)
#'
#' pwr <- fitPWRFisher(univtoydataset$x, univtoydataset$y, K = 5, p = 1)
#'
#' pwr$summary()
#'
#' pwr$plot()
fitPWRFisher = function(X, Y, K, p = 3) {

  Lmin <- p + 1

  paramPWR <- ParamPWR(X = X, Y = Y, K = K, p = p)

  C1 <- costMatrix(Y, paramPWR$phi)

  Ck <- paramPWR$computeDynamicProgram(C1, K)
  paramPWR$computeParam()

  statPWR <- StatPWR(paramPWR = paramPWR)

  # Compute statistics
  statPWR$computeStats(paramPWR)

  statPWR$objective = Ck[length(Ck)]

  return(ModelPWR(param = paramPWR, stat = statPWR))
}
