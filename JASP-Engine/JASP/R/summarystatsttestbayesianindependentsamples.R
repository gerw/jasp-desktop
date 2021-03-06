#
# Copyright (C) 2017 University of Amsterdam
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

SummaryStatsTTestBayesianIndependentSamples <- function(dataset = NULL, options, perform = "run", callback = function(...) 0,  ...) {

	run <- (perform == "run")
	state <- .retrieveState()

	# difference between the previous state options and current options
	diff <- NULL

	if (!is.null(state)) {
		diff <- .diff(options, state$options)
	}

	### options contains:
	## essentials:
	#   tStatistic:       numeric, value of the t-statistic to be converted into a BF
	#   n1Size:           integer, the size of sample 1
	#   n1Size:           integer, the size of sample 2
	#   hypothesis:       string, one of ["notEqualToTestValue", "greaterThanTestValue", "lessThanTestValue"]
	#   priorWidth:       numeric, width of the prior 
	#   bayesFactorType:  string, one of ["BF10", "BF01", "LogBF10"]
	## plotting:
	#   plotPriorAndPosterior:                    logical, make this plot?
	#   plotPriorAndPosteriorAdditionalInfo:      logical,
	#   plotBayesFactorRobustness:                logical,
	#   plotBayesFactorRobustnessAdditionalInfo:  logical,
	## advanced analysis:
	#   effectSize:                     string, one of ["standardized", "dienes"]
	#   effectSizeStandardized:         string, one of ["default", "informative"]
	#   defaultStandardizedEffectSize:  string, can only be "cauchy" for now
	#  -
	#   informativeStandardizedEffectSize:  string, one of ["cauchy", "normal","t"]
	#   informativeCauchyLocation:      numeric, -3 ≤ value ≤ 3, distribution used is dcauchy((tStatistic - CauchyLocation) / CauchyScale)
	#   informativeCauchyScale:         numeric,
	#  - 
	#   informativeTLocation:           numeric, -3 ≤ value ≤ 3, distribution used is dt((tStatistic - Tlocation) / Tscale, TDf)
	#   informativeTScale:              numeric, 0 ≤ value ≤ 2
	#   informativeTDf:                 integer, 1 ≤ value ≤ 500
	#  -
	#   informativeNormalMean:          numeric, -3 ≤ value ≤ 3, normal used is dnorm((tStatistic - NormalMean) / NormalStd)
	#   informativeNormalStd:           numeric, 0 ≤ value ≤ 2
	#  -
	#   dienesEffectSize:               string, one of ["uniform", "normal", "half_normal"]
	#   uniformDienesLowerBound:        numeric, 0 ≤ value ≤ 2, not guarantee to be smaller than uniformDienesUpperBound (???)
	#   uniformDienesUpperBound:        numeric, 0 ≤ value ≤ 2
	#   normalDienesMean:               numeric, 0 ≤ value ≤ 2
	#   normalDienesStd:                numeric, 0 ≤ value ≤ 2
	#   halfNormalDienesStd:            numeric, 0 ≤ value ≤ 2
	
	
	
	# Bayes factor type (BF10, BF01, log(BF10)) and title
	bftype <- .getBayesfactorTitle.summarystats.ttest(
								bayesFactorType = options$bayesFactorType,
								hypothesis = options$hypothesis
							)
	bf.title <- bftype$bftitle
	BFH1H0 <- bftype$BFH1H0

	hypothesis.variables <- .hypothesisType.summarystats.ttest.independent(options$hypothesis)
	oneSided <- hypothesis.variables$oneSided

	# initialize variables
	plots.sumstats.ttest <- list()
	plotTypes <- list()
	priorAndPosteriorPlot <- NULL
	bayesFactorRobustnessPlot <- NULL

	outputTableElements <- .getOutputRow.summarystats.ttest.independent(
														run = run,
														options = options,
														state = state,
														diff = diff,
														hypothesis.variables = hypothesis.variables
													)
	rowsTTestBayesianIndependentSamples <- outputTableElements$row
	bayesFactorObject <- outputTableElements$bayesFactorObject

	# Get prior and posterior plot
	if (options$plotPriorAndPosterior) {
		priorAndPosteriorPlot <- .getPriorAndPosteriorPlot.summarystats.ttest(
																run = run,
																options = options,
																state = state,
																diff = diff,
																bayesFactorObject = bayesFactorObject,
																oneSided = oneSided,
																paired = FALSE
															)
		plots.sumstats.ttest[[length(plots.sumstats.ttest) + 1]] <- priorAndPosteriorPlot
		if(options$plotPriorAndPosteriorAdditionalInfo) {
			plotTypes[[length(plotTypes) + 1]] <- "posteriorPlotAddInfo"
		} else {
			plotTypes[[length(plotTypes) + 1]] <- "posteriorPlot"
		}
	}

	# Get Bayes factor robustness plot
	if (options$plotBayesFactorRobustness) {
		bayesFactorRobustnessPlot <- .getBayesFactorRobustnessPlot.summarystats.ttest(
																		run = run,
																		options = options,
																		state = state,
																		diff = diff,
																		bayesFactorObject = bayesFactorObject,
																		oneSided = oneSided
																	)
		plots.sumstats.ttest[[length(plots.sumstats.ttest) + 1]] <- bayesFactorRobustnessPlot
		if(options$plotBayesFactorRobustnessAdditionalInfo) {
			plotTypes[[length(plotTypes) + 1]] <- "robustnessPlotAddInfo"
		} else {
			plotTypes[[length(plotTypes) + 1]] <- "robustnessPlot"
		}
	}

	# Populate the output table
	meta <- list()
	meta[[1]] <- list(name = "table", type = "table")
	meta[[2]] <- list(name = "inferentialPlots", type = "object",
										meta = list(list(name = "PriorPosteriorPlot", type = "image"),
																list(name = "BFrobustnessPlot", type = "image"))
									)

	fields <- list()
	fields[[length(fields)+1]] <- list(name = "tStatistic", type = "number", format = "sf:4;dp:3", title = "t")
	fields[[length(fields)+1]] <- list(name = "n1Size", type = "number", title = "n\u2081")
	fields[[length(fields)+1]] <- list(name = "n2Size", type = "number", title = "n\u2082")
	fields[[length(fields)+1]] <- list(name = "BF", type = "number", format = "sf:4;dp:3", title = bf.title)
	if (rowsTTestBayesianIndependentSamples$errorEstimate != "NaN") {
		fields[[length(fields)+1]] <- list(name = "errorEstimate", type = "number", format = "sf:4;dp:3", title = "error %")
	}
	fields[[length(fields)+1]] <- list(name = "pValue", type = "number", format = "sf:4;dp:3", title = "p")

	# add footnotes to the analysis result
	footnotes <- .newFootnotes()
	if (options$hypothesis != "groupsNotEqual") {
		.addFootnote(footnotes, symbol = "<em>Note.</em>", text = hypothesis.variables$message)
	}

	table <- list()
	table[["title"]] <- "Bayesian Independent Samples T-Test"
	table[["citation"]] <- list(
		"Morey, R. D., & Rouder, J. N. (2015). BayesFactor (Version 0.9.11-3)[Computer software].",
		"Rouder, J. N., Speckman, P. L., Sun, D., Morey, R. D., & Iverson, G. (2009). Bayesian t tests for accepting and rejecting the null hypothesis. Psychonomic Bulletin & Review, 16, 225–237.")
	table[["footnotes"]] <- as.list(footnotes)
	table[["schema"]] <- list(fields = fields)
	table[["data"]] <- list(rowsTTestBayesianIndependentSamples)

	results <- list()
	results[[".meta"]] <- meta
	results[["title"]] <- "Bayesian T-Test"
	results[["table"]] <- table

	if (options$plotPriorAndPosterior || options$plotBayesFactorRobustness) {
		results[["inferentialPlots"]] <- list(
										title = ifelse(sum(c(options$plotPriorAndPosterior,
																				options$plotBayesFactorRobustness)) > 1,
														"Inferential Plots",
														"Inferential Plot"),
										PriorPosteriorPlot = priorAndPosteriorPlot,
										BFrobustnessPlot = bayesFactorRobustnessPlot
								)
	}

	keep <- NULL

	for (plot in plots.sumstats.ttest) {
		keep <- c(keep, plot$data)
	}

	if (run) {
		status <- "complete"
		state <- list(options = options, bayesFactorObject = bayesFactorObject,
								rowsTTestBayesianIndependentSamples = rowsTTestBayesianIndependentSamples,
								plotsTtest = plots.sumstats.ttest, plotTypes = plotTypes)
	} else {
		status <- "inited"
	}

	return(list(results = results,
							status = status,
							state = state,
							keep = keep)
				)
}


