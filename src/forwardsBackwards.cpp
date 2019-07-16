// [[Rcpp::depends(RcppArmadillo)]]

#include <RcppArmadillo.h>

using namespace Rcpp;

arma::colvec normalizeColVec(arma::colvec v) {
  double z = sum(v);
  double s = z + (z == 0);
  return v / s;
}

arma::mat normalizeMat(arma::mat M) {
  double z = sum(sum(M));
  double s = z + (z == 0);
  return M / s;
}

// [[Rcpp::export]]
List forwardsBackwards(arma::vec& prior, arma::mat& transmat, arma::mat& f_tk) {
  // [tau_tk, xi_ikl, alpha, beta, loglik] = forwardsBackwards(prior, transmat, fik, filter_only)
  // forwardsBackwards : calculates the E-step of the EM algorithm for an HMMR
  // (Gaussian HMMR)

  // Inputs :
  //
  //         prior(k) = Pr(z_1 = k)
  //         transmat(\ell,k) = Pr(z_t=k | z_{t-1} = \ell)
  //         f_tk(t,k) = Pr(y_t | z_y=k;\theta) %gaussian
  //
  // Outputs:
  //
  //        tau_tk(t,k) = Pr(z_t=k | X): post probs (smoothing probs)
  //        xi_tk\elll(t,k,\ell)  = Pr(z_t=k, z_{t-1}=\ell | Y) t =2,..,n
  //        with Y = (y_1,...,y_n);
  //        alpha_tk: [nxK], forwards probs: Pr(y1...yt,zt=k)
  //        beta_tk: [nxK], backwards probs: Pr(yt+1...yn|zt=k)
  //
  //
  //
  //
  ////////////////////////////////////////////////////////////////////////////////////////////////

  double N = f_tk.n_cols;
  double K = f_tk.n_rows;

  arma::mat scale(1, N, arma::fill::ones); // so that loglik = sum(log(scale)) starts at zero
  arma::mat tau_tk(K, N, arma::fill::zeros);
  arma::cube xi_tkl(K, K, N - 1, arma::fill::zeros);

  arma::mat alpha_tk(K, N, arma::fill::zeros);
  arma::mat beta_tk(K, N, arma::fill::zeros);

  double loglik;

  // forwards: calculation of alpha_tk
  int t = 0;

  alpha_tk.col(t) = normalizeColVec(prior % f_tk.col(t));
  scale(0, t) = sum(prior % f_tk.col(t));

  for (t = 1; t < N; t++) {

    alpha_tk.col(t) = normalizeColVec((transmat.t() * alpha_tk.col(t - 1)) % f_tk.col(t));
    scale(0, t) = sum((transmat.t() * alpha_tk.col(t - 1)) % f_tk.col(t));

  }

  // loglikehood (with the scaling technique) (see Rabiner's paper/book)
  loglik = sum(sum(log(scale)));

  // backwards: calculation of beta_tk, tau_tk (and xi_tkl)
  beta_tk.col(N - 1) = arma::colvec(K, arma::fill::ones);
  tau_tk.col(N - 1) = normalizeColVec(alpha_tk.col(N - 1) % beta_tk.col(N - 1));

  for (t = N - 2; t >= 0; t--) {

    beta_tk.col(t) = normalizeColVec(transmat * (beta_tk.col(t + 1) % f_tk.col(t + 1)));
    tau_tk.col(t) = normalizeColVec(alpha_tk.col(t) % beta_tk.col(t));
    xi_tkl.slice(t) = normalizeMat(transmat % (alpha_tk.col(t) * trans(beta_tk.col(t + 1) % f_tk.col(t + 1))));

  }

  return List::create(Named("tau_tk") = tau_tk, Named("xi_tkl") = xi_tkl, Named("alpha_tk") = alpha_tk, Named("beta_tk") = beta_tk, Named("loglik") = loglik);

}
