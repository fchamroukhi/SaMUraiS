// [[Rcpp::depends(RcppArmadillo)]]

#include <RcppArmadillo.h>

using namespace Rcpp;

// [[Rcpp::export]]
List multinomialLogit(arma::mat& W, arma::mat& X, arma::mat& Y, arma::mat& Gamma) {

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // function [probs, loglik] = logit_model_MixRHLP(W, X, Y, Gamma)
  //
  // calculates the pobabilities according to multinomial logistic model:
  //
  // probs(i,k) = p(zi=k;W)= \pi_{ik}(W)
  //                                  exp(wk'vi)
  //                        =  ----------------------------
  //                          1 + sum_{l=1}^{K-1} exp(wl'vi)
  // for i=1,...,n and k=1...K
  //
  // Inputs :
  //
  //         1. W : parametre du modele logistique ,Matrice de dimensions
  //         [(q+1)x(K-1)]des vecteurs parametre wk. W = [w1 .. wk..w(K-1)]
  //         avec les wk sont des vecteurs colonnes de dim [(q+1)x1], le dernier
  //         est suppose nul (sum_{k=1}^K \pi_{ik} = 1 -> \pi{iK} =
  //         1-sum_{l=1}^{K-1} \pi{il}. vi : vecteur colonne de dimension [(q+1)x1]
  //         qui est la variable explicative (ici le temps): vi = [1;ti;ti^2;...;ti^q];
  //         2. M : Matrice de dimensions [nx(q+1)] des variables explicatives.
  //            M = transpose([v1... vi ....vn])
  //              = [1 t1 t1^2 ... t1^q
  //                 1 t2 t2^2 ... t2^q
  //                       ..
  //                 1 ti ti^2 ... ti^q
  //                       ..
  //                 1 tn tn^2 ... tn^q]
  //           q : ordre de regression logistique
  //           n : nombre d'observations
  //        3. Y Matrice de la partition floue (les probs a posteriori tik)
  //           tik = p(zi=k|xi;theta^m); Y de dimensions [nxK] avec K le nombre de classes
  // Sorties :
  //
  //        1. probs : Matrice de dim [nxK] des probabilites p(zi=k;W) de la vaiable zi
  //          (i=1,...,n)
  //        2. loglik : logvraisemblance du parametre W du modele logistique
  //           loglik = Q1(W) = E(l(W;Z)|X;theta^m) = E(p(Z;W)|X;theta^m)
  //                  = logsum_{i=1}^{n} sum_{k=1}^{K} tik log p(zi=k;W)
  //
  // Cette fonction peut egalement ?tre utilis?e pour calculer seulement les
  // probs de la fa?oc suivante : probs = modele_logit(W,X)
  //
  // Faicel Chamroukhi 31 Octobre 2008 (mise ? jour)
  /////////////////////////////////////////////////////////////////////////////////////////

  unsigned n = X.n_rows;
  unsigned q = X.n_cols;

  unsigned K = Y.n_cols;

  // Handle different q
  if (q != W.n_rows) {
    stop("W must have q + 1 rows and X must have q + 1 columns.");
  }

  arma::mat Wc = W;
  // Handle size of K issues
  if (Wc.n_cols == (K - 1)) { // W doesnt contain the null vector associated with the last class
    Wc = join_rows(Wc, arma::mat(q, 1, arma::fill::zeros)); // Add the null vector wK for the last component probability
  }
  if (Wc.n_cols != K) {
    stop("W must have K - 1 or K columns.");
  }

  // Handle different n
  if ((n != Y.n_cols) && (n != Gamma.n_rows)) {
    stop("X, Y and Gamma must have the same number of rows which is n.");
  }

  arma::mat XW(n, K, arma::fill::zeros);
  arma::colvec maxm(n, arma::fill::zeros);
  arma::mat expXW(n, K, arma::fill::zeros);
  arma::mat piik(n, K, arma::fill::zeros);
  arma::mat GammaMat(n, K, arma::fill::ones);

  GammaMat = Gamma * arma::rowvec(K, arma::fill::ones);

  double loglik;

  XW = X * Wc;
  maxm = arma::max(XW, 1);

  XW = XW - maxm * arma::rowvec(K, arma::fill::ones); // To avoid overfolow

  double minvalue = -745.1;
  XW = arma::max(XW, minvalue * arma::mat(XW.n_rows, XW.n_cols, arma::fill::ones));
  double maxvalue = 709.78;
  XW = arma::min(XW, maxvalue * arma::mat(XW.n_rows, XW.n_cols, arma::fill::ones));
  expXW = arma::exp(XW);

  piik = expXW / (arma::sum(expXW, 1) * arma::rowvec(K, arma::fill::ones));

  // log-likelihood
  loglik = sum(sum((GammaMat % (Y % XW)) - ((GammaMat % Y) % arma::log(arma::sum(expXW, 1) * arma::rowvec(K, arma::fill::ones)))));

  return List::create(Named("loglik") = loglik, Named("piik") = piik);

}
