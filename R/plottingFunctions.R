#' @import ggplot2
plotCompChr <- function(input_list = NULL,
                          geneinfo_df = NULL,
                          comp_idx,
                          x.axis = NULL,
                          covar_name = NULL) {
    if (is.null(x.axis)) {
        x.axis <- chrAxisCreator(geneinfo_df)
    }

    if (is.null(geneinfo_df)) {
        stop("Gene position information is missing.")
    }
    p_var <- round(input_list$percent_var[comp_idx], 5)
    covar_name <-
        colnames(input_list$comp_cov[[comp_idx]])[which.min(input_list$comp_cov[[comp_idx]])]

    if (class(input_list) == "ICAobject") {
        geneinfo_df$idx <- seq_len(nrow(geneinfo_df))
        geneinfo_df$loading <-
            input_list$S[as.character(geneinfo_df$phenotype), comp_idx]
        geneinfo_df$peaks <-
            1 * (as.character(geneinfo_df$phenotype) %in% names(input_list$peaks[[comp_idx]]))
        if (!is.null(covar_name)) {
            plot.title <- paste0(
                "IC",
                comp_idx,
                ", ",
                p_var,
                " (%) var, ",
                sum(geneinfo_df$peaks),
                " peaks, ",
                "covariate = ",
                covar_name
            )
        } else {
            plot.title <- paste0("IC",
                                 comp_idx,
                                 ", ",
                                 p_var,
                                 " (%) var, ",
                                 sum(geneinfo_df$peaks),
                                 " peaks")
        }


    } else if (class(input_list) == "PCAobject") {
        geneinfo_df$idx <- seq_len(nrow(geneinfo_df))
        geneinfo_df$loading <-
            input_list$rotation[as.character(geneinfo_df$phenotype), comp_idx]
        geneinfo_df$peaks <-
            1 * (as.character(geneinfo_df$phenotype) %in% names(input_list$peaks[[comp_idx]]))
        if (!is.null(covar_name)) {
            plot.title <- paste0(
                "PC",
                comp_idx,
                ", ",
                p_var,
                " (%) var, ",
                sum(geneinfo_df$peaks),
                " peaks, ",
                "covariate = ",
                covar_name
            )
        } else {
            plot.title <- paste0("PC",
                                 comp_idx,
                                 ", ",
                                 p_var,
                                 " (%) var, ",
                                 sum(geneinfo_df$peaks),
                                 " peaks")
        }

    }

    rects1 <- data.frame(
        xstart = x.axis[1, ],
        xend = x.axis[2, ],
        idx = rep(0),
        loading = rep(0),
        fill.col = factor(rep(c(0, 1),
                              length.out = length(x.axis[1, ])))
    )

    geneinfo_df$plot_factor <- factor(geneinfo_df$peaks)

    p <- ggplot(geneinfo_df, aes_string(x = "idx", y = "loading")) +
        geom_rect(
            data = rects1,
            aes_string(
                xmin = "xstart",
                xmax = "xend",
                ymin = "-Inf",
                ymax = "Inf",
                fill = "fill.col"
            ),
            alpha = 0.35
        ) +
        geom_linerange(aes_string(
            ymin = "0",
            ymax = "loading",
            colour = "plot_factor"
        )) +
        theme_bw() +
        #geom_vline(xintercept=c(0,x.axis[2,]), linetype="dotted") +
        scale_x_continuous(
            "Gene Chromosome Location",
            breaks = x.axis[3, ],
            labels = unique(geneinfo_df$pheno_chr)
        ) +
        scale_y_continuous(expand = c(0, 0)) + labs(title = plot.title) +
        scale_color_manual(values = c("grey", "red")) +
        scale_fill_manual(values = c("skyblue", NA)) +
        ylab("Gene Weights") +
        theme(legend.position = "none")

    return(p)
}

