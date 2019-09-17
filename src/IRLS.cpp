// [[Rcpp::depends(RcppArmadillo)]]

#include <RcppArmadillo.h>
#include "multinomialLogit.h"

using namespace Rcpp;

// [[Rcpp::export]]
List IRLS(arma::mat& X, arma::mat& Tau, arma::mat& Gamma, arma::mat& Winit, bool verbose = false) {

  // res = IRLS_MixFRHLP(X, Tau, Gamma, Winit, verbose) : an efficient Iteratively Reweighted Least-Squares (IRLS) algorithm for estimating
  // the parameters of a multinomial logistic regression model given the
  // "predictors" X and a partition (hard or smooth) Tau into K>=2 segments,
  // and a cluster weights Gamma (hard or smooth)
  //
  //
  // Inputs :
  //
  //         X : desgin matrix for the logistic weights.  dim(X) = [nx(q+1)]
  //                            X = [1 t1 t1^2 ... t1^q
  //                                 1 t2 t2^2 ... t2^q
  //                                      ..
  //                                 1 ti ti^2 ... ti^q
  //                                      ..
  //                                 1 tn tn^2 ... tn^q]
  //            q being the number of predictors
  //         Tau : matrix of a hard or fauzzy partition of the data (here for
  //         the RHLP model, Tau is the fuzzy partition represented by the
  //         posterior probabilities (responsibilities) (tik) obtained at the E-Step).
  //
  //         Winit : initial parameter values W(0). dim(Winit) = [(q+1)x(K-1)]
  //         verbose : 1 to print the loglikelihood values during the IRLS
  //         iterations, 0 if not
  //
  // Outputs :
  //
  //          res : structure containing the fields:
  //              W : the estimated parameter vector. matrix of dim [(q+1)x(K-1)]
  //                  (the last vector being the null vector)
  //              piigk : the logistic probabilities (dim [n x K])
  //              loglik : the value of the maximized objective
  //              LL : stored values of the maximized objective during the
  //              IRLS training
  //
  //        Probs(i,gk) = Pro(segment k|cluster g;W)
  //                    = \pi_{ik}(W)
  //                           exp(wgk'vi)
  //                    =  ---------------------------
  //                      1+sum_{l=1}^{K-1} exp(wgl'vi)
  //
  //       with :
  //            * Probs(i,gk) is the prob of component k at time t_i in
  //            cluster g
  //            i=1,...n,j=1...m,  k=1,...,K,
  //            * vi = [1,ti,ti^2,...,ti^q]^T;
  //       The parameter vecrots are in the matrix W=[w1,...,wK] (with wK is the null vector);
  //

  //// References
  // Please cite the following papers for this code:
  //
  //
  // @INPROCEEDINGS{Chamroukhi-IJCNN-2009,
  //   AUTHOR =       {Chamroukhi, F. and Sam\'e,  A. and Govaert, G. and Aknin, P.},
  //   TITLE =        {A regression model with a hidden logistic process for feature extraction from time series},
  //   BOOKTITLE =    {International Joint Conference on Neural Networks (IJCNN)},
  //   YEAR =         {2009},
  //   month = {June},
  //   pages = {489--496},
  //   Address = {Atlanta, GA},
  //  url = {https://chamroukhi.users.lmno.cnrs.fr/papers/chamroukhi_ijcnn2009.pdf}
  // }
  //
  // @article{chamroukhi_et_al_NN2009,
  // 	Address = {Oxford, UK, UK},
  // 	Author = {Chamroukhi, F. and Sam\'{e}, A. and Govaert, G. and Aknin, P.},
  // 	Date-Added = {2014-10-22 20:08:41 +0000},
  // 	Date-Modified = {2014-10-22 20:08:41 +0000},
  // 	Journal = {Neural Networks},
  // 	Number = {5-6},
  // 	Pages = {593--602},
  // 	Publisher = {Elsevier Science Ltd.},
  // 	Title = {Time series modeling by a regression approach based on a latent process},
  // 	Volume = {22},
  // 	Year = {2009},
  // 	url  = {https://chamroukhi.users.lmno.cnrs.fr/papers/Chamroukhi_Neural_Networks_2009.pdf}
  // 	}
  // @article{Chamroukhi-FDA-2018,
  // 	Journal = {},
  // 	Author = {Faicel Chamroukhi and Hien D. Nguyen},
  // 	Volume = {},
  // 	Title = {Model-Based Clustering and Classification of Functional Data},
  // 	Year = {2018},
  // 	eprint ={arXiv:1803.00276v2},
  // 	url =  {https://chamroukhi.users.lmno.cnrs.fr/papers/MBCC-FDA.pdf}
  // 	}
  //
  //
  //////////////////////////////////////////////////////////////////////////////////////////////

  int n = Tau.n_rows;
  int K = Tau.n_cols;

  int q = X.n_cols; // q here is (q+1)

  double lambda = 1e-9; // if a MAP regularization (a gaussian prior on W) (L_2 penalization); lambda is a positive hyperparameter
  arma::mat I(q * (K - 1), q * (K - 1), arma::fill::eye); // Define an identity matrix

  arma::mat piik_old(n, K, arma::fill::zeros);
  arma::mat piik(n, K, arma::fill::zeros);
  arma::colvec gwk(n, arma::fill::zeros);
  arma::colvec vq(n, arma::fill::zeros);

  arma::mat Hkl(q, q, arma::fill::zeros);
  arma::colvec vqa(n, arma::fill::zeros);
  arma::colvec vqb(n, arma::fill::zeros);
  double hwk;
  arma::colvec w(q * (K - 1), arma::fill::zeros);


  // IRLS Initialization (iter = 0)
  arma::mat W_old = Winit;

  List out = multinomialLogit(W_old, X, Tau, Gamma);

  double loglik_old = out["loglik"];
  arma::mat tmp = out["piik"];
  piik_old = tmp;
  piik = tmp;


  loglik_old = loglik_old - lambda * std::pow(arma::norm(W_old), 2.0);

  int iter = 0;
  int max_iter = 300;
  double loglik = 0;

  // List ret;
  List LL;

  bool converge1 = false;
  bool converge2 = false;
  bool converge = false;

  arma::mat W(q, K - 1, arma::fill::zeros);

  if (verbose == true) {
    Rcout << "IRLS : Iteration : "  + std::to_string(iter) + "; Log-lik: " + std::to_string(loglik_old) + "\n";
  }

  // IRLS

  // Hw_old a squared matrix of dimensions  q*(K-1) x  q*(K-1)
  int hx = q * (K - 1);
  arma::mat Hw_old(hx, hx, arma::fill::zeros);
  arma::mat gw_old(q, K - 1, arma::fill::zeros);


  while (not(converge) && (iter < max_iter)) {

    // Gradient :
    gw_old.reshape(q, (K - 1));
    for (int k = 0; k < K - 1; k++) {
      gwk = Gamma % (Tau.col(k) - piik_old.col(k));

      for (int qq = 0; qq < q; qq++) {
        vq = X.col(qq);
        gw_old(qq, k) = arma::as_scalar(gwk.t() * vq);
      }
    }
    gw_old.reshape(q * (K - 1), 1);

    // Hessian
    for (int k = 0; k < K - 1; k++) {
      for (int ell = 0; ell < K - 1; ell++) {
        bool delta_kl = (k == ell); // kronecker delta
        gwk = Gamma % (piik_old.col(k) % (arma::mat(n, 1, arma::fill::ones) * delta_kl - piik_old.col(ell)));
        for (int qqa = 0; qqa < q; qqa++) {
          vqa = X.col(qqa);
          for (int qqb = 0; qqb < q; qqb++) {
            vqb = X.col(qqb);
            hwk = as_scalar(vqb.t() * (gwk % vqa));
            Hkl(qqa, qqb) = hwk;

          }
        }
        Hw_old.submat(k * q, ell * q, (k + 1) * q - 1, (ell + 1) * q - 1) = -Hkl;
      }
    }

    // If a gaussian prior on W (lambda ~=0)
    Hw_old = Hw_old + lambda * I;
    gw_old = gw_old - lambda * vectorise(W_old, 0);

    // Newton Raphson : W(t+1) = W(t) - H(W(t))^(-1)g(W(t))
    w = vectorise(W_old, 0) - arma::inv(Hw_old) * gw_old; // [(q+1)x(K-1),1]
    W.reshape(1, q * (K - 1));
    W = w;
    W.reshape(q, K - 1); // [(q+1)*(K-1)]

    // Update probabilities and loglik
    out = multinomialLogit(W, X, Tau, Gamma);
    loglik = out["loglik"];
    loglik = loglik - lambda * std::pow(arma::norm(W), 2.0);
    arma::mat tmp = out["piik"];
    piik = tmp;

    // Check if Qw1(w^(t+1),w^(t))> Qw1(w^(t),w^(t))
    // (adaptive stepsize in case of troubles with stepsize 1) Newton Raphson : W(t+1) = W(t) - stepsize*H(W)^(-1)*g(W)
    double stepsize = 1; // Initialization, no adaptation of the Newton Raphson algo
    double alpha = 2;
    while (loglik < loglik_old) {

      stepsize = stepsize / alpha;

      // Recalculate the parameter W and the "loglik"
      w = vectorise(W_old, 0) - stepsize * arma::inv(Hw_old) * gw_old;
      W.reshape(1, q * (K - 1));
      W = w;
      W.reshape(q, K - 1);
      out = multinomialLogit(W, X, Tau, Gamma);
      loglik = out["loglik"];

      loglik = loglik - lambda * std::pow(arma::norm(W), 2.0);

      arma::mat tmp = out["piik"];
      piik = tmp;
    }

    converge1 = std::abs((loglik - loglik_old) / loglik_old) <= 1e-7;
    converge2 = std::abs(loglik - loglik_old) <= 1e-6;
    converge = converge1 || converge2;

    piik_old = piik;
    W_old = W;
    iter = iter + 1;
    LL[std::to_string(iter)] = loglik_old;
    loglik_old = loglik;

    if (verbose == true) {
      Rcout << "IRLS : Iteration : "  + std::to_string(iter) + "; Log-lik: " + std::to_string(loglik_old) + "\n";
    }
  } // End of IRLS

  if (converge == true) {
    if (verbose == true) {
      Rcout << "\n";
      Rcout << "IRLS convergence OK ; number of iterations: "  + std::to_string(iter) + "\n";
      Rcout << "\n";
    }
  } else {
    Rcout << "\n";
    Rcout << "IRLS : did not converge (increase the number of iterations > "  + std::to_string(max_iter) + ")\n";
  }

  double reg_irls = 0;
  if (lambda != 0) { // Calculate the value of the regularization part to calculate the value of the MAP criterion in case of regularization
    reg_irls = - lambda * std::pow(arma::norm(W), 2.0); // bayesian l2 regularization
  }

  return List::create(Named("W") = W, Named("LL") = LL, Named("loglik") = loglik, Named("piik") = piik, Named("reg_irls") = reg_irls);
}
