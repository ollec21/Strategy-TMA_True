/**
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_TMA_True_Params_M1 : Indi_TMA_True_Params {
  Indi_TMA_True_Params_M1() : Indi_TMA_True_Params(indi_tmat_defaults, PERIOD_M1) {
    atr_multiplier = 0;
    atr_period = 0;
    atr_tf = 0;
    bars_to_process = 0;
    half_length = 0;
    shift = 0;
  }
} indi_tmat_m1;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_TMA_True_Params_M1 : StgParams {
  // Struct constructor.
  Stg_TMA_True_Params_M1() : StgParams(stg_tmat_defaults) {
    lot_size = 0;
    signal_open_method = -4;
    signal_open_filter = 1;
    signal_open_level = (float)0.0;
    signal_open_boost = 1;
    signal_close_method = 0;
    signal_close_level = (float)0.0;
    price_stop_method = 0;
    price_stop_level = (float)0.0;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_tmat_m1;
