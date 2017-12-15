library(tidyverse)
library(spartan)
library(here)

data.path <- here('security-data_swarmtaxis')

samplesizes <- c(1,5,10, 20, 50, 100, 150, 200)
measures <- c('swarmsize', 'ticks')
subsets <- 20
fileformat <- 'csv'
filename <- 'ticks.csv'
colstart <- 1

colend <- 3
medians_filename <- 'swarmsecurity_medians.csv'
atest_filename   <- 'swarmsecurity_atests.csv'
summary_filename <- 'swarmsecurity_summary.csv'
graph_filename   <- 'swarmsecurity_atestmaxes.pdf'

largediff <- 0.23
small <- .56
medium <- .66
large <- .73

timepoints <- NULL
timepoints_scale <- NULL


aa_summariseReplicateRuns(  data.path, 
                            samplesizes, 
                            measures, 
                            filename, 
                            NULL, 
                            colstart,
                            colend,
                            medians_filename)

atestResults <- aa_getATestResults(data.path,
                            samplesizes,
                            subsets,
                            measures,
                            atest_filename,
                            largediff,
                            AA_SIM_RESULTS_FILE = medians_filename)

aa_sampleSizeSummary(       data.path, 
                            samplesizes, 
                            measures,
                            summary_filename,
                            atest_filename)
                     
aa_graphSampleSizeSummary(  data.path, 
                            measures, 
                            max(samplesizes),
                            small,
                            medium, 
                            large,
                            graph_filename, 
                            SAMPLESUMMARY_FILE = summary_filename)

 #  aa_analyse_all_sample_sizes(FILEPATH, SAMPLESIZES, NUMSUBSETSPERSAMPLESIZE,
 #  RESULTFILEFORMAT, RESULTFILENAME, ALTFILENAME, OUTPUTFILECOLSTART,
 #  OUTPUTFILECOLEND, MEASURES, MEDIANSFILEFORMAT,MEDIANSFILENAME,
 #  ATESTRESULTFILENAME, LARGEDIFFINDICATOR)
 
 # aa_sampleSizeSummary(FILEPATH,SAMPLESIZES,MEASURES,ATESTRESULTFILENAME,
 #  SUMMARYFILENAME)

 
 #  aa_getATestResults(FILEPATH, SAMPLESIZES, NUMSUBSETSPERSAMPLESIZE, MEASURES,
 #  MEDIANSFILENAME, ATESTRESULTFILENAME, LARGEDIFFINDICATOR)
 
 # aa_sampleSizeSummary(FILEPATH,SAMPLESIZES,MEASURES,ATESTRESULTFILENAME,
 #  SUMMARYFILENAME)
 
 # aa_graphSampleSizeSummary(FILEPATH,MEASURES, 400,SMALL, MEDIUM, LARGE,
                           # SUMMARYFILENAME, GRAPHOUTPUTFILE, TIMEPOINTS,TIMEPOINTSCALE)
 
 #  aa_graphSampleSizeSummary(FILEPATH,MEASURES, 300,SMALL, MEDIUM, LARGE,
 # SUMMARYFILENAME, GRAPHOUTPUTFILE)
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 