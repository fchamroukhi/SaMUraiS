#' fitPWRFisher is used to fit a PWR model.
#'
#' fitPWRFisher is used to fit a Piecewise Regression (PWR) model. The
#' estimation method is performed by the dynamic programming algorithm.
#'
#' @details fitPWRFisher function implements the dynamic programming algorithm.
#'   This function starts with the calculation of the "cost matrix" then it
#'   estimates the transition points given `K` the number of regimes thanks to
#'   the method `computeDynamicProgram` (method of the class
#'   [ParamPWR][ParamPWR]).
#'
#' @param X Numeric vector of length \emph{m} representing the covariates/inputs
#'   \eqn{x_{1},\dots,x_{m}}.
#' @param Y Numeric vector of length \emph{m} representing the observed
#'   response/output \eqn{y_{1},\dots,y_{m}}.
#' @param K The number of regimes (PWR components).
#' @param p Optional. The order of the polynomial regression. By default, `p` is
#'   set at 3.
#' @return fitPWRFisher returns an object of class [ModelPWR][ModelPWR].
#' @seealso [ModelPWR], [ParamPWR], [StatPWR]
#' @export
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
