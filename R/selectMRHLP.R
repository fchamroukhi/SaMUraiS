#' selectMRHLP implements the model selection procedure.
#'
#' @details selectMRHLP implements the model selection. This function runs every
#'   MRHLP model by varying the number of regimes `K` from `Kmin` to `Kmax` and
#'   the order of the polynomial regression `p` from `pmin` to `pmax`. The model
#'   having the highest value of the chosen selection criterion is then
#'   selected.
#'
#' @param X Numeric vector of length \emph{m} representing the covariates/inputs
#'   \eqn{x_{1},\dots,x_{m}}.
#' @param Y Matrix of size \eqn{(m, d)} representing a \eqn{d} dimension
#'   function of `X` observed at points \eqn{1,\dots,m}. `Y` is the
#'   observed response/output.
#' @param Kmin The minimum number of regimes (MRHLP components).
#' @param Kmax The maximum number of regimes (MRHLP components).
#' @param pmin The minimum order of the polynomial regression.
#' @param pmax The maximum order of the polynomial regression.
#' @param criterion The criterion used to select the MRHLP model ("BIC", "AIC").
#' @return selectMRHLP returns an object of class [ModelMRHLP][ModelMRHLP]
#'   representing the selected MRHLP model according to the chosen `criterion`.
#' @seealso [ModelMRHLP]
#' @export
selectMRHLP <- function(X, Y, Kmin = 1, Kmax = 10, pmin = 0, pmax = 4, criterion = c("BIC", "AIC")) {

  criterion <- match.arg(criterion)

  vmrhlp <- Vectorize(function(K, p, X1 = X, Y1 = Y) emMRHLP(X = X1, Y = Y1, K, p),
                     vectorize.args = c("K", "p"))

  mrhlp <- outer(Kmin:Kmax, pmin:pmax, vmrhlp)

  if (criterion == "BIC") {
    results <- apply(mrhlp, 1:2, function(x) x[[1]]$stat$BIC)
  } else {
    results <- apply(mrhlp, 1:2, function(x) x[[1]]$stat$AIC)
  }
  rownames(results) <- sapply(Kmin:Kmax, function(x) paste0("(K = ", x, ")"))
  colnames(results) <- sapply(pmin:pmax, function(x) paste0("(p = ", x, ")"))


  selected <- mrhlp[which(results == max(results), arr.ind = T)][[1]]

  cat(paste0("The MRHLP model selected via the \"", criterion, "\" has K = ",
             selected$param$K, " regimes \n and the order of the ",
             "polynomial regression is p = ", selected$param$p, "."))
  cat("\n")
  cat(paste0("BIC = ", selected$stat$BIC, "\n"))
  cat(paste0("AIC = ", selected$stat$AIC, "\n"))

  return(selected)

}
