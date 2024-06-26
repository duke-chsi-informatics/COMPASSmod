##' Fit the COMPASS Model
##'
##' This function fits the \code{COMPASS} model.
##'
##' @section Category Filter:
##' The category filter is used to exclude categories (combinations of
##' markers expressed for a particular cell) that are expressed very rarely.
##' It is applied to the \code{treatment} \emph{counts} matrix, which is a
##' \code{N} samples by \code{K} categories matrix. Those categories which
##' are mostly unexpressed can be excluded here. For example, the default
##' criteria,
##'
##' \code{category_filter=function(x) colSums(x > 5) > 2}
##'
##' indicates that we should only retain categories for which at least three samples
##' had at least six cells expressing that particular combination of markers.
##'
##' @param data An object of class \code{COMPASSContainer}.
##' @param treatment An \R expression, evaluated within the metadata, that
##'   returns \code{TRUE} for those samples that should belong to the
##'   treatment group. For example, if the samples that received a positive
##'   stimulation were named \code{"92TH023 Env"} within a variable in
##'   \code{meta} called \code{Stim}, you could write \code{Stim == "92TH023 Env"}.
##'   The expression should have the name of the stimulation vector on the
##'   left hand side.
##' @param control An \R expression, evaluated within the metadata, that
##'   returns \code{TRUE} for those samples that should belong to the
##'   control group. See above for details.
##' @param subset An expression used to subset the data. We keep only the samples
##'   for which the expression evaluates to \code{TRUE} in the metadata.
##' @param category_filter A filter for the categories that are generated. This is a
##'   function that will be applied to the \emph{treatment counts} matrix generated from
##'   the intensities. Only categories meeting the \code{category_filter} criteria will
##'   be kept.
##' @param filter_lowest_frequency A number specifying how many of the least
##'  expressed markers should be removed.
##' @param filter_specific_markers Similar to \code{filter_lowest_frequency},
##'   but lets you explicitly exclude markers.
##' @param model A string denoting which model to fit; currently, only
##' the discrete model (\code{"discrete"}) is available.
##' @param iterations The number of iterations (per 'replication') to perform.
##' @param replications The number of 'replications' to perform. In order to
##'   conserve memory, we only keep the model estimates from the last replication.
##' @param keep_original_data Keep the original \code{COMPASSContainer}
##'   as part of the \code{COMPASS} output? If memory or disk space is an issue,
##'   you may set this to \code{FALSE}.
##' @param verbose Boolean; if \code{TRUE} we output progress information.
##' @param dropDegreeOne Boolean; if \code{TRUE} we drop degree one categories
##'   and merge them with the negative subset.
##' @param init_with_fisher Boolean;initialize from fisher's exact test. Any subset and subject with lower 95% log odds estimate >1 will be initialized as a responder.
##'  Otherwise initialize very subject and subset as a responder except those where ps <= pu.
##' @param run_model_or_return_data \code{character} defaults to \code{"run_model"} otherwise set it to \code{"return_data"} in order to not fit the model just return the data set needed for modeling. Useful for extracting the boolean counts.
##' @param ... Other arguments; currently unused.
##'
##' @seealso
##'
##' \itemize{
##' \item \code{\link{COMPASSContainer}}, for constructing the data object
##' required by \code{COMPASS}
##' }
##'
##' @return A \code{COMPASSResult} is a list with the following components:
##'
##' \item{fit}{A list of various fitted parameters resulting from the
##' \code{COMPASS} model fitting procedure.}
##' \item{data}{The data used as input to the \code{COMPASS} fitting
##' procedure -- in particular, the counts matrices generated for the
##' selected categories, \code{n_s} and \code{n_u}, can be extracted
##' from here.}
##' \item{orig}{If \code{keep_original_data} was set to \code{TRUE}
##' in the \code{COMPASS} fit, then this will be the \code{COMPASSContainer}
##' passed in. This is primarily kept for easier running of the Shiny app.}
##'
##' The \code{fit} component is a list with the following components:
##'
##' \item{alpha_s}{The hyperparameter shared across all subjects under the
##' stimulated condition. It is updated through the \code{COMPASS} model
##' fitting process.}
##' \item{A_alphas}{The acceptance rate of \code{alpha_s}, as computed
##' through the MCMC sampling process in \code{COMPASS}.}
##' \item{alpha_u}{The hyperparameter shared across all subjects under the
##' unstimulated condition. It is updated through the \code{COMPASS}
##' model fitting process.}
##' \item{A_alphau}{The acceptance rate of \code{alpha_u}, as computed
##' through the MCMC sampling process in \code{COMPASS}.}
##' \item{gamma}{An array of dimensions \code{I x K x T}, where \code{I}
##' denotes the number of individuals, \code{K} denotes the number of
##' categories / subsets, and \code{T} denotes the number of iterations.
##' Each cell in a matrix for a given iteration is either zero or one,
##' reflecting whether individual \code{i} is responding to the stimulation
##' for subset \code{k}.}
##' \item{mean_gamma}{A matrix of mean response rates. Each cell denotes
##' the mean response of individual \code{i} and subset \code{k}.}
##' \item{A_gamma}{The acceptance rate for the gamma. Each element
##' corresponds to the number of times an individual's \code{gamma}
##' vector was updated.}
##' \item{categories}{The category matrix, showing which categories
##' entered the model.}
##' \item{model}{The type of model called.}
##' \item{posterior}{Posterior measures from the sample fit.}
##' \item{call}{The matched call used to generate the model fit.}
##'
##' The \code{data} component is a list with the following components:
##'
##' \item{n_s}{The counts matrix for stimulated samples.}
##' \item{n_u}{The counts matrix for unstimulated samples.}
##' \item{counts_s}{Total cell counts for stimulated samples.}
##' \item{counts_u}{Total cell counts for unstimulated samples.}
##' \item{categories}{The categories matrix used to define which
##' categories will enter the model.}
##' \item{meta}{The metadata. Note that only \strong{individual-level} metadata
##'   will be kept; sample-specific metadata is dropped.}
##' \item{sample_id}{The name of the vector in the metadata used to
##' identify the samples.}
##' \item{individual_id}{The name of the vector in the metadata used
##' to identify the individuals.}
##'
##' The \code{orig} component (included if \code{keep_original_data} is
##' \code{TRUE}) is the \code{\link{COMPASSContainer}} object used in the model
##' fit.
##'
##' @export
##' @example examples/COMPASS_fit.R
COMPASS <- function(data, treatment, control, subset=NULL,
                    category_filter=function(x) colSums(x > 5) > 2,
                    filter_lowest_frequency=0, filter_specific_markers=NULL,
                    model="discrete",
                    iterations=40000, replications=8,
                    keep_original_data=FALSE,
                    verbose=TRUE, dropDegreeOne=FALSE, init_with_fisher=FALSE,
		    run_model_or_return_data="run_model",...) {

	run_model_or_return_data=match.arg(run_model_or_return_data,c("run_model","return_data"))
    if (!inherits(data, "COMPASSContainer")) {
        stop("'data' must be an object of class 'COMPASSContainer'; see the ",
             "constructor 'COMPASSContainer' for more details.", call.=FALSE)
    }

    ## used for brevity in later parts of code
    sid <- data$sample_id
    iid <- data$individual_id

    vmessage <- function(...) if (verbose) message(...) else invisible(NULL)

    call <- match.call()

    ## make sure all the data input
    ## will survive the model fitting
    null_data <- sapply(data$data, is.null)
    bad_samples <- names(data$data)[null_data]
    if (any(null_data)) {
        warning("The following samples had no cytometry data available ",
                "and will not be included in the model fit:\n\t: ",
                paste( bad_samples, collapse=", ")
                )
        data$data <- data$data[ !(names(data$data) %in% bad_samples) ]
        data$counts <- data$counts[ !(names(data$counts) %in% bad_samples) ]
        data$meta <- data$meta[ !(data$meta[[sid]] %in% bad_samples), ]
    }

    ## If the object in the call is a symbol, try evaluating it partially
    if (is.symbol(call$treatment)) call$treatment <- eval(call$treatment)
    treatment <- call$treatment
    if (!is.call(treatment)) {
        stop("'treatment' must be an expression that defines the samples encompassing ",
             "the treatment group.", call.=FALSE)
    }

    if (is.symbol(call$control)) call$control <- eval(call$control)
    control <- call$control
    if (!is.call(control)) {
        stop("'control' must be an expression that defines the samples encompassing ",
             "the control group.", call.=FALSE)
    }

    subset <- call$subset

    ## subset the data
    if (!is.null(subset)) {
        keep <- data$meta[[sid]][eval(subset, envir=data$meta)]
        vmessage("Subsetting has removed ", length(data$data) - length(keep),
                 " of ", length(data$data), " samples.")
        data$data <- data$data[ names(data$data) %in% keep ]
        data$meta <- data$meta[ data$meta[[sid]] %in% keep, ]
    }

    .get_data <- function(data, expr, group) {
        which <- eval(expr, envir=data$meta, enclos=parent.frame(n=2))
        samples <- data$meta[[sid]][which]
        samples <- samples[ samples %in% names(data$data) ]
        individuals <- unique(data$meta[[iid]][ data$meta[[sid]] %in% samples ])
        individuals <- individuals[ !is.na(individuals) ]
        vmessage("There are a total of ", length(samples), " samples from ",
                 length(individuals), " individuals in the '", group, "' group.")

        if (length(samples) > length(individuals)) {
            vmessage("There are multiple samples per individual; ",
                     "these will be aggregated.")
        }

        output <- vector("list", length(individuals))
        for (i in seq_along(output)) {
            indiv <- individuals[i]

            ## get the samples belonging to the current individual
            c_samples <- samples[ samples %in% data$meta[[sid]][ data$meta[[iid]] == indiv ] ]
            output[[i]] <- do.call(rbind, data$data[match(c_samples, names(data$data))])
        }
        names(output) <- individuals
        return(output)
    }

    y_s <- .get_data(data, treatment, "treatment")
    y_u <- .get_data(data, control, "control")

    ## make sure the names match up
    ys_names <- names(y_s)
    yu_names <- names(y_u)

    diff <- setdiff(
        union(ys_names, yu_names),
        intersect(ys_names, yu_names)
    )

    if (length(diff)) {
        vmessage("The selection criteria for 'treatment' and 'control' do not produce ",
                 "paired samples for each individual. The following individual(s) will be dropped:\n\t",
                 paste(diff, collapse=", "))
        keep <- intersect(ys_names, yu_names)
        ys_keep <- match(keep, ys_names)
        yu_keep <- match(keep, yu_names)
        y_s <- y_s[ys_keep]
        y_u <- y_u[yu_keep]
    }

    if (length(y_s) == 0 || length(y_u) == 0) {
        stop("Filtering has removed all samples.", call.=FALSE)
    }

    ## reorder y_u to match order of y_s
    y_u <- y_u[ match(names(y_s), names(y_u)) ]

    ## filter lowest frequency markers (i.e. marginalize over rarely expressed
    ## markers so we get fewer singleton categories)
    proportions_expressed <- colMeans(do.call(rbind, y_s) > 0)

    ## markers we specifically want to drop
    drop_markers <- NULL
    c1 <- 0 < filter_lowest_frequency
    c2 <- filter_lowest_frequency < (length(proportions_expressed) - 2)
    if (c1 && c2) {
        drop_markers <- c(sort(proportions_expressed, decreasing = FALSE)[1:filter_lowest_frequency])
    }

    keep_markers <- setdiff(
        names(proportions_expressed),
        c(names(drop_markers), filter_specific_markers)
    )

    ## subset based on the markers we keep
    y_s <- lapply(y_s, function(x) x[, keep_markers, drop=FALSE])
    y_u <- lapply(y_u, function(x) x[, keep_markers, drop=FALSE])

    ## remove the null cells
    y_s <- lapply(y_s, function(x) x[rowSums(x) > 0, , drop=FALSE])
    y_u <- lapply(y_u, function(x) x[rowSums(x) > 0, , drop=FALSE])

    ## generate the categories matrix here, and with it, the counts
    .generate_categories <- function(data) {
        ## i'm sorry
        tmp <- unique( as.data.table( lapply( lapply( as.data.table( do.call( rbind, data ) ), as.logical ), as.integer ) ) )
        tmp[, c("Counts") := apply(.SD, 1, sum)]
        setkeyv(tmp, c("Counts", rev(names(tmp))))
        output <- as.matrix(tmp)
        output<-output[output[,"Counts"]>0,]

        ## the model output requires the last row to be the 'null' category;
        ## ie, number of cells that did not express one of the combinations
        output <- rbind(output, 0)
        return(output)
    }

    categories <- .generate_categories( c(y_s, y_u) )

    .counts <- function(y, categories, counts) {

        ## transform categories matrix into a list suitable for the counts function
        combos <- as.list( as.data.frame( apply(categories[, -ncol(categories)], 1, function(x) {
            tmp <- c( which(x == 1), -which(x == 0) )
            tmp <- tmp[ match(1:length(tmp), abs(tmp)) ]
            return(tmp)
        })))

        ## generate nice names for the combos
        names(combos) <- unname(sapply(combos, function(x) {
            n <- length(x)
            paste0( sep='', collapse='&',
                   swap(x, c(-n:-1, 1:n), c( rep("!", n), rep("", n) ) ),
                   colnames(categories)[-ncol(categories)]
                   )
        }))

        m <- .Call(C_COMPASS_CellCounts, y, combos)

        ## set the last column to be the 'null'
        m[, ncol(m)] <- counts[ names(y) ] - apply(m[,-ncol(m), drop=FALSE], 1, sum)

        return(m)
    }

    ## we have to regenerate cell count totals (by individual) to account
    ## for aggregation
    .update_total_CellCounts <- function(counts, individuals, expr) {
        which <- eval(expr, data$meta,enclos=parent.frame(n=2))
        new_counts <- sapply(individuals, function(ind) {
            ## get the samples corresponding to the current individual, expr
            which2 <- data$meta[[iid]] == ind
            keep <- sapply(as.logical(which * which2), isTRUE)
            smp <- as.character(data$meta[[sid]][keep])
            return( sum(counts[smp]) )
        })

        return(new_counts)

    }

    counts_s <- .update_total_CellCounts(data$counts, names(y_s), treatment)
    counts_u <- .update_total_CellCounts(data$counts, names(y_u), control)

    n_s <- .counts(y_s, categories, counts_s)
    n_u <- .counts(y_u, categories, counts_u)

    ## check for negative counts
    .check_negative_counts <- function(x) {
        if (any(x < 0)) stop("Internal error: negative counts in '", deparse(substitute(x)), "'")
        return( invisible(NULL) )
    }

    .check_negative_counts(n_s)
    .check_negative_counts(n_u)

    ## Check for rows in n_s, n_u with zero counts
    .zero_counts <- function(x, group) {
        bad_ids <- character()
        rs <- rowSums(x)
        for (i in seq_along(rs)) {
            if (rs[i] < 1) {
                bad_ids <- c(bad_ids, rownames(x)[i])
            }
        }
        if (length(bad_ids))
            vmessage("The following individual(s) had no cells available for ",
                     "the '", group, "' group and will be removed:\n\t",
                     paste(bad_ids, sep=", "))

        return(bad_ids)
    }

    bad_ids <- c(.zero_counts(n_s, "treatment"), .zero_counts(n_u, "control"))
    if (length(bad_ids)) {
        n_s <- n_s[ !(rownames(n_s) %in% bad_ids), ]
        n_u <- n_u[ !(rownames(n_u) %in% bad_ids), ]
        counts_s <- counts_s[ !(names(counts_s) %in% bad_ids) ]
        counts_u <- counts_u[ !(names(counts_u) %in% bad_ids) ]
        y_s <- y_s[ !(names(y_s) %in% bad_ids) ]
        y_u <- y_u[ !(names(y_u) %in% bad_ids) ]
    }

    vmessage("The model will be run on ", length(y_s), " paired samples.")

    ## filter the categories matrix
    if (!is.null(category_filter)) {
        category_filter <- match.fun(category_filter)
        del <- !category_filter(n_s)
        if (is.logical(del)) {
            del <- which(del)
        }

        ## only do this if del actually has a length, otherwise we get a 1-column vector.
        if (length(del) > 0) {

            vmessage("The category filter has removed ", length(del), " of ", nrow(categories), " categories.")

            ## since we're dropping some categories, those cells must be accounted
            ## for. We add them to the negative cell category.
            n_s[, ncol(n_s)] <- n_s[,ncol(n_s)] + rowSums(n_s[,del, drop = FALSE])
            n_u[, ncol(n_u)] <- n_u[,ncol(n_u)] + rowSums(n_u[,del, drop = FALSE])

            ## now we drop them
            n_s <- n_s[, -c(del), drop=FALSE]
            n_u <- n_u[, -c(del), drop=FALSE]
            categories <- categories[ -c(del), , drop=FALSE ]
        } else {
            vmessage("The category filter did not remove any categories.")
        }
    }

    if (nrow(categories) < 2) {
        stop("There must be at least 2 categories (including the null categoy) for testing.", call.=FALSE)
    }
    ## Drop degree one categories if the option is set
    if(class(dropDegreeOne)=="logical"){
        if(dropDegreeOne){
            .drop_degree_one <- function(categories=NULL,n_s=NULL,n_u=NULL){
                to_drop <- categories[,"Counts"]==1
                categories_new <- categories
                n_s_new <- n_s
                n_u_new <- n_u
                nc <- ncol(n_s_new)
                n_s_new[,nc] <- n_s_new[,nc]+rowSums(n_s[,to_drop])
                n_u_new[,nc] <- n_u_new[,nc]+rowSums(n_u[,to_drop])
                n_s_new <- n_s_new[,-which(to_drop),drop=FALSE]
                n_u_new <- n_u_new[,-which(to_drop),drop=FALSE]
                categories_new <- categories_new[!to_drop,,drop=FALSE]
                return(list(categories=categories_new,n_s=n_s_new,n_u=n_u_new))
            }

            reduced <- .drop_degree_one(categories=categories,n_s=n_s,n_u=n_u)
            categories <- reduced$categories
            n_s <- reduced$n_s
            n_u <- reduced$n_u
        }
    }else if(class(dropDegreeOne)=="character"){
        .drop_degree_one_ <- function(categories=NULL,n_s=NULL,n_u=NULL,marker=dropDegreeOne){
            to_drop <- categories[,"Counts"]==1
            if(!all(marker%in%colnames(categories))){
                stop(paste0("Invalid marker name(s): ",paste(marker[!marker%in%colnames(categories)],collapse=",")))
            }
            marker.test <- rowSums(categories[,marker,drop=FALSE])==1
            to_drop <- to_drop&marker.test
            categories_new <- categories
            n_s_new <- n_s
            n_u_new <- n_u
            nc <- ncol(n_s_new)
            n_s_new[,nc] <- n_s_new[,nc]+rowSums(n_s[,to_drop,drop=FALSE])
            n_u_new[,nc] <- n_u_new[,nc]+rowSums(n_u[,to_drop,drop=FALSE])
            n_s_new <- n_s_new[,-which(to_drop),drop=FALSE]
            n_u_new <- n_u_new[,-which(to_drop),drop=FALSE]
            categories_new <- categories_new[!to_drop,,drop=FALSE]
            return(list(categories=categories_new,n_s=n_s_new,n_u=n_u_new))
        }
        reduced <- .drop_degree_one_(categories=categories,n_s=n_s,n_u=n_u,marker=dropDegreeOne)
        categories <- reduced$categories
        n_s <- reduced$n_s
        n_u <- reduced$n_u
    }
  vmessage("There are a total of ", nrow(categories), " categories to be tested.")

  model <- match.arg(model)

  ## go to the model fitting processes
  if(run_model_or_return_data=="run_model"){
    output <- list(
        fit=.COMPASS.discrete(n_s=n_s, n_u=n_u, categories=categories,
        iterations=iterations, replications=replications, verbose=verbose, init_with_fisher=init_with_fisher, ...),
        data=list(n_s=n_s, n_u=n_u, counts_s=counts_s, counts_u=counts_u,
        categories=categories, meta=data$meta, sample_id=data$sample_id,
        individual_id=data$individual_id)
    )
  }else{
	output<-list(fit="No model was fitted");
  }
  if (keep_original_data) {
    output$orig <- data
  }

if(run_model_or_return_data == "run_model"){
  ## Compute the posterior ps-pu; log(ps)-log(pu)
  vmessage("Computing the posterior difference in proportions, posterior log ratio...")
  output$fit$posterior <- compute_posterior_full(output)
  vmessage("Done!")
}

  ## Filter metadata
  ..iid.. <- iid
  meta_dt <- as.data.table(data$meta)

  ## Only keep metadata variables that occur once for each subject
  meta_counts <- meta_dt[, lapply(.SD, function(x) length(unique(x))), by=..iid..]
  keep <- names(meta_counts)[sapply(meta_counts, function(x) all(x == 1))]
  output$data$meta <- as.data.frame(
    meta_dt[ meta_dt[, .I[1], by=eval(..iid..)]$V1 ][, c(..iid.., keep), with=FALSE]
  )

  ## Make sure that the symbols in the 'treatment', 'control' are evaluated

  ## if 'treatment' is a call, make sure the right side gets evaluated
  if (is.call(call[["treatment"]])) {
    if (is.symbol( call[["treatment"]][[3]] )) {
      call[["treatment"]][[3]] <- eval( call[["treatment"]][[3]] )
    }
  }

  ## similarily for 'control'
  if (is.call(call[["control"]])) {
    if (is.symbol( call[["control"]][[3]] )) {
      call[["control"]][[3]] <- eval( call[["control"]][[3]] )
    }
  }

  output$fit$call <- call

  class(output) <- "COMPASSResult"
  attr(output,"sessionInfo")<-sessionInfo()
  return(output)

}