.getOutputRow.summarystats.ttest.independent <- function(run, options, state, diff, hypothesis.variables) {
	# Returns a row to be shown in output tables
	#
	# Args:
	#   run: state of analysis - init or run
	#   options: a list of user options
	#   state: previous options state
	#   diff: diff between previous and current options
	#
	# Output:
	#   list containing:
	#      row containing output elements to be shown in table
	#      Bayes factor object

	rowsTTestBayesianIndependentSamples <- NULL
	bayesFactorObject <- NULL
	status <- NULL

	if (!is.null(state) && !is.null(diff) && !is.null(state$bayesFactorObject) && 
	    !any(unlist(diff))) {
	  
		rowsTTestBayesianIndependentSamples <- state$rowsTTestBayesianIndependentSamples
		bayesFactorObject <- state$bayesFactorObject

	} else {
		status <- .isInputValid.summarystats.ttest(options = options, independent = TRUE)
		rowsTTestBayesianIndependentSamples <- status$row

		# if state of analysis is run
		if (run) {
			if (status$ready) {

				## Compute the statistics
				
				bayesFactorObject <- .generalSummaryTtestBF(options = options)
				
				
				## Format the statistics for output
				
				bf <- bayesFactorObject$bf
				BF <- switch(options$bayesFactorType, BF10=bf, BF01=1/bf, log(bf))
				
				allPValues <- bayesFactorObject$pValue
				pValue <- switch(as.character(hypothesis.variables$oneSided), left=allPValues$minSided,
				                 right=allPValues$plusSided, allPValues$twoSided)
				
				## Store statistics in table row ouput structure
				
				rowsTTestBayesianIndependentSamples$BF <- .clean(BF)
				rowsTTestBayesianIndependentSamples$errorEstimate <- .clean(bayesFactorObject$properror)
				rowsTTestBayesianIndependentSamples$pValue <- .clean(pValue)
				
			}
		}
	}

	return(list(row = rowsTTestBayesianIndependentSamples, bayesFactorObject = bayesFactorObject))
}


.hypothesisType.summarystats.ttest.independent <- function(hypothesis) {
	# Returns different values that are based on the hypothesis chosen
	#   by the user
	#
	# Args:
	#   hypothesis: the hypothesis selected by user
	#
	# Output:
	#   list containing:
	#     nullInterval: vector containing lower and upper bounds of an interval hypothesis
	#     oneSided: if the hypothesis is one sided
	#
	nullInterval <- NULL
	oneSided <- FALSE

	if (hypothesis == "groupOneGreater") {

		nullInterval <- c(0, Inf)
		oneSided <- "right"
		message <- paste("For all tests, the alternative hypothesis specifies that group 1 is greater than group 2", sep = "")

	} else if (hypothesis == "groupTwoGreater") {

		nullInterval <- c(-Inf, 0)
		oneSided <- "left"
		message <- paste("For all tests, the alternative hypothesis specifies that group 1 is lesser than group 2", sep = "")
	}

	return(list(nullInterval = nullInterval,
							oneSided = oneSided,
							message = message)
				)
}