#' @import ggplot2
plotCompNoGeneinfo <- function(input_list = NULL,
                                  comp_idx) {
    p_var <- round(input_list$percent_var[comp_idx], 5)
    covar_name <-
        colnames(input_list$comp_cov[[comp_idx]])[which.min(input_list$comp_cov[[comp_idx]])]

    if (class(input_list) == "ICAobject") {
        comp_df <- data.frame(
            "idx" = seq_len(nrow(input_list$S)),
            "loading" = input_list$S[, comp_idx],
            "peaks" = 1 * (
                as.character(rownames(input_list$S)) %in% names(input_list$peaks[[comp_idx]])
            )
        )

        if (!is.null(covar_name)) {
            plot.title <- paste0(
                "IC",
                comp_idx,
                ", ",
                p_var,
                " (%) var, ",
                sum(comp_df$peaks),
                " peaks, ",
                "covariate = ",
                covar_name
            )
        } else {
            plot.title <- paste0("IC",
                                 comp_idx,
                                 ", ",
                                 p_var,
                                 " (%) var, ",
                                 sum(comp_df$peaks),
                                 " peaks")
        }


    } else if (class(input_list) == "PCAobject") {
        comp_df <- data.frame(
            "idx" = seq_len(nrow(input_list$rotation)),
            "loading" = input_list$rotation[, comp_idx],
            "peaks" = 1 * (
                as.character(rownames(input_list$rotation)) %in% names(input_list$peaks[[comp_idx]])
            )
        )


        if (!is.null(covar_name)) {
            plot.title <- paste0(
                "PC",
                comp_idx,
                ", ",
                p_var,
                " (%) var, ",
                sum(comp_df$peaks),
                " peaks, ",
                "covariate = ",
                covar_name
            )
        } else {
            plot.title <- paste0("PC",
                                 comp_idx,
                                 ", ",
                                 p_var,
                                 " (%) var, ",
                                 sum(comp_df$peaks),
                                 " peaks")
        }

    }

    comp_df$plot_factor <- factor(comp_df$peaks)
    p <- ggplot(comp_df, aes_string(x = "idx", y = "loading")) +
        geom_linerange(aes_string(
            ymin = "0",
            ymax = "loading",
            colour = "plot_factor"
        )) +
        theme_bw() + labs(title = plot.title) +
        scale_color_manual(values = c("grey", "red")) +
        ylab("Gene Weights") +
        theme(legend.position = "none")

    return(p)
}

compCoeffDF <- function(input_list = NULL,
                          comp_idx) {
    if (class(input_list) == "ICAobject") {
        comp_df <- data.frame("coeff" = input_list$A[comp_idx, ],
                              "sample_idx" = seq_len(ncol(input_list$A)))


    } else if (class(input_list) == "PCAobject") {
        comp_df <- data.frame("coeff" = input_list$x[, comp_idx],
                              "sample_idx" = seq_len(nrow(input_list$x)))

    }

    if (attr(input_list, "covar_cor") == "yes") {
        if (length(input_list$comp_cov[[comp_idx]]) > 0) {
            associated_covars <- input_list$comp_cov[[comp_idx]]
            max_assoc <-
                colnames(associated_covars)[which.min(associated_covars)]
            comp_df$covar <- input_list$covars[, max_assoc]
        }

    }

    if (attr(input_list, "clustering") == "yes") {
        if (input_list$n_clust[comp_idx] > 1) {
            comp_df$mclust <-
                as.factor(input_list$mclust_result[[comp_idx]]$classification)
        }
    }

    return(comp_df)

}

chrAxisCreator <- function(geneinfo.df) {
    chromosomes <- unique(geneinfo.df$pheno_chr)
    x.axis <- matrix(0, nrow = 3, ncol = length(chromosomes))
    geneinfo.df$idx <- seq_len(nrow(geneinfo.df))
    for (k in seq_len(length(chromosomes))) {
        j <- as.character(chromosomes[k])

        if (is.na(j)) {
            x.axis[1, k] <- max(x.axis[1, ]) + 1
            x.axis[2, k] <- max(geneinfo.df[, "idx"])
        } else {
            x.axis[1, k] <- min(geneinfo.df[which(geneinfo.df[,"pheno_chr"] == j), "idx"])
            x.axis[2, k] <-
                max(geneinfo.df[which(geneinfo.df[,"pheno_chr"] == j), "idx"])
        }

    }

    x.axis[3, ] <- (x.axis[1, ] + x.axis[2, ]) / 2
    return (x.axis)
}


multiplot <- function(plotlist = NULL,
                      layout = NULL,
                      cols = 1) {
    # Make a list from the ... arguments and plotlist
    #plots <- c(list(...), plotlist)
    plots <- plotlist
    numPlots = length(plots)

    # If layout is NULL, then use 'cols' to determine layout
    if (is.null(layout)) {
        # Make the panel
        # ncol: Number of columns of plots
        # nrow: Number of rows needed, calculated from # of cols
        layout <- matrix(seq(1, cols * ceiling(numPlots / cols)),
                         ncol = cols,
                         nrow = ceiling(numPlots / cols))
    }

    if (numPlots == 1) {
        print(plots[[1]])

    } else {
        # Set up the page
        grid::grid.newpage()
        grid::pushViewport(grid::viewport(layout = grid::grid.layout(nrow(layout), ncol(layout))))

        # Make each plot, in the correct location
        for (i in 1:numPlots) {
            # Get the i,j matrix positions of the regions that contain this subplot
            matchidx <-
                as.data.frame(which(layout == i, arr.ind = TRUE))

            print(
                plots[[i]],
                vp = grid::viewport(
                    layout.pos.row = matchidx$row,
                    layout.pos.col = matchidx$col
                )
            )
        }
    }
}


