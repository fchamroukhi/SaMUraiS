designmatrix = function(x, p, q = NULL, n = 1) {

  order_max <- p
  if (!is.null(q)) {
    order_max <- max(p, q)
  }

  X <- matrix(NA, length(x), order_max + 1)
  for (i in 0:(order_max)) {
    X[, i + 1] <- x ^ i
  }

  XBeta <- X[, 1:(p + 1)]
  # design matrix for Beta (the polynomial regressions)
  if (!is.null(q)) {
    Xw <- X[, 1:(q + 1)]
    Xw <- repmat(Xw, n, 1)
    # design matrix for w (the logistic regression)
  } else {
    Xw <- NULL
  }

  XBeta <- repmat(XBeta, n, 1)

  return(list(Xw = Xw, XBeta = XBeta))
}

ones <- function(n, d, g = 1) {
  if (g == 1) {
    return(matrix(1, n, d))
  }
  else{
    return(array(1, dim = c(n, d, g)))
  }
}

zeros <- function(n, d, g = 1) {
  if (g == 1) {
    return(matrix(0, n, d))
  }
  else{
    return(array(0, dim = c(n, d, g)))
  }
}

rand <- function(n, d, g = 1) {
  if (g == 1) {
    return(matrix(stats::runif(n * d), n, d))
  }
  else{
    return(array(stats::runif(n * d), dim = c(n, d, g)))
  }
}

repmat <- function(M, n, d) {
  return(kronecker(matrix(1, n, d), M))
}

drnorm <- function(n, d, mean, sd) {
  A <- matrix(nrow = n, ncol = d)
  for (i in 1:d) {
    A[, i] <- stats::rnorm(n, mean, sd)
  }
  return(A)
}

lognormalize <- function(M) {
  if (!is.matrix(M)) {
    M <- matrix(M)
  }
  n <- nrow(M)
  d <- ncol(M)
  a <- apply(M, 1, max)
  return(M - repmat(a + log(rowSums(exp(M - repmat(a, 1, d)))), 1, d))
}

normalize <- function(A, dim) {
  # Normalize makes the entries of a (multidimensional <= 2) array sum to 1.
  # Input
  # A = Array to be normalized
  # dim = dimension is specified to normalize.
  # Output
  # M = Array after normalize.
  # z is the normalize constant
  # Note:
  # If dim is specified, we normalize the specified dimension only,
  # Otherwise we normalize the whole array.
  # Dim = 1 normalize each column
  # Dim = 2 normalize each row

  if (nargs() < 2) {
    z <- sum(A)
    # Set any zeros to one before dividing
    # This is valid, since c = 0 ==> all i.A[i] = 0 ==> the anser should be 0/1 = 0.
    s <- z + (z == 0)
    M <- A / s
  } else if (dim == 1) {
    # normalize each column
    z <- colSums(A)
    s <- z + (z == 0)
    M <- A / matrix(s, nrow = dim(A)[1], ncol = length(s), byrow = TRUE)
  } else{
    z <- rowSums(A)
    s <- z + (z == 0)
    M <- A / matrix(s, ncol = dim(A)[2], nrow = length(s), byrow = FALSE)
  }
  output <- list(M = M, z = z)
  return(output)
}
