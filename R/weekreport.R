#' Wrapper for IDSR data processing and reporting functions in {epichecks}.
#' Will produce country feedback excel sheets (missings and thresholds),
#' country PDF letters, a weekly excel summary report and will aggregate country
#' data in to one large dataframe.
#'
#' @param current_year The year of interest as numeric (e.g. the default is 2020)
#' @param current_week The week of interest as numeric. The default is 1.
#' Values less than 10 are padded with leading zeros, e.g. 1 becomes 01. (You
#' could also enter 01 and it would be fine)
#' @param week_start First day of the week as accepted for {aweek}.
#' The default for this is "Monday" to confirm with ISO standards.
#' @param input_path File path where IDSR processed data is. The default is set
#' to your current directory, within the "Data Files" folder which should contain a
#' subfolder called "!Imported". Within "!Imported", there should be a folder for
#' each year - which has to fit to the current_year parameter above.
#' Within that a folder for each week, fitting to the current_week param.
#' All excel files within this folder will be read in.
#' @param output_path File path where you would like outputs to be saved to.
#' Within this folder a new folder will be created for the current year, and
#' within that the current week.
#' This defaults to your current directory, with subfolders of
#' Data Files > Output > 2020 > 01.
#' The year folder needs to exist already - only the current week folder will be created.
#' The file itself will labelled with the current week, e.g. "SummaryReport_2020-w01.xlsx"
#'
#' @importFrom aweek set_week_start as.aweek
#' @importFrom stringr str_pad str_glue
#' @importFrom rio import_list
#' @importFrom purrr map
#' @importFrom here here
#'
#' @seealso \code{\link{clean_idsr}} for preparing IDSR data for use with threshold_checker,
#' \code{\link{missing_checker}} for missing flags and \code{\link{threshold_checker}}
#' for threshold flags. In addition, see \code{\link{country_feedback}},
#' \code{\link{country_letters}} and \code{\link{weekly_summary}} for producing
#' feedback to countries; as well as \code{\link{aggregator}} to compile countries
#' in to one dataset.
#'
#' @export
week_report <- function(current_year = 2020,
                        current_week = 1,
                        week_start   = "Monday",
                        input_path   = here::here("Data Files"),
                        output_path  = here::here("Data Files", "Output")
                        ) {

  ## set the day that defines the beginning of your epiweek.
  aweek::set_week_start(week_start)


  ## pad the current week so it is always two values long
  current_week <- stringr::str_pad({current_week}, 2, pad = 0)

  ## set the current epiweek
  current_epiweek <- aweek::as.aweek(str_glue("{current_year}-W{current_week}"))

  ## get paths of all the files in a folder with .xlsx file format
  file_paths <- Sys.glob(str_glue(input_path, "/", current_year, "/",
                                  current_week,  "/!Imported/", "*.xlsx"))

  ## import each excel file individually saved in a list
  ## do not bind them together imediately
  processed_data <- rio::import_list(file_paths, rbind = FALSE, na = "NULL")

  ## apply cleaning steps to each country dataset in list
  processed_data <- purrr::map(processed_data, clean_idsr)

  ## pull country name from first row of country variable
  cleaned_names <- purrr::map_chr(purrr::map(processed_data, "country"), 1L)

  ## overwrite names in processed_data to be simplified country names
  names(processed_data) <- cleaned_names

  ## run missing_checker over each dataset in list to flag missing counts
  processed_data <- purrr::map(processed_data, missing_checker)

  ## run threshold_checker over each dataset in list to flag high counts
  processed_data <- purrr::map(processed_data, threshold_checker)

  ## run country_feedback to produce excel sheet with flags for each country
  ## and return a list with missings and alert flags for each country
  flags <- country_feedback(processed_data,
                            current_year = current_year,
                            current_week = current_week,
                            output_path  = output_path)

  ## run country_letters to produce feedback letters for each country
  country_letters(processed_data,
                  flags = flags,
                  current_year = current_year,
                  current_week = current_week,
                  output_path  = output_path)

  ## run aggregator function to pull together a merged dataset
  processed_data_agg <- aggregator(processed_data,
                                   output_path = str_glue(output_path, "/",
                                                          current_year, "/",
                                                          current_week, "/Merged.Rds"))

  ## run weekly_summary function to produce an excel overview of reports
  summary_report <- weekly_summary(processed_data_agg,
                                   current_year = current_year,
                                   current_week = current_week,
                                   output_path = output_path)
}

