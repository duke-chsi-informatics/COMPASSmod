// This file was automatically generated by Kmisc::registerFunctions()

#include <R.h>
#include <Rinternals.h>

#include <R_ext/Rdynload.h>

SEXP melt_dataframe(SEXP x,
                    SEXP id_ind_,
                    SEXP val_ind_,
                    SEXP variable_name,
                    SEXP value_name);
SEXP melt_matrix(SEXP x);
SEXP transpose_list(SEXP x);
SEXP _COMPASS_CellCounts_character(SEXP dataSEXP, SEXP combinationsSEXP);
SEXP _COMPASS_CellCounts(SEXP xSEXP, SEXP combosSEXP);
SEXP samplePuPs(SEXP alphau,
                SEXP alphas,
                SEXP gammat,
                SEXP T,
                SEXP K,
                SEXP nsi,
                SEXP nui,
                SEXP d,
                SEXP M);
SEXP samplePuPs_full(SEXP alphau,
                     SEXP alphas,
                     SEXP gammat,
                     SEXP T,
                     SEXP K,
                     SEXP nsi,
                     SEXP nui,
                     SEXP d,
                     SEXP M);
SEXP updatealphas_Exp(SEXP alphast,
                      SEXP n_s,
                      SEXP K,
                      SEXP I,
                      SEXP lambda_s,
                      SEXP gammat,
                      SEXP var_1,
                      SEXP var_2,
                      SEXP p_var,
                      SEXP ttt);
SEXP updatealphas_Exp_MH(SEXP alphast,
                         SEXP n_s,
                         SEXP K,
                         SEXP I,
                         SEXP lambda_s,
                         SEXP gammat,
                         SEXP var_1,
                         SEXP var_2,
                         SEXP p_var);
SEXP updatealphau_noPu_Exp(SEXP alphaut,
                           SEXP n_s,
                           SEXP n_u,
                           SEXP I,
                           SEXP K,
                           SEXP lambda_u,
                           SEXP var_p,
                           SEXP ttt,
                           SEXP gammat);
SEXP updatealphau_noPu_Exp_MH(SEXP alphaut,
                              SEXP n_s,
                              SEXP n_u,
                              SEXP I,
                              SEXP K,
                              SEXP lambda_u,
                              SEXP var_p,
                              SEXP gammat);
SEXP updategammak_noPu(SEXP n_s,
                       SEXP n_u,
                       SEXP gammat,
                       SEXP I,
                       SEXP K,
                       SEXP SS,
                       SEXP alphau,
                       SEXP alphas,
                       SEXP alpha,
                       SEXP mk,
                       SEXP Istar,
                       SEXP mKstar,
                       SEXP pp,
                       SEXP pb1,
                       SEXP pb2,
                       SEXP indi);

R_CallMethodDef callMethods[] = {
    {"C_melt_dataframe", (DL_FUNC) & melt_dataframe, 5},
    {"C_melt_matrix", (DL_FUNC) & melt_matrix, 1},
    {"C_transpose_list", (DL_FUNC) & transpose_list, 1},
    {"C_COMPASS_CellCounts_character", (DL_FUNC) & _COMPASS_CellCounts_character,
     2},
    {"C_COMPASS_CellCounts", (DL_FUNC) & _COMPASS_CellCounts, 2},
    {"C_samplePuPs", (DL_FUNC) & samplePuPs, 9},
    {"C_samplePuPs_full", (DL_FUNC) &samplePuPs_full, 9},
    {"C_updatealphas_Exp", (DL_FUNC) & updatealphas_Exp, 10},
    {"C_updatealphas_Exp_MH", (DL_FUNC) & updatealphas_Exp_MH, 9},
    {"C_updatealphau_noPu_Exp", (DL_FUNC) & updatealphau_noPu_Exp, 9},
    {"C_updatealphau_noPu_Exp_MH", (DL_FUNC) & updatealphau_noPu_Exp_MH, 8},
    {"C_updategammak_noPu", (DL_FUNC) & updategammak_noPu, 16},
    {NULL, NULL, 0}};

void R_init_COMPASS(DllInfo* info) {
  R_registerRoutines(info, NULL, callMethods, NULL, NULL);
  R_useDynamicSymbols(info, FALSE);
}
