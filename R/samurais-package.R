#' SaMUraiS: StAtistical Models for the UnsupeRvised segmentAtIon of time-Series
#'
#' @description `samurais` is a toolbox including many original and flexible
#' user-friendly statistical latent variable models and efficient unsupervised
#' algorithms to segment and represent time-series data (univariate or
#' multivariate), and more generally, longitudinal data, which include regime
#' changes.
#'
#' `samurais` contains the following time series segmentation models:
#'
#' \itemize{
#' \item RHLP;
#' \item HMM/HMMR;
#' \item PWR;
#' \item MRHLP;
#' \item MHMMR;
#' }
#'
#' For the advantages/differences of each of them, the user is referred to our
#' mentioned paper references.
#'
#' To learn more about `samurais`, start with the vignettes:
#' `browseVignettes(package = "samurais")`
#'
#' @references
#'
#' Chamroukhi, F., and Hien D. Nguyen. 2019. \emph{Model-Based Clustering and Classification of Functional Data.} Wiley Interdisciplinary Reviews: Data Mining and Knowledge Discovery. \url{https://doi.org/10.1002/widm.1298}.
#'
#' Chamroukhi, F. 2015. \emph{Statistical Learning of Latent Data Models for Complex Data Analysis.} Habilitation Thesis (HDR), Universite de Toulon. \url{https://chamroukhi.com/Dossier/FChamroukhi-Habilitation.pdf}.
#'
#' Trabelsi, D., S. Mohammed, F. Chamroukhi, L. Oukhellou, and Y. Amirat. 2013. \emph{An Unsupervised Approach for Automatic Activity Recognition Based on Hidden Markov Model Regression.} IEEE Transactions on Automation Science and Engineering 3 (10): 829--335. \url{https://chamroukhi.com/papers/Chamroukhi-MHMMR-IeeeTase.pdf}.
#'
#' Chamroukhi, F., D. Trabelsi, S. Mohammed, L. Oukhellou, and Y. Amirat. 2013. \emph{Joint Segmentation of Multivariate Time Series with Hidden Process Regression for Human Activity Recognition.} Neurocomputing 120: 633--44. \url{https://chamroukhi.com/papers/chamroukhi_et_al_neucomp2013b.pdf}.
#'
#' Chamroukhi, F., A. Same, G. Govaert, and P. Aknin. 2010. \emph{A Hidden Process Regression Model for Functional Data Description. Application to Curve Discrimination.} Neurocomputing 73 (7-9): 1210--21. \url{https://chamroukhi.com/papers/chamroukhi_neucomp_2010.pdf}.
#'
#' Chamroukhi, F. 2010. \emph{Hidden Process Regression for Curve Modeling, Classification and Tracking.} Ph.D. Thesis, Universite de Technologie de Compiegne. \url{https://chamroukhi.com/papers/FChamroukhi-Thesis.pdf}.
#'
#' Chamroukhi, F., A. Same, G. Govaert, and P. Aknin. 2009. \emph{Time Series Modeling by a Regression Approach Based on a Latent Process.} Neural Networks 22 (5-6): 593--602. \url{https://chamroukhi.com/papers/Chamroukhi_Neural_Networks_2009.pdf}.
#'
#' @import methods
## usethis namespace: start
#' @useDynLib samurais, .registration = TRUE
## usethis namespace: end
## usethis namespace: start
#' @importFrom Rcpp sourceCpp
## usethis namespace: end
"_PACKAGE"
