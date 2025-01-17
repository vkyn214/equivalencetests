#' Run equivalence based correlation tests
#' 
#' Function performs a traditional Pearson correlation test, an equivalence based test of lack
#' of association, an equivalence based test of lack of association using a Fisher's z 
#' transformation, and an equivalence based test of lack of association with resampling. 
#' 
#' @aliases equiv_corr
#' @param dat a data.frame or matrix containing only 2 variables
#' @param equivint equivalence interval
#' @param alpha desired alpha level
#' @param na.rm logical; remove missing values?
#' @param ... additional arguments to be passed
#' 
#' @return returns a \code{list} containing each analysis and their respective statistics
#'   and decision
#' 
#' @author Rob Cribbie \email{cribbie@@yorku.ca} and 
#'   Phil Chalmers \email{rphilip.chalmers@@gmail.com}
#' @export equiv_corr
#' @examples
#' \dontrun{
#' #equivalence correlation test between v1 and v2 with an interval of .2
#' v1 <- rnorm(100)
#' v2 <- v1 + rnorm(100, 2)
#' dat <- data.frame(v1, v2)
#' equiv_corr(dat, .2)
#' }
equiv_corr <- function(dat, equivint, alpha = 0.05, na.rm = TRUE, ...) {
    dat <- na.omit(dat)
    var1 <- x <- dat[, 1]
    var2 <- y <- dat[, 2]
    corxy <- cor(var1, var2)
    n <- length(var1)
    nresamples <- 10000
    #### Running a traditional t test to determine if the correlation is significant######
    t <- corxy/(sqrt((1 - corxy^2)/(n - 2)))
    pvalue_tradt <- 1 - pt(abs(t), n - 2)
    ifelse(pvalue_tradt <= alpha, decis_tradt <- "The null hypothesis that there is no correlation between x and y can be rejected.", 
        decis_tradt <- "The null hypothesis that there is no correlation between x and y cannot be rejected.")
    #### Running an original two t-test procedure for equivalence #######
    equivt1 <- (corxy - equivint)/sqrt((1 - corxy^2)/(n - 2))
    pvalue1_equivt <- pt(equivt1, n - 2)
    equivt2 <- (corxy + equivint)/sqrt((1 - corxy^2)/(n - 2))
    pvalue2_equivt <- 1 - pt(equivt2, n - 2)
    ifelse(pvalue1_equivt <= alpha & pvalue2_equivt <= alpha, decis_equivt <- "The null hypothesis that the correlation between var1 and var2 falls outside of the equivalence interval can be rejected.", 
        decis_equivt <- " The null hypothesis that the correlation between var1 and var2 falls outside of the equivalence interval cannot be rejected.")
    ##### Run a two t-test procedure for equivlance with Fisher's z transformation ####
    zei <- log((1 + equivint)/(1 - equivint))/2
    zcorxy <- log((1 + corxy)/(1 - corxy))/2
    equivt1_fz <- (zcorxy - zei)/(1/sqrt(n - 3))
    pvalue1_fz <- pnorm(equivt1_fz)
    equivt2_fz <- (zcorxy + zei)/(1/sqrt(n - 3))
    pvalue2_fz <- 1 - pnorm(equivt2_fz)
    ifelse(pvalue1_fz <= alpha & pvalue2_fz <= alpha, decis_fz <- "The null hypothesis that the correlation between var1 and var2 falls outside of the equivalence interval can be rejected.", 
        decis_fz <- "The null hypothesis that the correlation between var1 and var2 falls outside of the equivalence interval cannot be rejected.")
    #### Run the resampling version of the two t-test procedure for equivalence #####
    resamp <- function(x, m = 10000, theta, conf.level = 0.95, ...) {
        n <- length(x)
        Data <- matrix(sample(x, size = n * m, replace = T), nrow = m)
        thetastar <- apply(Data, 1, theta, ...)
        M <- mean(thetastar)
        S <- sd(thetastar)
        alpha <- 1 - conf.level
        CI <- quantile(thetastar, c(alpha/2, 1 - alpha/2))
        return(list(ThetaStar = thetastar, Mean.ThetaStar = M, S.E.ThetaStar = S, Percentile.CI = CI))
    }
    matr <- cbind(var1, var2)
    mat <- as.matrix(matr)
    theta <- function(x, mat) {
        cor(mat[x, 1], mat[x, 2])
    }
    results <- resamp(x = 1:n, m = nresamples, theta = theta, mat = mat)
    q1 <- quantile(results$ThetaStar, 0.05)
    q2 <- quantile(results$ThetaStar, 0.95)
    q1negei <- q1 - equivint
    q2negei <- q2 - equivint
    q1posei <- q1 + equivint
    q2posei <- q2 + equivint
    ifelse(q2negei < 0 & q1posei > 0, decis_rs <- "The null hypothesis that the correlation between var1 and var2 falls outside of the equivalence interval can be rejected.", 
        decis_rs <- "The null hypothesis that the correlation between var1 and var2 falls outside of the equivalence interval cannot be rejected.")
    #### Summary #####
    title1 <- "Traditional Test of Correlation, Ho: rho=0"
    title2 <- "Equivalence Based Test of Lack of Association"
    title3 <- "Equivalence Based Test of Lack of Association with Fisher's z transformation"
    title4 <- "Equivalence Based Test of Lack of Association with Resampling"
    stats_tradt <- c(corxy, t, n - 2, pvalue_tradt)
    names(stats_tradt) <- c("Pearson r", "t-statistic", "df", "p-value")
    stats_equivt <- c(corxy, equivint, equivt1, pvalue1_equivt, equivt2, pvalue2_equivt, n - 2)
    names(stats_equivt) <- c("Pearson r", "Equivalence Interval", "t-stat 1", "pval_t1", "t-stat 2", "pval_t2", 
        "df")
    stats_fz <- c(corxy, equivint, equivt1_fz, pvalue1_fz, equivt2_fz, pvalue2_fz)
    names(stats_fz) <- c("Pearson r", "Equivalence Interval", "z-stat 1", "pval_z1", "z-stat 2", "pval_z2")
    stats_rs <- c(corxy, equivint, nresamples, q1, q2)
    names(stats_rs) <- c("Pearson r", "Equivalence Interval", "# of Resamples", "5th Percentile", "95th Percentile")
    out <- list(list(title1, stats_tradt, decis_tradt), list(title2, stats_equivt, decis_equivt), list(title3, 
        stats_fz, decis_fz), list(title4, stats_rs, decis_rs))
    class(out) <- "equiv_corr"
    out
}

#' @S3method print equiv_corr
#' @rdname equiv_corr
#' @method print equiv_corr
#' @param x object of class \code{equiv_corr}
print.equiv_corr <- function(x, ...) {
    lapply(x, function(y) {
        cat("**************************************************\n\n", y[[1]], "\n\n")
        print(y[[2]])
        cat("\n\n", y[[3]], "\n\n")
    })
} 
