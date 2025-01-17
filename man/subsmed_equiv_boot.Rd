\name{subsmed_equiv_boot}
\alias{print.subsmed_equiv_boot}
\alias{subsmed_equiv_boot}
\title{Computes the equivalence and bootstrap-based test of substantial mediation}
\usage{
subsmed_equiv_boot(IV, DV, m, ei, standardize = FALSE, nboot = 10000,
  alpha = 0.05)

\method{print}{subsmed_equiv_boot}(x, ...)
}
\arguments{
  \item{IV}{independent variable}

  \item{DV}{dependent variable}

  \item{m}{mediator}

  \item{ei}{equivalence interval}

  \item{standardize}{logical; indicate whether the analysis
  should be done on the raw data or on standardized data
  (i.e., all variables having a mean of 0 and standard
  deviation of 1)}

  \item{nboot}{number of bootstraps}

  \item{alpha}{the appropriate alpha level}

  \item{x}{object of class \code{subsmed_equiv_boot}}

  \item{...}{additional arguments}
}
\description{
This function computes the equivalence and bootstrap-based
test of substantial mediation outlined in: Mara, C. &
Cribbie, R. A. (submitted). An equivalence-based procedure
for assessing substantial mediation. Psychological Methods.
}
\details{
This function determines whether a single mediator accounts
for a substantial proportion of the relationship between an
independent variable (IV) and a dependent variable (DV),
where quantifying 'a substantial proportion' depends on the
width of the equivalence interval. For a mediator to be
said to account for a substantial proportion of the
relationship between the IV and DV, the raw relationship
between IV and DV should be very similar to the reproduced
IV-DV relationship (i.e., IV->M*M->DV). The equivalence
interval defines how similar these relationships must be in
order for the mediation to be substantial.
}
\examples{
\dontrun{
# equivalence interval of .1, a standardized solution, 1000 bootstrap samples,
#  and the default alpha level (.05)
m <- rnorm(500)
x <- m + rnorm(500)
y <- m + rnorm(500)
subsmed_equiv_boot(x,y,m,ei=.1,nboot=1000,standardize=TRUE)
}
}
\author{
Constance Mara \email{constancemara@gmail.com}, Rob Cribbie
\email{cribbie@yorku.ca}, and Phil Chalmers
\email{rphilip.chalmers@gmail.com}
}
\references{
Mara, C. & Cribbie, R. A. (submitted). An equivalence-based
procedure for assessing substantial mediation.
\emph{Psychological Methods}.
}