#' Generate plots for single component
#'
#' Generate gene weight and coefficient plots for a single independent
#' or principal component.
#'
#' @param input_list ICA or PCA object generated by `runICA()` or `runPCA()`
#' @param comp_idx Component number to be plotted.
#' @param geneinfo_df Dataframe containing information about the gene positions.
#'                    This is used to generate the gene weight plot
#' @param plot_here If set to TRUE it will generate the plots in the
#'                  current session, and if set to FALSE it will
#'                  return a list of plots only and not generate plots
#'                  in the current session.
#' @return List of plots
#'
#'
#' @import ggplot2
#'
#' @examples
#' data(expr_data)
#'
#' pca_object <- runPCA(expr_data)
#' plotComponent(pca_object, comp_idx = 1)
#'
#' @export
plotComponent <- function(input_list = NULL,
                           comp_idx,
                           geneinfo_df = NULL,
                           plot_here = TRUE) {
    component_plots <- list()


    if (!is.null(geneinfo_df)) {
        component_plots[[1]] <- plotCompChr(input_list,
                                              comp_idx = comp_idx,
                                              geneinfo_df = geneinfo_df)
    } else {
        component_plots[[1]] <- plotCompNoGeneinfo(input_list,
                                                      comp_idx = comp_idx)
    }

    coeff_plot_df <- compCoeffDF(input_list, comp_idx)

    if (is.null(coeff_plot_df$covar) &
        is.null(coeff_plot_df$mclust)) {
        component_plots[[3]] <- ggplot(coeff_plot_df,
                                       aes_string(x = "sample_idx", y = "coeff")) +
            geom_point() + theme_bw() + theme(legend.position = "none")

        component_plots[[2]] <-
            ggplot(coeff_plot_df, aes_string(x = "coeff")) +
            geom_histogram(alpha = 0.7, position = "identity") +
            coord_flip() + theme_bw() + scale_y_reverse()

    } else if (!is.null(coeff_plot_df$covar)) {
        covar_name <-
            colnames(input_list$comp_cov[[comp_idx]])[which.min(input_list$comp_cov[[comp_idx]])]

        if (class(coeff_plot_df$covar) == "numeric") {
            component_plots[[3]] <- ggplot(coeff_plot_df,
                                           aes_string(
                                               x = "covar",
                                               y = "coeff",
                                               col = "covar"
                                           )) +
                geom_point() + theme_bw() + xlab(covar_name) +
                scale_colour_gradient(low = "blue", high = "red")
        } else {
            component_plots[[3]] <- ggplot(coeff_plot_df,
                                           aes_string(
                                               x = "covar",
                                               y = "coeff",
                                               col = "covar"
                                           )) +
                geom_jitter(width = 0.3) + theme_bw() + xlab(covar_name) +
                theme(
                    axis.text.x = element_text(angle = 90, hjust = 1),
                    legend.position = "none"
                )

        }

        component_plots[[2]] <-
            ggplot(coeff_plot_df, aes_string(x = "coeff",
                                      fill = "covar")) +
            geom_histogram(alpha = 0.7, position = "identity") +
            coord_flip() + theme_bw() + scale_y_reverse() +
            theme(legend.position = "none")

    } else if (is.null(coeff_plot_df$covar) &
               !is.null(coeff_plot_df$mclust)) {
        component_plots[[3]] <- ggplot(coeff_plot_df, aes_string(x = "mclust",
                                                          y = "coeff",
                                                          col = "mclust")) +
            geom_jitter(width = 0.3) + theme_bw() +
            theme(legend.position = "none") +
            scale_colour_brewer(palette = "Dark2") +
            xlab("estimated clusters")

        component_plots[[2]] <- ggplot(coeff_plot_df,
                                       aes_string(x = "coeff",
                                           fill = "mclust")) +
            geom_histogram(alpha = 0.7, position = "identity") +
            coord_flip() + theme_bw() + scale_fill_brewer(palette = "Dark2") +
            scale_y_reverse() + theme(legend.position = "none")
    }

    if (plot_here) {
        suppressMessages(multiplot(
            plotlist = component_plots,
            layout = matrix(
                c(1, 1, 1, 1, 2, 2, 3, 3),
                ncol = 4 ,
                byrow = TRUE
            )
        ))

    }
    return(component_plots)


}

