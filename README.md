
<!-- README.md is generated from README.Rmd. Please edit that file -->

# **SaMUraiS**: **S**t**A**tistical **M**odels for the **U**nsupe**R**vised segment**A**tion of t**I**me **S**eries

SaMUraiS is a toolbox including many flexible user-friendly and original
statistical latent variable models and unsupervised algorithms to
segment and represent, time-series data (univariate or multivariate),
and more generally, longitudinal data which include regime changes.

Our SaMUraiS use mainly the following efficient “sword” packages to
segment data:

  - RHLP;
  - MRHLP;
  - HMM/HMMR;
  - MHMMR;
  - PWR.

The models and algorithms are developed and written in Matlab by Faicel
Chamroukhi, and translated and designed into R packages by Florian
Lecocq, Marius Bartcus and Faicel Chamroukhi.

<!-- badges: start -->

<!-- badges: end -->

# Installation

You can install the **samurais** package from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("fchamroukhi/SaMUraiS")
```

To build *vignettes* for examples of usage, type the command below
instead:

``` r
# install.packages("devtools")
devtools::install_github("fchamroukhi/SaMUraiS", 
                         build_opts = c("--no-resave-data", "--no-manual"), 
                         build_vignettes = TRUE)
```

Use the following command to display vignettes:

``` r
browseVignettes("samurais")
```

# Usage

# References

<div id="refs" class="references">

<div id="ref-item5">

Chamroukhi, F. 2010. “Hidden Process Regression for Curve Modeling,
Classification and Tracking.” Ph.D. Thesis, Université de Technologie de
Compiègne. <https://chamroukhi.com/papers/FChamroukhi-Thesis.pdf>.

</div>

<div id="ref-item2">

———. 2015. “Statistical Learning of Latent Data Models for Complex Data
Analysis.” Habilitation Thesis (HDR), Université de Toulon.

</div>

<div id="ref-item1">

Chamroukhi, F., and Hien D. Nguyen. 2019. “Model-Based Clustering and
Classification of Functional Data.” *Wiley Interdisciplinary Reviews:
Data Mining and Knowledge Discovery*.
<https://doi.org/10.1002/widm.1298>.

</div>

<div id="ref-item7">

Chamroukhi, F., A. Samé, G. Govaert, and P. Aknin. 2009. “Time Series
Modeling by a Regression Approach Based on a Latent Process.” *Neural
Networks* 22 (5-6): 593–602.
<https://chamroukhi.com/papers/Chamroukhi_Neural_Networks_2009.pdf>.

</div>

<div id="ref-item6">

———. 2010. “A Hidden Process Regression Model for Functional Data
Description. Application to Curve Discrimination.” *Neurocomputing* 73
(7-9): 1210–21.
<https://chamroukhi.com/papers/chamroukhi_neucomp_2010.pdf>.

</div>

<div id="ref-item3">

Chamroukhi, F., D. Trabelsi, S. Mohammed, L. Oukhellou, and Y. Amirat.
2013. “Joint Segmentation of Multivariate Time Series with Hidden
Process Regression for Human Activity Recognition.” *Neurocomputing*
120: 633–44.
<https://chamroukhi.com/papers/chamroukhi_et_al_neucomp2013b.pdf>.

</div>

<div id="ref-item4">

Trabelsi, D., S. Mohammed, F. Chamroukhi, L. Oukhellou, and Y. Amirat.
2013. “An Unsupervised Approach for Automatic Activity Recognition Based
on Hidden Markov Model Regression.” *IEEE Transactions on Automation
Science and Engineering* 3 (10): 829–335.
<https://chamroukhi.com/papers/Chamroukhi-MHMMR-IeeeTase.pdf>.

</div>

</div>
