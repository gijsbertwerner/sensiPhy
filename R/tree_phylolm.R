#' Phylogenetic uncertainty - Phylogenetic Linear Regression
#'
#' Performs Phylogenetic linear regression accounting for
#' uncertainty in trees topology.
#'
#' @param formula The model formula
#' @param data Data frame containing species traits with species as row names.
#' @param phy A phylogeny (class 'multiPhylo', see ?\code{ape}).
#' @param ntree Number of times to repeat the analysis with n different trees picked 
#' randomly in the multiPhylo file.
#' If NULL, \code{ntree} = 2
#' @param model The phylogenetic model to use (see Details). Default is \code{lambda}.
#' @param track Print a report tracking function progress (default = TRUE)
#' @param ... Further arguments to be passed to \code{phylolm}
#' @details
#' This function fits a phylogenetic linear regression model using \code{\link[phylolm]{phylolm}}
#' to n trees, randomly picked in a multiPhylo file.
#'
#' All phylogenetic models from \code{phylolm} can be used, i.e. \code{BM},
#' \code{OUfixedRoot}, \code{OUrandomRoot}, \code{lambda}, \code{kappa},
#' \code{delta}, \code{EB} and \code{trend}. See ?\code{phylolm} for details.
#'
#' Currently, this function can only implement simple linear models (i.e. \eqn{trait~
#' predictor}). In the future we will implement more complex models.
#'
#' Output can be visualised using \code{sensi_plot}.
#'
#' @return The function \code{tree_phylolm} returns a list with the following
#' components:
#' @return \code{formula}: The formula
#' @return \code{model_results}: Coefficients, aic and the optimised
#' value of the phylogenetic parameter (e.g. \code{lambda}) for each regression with a 
#' different phylogenetic tree.
#' @return \code{N.obs}: Size of the dataset after matching it with tree tips and removing NA's.
#' @return \code{stats}: Statistics for model parameters. code{sd_tree} is the standard deviation 
#' due to phylogenetic uncertainty.
#' 
#' @examples
#' \dontrun{
#' library(sensiPhy);library(phylolm)
#' #which example should we put here?
#'
#'
#'
#'
#' @authors Caterina Penone & Pablo Ariel Martinez
#' @seealso \code{\link{sensi_plot}}
#' @references Here still: reference to phylolm paper + our own?
#' @export

tree_phylolm <- function(formula,data,phy,
                         ntree=2,model="lambda",track=TRUE){
  
  #Error check
  if (!inherits(phy, "multiPhylo"))
    stop("'", deparse(substitute(phy)), "' not of class 'multiPhylo'")
  
  #Matching tree and phylogeny using utils.R
  datphy<-match_dataphy(formula,data,phy)
  data<-datphy[[1]]
  phy<-datphy[[2]]

  # If the class of tree is multiphylo pick n=ntree random trees
  trees<-sample(length(phy),ntree,replace=F)

  #Create the results data.frame
  tree.model.estimates<-data.frame("n.tree"=numeric(),"intercept"=numeric(),"se.intercept"=numeric(),
                         "pval.intercept"=numeric(),"slope"=numeric(),"se.slope"=numeric(),
                         "pval.slope"=numeric(),"aic"=numeric(),"optpar"=numeric())

  #Model calculation
  counter=1
  errors <- NULL
  c.data<-list()
  for (j in trees){
      
      #phylolm model
      mod = try(phylolm::phylolm(formula, data=data,model=model,phy=phy[[j]]),TRUE)

      
      if(isTRUE(class(mod)=="try-error")) {
        error <- j
        names(error) <- rownames(c.data$data)[j]
        errors <- c(errors,error)
        next }
      
      
      else{
        intercept            <- phylolm::summary.phylolm(mod)$coefficients[[1,1]]
        se.intercept         <- phylolm::summary.phylolm(mod)$coefficients[[1,2]]
        slope                <- phylolm::summary.phylolm(mod)$coefficients[[2,1]]
        se.slope             <- phylolm::summary.phylolm(mod)$coefficients[[2,2]]
        pval.intercept       <- phylolm::summary.phylolm(mod)$coefficients[[1,4]]
        pval.slope           <- phylolm::summary.phylolm(mod)$coefficients[[2,4]]
        aic.mod              <- mod$aic
        n                    <- mod$n
        d                    <- mod$d
        if (model == "BM"){
          optpar <- NA
        }
        if (model != "BM"){
          optpar               <- mod$optpar
        }
        
        if(track==TRUE) print(paste("tree: ",j,sep=""))
        
        #write in a table
        tree.model.estimates[counter,1] <- j
        tree.model.estimates[counter,2] <- intercept
        tree.model.estimates[counter,3] <- se.intercept
        tree.model.estimates[counter,4] <- pval.intercept
        tree.model.estimates[counter,5] <- slope
        tree.model.estimates[counter,6] <- se.slope
        tree.model.estimates[counter,7] <- pval.slope
        tree.model.estimates[counter,8] <- aic.mod
        tree.model.estimates[counter,9]<-  optpar
        
        
        counter=counter+1
        
      }
    }

  #calculate mean and sd for each parameter
  #variation due to tree choice
  mean_by_tree<-stats::aggregate(.~n.tree, data=tree.model.estimates, mean)

  statresults<-data.frame(min=apply(tree.model.estimates,2,min),
                          max=apply(tree.model.estimates,2,max),
                          mean=apply(tree.model.estimates,2,mean),
                          sd_tree=apply(mean_by_tree,2,sd))[-(1:2),]
  
  
  output <- list(analysis.type="tree_phylolm",formula=formula,
                 model_results=tree.model.estimates,N.obs=n,
                 stats=statresults)
  
  return(output)
}