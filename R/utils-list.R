

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
