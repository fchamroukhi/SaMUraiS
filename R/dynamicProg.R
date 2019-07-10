dynamicProg = function(matJ, K) {

  n <- nrow(matJ)

  if (K > 1) {
    I <- matrix(Inf , nrow = K , ncol = n)
    t <- matrix(0 , nrow = (K - 1) , ncol = n)

    I[1,] = matJ[1,]
    if (K > 2) {
      for (k in 2:(K - 1)) {
        for (L in 2:n) {
          temp <- I[k - 1, 1:L - 1] + t(matJ[2:L, L])
          I[k, L] <- min(temp)
          t[k - 1, L] <- which.min(temp)
        }
      }
    }

    temp <- I[K - 1, 1:n - 1] + t(matJ[2:n, n])
    I[K, n] <- min(temp)
    t[K - 1, n] <- which.min(temp)
    J <- I[, n]
  } else {
    J <- matJ[1, n]
  }

  # Calculates the change point instants
  t_est <- n * diag(K)

  if (K > 1) {
    for (K in 2:K) {
      for (k in (K - 1):1) {
        t_est[K, k] = t[k, t_est[K, k + 1]]
      }
    }
  }

  return(list(t_est = t_est, J = J))
}
