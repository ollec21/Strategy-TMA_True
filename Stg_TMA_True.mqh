/**
 * @file
 * Implements TMA_True strategy based on the TMA_True indicator.
 */

// User input params.
INPUT float TMA_True_LotSize = 0;               // Lot size
INPUT int TMA_True_Shift = 0;                   // Shift (relative to the current bar, 0 - default)
INPUT int TMA_True_SignalOpenMethod = 0;        // Signal open method
INPUT int TMA_True_SignalOpenFilterMethod = 0;  // Signal open filter method
INPUT float TMA_True_SignalOpenLevel = 0;       // Signal open level
INPUT int TMA_True_SignalOpenBoostMethod = 0;   // Signal open boost method
INPUT int TMA_True_SignalCloseMethod = 0;       // Signal close method
INPUT float TMA_True_SignalCloseLevel = 0;      // Signal close level
INPUT int TMA_True_PriceLimitMethod = 0;        // Price limit method
INPUT float TMA_True_PriceLimitLevel = 2;       // Price limit level
INPUT int TMA_True_TickFilterMethod = 1;        // Tick filter method (0-255)
INPUT float TMA_True_MaxSpread = 2.0;           // Max spread to trade (in pips)

// Includes.
//#include <EA31337-classes/Indicators/Indi_TMA_True.mqh>
#include <EA31337-classes/Strategy.mqh>

// Defines struct with default user strategy values.
struct Stg_TMA_True_Params_Defaults : StgParams {
  Stg_TMA_True_Params_Defaults()
      : StgParams(::TMA_True_SignalOpenMethod, ::TMA_True_SignalOpenFilterMethod, ::TMA_True_SignalOpenLevel,
                  ::TMA_True_SignalOpenBoostMethod, ::TMA_True_SignalCloseMethod, ::TMA_True_SignalCloseLevel,
                  ::TMA_True_PriceLimitMethod, ::TMA_True_PriceLimitLevel, ::TMA_True_TickFilterMethod,
                  ::TMA_True_MaxSpread, ::TMA_True_Shift) {}
} stg_tmat_defaults;

// Defines struct to store indicator and strategy params.
struct Stg_TMA_True_Params {
  StgParams sparams;

  // Struct constructors.
  Stg_TMA_True_Params(StgParams &_sparams) : sparams(stg_tmat_defaults) { sparams = _sparams; }
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_H8.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_TMA_True : public Strategy {
 public:
  Stg_TMA_True(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_TMA_True *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    StgParams _stg_params(stg_tmat_defaults);
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<StgParams>(_stg_params, _tf, stg_tmat_m1, stg_tmat_m5, stg_tmat_m15, stg_tmat_m30, stg_tmat_h1,
                               stg_tmat_h4, stg_tmat_h8);
    }
    // Initialize indicator.
    //_stg_params.SetIndicator(new Indi_TMA_True());
    // Initialize strategy parameters.
    _stg_params.GetLog().SetLevel(_log_level);
    _stg_params.SetMagicNo(_magic_no);
    _stg_params.SetTf(_tf, _Symbol);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_TMA_True(_stg_params, "TMA True");
    _stg_params.SetStops(_strat, _strat);
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f) {
    Indicator *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid();
    bool _result = _is_valid;
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    double _value = _indi[CURR][0];
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        // Buy signal.
        _result = _indi[CURR][0] < _indi[PREV][0];
        break;
      case ORDER_TYPE_SELL:
        // Sell signal.
        _result = _indi[CURR][0] < _indi[PREV][0];
        break;
    }
    return _result;
  }

  /**
   * Gets price limit value for profit take or stop loss.
   */
  float PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0f) {
    // Indicator *_indi = Data();
    double _trail = _level * Market().GetPipSize();
    // int _bar_count = (int)_level * 10;
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    // ENUM_APPLIED_PRICE _ap = _direction > 0 ? PRICE_HIGH : PRICE_LOW;
    switch (_method) {
      case 1:
        // Trailing stop here.
        break;
    }
    return (float)_result;
  }
};
