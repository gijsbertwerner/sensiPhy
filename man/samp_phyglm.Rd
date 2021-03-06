% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/samp_phyloglm.R
\name{samp_phyglm}
\alias{samp_phyglm}
\title{Sensitivity Analysis Species Sampling  - Phylogenetic Logistic Regression}
\usage{
samp_phyglm(formula, data, phy, times = 30, breaks = seq(0.1, 0.5, 0.1),
  btol = 50, track = TRUE, ...)
}
\arguments{
\item{formula}{The model formula}

\item{data}{Data frame containing species traits with row names matching tips
in \code{phy}.}

\item{phy}{A phylogeny (class 'phylo') matching \code{data}.}

\item{times}{The number of times species are randomly deleted for each
\code{break}.}

\item{breaks}{A vector containing the percentages of species to remove.}

\item{btol}{Bound on searching space. For details see \code{phyloglm}}

\item{track}{Print a report tracking function progress (default = TRUE)}

\item{...}{Further arguments to be passed to \code{phylolm}}
}
\value{
The function \code{samp_phylm} returns a list with the following
components:

\code{formula}: The formula

\code{full.model.estimates}: Coefficients, aic and the optimised
value of the phylogenetic parameter (e.g. \code{lambda} or \code{kappa}) for
the full model without deleted species.

\code{samp.model.estimates}: A data frame with all simulation
estimates. Each row represents a model rerun with a given number of species
\code{n.remov} removed, representing \code{n.percent} of the full dataset.
Columns report the calculated regression intercept (\code{intercept}),
difference between simulation intercept and full model intercept (\code{DFintercept}),
the percentage of change in intercept compared to the full model (\code{intercept.perc})
and intercept p-value (\code{pval.intercept}). All these parameters are also reported
for the regression slope (\code{DFslope} etc.). Additionally, model aic value
(\code{AIC}) and the optimised value (\code{optpar}) of the phylogenetic
parameter (e.g. \code{kappa} or \code{lambda}, depending on the phylogenetic model
used) are reported.

\code{sign.analysis} For each break (i.e. each percentage of species
removed) this reports the percentage of statistically signficant (at p<0.05)
intercepts (\code{perc.sign.intercept}) over all repititions as well as the
percentage of statisticaly significant (at p<0.05) slopes (\code{perc.sign.slope}).

\code{data}: Original full dataset.
}
\description{
Performs analyses of sensitivity to species sampling by randomly removing
species and detecting the effects on parameter estimates in phylogenetic
logistic regression.
}
\details{
This function randomly removes a given percentage of species (controlled by
\code{breaks}) from the full phylogenetic logistic regression, fits a phylogenetic
logistic regression model without these species using \code{\link[phylolm]{phyloglm}},
repeats this many times (controlled by \code{times}), stores the results and
calculates the effects on model parameters.

Only logistic regression using the "logistic_MPLE"-method from
\code{phyloglm} is implemented.

Currently, this function can only implement simple linear models (i.e. \eqn{trait~
predictor}). In the future we will implement more complex models.

Output can be visualised using \code{sensi_plot}.
}
\examples{
\dontrun{
# Simulate Data:
set.seed(6987)
phy = rtree(150)
x = rTrait(n=1,phy=phy)
X = cbind(rep(1,150),x)
y = rbinTrait(n=1,phy=phy, beta=c(-1,0.5), alpha=.7 ,X=X)
dat = data.frame(y, x)
# Run sensitivity analysis:
samp <- samp_phyglm(y ~ x, data = dat, phy = phy, times = 30) 
# To check summary results and most influential species:
summary(samp)
# Visual diagnostics for clade removal:
sensi_plot(samp)
}
}
\author{
Gustavo Paterno & Gijsbert D.A. Werner
}
\references{
Here still: reference to phylolm paper + our own + some more
background papers.
}
\seealso{
\code{\link[phylolm]{phyloglm}}, \code{\link{samp_phylm}},
\code{\link{influ_phyglm}}, \code{\link{sensi_plot}}
}

