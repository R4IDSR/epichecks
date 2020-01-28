% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/weekreport.R
\name{week_report}
\alias{week_report}
\title{Wrapper for IDSR data processing and reporting functions in {epichecks}.
Will produce country feedback excel sheets (missings and thresholds),
country PDF letters, a weekly excel summary report and will aggregate country
data in to one large dataframe.}
\usage{
week_report(
  current_week = "2018-W35",
  week_start = "Monday",
  input_path = here::here("Data", "Processed"),
  output_path = here::here("Data", "Outputs", "Verification")
)
}
\arguments{
\item{current_week}{The week of interest as a character or {aweek} object.
Needs to be in the correct format ("YYYY-Www").
The default "2018-W35" is just to demonstrate the necessary format.}

\item{week_start}{First day of the week as accepted for {aweek}.
The default for this is "Monday" to confirm with ISO standards.}

\item{input_path}{File path where IDSR processed data is. The default is set
to your current directory, within the "Data" folder which should contain a
subfolder called "Processed" and then within that a folder for each week with
the appropriate data. The week forlder should be named the same way as
the current_week param.}

\item{output_path}{File path where you would like outputs to be saved to.
Within this folder a new folder will be created and named after the current week.
This defaults to your current directory, with subfolders of data > outputs > verification.
These folders need to exist already - only the current week folder will be created.
The file itself will labelled with the current week, e.g. "SummaryReport_2018-w35.xlsx"}
}
\description{
Wrapper for IDSR data processing and reporting functions in {epichecks}.
Will produce country feedback excel sheets (missings and thresholds),
country PDF letters, a weekly excel summary report and will aggregate country
data in to one large dataframe.
}
\seealso{
\code{\link{clean_data}} for preparing IDSR data for use with threshold_checker,
\code{\link{missing_checker}} for missing flags and \code{\link{threshold_checker}}
for threshold flags. In addition, see \code{\link{country_feedback}},
\code{\link{country_letters}} and \code{\link{weekly_summary}} for producing
feedback to countries; as well as \code{\link{aggregator}} to compile countries
in to one dataset.
}