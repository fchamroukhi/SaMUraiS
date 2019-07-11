#' hmmProcess calculates the probability distribution of a random process following a Markov chain
#'
#' @details hmmProcess calculates the distribution
#'   \eqn{P(Z_{1},\dots,Z_{n};\pi,A)} of a Markov chain
#'   \eqn{(Z_{1},\dots,Z_{n})} with prior probability \eqn{\pi} and transition
#'   matrix \eqn{A}.
#'
#'   The calculation is based on the following formula:
#'
#'   \eqn{P(Z_{i} = k) = \sum_{l} P(Z_{i} = k, Z_{i-1} = l) = \sum_{l} P(Z_{i} =
#'   k | Z_{i-1} = l) \times P(Z_{i-1} = l) = \sum_{l} A_{lk} \times
#'   P(Z_{i-1})}{P(Z_{i} = k) = \sum_{l} P(Z_{i} = k, Z_{i-1} = l) = \sum_{l}
#'   P(Z_{i} = k | Z_{i-1} = l) x P(Z_{i-1} = l) = \sum_{l} A_{lk} x P(Z_{i-1})}
#'
#' @param prior Numeric vector or a one row matrix of length K representing the
#'   prior probabilities of the Markov chain.
#' @param trans_mat Matrix of size \eqn{(K, K)} representing the transition
#'   matrix of the Markov chain.
#' @param n Numeric. Number of variables of the Markov chain.
#' @return Matrix of size \eqn{(n, K)} giving the distribution of process given the K-state Markov
#'   chain parameters.
hmmProcess <- function(prior, trans_mat, n) {

  K <- length(prior)
  state_probs <- matrix(0, n, K)
  pz1 <- prior
  state_probs[1, ] <- pz1
  for (t in 2:n) {
    pzt <-  t(trans_mat) %*% state_probs[t - 1, ] # p(z_i = k ) = sum_l (p(z_i=k,z_{i-1}=l)) = sum_l (p(z_i=k|z_i-1=l))*p(z_{i-1}= l) = sum_l A_{lk}*p(z_{i-1})
    state_probs[t, ] <- pzt
  }
  return(state_probs)
}
