##' Retrieve Posterior Measures from a COMPASS fit
##'
##' These functions can be used to retrieve different posterior measures
##' from a \code{COMPASS} fit object.
##'
##' The posterior items retrieved are described as follows::
##'
##' \describe{
##' \item{\code{compute_posterior}:}{Compute the posterior predicted mean values for Pu and Ps.}
##' \item{\code{compute_posterior_full}:}{Compute the full posterior predicted values for Pu and Ps.}
##' \item{\code{PosteriorPs}:}{The posterior estimate of the proportion of cells in the stimulated sample.}
##' \item{\code{PosteriorPu:}}{The posterior estimate of the proportio of cells in the unstimulated sample.}
##' \item{\code{PosteriorDiff}:}{The difference in posterior proportions,
##' as described above.}
##' \item{\code{PosteriorLogDiff}:}{The difference in the log posterior proportions,
##' as described above.}
##' }
##'
##' @param x An object of class \code{COMPASSResult}.
##' @export
##' @examples
##' Posterior(CR)
##' compute_posterior(CR)
##' compute_posterior_full(CR)
##' PosteriorPs(CR)
##' PosteriorPu(CR)
##' PosteriorDiff(CR)
##' PosteriorLogDiff(CR)
Posterior <- function(x) {
  if (!inherits(x, "COMPASSResult")) {
    stop("'x' must be an object of class 'COMPASSResult'")
  }

  return(x$fit$posterior)
}

##' @rdname Posterior
##' @export
compute_posterior <- function(x) {

  output <- lapply( 1:nrow(x$data$n_s), function(i) {
    .Call( C_samplePuPs,
      x$fit$alpha_u,
      x$fit$alpha_s,
      x$fit$gamma[i, , ],
      dim(x$fit$gamma)[[3]],
      dim(x$fit$gamma)[[2]],
      x$data$n_s[i, ],
      x$data$n_u[i, ],
      x$fit$categories,
      ncol(x$fit$categories) - 1L
    )
  })

  names(output) <- rownames(x$data$n_s)
  return(output)
}


##' @rdname Posterior
##' @export
compute_posterior_full <- function(x) {

  output <- lapply( 1:nrow(x$data$n_s), function(i) {
    .Call( C_samplePuPs_full,
           x$fit$alpha_u,
           x$fit$alpha_s,
           x$fit$gamma[i, , ],
           dim(x$fit$gamma)[[3]],
           dim(x$fit$gamma)[[2]],
           x$data$n_s[i, ],
           x$data$n_u[i, ],
           x$fit$categories,
           ncol(x$fit$categories) - 1L
    )
  })

  names(output) <- rownames(x$data$n_s)
  return(output)
}

##' @rdname Posterior
##' @export
PosteriorDiff <- function(x) {

  if (!inherits(x, "COMPASSResult")) {
    stop("'x' must be an object of class 'COMPASSResult'")
  }

  post <- x$fit$posterior
  output <- sapply(post, "[[", "diff")
  nm <- colnames( x$data$n_s )
  rownames(output) <- nm[ -length(nm) ]
  return( t(output) )

}

##' @rdname Posterior
##' @export
PosteriorLogDiff <- function(x) {

  if (!inherits(x, "COMPASSResult")) {
    stop("'x' must be an object of class 'COMPASSResult'")
  }

  post <- x$fit$posterior
  output <- sapply(post, "[[", "logd")
  nm <- colnames( x$data$n_s )
  rownames(output) <- nm[ -length(nm) ]
  return( t(output) )

}

##' @rdname Posterior
##' @export
PosteriorPs <- function(x) {

  if (!inherits(x, "COMPASSResult")) {
    stop("'x' must be an object of class 'COMPASSResult'")
  }

  post <- x$fit$posterior
  output <- sapply(post, "[[", "p_s")
  nm <- colnames( x$data$n_s )
  rownames(output) <- nm[ -length(nm) ]
  return( t(output) )

}

##' @rdname Posterior
##' @export
PosteriorPu <- function(x) {

  if (!inherits(x, "COMPASSResult")) {
    stop("'x' must be an object of class 'COMPASSResult'")
  }

  post <- x$fit$posterior
  output <- sapply(post, "[[", "p_u")
  nm <- colnames( x$data$n_s )
  rownames(output) <- nm[ -length(nm) ]
  return( t(output) )

}
