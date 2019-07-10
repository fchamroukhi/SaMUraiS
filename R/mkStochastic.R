#' mkStochastic ensures that it is a stochastic vector, matrix or array.
#'
#' @details mkStochastic ensures that the giving argument is a stochastic
#'   vector, matrix or array, i.e., that the sum over the last dimension is 1.
#'
#' @param M A vector, matrix or array to transform.
#' @return A vector, matrix or array for which the sum over the last dimension
#'   is 1.
mkStochastic <- function(M) {
  if (is.vector(M) == TRUE) { # Vector
    M <- normalize(M)$M
  } else if (is.matrix(M) == TRUE) { # Matrix
    S <- apply(M, 1, sum)
    S <- S + (S == 0)
    norm <- matrix(rep(S, ncol(M)), nrow = length(S))
    M <- M / norm
  } else {# Multi-dimensional array
    ns <- dim(M)
    M <- matrix(M, prod(ns[1]:ns[length(ns) - 1]), ns[length(ns)])
    S <- apply(M, 1, sum)
    S <- S + (S == 0)
    norm <- matrix(rep(S, ncol(M)), nrow = length(S), ncol = ns[length(ns)])
    M <- M / norm
    M <- array(M, ns)
  }
  return(M)
}
