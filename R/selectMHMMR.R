#' selectMHMMR implements a model selection procedure to select an optimal MHMMR
#' model with unknown structure.
#'
#' @details selectMHMMR selects the optimal MHMMR model among a set of model
#'   candidates by optimizing a model selection criteria, including the Bayesian
#'   Information Criterion (BIC). This function first fits the different MHMMR
#'   model candidates by varying the number of regimes `K` from `Kmin` to `Kmax`
#'   and the order of the polynomial regression `p` from `pmin` to `pmax`. The
#'   model having the highest value of the chosen selection criterion is then
#'   selected.
#'
#' @param X Numeric vector of length \emph{m} representing the covariates/inputs
#'   \eqn{x_{1},\dots,x_{m}}.
#' @param Y Matrix of size \eqn{(m, d)} representing a \eqn{d} dimension time
#'   series observed at points \eqn{1,\dots,m}.
#' @param Kmin The minimum number of regimes (c components).
#' @param Kmax The maximum number of regimes (MHMMR components).
#' @param pmin The minimum order of the polynomial regression.
#' @param pmax The maximum order of the polynomial regression.
#' @param criterion The criterion used to select the MHMMR model ("BIC", "AIC").
#' @return selectMHMMR returns an object of class [ModelMHMMR][ModelMHMMR]
#'   representing the selected MHMMR model according to the chosen `criterion`.
#' @seealso [ModelMHMMR]
#' @export
selectMHMMR <- function(X, Y, Kmin = 1, Kmax = 10, pmin = 0, pmax = 4, criterion = c("BIC", "AIC")) {

  criterion <- match.arg(criterion)

  vmhmmr <- Vectorize(function(K, p, X1 = X, Y1 = Y) emMHMMR(X = X1, Y = Y1, K, p),
                     vectorize.args = c("K", "p"))

  mhmmr <- outer(Kmin:Kmax, pmin:pmax, vmhmmr)

  if (criterion == "BIC") {
    results <- apply(mhmmr, 1:2, function(x) x[[1]]$stat$BIC)
  } else {
    results <- apply(mhmmr, 1:2, function(x) x[[1]]$stat$AIC)
  }
  rownames(results) <- sapply(Kmin:Kmax, function(x) paste0("(K = ", x, ")"))
  colnames(results) <- sapply(pmin:pmax, function(x) paste0("(p = ", x, ")"))


  selected <- mhmmr[which(results == max(results), arr.ind = T)][[1]]

  cat(paste0("The MHMMR model selected via the \"", criterion, "\" has K = ",
             selected$param$K, " regimes \n and the order of the ",
             "polynomial regression is p = ", selected$param$p, "."))
  cat("\n")
  cat(paste0("BIC = ", selected$stat$BIC, "\n"))
  cat(paste0("AIC = ", selected$stat$AIC, "\n"))

  return(selected)

}
