// [[Rcpp::depends(RcppArmadillo)]]

#include <RcppArmadillo.h>

using namespace Rcpp;

// [[Rcpp::export]]
arma::mat costMatrix(arma::colvec& y, arma::mat& X, double Lmin = 1) {

    double nl = y.size() - Lmin + 1;

    arma::Mat<double> C1 = arma::mat(y.size(), y.size());
    C1.fill(arma::datum::inf);
    C1 = arma::trimatl(C1, Lmin - 2);

    for (int a = 0; a <= nl; a++) {

      if ((a + Lmin) <= y.size()) { // To check

        // ############################################################################
        // # Condition added to handle the cases (a + 1 + Lmin) > n                   #
        // ############################################################################

        for (int b = (a + Lmin); b < y.size(); b++)  {

          arma::colvec yab = y.subvec(a, b);
          arma::mat X_ab = X.rows(a, b);

          double nk = b - a;

          arma::colvec beta = pinv(X_ab.t() * X_ab) * X_ab.t() * yab;
          arma::colvec z = yab - X_ab * beta;
          double sigma = arma::as_scalar(z.t() * z) / nk;
          C1(a, b) = nk + nk * log(sigma + 2.220446e-16);
        }
      }
    }

    return C1;
}
