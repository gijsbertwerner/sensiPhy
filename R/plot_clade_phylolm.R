#' Graphical diagnostics for class 'sensiClade'
#'
#' Plot results from \code{clade_phylm} and \code{clade_phyglm}
#' @param x output from \code{clade_phylm} or \code{clade_phyglm}
#' @param clade The name of the clade to be evaluated (see details)
#' @param ... further arguments to methods.
#' @importFrom ggplot2 aes theme element_text geom_point element_rect ylab xlab
#' ggtitle element_blank geom_abline scale_shape_manual scale_linetype_manual 
#' guide_legend element_rect
#' guides
#' 
#' @author Gustavo Paterno
#' @seealso \code{\link[sensiPhy]{clade_phylm}} 
#' @details This function plots the original scatterplot \eqn{y = a + bx} (with the 
#' full dataset) and a comparison between the regression lines of the full model
#' and the model without the selected clade (set by \code{clade}). For further
#' details about this method, see \code{\link[sensiPhy]{clade_phylm}}.
#' 
#' Species from the selected clade are represented in red (removed species),
#' solid line represents the regression with the full model and dashed line represents
#' the regression of the model without the species from the selected clade.
#' To check the available clades to plot, see \code{x$clade.model.estimates$clade} 
#' in the object returned from \code{clade_phylm} or \code{clade_phyglm}. 
#' @importFrom ggplot2 aes_string
#' @importFrom stats model.frame qt plogis 
#' @export

sensi_plot.sensiClade <- function(x, clade = NULL, ...){
    
    #x <- clade
    #clade <- NULL
    yy <- NULL
    # start:
    full.data <- x$data
    mappx <- x$formula[[3]]
    mappy <- x$formula[[2]]
    vars <- all.vars(x$formula)
    clade.col <- x$clade.col
    
    clades.names <- x$clade.model.estimates$clade
    if (is.null(clade) == T){
        clade <- clades.names[1]
        warning("Clade argument was not defined. Plotting results for clade: ",
                clade,"
                Use clade = 'clade name' to plot results for other clades")
    }
    clade.n <- which(clade == clades.names)
    if (length(clade.n) == 0) stop(paste(clade,"is not a valid clade name"))
    
    ### Organizing values:
    result <- x$clade.model.estimates
    intercept.0 <-  as.numeric(x$full.model.estimates$coef[1])
    slope.0     <-  as.numeric(x$full.model.estimates$coef[2])

    inter <- c(x$clade.model.estimates$intercept[clade.n ],
               intercept.0)
    slo <-  c(x$clade.model.estimates$slope[clade.n ],
              slope.0)
    model <- NULL
    estimates <- data.frame(inter,slo, model=c("Without clade", "Full model"))
    
    xf <- model.frame(formula = x$formula, data = full.data)[,2]
    yf <- plogis(estimates[2,1] + estimates[2,2] * xf)
    yw <- plogis(estimates[1,1] + estimates[1,2] * xf)
    plot_data <- data.frame("xf" = c(xf,xf),
                            "yy" = c(yw, yf),
                            model = rep(c("Without clade","Full model"),
                                        each = length(yf)))
                            
    match.y <- which(full.data[, clade.col] == clade)
    match.n <- which(full.data[, clade.col] != clade)
    
    g1 <- ggplot2::ggplot(full.data, aes_string(y = mappy, x = mappx),
                    environment = parent.frame())+
        geom_point(data = full.data[match.n, ], alpha = .7,
                   size = 4)+
        geom_point(data = full.data[match.y, ],alpha = .5,
                   size = 4, aes(shape = "Removed species"), colour = "red")+
        
        scale_shape_manual(name = "", values = c("Removed species" = 16))+
        guides(shape = guide_legend(override.aes = list(linetype = 0)))+
        scale_linetype_manual(name = "Model", values = c("Full model" = "solid",
                                                    "Without clade" = "dashed"))+
        theme(axis.text = element_text(size = 18),
              axis.title = element_text(size = 18),
              legend.text = element_text(size = 16),
              plot.title = element_text(size = 20),
              panel.background = element_rect(fill = "white", colour = "black"))+
        ggtitle(paste("Clade removed: ", clade, sep = ""))
    
    ### plot lines: linear or logistic depending on output class
    if(length(class(x)) == 1){
        g.out <- g1 + geom_abline(data = estimates, aes(intercept = inter, slope = slo,
                                      linetype = factor(model)),
                size=.8)
    }
    if(length(class(x)) == 2){
        g.out <- g1 + geom_line(data = plot_data, aes(x = xf, y = yy, linetype = factor(model)))
    }
    return(g.out)
}

