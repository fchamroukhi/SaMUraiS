// Defines a header file containing function signatures for functions in src/

// Protect signatures using an inclusion guard.
#ifndef multinomialLogit_H
#define multinomialLogit_H

Rcpp::List multinomialLogit(arma::mat& W, arma::mat& X, arma::mat& Y, arma::mat& Gamma);

#endif
