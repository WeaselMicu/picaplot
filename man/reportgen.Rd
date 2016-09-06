% Generated by roxygen2 (4.0.2): do not edit by hand
\name{reportgen}
\alias{reportgen}
\title{Generating ICA or PCA summary reports.}
\usage{
reportgen(input_list = NULL, n_comps = NULL, prefix = NULL,
  geneinfo_df = NULL, output.path = NULL, file.ext = "png")
}
\arguments{
\item{input_list}{ICA or PCA result list created by either \code{run_ica()} or \code{run_pca()}.}

\item{n_comps}{Number of components to plot.
Default is set to plot every component.}

\item{prefix}{Output filename prefix. The output file will be named
"prefix_PICA_summary.html".}

\item{geneinfo_df}{Dataframe that contains positions of the genes. Column names should be
"pheno_chr" for chromosomes, "pheno_start" for starting position and "pheno_end" for
ending positions.}

\item{output.path}{Directory path for generating the output HTML file.
default is set to current working directory.}

\item{file.ext}{File extension to be used for saved plots.
Default is set to png for html reports.
Note that if you use pdf plots for html files they will not show up in your report.}
}
\value{
output HTML report.
}
\description{
Generating a HTML report from a ICA or PCA list object.
}
\keyword{keywords}
