## File Name: tam_mml_ic.R
## File Version: 9.1992


#--- information criteria
tam_mml_ic <- function( nstud, deviance, xsi, xsi.fixed,
    beta, beta.fixed, ndim, variance.fixed, G, irtmodel,
    B_orig=NULL, B.fixed, E, est.variance, resp,
    est.slopegroups=NULL, variance.Npars=NULL, group, penalty_xsi=0,
    AXsi=NULL, pweights=NULL, resp.ind=NULL)
{

    #--- log likelihood and log prior
    deviance <- deviance - penalty_xsi
    loglike <- - deviance / 2
    logprior <- - penalty_xsi / 2
    logpost <- loglike + logprior

    #***Model parameters
    ic <- data.frame("n"=nstud, "deviance"=deviance )
    ic$loglike <- loglike
    ic$logprior <- logprior
    ic$logpost <- logpost
    dev <- deviance
    # xsi parameters
    ic$Nparsxsi <- length(xsi)
    if ( ! is.null( xsi.fixed) ){
        ic$Nparsxsi <- ic$Nparsxsi - nrow(xsi.fixed )
    }
    #-- B slopes
    if (!is.null(AXsi)){
        maxKi <- rowSums( ! is.na(AXsi) ) - 1
        NB <- dim(B_orig)[3]
        NparsB <- 0
        for (dd in 1:NB){
            NparsB <- NparsB + sum( maxKi*(rowSums(B_orig[,,dd]) > 0) )
        }
    }

    ic$NparsB <- 0
    if ( irtmodel=="2PL" ){
        ic$NparsB <- sum( B_orig !=0 )
    }
    if ( irtmodel=="GPCM" ){
        ic$NparsB <- NparsB
    }
    if ( irtmodel=="GPCM.design" ){
        ic$NparsB <- ncol(E)
    }
    if ( irtmodel=="2PL.groups" ){
        ic$NparsB <- length( unique( est.slopegroups ) )
        # This is not yet correct for multiple dimensions and multiple
        # categories
    }
    if ( ! is.null( B.fixed ) ){
        nB <- nrow(B.fixed)
        if ( irtmodel=="GPCM" ){
            nB <- length(B.fixed[ B.fixed[,2]==2,1])
        }
        ic$NparsB <- max(ic$NparsB - nB, 0)
    }

    # beta regression parameters
    ic$Nparsbeta <- dim(beta)[1] * dim(beta)[2]
    if ( ! is.null( beta.fixed) ){
        ic$Nparsbeta <- ic$Nparsbeta - nrow(beta.fixed )
    }
    # variance/covariance matrix
    ic$Nparscov <- ndim + ndim*(ndim-1)/2
    if ( ! est.variance ){
        ic$Nparscov <- ic$Nparscov - ndim
    }
    if ( ! is.null(variance.fixed) ){
        ic$Nparscov <- max(0, ic$Nparscov - nrow(variance.fixed ) )
    }

    if ( ! is.null(variance.Npars) ){
        ic$Nparscov <- variance.Npars
    }
    if ( ! is.null(group) ){
        ic$Nparscov <- ic$Nparscov + length( unique(group) ) - 1
    }
    # total number of parameters
    ic$Npars <- ic$np <- ic$Nparsxsi + ic$NparsB + ic$Nparsbeta + ic$Nparscov

    #- compute total number of observations
    ic$ghp_obs <- tam_ghp_number_informations(pweights=pweights, resp.ind=resp.ind)

    #--- calculate all criteria
    ic <- tam_mml_ic_criteria(ic=ic)

    #--- OUTPUT
    return(ic)
}


.TAM.ic <- tam_mml_ic
