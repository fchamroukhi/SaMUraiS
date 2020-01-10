
<!-- README.md is generated from README.Rmd. Please edit that file -->

# **SaMUraiS**: **S**t**A**tistical **M**odels for the **U**nsupe**R**vised segment**A**t**I**on of time-**S**eries

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/fchamroukhi/SaMUraiS.svg?branch=master)](https://travis-ci.org/fchamroukhi/SaMUraiS)
[![CRAN
versions](https://www.r-pkg.org/badges/version/samurais)](https://CRAN.R-project.org/package=samurais)
[![CRAN
logs](https://cranlogs.r-pkg.org/badges/samurais)](https://CRAN.R-project.org/package=samurais)
<!-- badges: end -->

samurais is an open source toolbox (available in R and in Matlab)
including many original and flexible user-friendly statistical latent
variable models and unsupervised algorithms to segment and represent,
time-series data (univariate or multivariate), and more generally,
longitudinal data which include regime changes.

Our samurais use mainly the following efficient “sword” packages to
segment data: Regression with Hidden Logistic Process (**RHLP**), Hidden
Markov Model Regression (**HMMR**), Piece-Wise regression (**PWR**),
Multivariate ‘RHLP’ (**MRHLP**), and Multivariate ‘HMMR’ (**MHMMR**).

The models and algorithms are developed and written in Matlab by Faicel
Chamroukhi, and translated and designed into R packages by Florian
Lecocq, Marius Bartcus and Faicel Chamroukhi.

# Installation

You can install the **samurais** package from
[GitHub](https://github.com/fchamroukhi/SaMUraiS) with:

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

``` r
library(samurais)
```

<details>

<summary>RHLP</summary>

``` r
# Application to a toy data set
data("univtoydataset")
x <- univtoydataset$x
y <- univtoydataset$y

K <- 5 # Number of regimes (mixture components)
p <- 3 # Dimension of beta (order of the polynomial regressors)
q <- 1 # Dimension of w (order of the logistic regression: to be set to 1 for segmentation)
variance_type <- "heteroskedastic" # "heteroskedastic" or "homoskedastic" model

n_tries <- 1
max_iter = 1500
threshold <- 1e-6
verbose <- TRUE
verbose_IRLS <- FALSE

rhlp <- emRHLP(X = x, Y = y, K, p, q, variance_type, n_tries, 
               max_iter, threshold, verbose, verbose_IRLS)
#> EM: Iteration : 1 || log-likelihood : -2119.27308534609
#> EM: Iteration : 2 || log-likelihood : -1149.01040321999
#> EM: Iteration : 3 || log-likelihood : -1118.20384281234
#> EM: Iteration : 4 || log-likelihood : -1096.88260636121
#> EM: Iteration : 5 || log-likelihood : -1067.55719357295
#> EM: Iteration : 6 || log-likelihood : -1037.26620122646
#> EM: Iteration : 7 || log-likelihood : -1022.71743069484
#> EM: Iteration : 8 || log-likelihood : -1006.11825447077
#> EM: Iteration : 9 || log-likelihood : -1001.18491883952
#> EM: Iteration : 10 || log-likelihood : -1000.91250763556
#> EM: Iteration : 11 || log-likelihood : -1000.62280600209
#> EM: Iteration : 12 || log-likelihood : -1000.3030988811
#> EM: Iteration : 13 || log-likelihood : -999.932334880131
#> EM: Iteration : 14 || log-likelihood : -999.484219706691
#> EM: Iteration : 15 || log-likelihood : -998.928118038989
#> EM: Iteration : 16 || log-likelihood : -998.234244664472
#> EM: Iteration : 17 || log-likelihood : -997.359536276056
#> EM: Iteration : 18 || log-likelihood : -996.152654857298
#> EM: Iteration : 19 || log-likelihood : -994.697863447307
#> EM: Iteration : 20 || log-likelihood : -993.186583974542
#> EM: Iteration : 21 || log-likelihood : -991.81352379631
#> EM: Iteration : 22 || log-likelihood : -990.611295217008
#> EM: Iteration : 23 || log-likelihood : -989.539226273251
#> EM: Iteration : 24 || log-likelihood : -988.55311887915
#> EM: Iteration : 25 || log-likelihood : -987.539963690533
#> EM: Iteration : 26 || log-likelihood : -986.073920116541
#> EM: Iteration : 27 || log-likelihood : -983.263549878169
#> EM: Iteration : 28 || log-likelihood : -979.340492188909
#> EM: Iteration : 29 || log-likelihood : -977.468559852711
#> EM: Iteration : 30 || log-likelihood : -976.653534236095
#> EM: Iteration : 31 || log-likelihood : -976.5893387433
#> EM: Iteration : 32 || log-likelihood : -976.589338067237

rhlp$summary()
#> ---------------------
#> Fitted RHLP model
#> ---------------------
#> 
#> RHLP model with K = 5 components:
#> 
#>  log-likelihood nu       AIC       BIC       ICL
#>       -976.5893 33 -1009.589 -1083.959 -1083.176
#> 
#> Clustering table (Number of observations in each regimes):
#> 
#>   1   2   3   4   5 
#> 100 120 200 100 150 
#> 
#> Regression coefficients:
#> 
#>       Beta(K = 1) Beta(K = 2) Beta(K = 3) Beta(K = 4) Beta(K = 5)
#> 1    6.031875e-02   -5.434903   -2.770416    120.7699    4.027542
#> X^1 -7.424718e+00  158.705091   43.879453   -474.5888   13.194261
#> X^2  2.931652e+02 -650.592347  -94.194780    597.7948  -33.760603
#> X^3 -1.823560e+03  865.329795   67.197059   -244.2386   20.402153
#> 
#> Variances:
#> 
#>  Sigma2(K = 1) Sigma2(K = 2) Sigma2(K = 3) Sigma2(K = 4) Sigma2(K = 5)
#>       1.220624      1.110243      1.079394     0.9779734      1.028332

rhlp$plot()
```

<img src="man/figures/README-unnamed-chunk-6-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-6-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-6-3.png" style="display: block; margin: auto;" />

``` r
# Application to a real data set
data("univrealdataset")
x <- univrealdataset$x
y <- univrealdataset$y2

K <- 5 # Number of regimes (mixture components)
p <- 3 # Dimension of beta (order of the polynomial regressors)
q <- 1 # Dimension of w (order of the logistic regression: to be set to 1 for segmentation)
variance_type <- "heteroskedastic" # "heteroskedastic" or "homoskedastic" model

n_tries <- 1
max_iter = 1500
threshold <- 1e-6
verbose <- TRUE
verbose_IRLS <- FALSE

rhlp <- emRHLP(X = x, Y = y, K, p, q, variance_type, n_tries, 
               max_iter, threshold, verbose, verbose_IRLS)
#> EM: Iteration : 1 || log-likelihood : -3321.6485760125
#> EM: Iteration : 2 || log-likelihood : -2286.48632282875
#> EM: Iteration : 3 || log-likelihood : -2257.60498391374
#> EM: Iteration : 4 || log-likelihood : -2243.74506764308
#> EM: Iteration : 5 || log-likelihood : -2233.3426635247
#> EM: Iteration : 6 || log-likelihood : -2226.89953345319
#> EM: Iteration : 7 || log-likelihood : -2221.77999023589
#> EM: Iteration : 8 || log-likelihood : -2215.81305295291
#> EM: Iteration : 9 || log-likelihood : -2208.25998029539
#> EM: Iteration : 10 || log-likelihood : -2196.27872403055
#> EM: Iteration : 11 || log-likelihood : -2185.40049009242
#> EM: Iteration : 12 || log-likelihood : -2180.13934245387
#> EM: Iteration : 13 || log-likelihood : -2175.4276274402
#> EM: Iteration : 14 || log-likelihood : -2170.86113669353
#> EM: Iteration : 15 || log-likelihood : -2165.34927170608
#> EM: Iteration : 16 || log-likelihood : -2161.12419211511
#> EM: Iteration : 17 || log-likelihood : -2158.63709280617
#> EM: Iteration : 18 || log-likelihood : -2156.19846850913
#> EM: Iteration : 19 || log-likelihood : -2154.04107470071
#> EM: Iteration : 20 || log-likelihood : -2153.24544245686
#> EM: Iteration : 21 || log-likelihood : -2151.74944795242
#> EM: Iteration : 22 || log-likelihood : -2149.90781423151
#> EM: Iteration : 23 || log-likelihood : -2146.40042232588
#> EM: Iteration : 24 || log-likelihood : -2142.37530025533
#> EM: Iteration : 25 || log-likelihood : -2134.85493291884
#> EM: Iteration : 26 || log-likelihood : -2129.67399002071
#> EM: Iteration : 27 || log-likelihood : -2126.44739300481
#> EM: Iteration : 28 || log-likelihood : -2124.94603052064
#> EM: Iteration : 29 || log-likelihood : -2122.51637426267
#> EM: Iteration : 30 || log-likelihood : -2121.01493646146
#> EM: Iteration : 31 || log-likelihood : -2118.45402063643
#> EM: Iteration : 32 || log-likelihood : -2116.9336204919
#> EM: Iteration : 33 || log-likelihood : -2114.34424563452
#> EM: Iteration : 34 || log-likelihood : -2112.84844186712
#> EM: Iteration : 35 || log-likelihood : -2110.34494568025
#> EM: Iteration : 36 || log-likelihood : -2108.81734757025
#> EM: Iteration : 37 || log-likelihood : -2106.26527191053
#> EM: Iteration : 38 || log-likelihood : -2104.96591147986
#> EM: Iteration : 39 || log-likelihood : -2102.43927829964
#> EM: Iteration : 40 || log-likelihood : -2101.27820194404
#> EM: Iteration : 41 || log-likelihood : -2098.81151697567
#> EM: Iteration : 42 || log-likelihood : -2097.48008514591
#> EM: Iteration : 43 || log-likelihood : -2094.98259556552
#> EM: Iteration : 44 || log-likelihood : -2093.66517040802
#> EM: Iteration : 45 || log-likelihood : -2091.23625905564
#> EM: Iteration : 46 || log-likelihood : -2089.91118603989
#> EM: Iteration : 47 || log-likelihood : -2087.67388435026
#> EM: Iteration : 48 || log-likelihood : -2086.11373786756
#> EM: Iteration : 49 || log-likelihood : -2083.84931461869
#> EM: Iteration : 50 || log-likelihood : -2082.16175664198
#> EM: Iteration : 51 || log-likelihood : -2080.45137011098
#> EM: Iteration : 52 || log-likelihood : -2078.37066132008
#> EM: Iteration : 53 || log-likelihood : -2077.06827662071
#> EM: Iteration : 54 || log-likelihood : -2074.66718553694
#> EM: Iteration : 55 || log-likelihood : -2073.68137124781
#> EM: Iteration : 56 || log-likelihood : -2071.20390017789
#> EM: Iteration : 57 || log-likelihood : -2069.88260759288
#> EM: Iteration : 58 || log-likelihood : -2067.30246728287
#> EM: Iteration : 59 || log-likelihood : -2066.08897944236
#> EM: Iteration : 60 || log-likelihood : -2064.14482062792
#> EM: Iteration : 61 || log-likelihood : -2062.39859624374
#> EM: Iteration : 62 || log-likelihood : -2060.73756242314
#> EM: Iteration : 63 || log-likelihood : -2058.4448132974
#> EM: Iteration : 64 || log-likelihood : -2057.23564743141
#> EM: Iteration : 65 || log-likelihood : -2054.73129678764
#> EM: Iteration : 66 || log-likelihood : -2053.66525147972
#> EM: Iteration : 67 || log-likelihood : -2051.05262427909
#> EM: Iteration : 68 || log-likelihood : -2049.89030367995
#> EM: Iteration : 69 || log-likelihood : -2047.68843285481
#> EM: Iteration : 70 || log-likelihood : -2046.16052536146
#> EM: Iteration : 71 || log-likelihood : -2044.92677581091
#> EM: Iteration : 72 || log-likelihood : -2042.67687818721
#> EM: Iteration : 73 || log-likelihood : -2041.77608506749
#> EM: Iteration : 74 || log-likelihood : -2039.40345316134
#> EM: Iteration : 75 || log-likelihood : -2038.20062153928
#> EM: Iteration : 76 || log-likelihood : -2036.05846372404
#> EM: Iteration : 77 || log-likelihood : -2034.52492449426
#> EM: Iteration : 78 || log-likelihood : -2033.44774900177
#> EM: Iteration : 79 || log-likelihood : -2031.15837908019
#> EM: Iteration : 80 || log-likelihood : -2030.29908045026
#> EM: Iteration : 81 || log-likelihood : -2028.08193331457
#> EM: Iteration : 82 || log-likelihood : -2026.82779637097
#> EM: Iteration : 83 || log-likelihood : -2025.51219569808
#> EM: Iteration : 84 || log-likelihood : -2023.47136697978
#> EM: Iteration : 85 || log-likelihood : -2022.86702240332
#> EM: Iteration : 86 || log-likelihood : -2021.05803372565
#> EM: Iteration : 87 || log-likelihood : -2019.68013062929
#> EM: Iteration : 88 || log-likelihood : -2018.57796815284
#> EM: Iteration : 89 || log-likelihood : -2016.51065270015
#> EM: Iteration : 90 || log-likelihood : -2015.84957111014
#> EM: Iteration : 91 || log-likelihood : -2014.25626618564
#> EM: Iteration : 92 || log-likelihood : -2012.83069679254
#> EM: Iteration : 93 || log-likelihood : -2012.36700738444
#> EM: Iteration : 94 || log-likelihood : -2010.80319327333
#> EM: Iteration : 95 || log-likelihood : -2009.62231094925
#> EM: Iteration : 96 || log-likelihood : -2009.18020396728
#> EM: Iteration : 97 || log-likelihood : -2007.70135886708
#> EM: Iteration : 98 || log-likelihood : -2006.56703696874
#> EM: Iteration : 99 || log-likelihood : -2006.01673291469
#> EM: Iteration : 100 || log-likelihood : -2004.41194242792
#> EM: Iteration : 101 || log-likelihood : -2003.4625414477
#> EM: Iteration : 102 || log-likelihood : -2002.88040058763
#> EM: Iteration : 103 || log-likelihood : -2001.35926477816
#> EM: Iteration : 104 || log-likelihood : -2000.57003100128
#> EM: Iteration : 105 || log-likelihood : -2000.13742634303
#> EM: Iteration : 106 || log-likelihood : -1998.8742667185
#> EM: Iteration : 107 || log-likelihood : -1997.9672441114
#> EM: Iteration : 108 || log-likelihood : -1997.53617878001
#> EM: Iteration : 109 || log-likelihood : -1996.26856906479
#> EM: Iteration : 110 || log-likelihood : -1995.29073069489
#> EM: Iteration : 111 || log-likelihood : -1994.96901833912
#> EM: Iteration : 112 || log-likelihood : -1994.04338389315
#> EM: Iteration : 113 || log-likelihood : -1992.93228304533
#> EM: Iteration : 114 || log-likelihood : -1992.58825334521
#> EM: Iteration : 115 || log-likelihood : -1992.08820485443
#> EM: Iteration : 116 || log-likelihood : -1990.99459284997
#> EM: Iteration : 117 || log-likelihood : -1990.39820233453
#> EM: Iteration : 118 || log-likelihood : -1990.25156085256
#> EM: Iteration : 119 || log-likelihood : -1990.02689844513
#> EM: Iteration : 120 || log-likelihood : -1989.4524459209
#> EM: Iteration : 121 || log-likelihood : -1988.77939887023
#> EM: Iteration : 122 || log-likelihood : -1988.43670301286
#> EM: Iteration : 123 || log-likelihood : -1988.05097380424
#> EM: Iteration : 124 || log-likelihood : -1987.13583867675
#> EM: Iteration : 125 || log-likelihood : -1986.24508709354
#> EM: Iteration : 126 || log-likelihood : -1985.66862327892
#> EM: Iteration : 127 || log-likelihood : -1984.91555844651
#> EM: Iteration : 128 || log-likelihood : -1984.02840365821
#> EM: Iteration : 129 || log-likelihood : -1983.69130067161
#> EM: Iteration : 130 || log-likelihood : -1983.59891631866
#> EM: Iteration : 131 || log-likelihood : -1983.46950685882
#> EM: Iteration : 132 || log-likelihood : -1983.16677154063
#> EM: Iteration : 133 || log-likelihood : -1982.7130488681
#> EM: Iteration : 134 || log-likelihood : -1982.36482921383
#> EM: Iteration : 135 || log-likelihood : -1982.09501016661
#> EM: Iteration : 136 || log-likelihood : -1981.45901315766
#> EM: Iteration : 137 || log-likelihood : -1980.56116931257
#> EM: Iteration : 138 || log-likelihood : -1979.78682525118
#> EM: Iteration : 139 || log-likelihood : -1978.57039689029
#> EM: Iteration : 140 || log-likelihood : -1977.62583903156
#> EM: Iteration : 141 || log-likelihood : -1976.44993964017
#> EM: Iteration : 142 || log-likelihood : -1975.34352117182
#> EM: Iteration : 143 || log-likelihood : -1973.94511304916
#> EM: Iteration : 144 || log-likelihood : -1972.69707782729
#> EM: Iteration : 145 || log-likelihood : -1971.24412635765
#> EM: Iteration : 146 || log-likelihood : -1970.06230181165
#> EM: Iteration : 147 || log-likelihood : -1968.63106242841
#> EM: Iteration : 148 || log-likelihood : -1967.54773416029
#> EM: Iteration : 149 || log-likelihood : -1966.19481640747
#> EM: Iteration : 150 || log-likelihood : -1965.07487280506
#> EM: Iteration : 151 || log-likelihood : -1963.69466194804
#> EM: Iteration : 152 || log-likelihood : -1962.43103040224
#> EM: Iteration : 153 || log-likelihood : -1961.13942311651
#> EM: Iteration : 154 || log-likelihood : -1959.76348415393
#> EM: Iteration : 155 || log-likelihood : -1958.66111557445
#> EM: Iteration : 156 || log-likelihood : -1957.08412155615
#> EM: Iteration : 157 || log-likelihood : -1956.38405033098
#> EM: Iteration : 158 || log-likelihood : -1955.13976323662
#> EM: Iteration : 159 || log-likelihood : -1954.0307602366
#> EM: Iteration : 160 || log-likelihood : -1953.28771131999
#> EM: Iteration : 161 || log-likelihood : -1951.68947232015
#> EM: Iteration : 162 || log-likelihood : -1950.97779043109
#> EM: Iteration : 163 || log-likelihood : -1950.82786273359
#> EM: Iteration : 164 || log-likelihood : -1950.39568293481
#> EM: Iteration : 165 || log-likelihood : -1949.51404624208
#> EM: Iteration : 166 || log-likelihood : -1948.906374824
#> EM: Iteration : 167 || log-likelihood : -1948.43487893552
#> EM: Iteration : 168 || log-likelihood : -1947.2118394595
#> EM: Iteration : 169 || log-likelihood : -1946.34871715855
#> EM: Iteration : 170 || log-likelihood : -1946.22041468711
#> EM: Iteration : 171 || log-likelihood : -1946.2132265072
#> EM: Iteration : 172 || log-likelihood : -1946.21315057723

rhlp$summary()
#> ---------------------
#> Fitted RHLP model
#> ---------------------
#> 
#> RHLP model with K = 5 components:
#> 
#>  log-likelihood nu       AIC       BIC       ICL
#>       -1946.213 33 -1979.213 -2050.683 -2050.449
#> 
#> Clustering table (Number of observations in each regimes):
#> 
#>   1   2   3   4   5 
#>  16 129 180 111 126 
#> 
#> Regression coefficients:
#> 
#>     Beta(K = 1) Beta(K = 2) Beta(K = 3) Beta(K = 4) Beta(K = 5)
#> 1      2187.539   330.05723   1508.2809 -13446.7332  6417.62830
#> X^1  -15032.659  -107.79782  -1648.9562  11321.4509 -3571.94090
#> X^2  -56433.432    14.40154    786.5723  -3062.2825   699.55894
#> X^3  494014.670    56.88016   -118.0693    272.7844   -45.42922
#> 
#> Variances:
#> 
#>  Sigma2(K = 1) Sigma2(K = 2) Sigma2(K = 3) Sigma2(K = 4) Sigma2(K = 5)
#>       8924.363      49.22616       78.2758      105.6606      15.66317

rhlp$plot()
```

<img src="man/figures/README-unnamed-chunk-7-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-7-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-7-3.png" style="display: block; margin: auto;" />

</details>

<details>

<summary>HMMR</summary>

``` r
# Application to a toy data set
data("univtoydataset")
x <- univtoydataset$x
y <- univtoydataset$y

K <- 5 # Number of regimes (states)
p <- 3 # Dimension of beta (order of the polynomial regressors)
variance_type <- "heteroskedastic" # "heteroskedastic" or "homoskedastic" model

n_tries <- 1
max_iter <- 1500
threshold <- 1e-6
verbose <- TRUE

hmmr <- emHMMR(X = x, Y = y, K, p, variance_type, 
               n_tries, max_iter, threshold, verbose)
#> EM: Iteration : 1 || log-likelihood : -1556.39696825601
#> EM: Iteration : 2 || log-likelihood : -1022.47935723687
#> EM: Iteration : 3 || log-likelihood : -1019.51830707432
#> EM: Iteration : 4 || log-likelihood : -1019.51780361388

hmmr$summary()
#> ---------------------
#> Fitted HMMR model
#> ---------------------
#> 
#> HMMR model with K = 5 components:
#> 
#>  log-likelihood nu       AIC       BIC
#>       -1019.518 49 -1068.518 -1178.946
#> 
#> Clustering table (Number of observations in each regimes):
#> 
#>   1   2   3   4   5 
#> 100 120 200 100 150 
#> 
#> Regression coefficients:
#> 
#>       Beta(K = 1) Beta(K = 2) Beta(K = 3) Beta(K = 4) Beta(K = 5)
#> 1    6.031872e-02   -5.326689    -2.65064    120.8612    3.858683
#> X^1 -7.424715e+00  157.189455    43.13601   -474.9870   13.757279
#> X^2  2.931651e+02 -643.706204   -92.68115    598.3726  -34.384734
#> X^3 -1.823559e+03  855.171715    66.18499   -244.5175   20.632196
#> 
#> Variances:
#> 
#>  Sigma2(K = 1) Sigma2(K = 2) Sigma2(K = 3) Sigma2(K = 4) Sigma2(K = 5)
#>       1.220624      1.111487      1.080043     0.9779724      1.028399

hmmr$plot(what = c("smoothed", "regressors", "loglikelihood"))
```

<img src="man/figures/README-unnamed-chunk-8-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-8-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-8-3.png" style="display: block; margin: auto;" />

``` r
# Application to a real data set
data("univrealdataset")
x <- univrealdataset$x
y <- univrealdataset$y2

K <- 5 # Number of regimes (states)
p <- 3 # Dimension of beta (order of the polynomial regressors)
variance_type <- "heteroskedastic" # "heteroskedastic" or "homoskedastic" model

n_tries <- 1
max_iter <- 1500
threshold <- 1e-6
verbose <- TRUE

hmmr <- emHMMR(X = x, Y = y, K, p, variance_type, 
               n_tries, max_iter, threshold, verbose)
#> EM: Iteration : 1 || log-likelihood : -2733.41028643114
#> EM: Iteration : 2 || log-likelihood : -2303.24018378559
#> EM: Iteration : 3 || log-likelihood : -2295.0470677529
#> EM: Iteration : 4 || log-likelihood : -2288.57866215726
#> EM: Iteration : 5 || log-likelihood : -2281.36756202518
#> EM: Iteration : 6 || log-likelihood : -2273.50303676091
#> EM: Iteration : 7 || log-likelihood : -2261.70334656117
#> EM: Iteration : 8 || log-likelihood : -2243.43509121433
#> EM: Iteration : 9 || log-likelihood : -2116.4610801575
#> EM: Iteration : 10 || log-likelihood : -2046.73194777839
#> EM: Iteration : 11 || log-likelihood : -2046.68328282973
#> EM: Iteration : 12 || log-likelihood : -2046.67329222076
#> EM: Iteration : 13 || log-likelihood : -2046.66915144265
#> EM: Iteration : 14 || log-likelihood : -2046.66694236131
#> EM: Iteration : 15 || log-likelihood : -2046.66563379017

hmmr$summary()
#> ---------------------
#> Fitted HMMR model
#> ---------------------
#> 
#> HMMR model with K = 5 components:
#> 
#>  log-likelihood nu       AIC       BIC
#>       -2046.666 49 -2095.666 -2201.787
#> 
#> Clustering table (Number of observations in each regimes):
#> 
#>   1   2   3   4   5 
#>  14 214  99 109 126 
#> 
#> Regression coefficients:
#> 
#>     Beta(K = 1) Beta(K = 2) Beta(K = 3) Beta(K = 4) Beta(K = 5)
#> 1       2152.64   379.75158   5211.1759 -14306.4654  6417.62823
#> X^1   -12358.67  -373.37266  -5744.7879  11987.6666 -3571.94086
#> X^2  -103908.33   394.49359   2288.9418  -3233.8021   699.55894
#> X^3   722173.26   -98.60485   -300.7686    287.4567   -45.42922
#> 
#> Variances:
#> 
#>  Sigma2(K = 1) Sigma2(K = 2) Sigma2(K = 3) Sigma2(K = 4) Sigma2(K = 5)
#>       9828.793      125.3346      58.71053      105.8328      15.66317

hmmr$plot(what = c("smoothed", "regressors", "loglikelihood"))
```

<img src="man/figures/README-unnamed-chunk-9-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-9-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-9-3.png" style="display: block; margin: auto;" />

</details>

<details>

<summary>PWR</summary>

``` r
# Application to a toy data set
data("univtoydataset")
x <- univtoydataset$x
y <- univtoydataset$y

K <- 5 # Number of segments
p <- 3 # Polynomial degree

pwr <- fitPWRFisher(X = x, Y = y, K, p)

pwr$summary()
#> --------------------
#> Fitted PWR model
#> --------------------
#> 
#> PWR model with K = 5 components:
#> 
#> Clustering table (Number of observations in each regimes):
#> 
#>   1   2   3   4   5 
#> 100 120 200 100 150 
#> 
#> Regression coefficients:
#> 
#>       Beta(K = 1) Beta(K = 2) Beta(K = 3) Beta(K = 4) Beta(K = 5)
#> 1    6.106872e-02   -5.450955   -2.776275    122.7045    4.020809
#> X^1 -7.486945e+00  158.922010   43.915969   -482.8929   13.217587
#> X^2  2.942201e+02 -651.540876  -94.269414    609.6493  -33.787416
#> X^3 -1.828308e+03  866.675017   67.247141   -249.8667   20.412380
#> 
#> Variances:
#> 
#>  Sigma2(K = 1) Sigma2(K = 2) Sigma2(K = 3) Sigma2(K = 4) Sigma2(K = 5)
#>       1.220624      1.110193      1.079366     0.9779733      1.028329

pwr$plot()
```

<img src="man/figures/README-unnamed-chunk-10-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-10-2.png" style="display: block; margin: auto;" />

``` r
# Application to a real data set
data("univrealdataset")
x <- univrealdataset$x
y <- univrealdataset$y2

K <- 5 # Number of segments
p <- 3 # Polynomial degree

pwr <- fitPWRFisher(X = x, Y = y, K, p)

pwr$summary()
#> --------------------
#> Fitted PWR model
#> --------------------
#> 
#> PWR model with K = 5 components:
#> 
#> Clustering table (Number of observations in each regimes):
#> 
#>   1   2   3   4   5 
#>  15 130 178 113 126 
#> 
#> Regression coefficients:
#> 
#>     Beta(K = 1) Beta(K = 2) Beta(K = 3) Beta(K = 4) Beta(K = 5)
#> 1      2163.323   334.23747   1458.6530 -11445.9003  6418.36449
#> X^1  -13244.753  -125.04633  -1578.1793   9765.9713 -3572.38535
#> X^2  -86993.374    35.33532    753.8468  -2660.5976   699.64809
#> X^3  635558.069    49.12683   -113.1589    238.3246   -45.43516
#> 
#> Variances:
#> 
#>  Sigma2(K = 1) Sigma2(K = 2) Sigma2(K = 3) Sigma2(K = 4) Sigma2(K = 5)
#>       9326.335      50.71573      75.23989      110.6818      15.66317

pwr$plot()
```

<img src="man/figures/README-unnamed-chunk-11-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-11-2.png" style="display: block; margin: auto;" />

</details>

<details>

<summary>MRHLP</summary>

``` r
# Application to a toy data set
data("multivtoydataset")
x <- multivtoydataset$x
y <- multivtoydataset[,c("y1", "y2", "y3")]

K <- 5 # Number of regimes (mixture components)
p <- 1 # Dimension of beta (order of the polynomial regressors)
q <- 1 # Dimension of w (order of the logistic regression: to be set to 1 for segmentation)
variance_type <- "heteroskedastic" # "heteroskedastic" or "homoskedastic" model

n_tries <- 1
max_iter <- 1500
threshold <- 1e-6
verbose <- TRUE
verbose_IRLS <- FALSE

mrhlp <- emMRHLP(X = x, Y = y, K, p, q, variance_type, n_tries, 
                 max_iter, threshold, verbose, verbose_IRLS)
#> EM: Iteration : 1 || log-likelihood : -4807.6644322901
#> EM: Iteration : 2 || log-likelihood : -3314.25165556383
#> EM: Iteration : 3 || log-likelihood : -3216.8871750704
#> EM: Iteration : 4 || log-likelihood : -3126.33556053822
#> EM: Iteration : 5 || log-likelihood : -2959.59933830667
#> EM: Iteration : 6 || log-likelihood : -2895.65953485704
#> EM: Iteration : 7 || log-likelihood : -2892.93263500326
#> EM: Iteration : 8 || log-likelihood : -2889.34084959654
#> EM: Iteration : 9 || log-likelihood : -2884.56422084139
#> EM: Iteration : 10 || log-likelihood : -2878.29772085061
#> EM: Iteration : 11 || log-likelihood : -2870.61242183846
#> EM: Iteration : 12 || log-likelihood : -2862.86238149363
#> EM: Iteration : 13 || log-likelihood : -2856.85351443338
#> EM: Iteration : 14 || log-likelihood : -2851.74642203885
#> EM: Iteration : 15 || log-likelihood : -2850.00381259526
#> EM: Iteration : 16 || log-likelihood : -2849.86516522686
#> EM: Iteration : 17 || log-likelihood : -2849.7354103643
#> EM: Iteration : 18 || log-likelihood : -2849.56953544124
#> EM: Iteration : 19 || log-likelihood : -2849.40322468732
#> EM: Iteration : 20 || log-likelihood : -2849.40321381274

mrhlp$summary()
#> ----------------------
#> Fitted MRHLP model
#> ----------------------
#> 
#> MRHLP model with K = 5 regimes
#> 
#>  log-likelihood nu       AIC       BIC       ICL
#>       -2849.403 68 -2917.403 -3070.651 -3069.896
#> 
#> Clustering table:
#>   1   2   3   4   5 
#> 100 120 200 100 150 
#> 
#> 
#> ------------------
#> Regime 1 (K = 1):
#> 
#> Regression coefficients:
#> 
#>     Beta(d = 1) Beta(d = 2) Beta(d = 3)
#> 1    0.11943184   0.6087582   -2.038486
#> X^1 -0.08556857   4.1038126    2.540536
#> 
#> Covariance matrix:
#>                                    
#>  1.19063336  0.12765794  0.05537134
#>  0.12765794  0.87144062 -0.05213162
#>  0.05537134 -0.05213162  0.87885166
#> ------------------
#> Regime 2 (K = 2):
#> 
#> Regression coefficients:
#> 
#>     Beta(d = 1) Beta(d = 2) Beta(d = 3)
#> 1      6.924025   4.9368460   10.288339
#> X^1    1.118034   0.4726707   -1.409218
#> 
#> Covariance matrix:
#>                                   
#>   1.0690431 -0.18293369 0.12602459
#>  -0.1829337  1.05280632 0.01390041
#>   0.1260246  0.01390041 0.75995058
#> ------------------
#> Regime 3 (K = 3):
#> 
#> Regression coefficients:
#> 
#>     Beta(d = 1) Beta(d = 2) Beta(d = 3)
#> 1     3.6535241   6.3654379    8.488318
#> X^1   0.6233579  -0.8866887   -1.126692
#> 
#> Covariance matrix:
#>                                     
#>   1.02591553 -0.05445227 -0.02019896
#>  -0.05445227  1.18941700  0.01565240
#>  -0.02019896  0.01565240  1.00257195
#> ------------------
#> Regime 4 (K = 4):
#> 
#> Regression coefficients:
#> 
#>     Beta(d = 1) Beta(d = 2) Beta(d = 3)
#> 1     -1.439637   -4.463014    2.952470
#> X^1    0.703211    3.649717   -4.187703
#> 
#> Covariance matrix:
#>                                     
#>   0.88000190 -0.03249118 -0.03411075
#>  -0.03249118  1.12087583 -0.07881351
#>  -0.03411075 -0.07881351  0.86060127
#> ------------------
#> Regime 5 (K = 5):
#> 
#> Regression coefficients:
#> 
#>     Beta(d = 1) Beta(d = 2) Beta(d = 3)
#> 1     3.4982408   2.5357751    7.652113
#> X^1   0.0574791  -0.7286824   -3.005802
#> 
#> Covariance matrix:
#>                                  
#>  1.13330209 0.25869951 0.03163467
#>  0.25869951 1.21230741 0.04746018
#>  0.03163467 0.04746018 0.80241715

mrhlp$plot()
```

<img src="man/figures/README-unnamed-chunk-12-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-12-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-12-3.png" style="display: block; margin: auto;" />

``` r
# Application to a real data set (human activity recogntion data)
data("multivrealdataset")
x <- multivrealdataset$x
y <- multivrealdataset[,c("y1", "y2", "y3")]

K <- 5 # Number of regimes (mixture components)
p <- 3 # Dimension of beta (order of the polynomial regressors)
q <- 1 # Dimension of w (order of the logistic regression: to be set to 1 for segmentation)
variance_type <- "heteroskedastic" # "heteroskedastic" or "homoskedastic" model

n_tries <- 1
max_iter <- 1500
threshold <- 1e-6
verbose <- TRUE
verbose_IRLS <- FALSE

mrhlp <- emMRHLP(X = x, Y = y, K, p, q, variance_type, n_tries, 
                 max_iter, threshold, verbose, verbose_IRLS)
#> EM: Iteration : 1 || log-likelihood : -792.888668727036
#> EM: Iteration : 2 || log-likelihood : 6016.45835957306
#> EM: Iteration : 3 || log-likelihood : 6362.81791662824
#> EM: Iteration : 4 || log-likelihood : 6615.72233403002
#> EM: Iteration : 5 || log-likelihood : 6768.32107943849
#> EM: Iteration : 6 || log-likelihood : 6840.97339565987
#> EM: Iteration : 7 || log-likelihood : 6860.97262839295
#> EM: Iteration : 8 || log-likelihood : 6912.25605673784
#> EM: Iteration : 9 || log-likelihood : 6945.96718258737
#> EM: Iteration : 10 || log-likelihood : 6951.28584396645
#> EM: Iteration : 11 || log-likelihood : 6952.37644678517
#> EM: Iteration : 12 || log-likelihood : 6954.80510338749
#> EM: Iteration : 13 || log-likelihood : 6958.99033092484
#> EM: Iteration : 14 || log-likelihood : 6964.81099837456
#> EM: Iteration : 15 || log-likelihood : 6999.90358068156
#> EM: Iteration : 16 || log-likelihood : 7065.39327246318
#> EM: Iteration : 17 || log-likelihood : 7166.23398344994
#> EM: Iteration : 18 || log-likelihood : 7442.73330846285
#> EM: Iteration : 19 || log-likelihood : 7522.65416438396
#> EM: Iteration : 20 || log-likelihood : 7524.41524338024
#> EM: Iteration : 21 || log-likelihood : 7524.57590110924
#> EM: Iteration : 22 || log-likelihood : 7524.73808801417
#> EM: Iteration : 23 || log-likelihood : 7524.88684996651
#> EM: Iteration : 24 || log-likelihood : 7524.9753964817
#> EM: Iteration : 25 || log-likelihood : 7524.97701548847

mrhlp$summary()
#> ----------------------
#> Fitted MRHLP model
#> ----------------------
#> 
#> MRHLP model with K = 5 regimes
#> 
#>  log-likelihood nu      AIC      BIC      ICL
#>        7524.977 98 7426.977 7146.696 7147.535
#> 
#> Clustering table:
#>   1   2   3   4   5 
#> 413 344 588 423 485 
#> 
#> 
#> ------------------
#> Regime 1 (K = 1):
#> 
#> Regression coefficients:
#> 
#>     Beta(d = 1) Beta(d = 2) Beta(d = 3)
#> 1    1.64847721  2.33823068  9.40173242
#> X^1 -0.31396583  0.38235782 -0.10031616
#> X^2  0.23954454 -0.30105177  0.07812145
#> X^3 -0.04725267  0.06166899 -0.01586579
#> 
#> Covariance matrix:
#>                                          
#>   0.0200740364 -0.004238036  0.0004011388
#>  -0.0042380363  0.006082904 -0.0012973026
#>   0.0004011388 -0.001297303  0.0013201963
#> ------------------
#> Regime 2 (K = 2):
#> 
#> Regression coefficients:
#> 
#>      Beta(d = 1) Beta(d = 2)  Beta(d = 3)
#> 1   -106.0250571 -31.4671946 -107.9697464
#> X^1   45.2035210  21.2126134   72.0220177
#> X^2   -5.7330338  -4.1285514  -13.9857795
#> X^3    0.2343552   0.2485377    0.8374817
#> 
#> Covariance matrix:
#>                                     
#>   0.11899225 -0.03866052 -0.06693441
#>  -0.03866052  0.17730401  0.04036629
#>  -0.06693441  0.04036629  0.11983979
#> ------------------
#> Regime 3 (K = 3):
#> 
#> Regression coefficients:
#> 
#>       Beta(d = 1)  Beta(d = 2)  Beta(d = 3)
#> 1    9.0042249443 -1.247752962 -2.492119515
#> X^1  0.2191555621  0.418071041  0.310449523
#> X^2 -0.0242080660 -0.043802827 -0.039012607
#> X^3  0.0008494208  0.001474635  0.001427627
#> 
#> Covariance matrix:
#>                                          
#>   4.103351e-04 -0.0001330363 5.289199e-05
#>  -1.330363e-04  0.0006297205 2.027763e-04
#>   5.289199e-05  0.0002027763 1.374405e-03
#> ------------------
#> Regime 4 (K = 4):
#> 
#> Regression coefficients:
#> 
#>       Beta(d = 1) Beta(d = 2)  Beta(d = 3)
#> 1   -1029.9071752 334.4975068  466.0981076
#> X^1   199.9531885 -68.7252041 -105.6436899
#> X^2   -12.6550086   4.6489685    7.6555642
#> X^3     0.2626998  -0.1032161   -0.1777453
#> 
#> Covariance matrix:
#>                                       
#>   0.058674116 -0.017661572 0.002139975
#>  -0.017661572  0.047588713 0.007867532
#>   0.002139975  0.007867532 0.067150809
#> ------------------
#> Regime 5 (K = 5):
#> 
#> Regression coefficients:
#> 
#>      Beta(d = 1)   Beta(d = 2)  Beta(d = 3)
#> 1   27.247199195 -14.393798357 19.741283724
#> X^1 -3.530625667   2.282492947 -1.511225702
#> X^2  0.161234880  -0.101613670  0.073003292
#> X^3 -0.002446104   0.001490288 -0.001171127
#> 
#> Covariance matrix:
#>                                          
#>   6.900384e-03 -0.001176838  2.966199e-05
#>  -1.176838e-03  0.003596238 -2.395420e-04
#>   2.966199e-05 -0.000239542  5.573451e-04

mrhlp$plot()
```

<img src="man/figures/README-unnamed-chunk-13-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-13-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-13-3.png" style="display: block; margin: auto;" />

</details>

<details>

<summary>MHMMR</summary>

``` r
# Application to a simulated data set
data("multivtoydataset")
x <- multivtoydataset$x
y <- multivtoydataset[,c("y1", "y2", "y3")]

K <- 5 # Number of regimes (states)
p <- 1 # Dimension of beta (order of the polynomial regressors)
variance_type <- "heteroskedastic" # "heteroskedastic" or "homoskedastic" model

n_tries <- 1
max_iter <- 1500
threshold <- 1e-6
verbose <- TRUE

mhmmr <- emMHMMR(X = x, Y = y, K, p, variance_type, n_tries, 
                 max_iter, threshold, verbose)
#> EM: Iteration : 1 || log-likelihood : -4539.37845473736
#> EM: Iteration : 2 || log-likelihood : -3075.7862970485
#> EM: Iteration : 3 || log-likelihood : -2904.71126233611
#> EM: Iteration : 4 || log-likelihood : -2883.23456594806
#> EM: Iteration : 5 || log-likelihood : -2883.12446634454
#> EM: Iteration : 6 || log-likelihood : -2883.12436399888

mhmmr$summary()
#> ----------------------
#> Fitted MHMMR model
#> ----------------------
#> 
#> MHMMR model with K = 5 regimes
#> 
#>  log-likelihood nu       AIC      BIC
#>       -2883.124 84 -2967.124 -3156.43
#> 
#> Clustering table:
#>   1   2   3   4   5 
#> 100 120 200 100 150 
#> 
#> 
#> ------------------
#> Regime 1 (K = 1):
#> 
#> Regression coefficients:
#> 
#>     Beta(d = 1) Beta(d = 2) Beta(d = 3)
#> 1    0.11943184   0.6087582   -2.038486
#> X^1 -0.08556857   4.1038126    2.540536
#> 
#> Covariance matrix:
#>                                    
#>  1.19064336  0.12765794  0.05537134
#>  0.12765794  0.87145062 -0.05213162
#>  0.05537134 -0.05213162  0.87886166
#> ------------------
#> Regime 2 (K = 2):
#> 
#> Regression coefficients:
#> 
#>     Beta(d = 1) Beta(d = 2) Beta(d = 3)
#> 1      6.921139   4.9377164   10.290536
#> X^1    1.131946   0.4684922   -1.419758
#> 
#> Covariance matrix:
#>                                   
#>   1.0688949 -0.18240787 0.12675972
#>  -0.1824079  1.05317924 0.01419686
#>   0.1267597  0.01419686 0.76030310
#> ------------------
#> Regime 3 (K = 3):
#> 
#> Regression coefficients:
#> 
#>     Beta(d = 1) Beta(d = 2) Beta(d = 3)
#> 1     3.6576562   6.3642526    8.493765
#> X^1   0.6155173  -0.8844373   -1.137027
#> 
#> Covariance matrix:
#>                                     
#>   1.02647251 -0.05491451 -0.01930098
#>  -0.05491451  1.18921808  0.01510035
#>  -0.01930098  0.01510035  1.00352482
#> ------------------
#> Regime 4 (K = 4):
#> 
#> Regression coefficients:
#> 
#>     Beta(d = 1) Beta(d = 2) Beta(d = 3)
#> 1     -1.439637   -4.463014    2.952470
#> X^1    0.703211    3.649717   -4.187703
#> 
#> Covariance matrix:
#>                                     
#>   0.88001190 -0.03249118 -0.03411075
#>  -0.03249118  1.12088583 -0.07881351
#>  -0.03411075 -0.07881351  0.86061127
#> ------------------
#> Regime 5 (K = 5):
#> 
#> Regression coefficients:
#> 
#>     Beta(d = 1) Beta(d = 2) Beta(d = 3)
#> 1     3.4982408   2.5357751    7.652113
#> X^1   0.0574791  -0.7286824   -3.005802
#> 
#> Covariance matrix:
#>                                  
#>  1.13331209 0.25869951 0.03163467
#>  0.25869951 1.21231741 0.04746018
#>  0.03163467 0.04746018 0.80242715

mhmmr$plot(what = c("smoothed", "regressors", "loglikelihood"))
```

<img src="man/figures/README-unnamed-chunk-14-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-14-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-14-3.png" style="display: block; margin: auto;" />

``` r
# Application to a real data set (human activity recognition data)
data("multivrealdataset")
x <- multivrealdataset$x
y <- multivrealdataset[,c("y1", "y2", "y3")]

K <- 5 # Number of regimes (states)
p <- 3 # Dimension of beta (order of the polynomial regressors)
variance_type <- "heteroskedastic" # "heteroskedastic" or "homoskedastic" model

n_tries <- 1
max_iter <- 1500
threshold <- 1e-6
verbose <- TRUE

mhmmr <- emMHMMR(X = x, Y = y, K, p, variance_type, n_tries, 
                 max_iter, threshold, verbose)
#> EM: Iteration : 1 || log-likelihood : 817.206309249687
#> EM: Iteration : 2 || log-likelihood : 1793.49320726452
#> EM: Iteration : 3 || log-likelihood : 1908.47251424374
#> EM: Iteration : 4 || log-likelihood : 2006.7976746047
#> EM: Iteration : 5 || log-likelihood : 3724.91911814713
#> EM: Iteration : 6 || log-likelihood : 3846.02584774854
#> EM: Iteration : 7 || log-likelihood : 3957.04953794437
#> EM: Iteration : 8 || log-likelihood : 4008.60804596975
#> EM: Iteration : 9 || log-likelihood : 4011.09964067314
#> EM: Iteration : 10 || log-likelihood : 4014.35810165377
#> EM: Iteration : 11 || log-likelihood : 4026.38632031497
#> EM: Iteration : 12 || log-likelihood : 4027.13758668835
#> EM: Iteration : 13 || log-likelihood : 4027.13639613206

mhmmr$summary()
#> ----------------------
#> Fitted MHMMR model
#> ----------------------
#> 
#> MHMMR model with K = 5 regimes
#> 
#>  log-likelihood  nu      AIC      BIC
#>        4027.136 114 3913.136 3587.095
#> 
#> Clustering table:
#>   1   2   3   4   5 
#> 461 297 587 423 485 
#> 
#> 
#> ------------------
#> Regime 1 (K = 1):
#> 
#> Regression coefficients:
#> 
#>     Beta(d = 1) Beta(d = 2)  Beta(d = 3)
#> 1    1.41265303  2.42222746  9.381994682
#> X^1  0.47242692  0.09217574 -0.023282898
#> X^2 -0.28135064 -0.10169173  0.018998710
#> X^3  0.04197568  0.02620151 -0.004217078
#> 
#> Covariance matrix:
#>                                       
#>   0.12667921 -0.019381009 -0.018810846
#>  -0.01938101  0.109202105 -0.001402791
#>  -0.01881085 -0.001402791  0.026461790
#> ------------------
#> Regime 2 (K = 2):
#> 
#> Regression coefficients:
#> 
#>     Beta(d = 1) Beta(d = 2) Beta(d = 3)
#> 1    -3.6868321   2.4724043    7.794639
#> X^1  -6.8471097   4.6786664   14.749215
#> X^2   2.9742521  -1.4716819   -4.646020
#> X^3  -0.2449644   0.1076065    0.335142
#> 
#> Covariance matrix:
#>                                      
#>   0.22604244 -0.032716477 0.013626769
#>  -0.03271648  0.032475350 0.008585402
#>   0.01362677  0.008585402 0.041960228
#> ------------------
#> Regime 3 (K = 3):
#> 
#> Regression coefficients:
#> 
#>      Beta(d = 1)  Beta(d = 2)   Beta(d = 3)
#> 1    0.776245522  0.014437427 -0.1144683124
#> X^1  2.627158141  0.048519275 -0.3883099866
#> X^2 -0.255314738 -0.008318957  0.0283047828
#> X^3  0.008129981  0.000356239 -0.0007003718
#> 
#> Covariance matrix:
#>                                           
#>   0.0012000978 -0.0002523608 -0.0001992900
#>  -0.0002523608  0.0006584694  0.0002391577
#>  -0.0001992900  0.0002391577  0.0014228769
#> ------------------
#> Regime 4 (K = 4):
#> 
#> Regression coefficients:
#> 
#>      Beta(d = 1)   Beta(d = 2)  Beta(d = 3)
#> 1    0.002894474 -0.0002900823 -0.001513232
#> X^1  0.029936273 -0.0029993910 -0.015647636
#> X^2  0.232798943 -0.0233058753 -0.121611904
#> X^3 -0.013209774  0.0019141508  0.009151938
#> 
#> Covariance matrix:
#>                                     
#>   0.21455830 -0.07328139 -0.08824736
#>  -0.07328139  0.17055704  0.45218611
#>  -0.08824736  0.45218611  1.76616982
#> ------------------
#> Regime 5 (K = 5):
#> 
#> Regression coefficients:
#> 
#>       Beta(d = 1)   Beta(d = 2)   Beta(d = 3)
#> 1    9.416685e-05  0.0001347198  0.0005119141
#> X^1  1.259159e-03  0.0018014389  0.0068451694
#> X^2  1.265758e-02  0.0181095390  0.0688126905
#> X^3 -4.344666e-04 -0.0005920827 -0.0022723501
#> 
#> Covariance matrix:
#>                                       
#>   0.009259719 -0.000696446 0.006008102
#>  -0.000696446  0.003732296 0.001056145
#>   0.006008102  0.001056145 0.016144263

mhmmr$plot(what = c("smoothed", "regressors", "loglikelihood"))
```

<img src="man/figures/README-unnamed-chunk-15-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-15-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-15-3.png" style="display: block; margin: auto;" />

</details>

# Model selection

samurais also implements model selection procedures to select an optimal
model based on information criteria including **BIC**, **AIC** and
**ICL**.

The selection can be done for the two following parameters:

  - **K**: The number of regimes (segments);
  - **p**: The order of the polynomial regression.

Instructions below can be used to illustrate the model on provided
simulated and real data sets.

<details>

<summary>RHLP</summary>

Let’s select a RHLP model for the following time series:

``` r
data("univtoydataset")
x = univtoydataset$x
y = univtoydataset$y

plot(x, y, type = "l", xlab = "x", ylab = "Y")
```

<img src="man/figures/README-unnamed-chunk-16-1.png" style="display: block; margin: auto;" />

``` r
selectedrhlp <- selectRHLP(X = x, Y = y, Kmin = 2, Kmax = 6, pmin = 0, pmax = 3)
#> The RHLP model selected via the "BIC" has K = 5 regimes 
#>  and the order of the polynomial regression is p = 0.
#> BIC = -1041.40789532438
#> AIC = -1000.84239591291

selectedrhlp$plot(what = "estimatedsignal")
```

<img src="man/figures/README-unnamed-chunk-17-1.png" style="display: block; margin: auto;" />

</details>

<details>

<summary>HMMR</summary>

Let’s select a HMMR model for the following time series:

``` r
data("univtoydataset")
x = univtoydataset$x
y = univtoydataset$y

plot(x, y, type = "l", xlab = "x", ylab = "Y")
```

<img src="man/figures/README-unnamed-chunk-18-1.png" style="display: block; margin: auto;" />

``` r
selectedhmmr <- selectHMMR(X = x, Y = y, Kmin = 2, Kmax = 6, pmin = 0, pmax = 3)
#> The HMMR model selected via the "BIC" has K = 5 regimes 
#>  and the order of the polynomial regression is p = 0.
#> BIC = -1136.39152222095
#> AIC = -1059.76780111041

selectedhmmr$plot(what = "smoothed")
```

<img src="man/figures/README-unnamed-chunk-19-1.png" style="display: block; margin: auto;" />

</details>

<details>

<summary>MRHLP</summary>

Let’s select a MRHLP model for the following multivariate time series:

<br />

``` r
data("multivtoydataset")
x <- multivtoydataset$x
y <- multivtoydataset[, c("y1", "y2", "y3")]
matplot(x, y, type = "l", xlab = "x", ylab = "Y", lty = 1)
```

<img src="man/figures/README-unnamed-chunk-20-1.png" style="display: block; margin: auto;" />

``` r
selectedmrhlp <- selectMRHLP(X = x, Y = y, Kmin = 2, Kmax = 6, pmin = 0, pmax = 3)
#> Warning in emMRHLP(X = X1, Y = Y1, K, p): EM log-likelihood is decreasing from
#> -3105.78591044952to -3105.78627830471 !
#> The MRHLP model selected via the "BIC" has K = 5 regimes 
#>  and the order of the polynomial regression is p = 0.
#> BIC = -3033.20042397111
#> AIC = -2913.75756459291

selectedmrhlp$plot(what = "estimatedsignal")
```

<img src="man/figures/README-unnamed-chunk-21-1.png" style="display: block; margin: auto;" />

</details>

<details>

<summary>MHMMR</summary>

Let’s select a MHMMR model for the following multivariate time series:

``` r
data("multivtoydataset")
x <- multivtoydataset$x
y <- multivtoydataset[, c("y1", "y2", "y3")]
matplot(x, y, type = "l", xlab = "x", ylab = "Y", lty = 1)
```

<img src="man/figures/README-unnamed-chunk-22-1.png" style="display: block; margin: auto;" />

``` r
selectedmhmmr <- selectMHMMR(X = x, Y = y, Kmin = 2, Kmax = 6, pmin = 0, pmax = 3)
#> The MHMMR model selected via the "BIC" has K = 5 regimes 
#>  and the order of the polynomial regression is p = 0.
#> BIC = -3118.9815385353
#> AIC = -2963.48045745801

selectedmhmmr$plot(what = "smoothed")
```

<img src="man/figures/README-unnamed-chunk-23-1.png" style="display: block; margin: auto;" />

</details>

# References

<div id="refs" class="references">

<div id="ref-Chamroukhi-FDA-2018">

Chamroukhi, Faicel, and Hien D. Nguyen. 2019. “Model-Based Clustering
and Classification of Functional Data.” *Wiley Interdisciplinary
Reviews: Data Mining and Knowledge Discovery*.
<https://chamroukhi.com/papers/MBCC-FDA.pdf>.

</div>

<div id="ref-Chamroukhi-HDR-2015">

Chamroukhi, F. 2015. “Statistical Learning of Latent Data Models for
Complex Data Analysis.” Habilitation Thesis (HDR), Université de Toulon.
<https://chamroukhi.com/FChamroukhi-HDR.pdf>.

</div>

<div id="ref-Chamroukhi-MHMMR-2013">

Trabelsi, D., S. Mohammed, F. Chamroukhi, L. Oukhellou, and Y. Amirat.
2013. “An Unsupervised Approach for Automatic Activity Recognition Based
on Hidden Markov Model Regression.” *IEEE Transactions on Automation
Science and Engineering* 3 (10): 829–335.
<https://chamroukhi.com/papers/Chamroukhi-MHMMR-IeeeTase.pdf>.

</div>

<div id="ref-Chamroukhi-MRHLP-2013">

Chamroukhi, F., D. Trabelsi, S. Mohammed, L. Oukhellou, and Y. Amirat.
2013. “Joint Segmentation of Multivariate Time Series with Hidden
Process Regression for Human Activity Recognition.” *Neurocomputing*
120: 633–44.
<https://chamroukhi.com/papers/chamroukhi_et_al_neucomp2013b.pdf>.

</div>

<div id="ref-chamroukhi_et_al_neurocomp2010">

Chamroukhi, F., A. Samé, G. Govaert, and P. Aknin. 2010. “A Hidden
Process Regression Model for Functional Data Description. Application to
Curve Discrimination.” *Neurocomputing* 73 (7-9): 1210–21.
<https://chamroukhi.com/papers/chamroukhi_neucomp_2010.pdf>.

</div>

<div id="ref-Chamroukhi_PhD_2010">

Chamroukhi, F. 2010. “Hidden Process Regression for Curve Modeling,
Classification and Tracking.” Ph.D. Thesis, Université de Technologie de
Compiègne. <https://chamroukhi.com/FChamroukhi-PhD.pdf>.

</div>

<div id="ref-chamroukhi_et_al_NN2009">

Chamroukhi, F., A. Samé, G. Govaert, and P. Aknin. 2009. “Time Series
Modeling by a Regression Approach Based on a Latent Process.” *Neural
Networks* 22 (5-6): 593–602.
<https://chamroukhi.com/papers/Chamroukhi_Neural_Networks_2009.pdf>.

</div>

</div>
