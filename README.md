
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cryogenic

<!-- badges: start -->

![](https://img.shields.io/badge/cool-useless-green.svg) [![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

`cryogenic` is a package for freezing a function call, modifying its
arguments and then evaluating later.

This package is written for a particular use case I have in mind, and
may not be generally applicable. The functions are all in base R and
quite small, and the reasoning for having this in a package is
*consistency* of the interface.

See [rlang](https://cran.r-project.org/package=rlang) for a much more
comprehensive and generalisable approach.

## My Use Case

  - Both the calling environment and evaluation environment are under my
    control.
      - I am not executing captured calls based on user input.
  - Need an R package for this as I need to use this code across
    multiple packages
  - Need eager evaluation of arguments when call is captured
  - Need to be able to update any arguments
      - Need to be able to update an argument to have a value of `NULL`
  - Need to be able to set arguments to a default value if they aren’t
    already present
  - Nearly everything is in lists
  - Need to be able to consistently add arbitrary `meta` information as
    an attribute on the call
  - There are probably other constraints which I’ll add as I think of
    them

## What’s in the box

  - `capture_call()` to capture a call without evaluating it
  - `modify_call()` to modify call arguments
  - `evaluate_call()` to evaluate a call - and optionally modify the
    call arguments just prior to the evaluation.

## Installation

You can install from
[GitHub](https://github.com/coolbutuseless/cryogenic) with:

``` r
# install.package('remotes')
remotes::install_github('coolbutuseless/cryogenic')
```

## Simple example 1

  - capture a call
  - modify the call
  - evaluate the call

<!-- end list -->

``` r
library(cryogenic)

cc <- capture_call(runif(n = 10, min=-3))
cc
```

    #> runif(n = 10, min = -3)

``` r
cc <- modify_call(cc, defaults = list(min=0, max=5), update = list(n = 5))
cc
```

    #> runif(n = 5, min = -3, max = 5)

``` r
evaluate_call(cc)
```

    #> [1] -0.8759307 -0.0230088  1.5828269  4.2656623 -1.3865446

## Simple example 2

  - capture a call
  - simultaneously update a call and evalute it

<!-- end list -->

``` r
library(cryogenic)

cc <- capture_call(runif(n = 10, min=-3))
cc
```

    #> runif(n = 10, min = -3)

``` r
evaluate_call(cc, defaults = list(min=0, max=5), update = list(n = 15))
```

    #>  [1]  4.18711748  4.55740215  2.28638234  2.03291235 -2.50570984 -1.35220340
    #>  [7] -1.58754598  2.49618277  0.07282975  3.15873136  0.98159394  2.74094807
    #> [13]  4.93524876  0.04028144  3.21956177

## Simple example 3

``` r
library(cryogenic)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Capture a call as-is.
#
# * the function does not have to exist in the capturing environment
# * By default, all arguments are eagerly evaluated in the environment in which
#   the call was captured
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cc <- capture_call(farnarkle(6, x = 2, y = 3, z = 2+9, error = TRUE))
cc
```

    #> farnarkle(6, x = 2, y = 3, z = 11, error = TRUE)

``` r
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Update the arguments to the call
#
# * 'defaults' are only added to the arguments if the named argument does 
#    not already exist there.
# * 'update' values are added to the arguments unconditionally
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cc <- modify_call(
  cc, 
  defaults = list(x = NULL, y = 7), 
  update   = list(z = NULL, na.rm = TRUE),
  delete   = c('error')
)

cc
```

    #> farnarkle(6, x = 2, y = 3, z = NULL, na.rm = TRUE)

``` r
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 'farnarkle' is not yet defined, so evaluation should fail
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
evaluate_call(cc)
```

    #> Error in farnarkle(6, x = 2, y = 3, z = NULL, na.rm = TRUE): could not find function "farnarkle"

``` r
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# define farnarkle and it should work
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
farnarkle <- function(...) {print("Hello #Rstats")}
evaluate_call(cc)
```

    #> [1] "Hello #Rstats"

## Related Software

  - `rlang` offers a lot of tools for call modification, but wasn’t
    quite a match for how I’m working.
  - `pryr::modify_call()` is similar to what is done in this package,
    but `cryogenic` offers a few more features I need.

## Acknowledgements

  - R Core for developing and maintaining the language.
  - CRAN maintainers, for patiently shepherding packages onto CRAN and
    maintaining the repository
