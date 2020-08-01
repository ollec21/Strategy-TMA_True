//+------------------------------------------------------------------+
//|                                      Copyright 2016-2020, kenorb |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

// User input params.
INPUT string __TMA_True_Indi_Params__ = "-- TMA True indicator params --";  // >>> TMA True indicator <<<
INPUT int Indi_TMA_True_TEMAPeriod = 8;                                     // TEMA Period
INPUT int Indi_TMA_True_SvePeriod = 18;                                     // SVE Period
INPUT double Indi_TMA_True_BBUpDeviations = 1.6;                            // BB Up Deviation
INPUT double Indi_TMA_True_BBDnDeviations = 1.6;                            // BB Down Deviation
INPUT int Indi_TMA_True_DeviationsPeriod = 63;                              // Deviations Period
INPUT int Indi_TMA_True_Shift = 0;                                          // Indicator Shift

// Includes.
#include <EA31337-classes/Indicator.mqh>

// Indicator line identifiers used in the indicator.
enum ENUM_SVE_BAND_LINE {
  SVE_BAND_MAIN = 0,   // Main line.
  SVE_BAND_UPPER = 1,  // Upper limit.
  SVE_BAND_LOWER = 2,  // Lower limit.
  FINAL_SVE_BAND_LINE_ENTRY,
};

// Structs.

// Defines struct to store indicator parameter values.
struct Indi_TMA_True_Params : public IndicatorParams {
  // Indicator params.
  int TEMAPeriod;
  int SvePeriod;
  double BBUpDeviations;
  double BBDnDeviations;
  int DeviationsPeriod;
  // Struct constructors.
  void Indi_TMA_True_Params(int _tema_period, int _sve_period, double _deviations_up, double _deviations_down,
                            int _deviations_period, int _shift)
      : TEMAPeriod(_tema_period),
        SvePeriod(_sve_period),
        BBUpDeviations(_deviations_up),
        BBDnDeviations(_deviations_down),
        DeviationsPeriod(_deviations_period) {
    max_modes = FINAL_SVE_BAND_LINE_ENTRY;
    custom_indi_name = "Indi_TMA_True";
    SetDataSourceType(IDATA_ICUSTOM);
    SetDataValueType(TYPE_DOUBLE);
  };
  void Indi_TMA_True_Params(Indi_TMA_True_Params &_params, ENUM_TIMEFRAMES _tf) {
    this = _params;
    _params.tf = _tf;
  }
  // Getters.
  int GetTEMAPeriod() { return TEMAPeriod; }
  int GetSvePeriod() { return SvePeriod; }
  double GetBBUpDeviations() { return BBUpDeviations; }
  double GetBBDnDeviations() { return BBDnDeviations; }
  int GetDeviationsPeriod() { return DeviationsPeriod; }
  // Setters.
  void SetTEMAPeriod(int _value) { TEMAPeriod = _value; }
  void SetSvePeriod(int _value) { SvePeriod = _value; }
  void SetBBUpDeviations(double _value) { BBUpDeviations = _value; }
  void SetBBDnDeviations(double _value) { BBDnDeviations = _value; }
  void SetDeviationsPeriod(int _value) { DeviationsPeriod = _value; }
};

// Defines struct with default user indicator values.
struct Indi_TMA_True_Params_Defaults : Indi_TMA_True_Params {
  Indi_TMA_True_Params_Defaults()
      : Indi_TMA_True_Params(::Indi_TMA_True_TEMAPeriod, ::Indi_TMA_True_SvePeriod, ::Indi_TMA_True_BBUpDeviations,
                             ::Indi_TMA_True_BBDnDeviations, ::Indi_TMA_True_DeviationsPeriod, ::Indi_TMA_True_Shift) {}
} indi_tmat_defaults;

/**
 * Implements indicator class.
 */
class Indi_TMA_True : public Indicator {
 public:
  // Structs.
  Indi_TMA_True_Params params;

  /**
   * Class constructor.
   */
  Indi_TMA_True(Indi_TMA_True_Params &_p)
      : params(_p.TEMAPeriod, _p.SvePeriod, _p.BBUpDeviations, _p.BBDnDeviations, _p.DeviationsPeriod, _p.shift),
        Indicator((IndicatorParams)_p) {
    params = _p;
  }
  Indi_TMA_True(Indi_TMA_True_Params &_p, ENUM_TIMEFRAMES _tf)
      : params(_p.TEMAPeriod, _p.SvePeriod, _p.BBUpDeviations, _p.BBDnDeviations, _p.DeviationsPeriod, _p.shift),
        Indicator(NULL, _tf) {
    params = _p;
  }

  /**
   * Gets indicator's params.
   */
  // Indi_TMA_True_Params GetIndiParams() const { return params; }

  /**
   * Returns the indicator's value.
   *
   */
  double GetValue(ENUM_SVE_BAND_LINE _mode, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), params.custom_indi_name, params.GetTEMAPeriod(),
                         params.GetSvePeriod(), params.GetBBUpDeviations(), params.GetBBDnDeviations(),
                         params.GetDeviationsPeriod(), _mode, _shift);
        break;
      default:
        SetUserError(ERR_USER_NOT_SUPPORTED);
        _value = EMPTY_VALUE;
    }
    istate.is_changed = false;
    istate.is_ready = _LastError == ERR_NO_ERROR;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  IndicatorDataEntry GetEntry(int _shift = 0) {
    long _bar_time = GetBarTime(_shift);
    unsigned int _position;
    IndicatorDataEntry _entry;
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      for (ENUM_SVE_BAND_LINE _mode = 0; _mode < FINAL_SVE_BAND_LINE_ENTRY; _mode++) {
        _entry.value.SetValue(params.idvtype, GetValue(_mode, _shift), _mode);
      }
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, _entry.value.GetMinDbl(params.idvtype) > 0 &&
                                                   _entry.value.GetValueDbl(params.idvtype, SVE_BAND_LOWER) <
                                                       _entry.value.GetValueDbl(params.idvtype, SVE_BAND_UPPER));
      if (_entry.IsValid()) {
        idata.Add(_entry, _bar_time);
      }
    }
    return _entry;
  }
};