#' @import ggplot2
plotSummary <- function(input_list = NULL,
                         plot_here = TRUE) {
    var_order <- order(input_list$percent_var, decreasing = TRUE)
    summary_df <-
        data.frame(
            "var_percent" = input_list$percent_var[var_order],
            "idx" = seq_len(length(input_list$percent_var)),
            "comp_num" = var_order
        )
    summary_plots <- list()

    # scree of variance explained by each PC
    summary_plots[[1]] <- ggplot(summary_df,
                                 aes_string(x = "idx", y = "var_percent")) +
        geom_bar(stat = 'identity') +
        labs(title = "Variance by Component") +
        ylab("Variance (%) Explained") + theme_bw()

    if (class(input_list) == "PCAobject") {
        summary_plots[[1]] <- summary_plots[[1]] + xlab("PC index")
        proj_df <- data.frame("comp1" = input_list$x[, 1],
                              "comp2" = input_list$x[, 2])
        summary_plots[[2]] <-
            ggplot(proj_df, aes_string(x = "comp1", y = "comp2")) +
            geom_point() + theme_bw()
        if (attr(input_list, "covar_cor") == "yes") {
            if (length(input_list$comp_cov[[1]]) > 0) {
                associated_covars <- input_list$comp_cov[[1]]
                max_assoc <-
                    colnames(associated_covars)[which.min(associated_covars)]
                proj_df$covar <- input_list$covars[, max_assoc]
                summary_plots[[2]] <-
                    ggplot(proj_df, aes_string(
                        x = "comp1",
                        y = "comp2",
                        col = "covar"
                    )) +
                    geom_point() + theme_bw()
            } else if ((length(input_list$comp_cov[[1]]) == 0) &
                       (length(input_list$comp_cov[[2]]) > 0)) {
                associated_covars <- input_list$comp_cov[[2]]
                max_assoc <-
                    colnames(associated_covars)[which.min(associated_covars)]
                proj_df$covar <- input_list$covars[, max_assoc]
                summary_plots[[2]] <-
                    ggplot(proj_df, aes_string(
                        x = "comp1",
                        y = "comp2",
                        col = "covar"
                    )) +
                    geom_point() + theme_bw()
            }
        }
        summary_plots[[2]] <-
            summary_plots[[2]] + xlab("PC1") + ylab("PC2")

    } else if (class(input_list) == "ICAobject") {
        p1 <- order(input_list$percent_var, decreasing = TRUE)[1]
        p2 <- order(input_list$percent_var, decreasing = TRUE)[2]
        summary_plots[[1]] <-
            summary_plots[[1]] + xlab("IC ordered by variance")
        proj_df <- data.frame("comp1" = input_list$A[p1, ],
                              "comp2" = input_list$A[p2, ])

        summary_plots[[2]] <-
            ggplot(proj_df, aes_string(x = "comp1", y = "comp2")) +
            geom_point() + theme_bw()
        if (attr(input_list, "covar_cor") == "yes") {
            if (length(input_list$comp_cov[[p1]]) > 0) {
                associated_covars <- input_list$comp_cov[[p1]]
                max_assoc <-
                    colnames(associated_covars)[which.min(associated_covars)]
                proj_df$covar <- input_list$covars[, max_assoc]
                summary_plots[[2]] <-
                    ggplot(proj_df, aes_string(
                        x = "comp1",
                        y = "comp2",
                        col = "covar"
                    )) +
                    geom_point() + theme_bw()
            } else if ((length(input_list$comp_cov[[p1]]) == 0) &
                       (length(input_list$comp_cov[[p2]]) > 0)) {
                associated_covars <- input_list$comp_cov[[p2]]
                max_assoc <-
                    colnames(associated_covars)[which.min(associated_covars)]
                proj_df$covar <- input_list$covars[, max_assoc]
                summary_plots[[2]] <-
                    ggplot(proj_df, aes_string(
                        x = "comp1",
                        y = "comp2",
                        col = "covar"
                    )) +
                    geom_point() + theme_bw()
            }

        }
        summary_plots[[2]] <-
            summary_plots[[2]] + xlab(paste0("IC", p1)) + ylab(paste0("IC", p2))

    }



    if (plot_here) {
        suppressMessages(multiplot(
            plotlist = summary_plots,
            layout = matrix(c(1, 1, 2, 2),
                            ncol = 4 , byrow = TRUE)
        ))

    }
    return(summary_plots)


}

#' @import ggplot2
plotCovCorSummary <- function(input_list) {
    plot_df <- data.frame(
        "covars" = colnames(input_list$covar_pvals),
        "count" = apply(input_list$covar_pvals, 2,
                        function(x)
                            sum(x < input_list$covar_threshold))
    )

    covar_summary <- ggplot(plot_df, aes_string(x = "covars", y = "count")) +
        geom_bar(stat = 'identity') +
        theme_bw() + xlab("covariate") + ylab("Associated Components")

    print(covar_summary)

    return(covar_summary)
}
