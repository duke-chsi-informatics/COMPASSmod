// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

#ifdef RCPP_USE_GLOBAL_ROSTREAM
Rcpp::Rostream<true>&  Rcpp::Rcout = Rcpp::Rcpp_cout_get();
Rcpp::Rostream<false>& Rcpp::Rcerr = Rcpp::Rcpp_cerr_get();
#endif

// CellCounts
IntegerMatrix CellCounts(List x, List combos);
RcppExport SEXP _COMPASS_CellCounts(SEXP xSEXP, SEXP combosSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< List >::type x(xSEXP);
    Rcpp::traits::input_parameter< List >::type combos(combosSEXP);
    rcpp_result_gen = Rcpp::wrap(CellCounts(x, combos));
    return rcpp_result_gen;
END_RCPP
}
// CellCounts_character
IntegerMatrix CellCounts_character(List data, List combinations);
RcppExport SEXP _COMPASS_CellCounts_character(SEXP dataSEXP, SEXP combinationsSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< List >::type data(dataSEXP);
    Rcpp::traits::input_parameter< List >::type combinations(combinationsSEXP);
    rcpp_result_gen = Rcpp::wrap(CellCounts_character(data, combinations));
    return rcpp_result_gen;
END_RCPP
}
