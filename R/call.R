

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Check a list is either empty or fully named
#'
#' @param ll list
#'
#' @return logical
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
is_fully_named_list <- function(ll) {
  nn <- names(ll)
  is.list(ll) &&
    ((length(ll) == 0) ||
     (!is.null(nn) && !anyNA(nn) && !any(nn == '')))
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Add named arguments to the current list
#'
#' @param current current list
#' @param update named list of items to update
#'
#' @return new list with all elements of update added to current
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
modify_list <- function (current, update) {
  stopifnot(is_fully_named_list(update))
  for (i in names(update)) {
    current[i] <- list(update[[i]])
  }
  current
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Add named arguments to the current list only if they do not already exist
#'
#' @param current current list
#' @param update named list of items to update
#'
#' @return new list with elements of update added to current if there isn't
#' already an element of that name
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
add_items_if_not_present <- function(current, update) {
  stopifnot(is_fully_named_list(update))
  new_names <- setdiff(names(update), names(current))
  new_names <- new_names[nzchar(new_names)]
  for (i in new_names) {
    current[i] <- list(update[[i]])
  }
  current
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Capture the first argument as a call to save for later
#'
#' Eagerly evaluate all arguments
#'
#' @param eager Eagerly evaluate the arguments to the call. Default: TRUE
#' @param meta A list of information that may be needed to support the call
#'        before/after its actual evaluation. This is stored as the
#'        'meta' attribute on the call object itself.  The handling of the
#'        meta results during evaluation is user-defined, and nothing is done
#'        automatically.
#' @param envir if \code{eager = TRUE} this is the environment for evaluation
#'        of the arguments. Default: \code{parent.frame()} i.e. the environment which
#'        initiated the \code{capture_call()}
#' @param standardise standardise the call arguments. default: FALSE.  Setting to
#'        true will try and evaluate the argument in the calling environment.
#' @inheritParams modify_call
#'
#' @examples
#' cc <- capture_call(mean(x = c(1, 2, 3)), meta = list(var = 'x'))
#' var_name <- attr(cc, 'meta')$var
#' assign(var_name, evaluate_call(cc))
#' var_name
#' x
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
capture_call <- function(x, meta = NULL, defaults = list(), update = list(),
                         delete = character(0), envir = parent.frame(), eager = TRUE,
                         standardise = FALSE) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Capture the call the user supplied
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  x <- substitute(x)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Standardise the call
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (standardise) {
    f <- eval(x[[1]], envir)
    if (!is.primitive(f)) {
      x <- match.call(f, x)
    }
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Eagerly evaluate all arguments when call is captured
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  func <- x[[1]]
  args <- as.list(x[-1])

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Optional: Eagerly evaluate args in calling environment
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (isTRUE(eager)) {
    args <- lapply(args, eval, envir = envir)
    x    <- as.call(c(func, args))
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Update the call arguments
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  x <- modify_call(x, defaults = defaults, update = update, delete = delete)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Add the 'meta' attributes
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr(x, 'meta') <- meta

  x
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Evaluate a call with options for changing the arguments
#'
#' This is an augmented version of \code{base::eval()} which has options for
#' overriding arguments before evaluation
#'
#' @inheritParams modify_call
#' @param envir evaluation environment
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
evaluate_call <- function(x, defaults = list(), update = list(),
                          delete = character(0), envir = parent.frame()) {

  stopifnot(`evaluate_call(): Expected a call object` = is.call(x))

  x <- modify_call(x, defaults = defaults, update = update, delete = delete)
  eval(x, envir = envir)
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Change a call by updating its arguments
#'
#' @param x call object
#' @param defaults list of arguments which would act as the default. These will
#'        be superseded by any arguments of the same name that already exist
#'        in the call object \code{x}
#' @param update named list of values which override arguments in the call.
#'        Note: "NULL" is \emph{not} used to remove an argument, but will actually
#'        set that argument value to NULL.  If you want to remove an argument, use
#'        \code{delete}.
#' @param delete character vector of named arguments to delete.
#'
#' @examples
#' cc <- capture_call(farnarkle(6, x = 2, z = 9))
#' cc <- modify_call(cc, defaults = list(x = 1, y = 7), update = list(z = 0))
#' cc
#'
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
modify_call <- function(x, defaults = list(), update = list(), delete = character(0)) {

  stopifnot(`modify_call(): Expected a call object` = is.call(x))
  stopifnot(`'defaults' must be a fully named list` = is_fully_named_list(defaults))
  stopifnot(`'update' must be a fully named list`   = is_fully_named_list(update  ))
  stopifnot(`'delete' must a character vector`      = is.character(delete))

  func <- x[[1]]
  args <- as.list(x[-1])

  args <- add_items_if_not_present(args, defaults)
  args <- modify_list(args, update)

  for (name in delete) {
    args[[name]] <- NULL
  }

  as.call(c(func, args))
}




if (FALSE) {

  modify_list(list(a=1, b=2, c=3), list(b = NULL, c=4, d=5, 1))
  add_items_if_not_present(list(a=1, b=2, c=3), list(b = NULL, c=4, d=5, 1))


}

