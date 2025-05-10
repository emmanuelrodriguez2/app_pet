import 'dart:math';
import 'package:app_pet/domain/model/dog_profile.dart';
import 'package:flutter/foundation.dart';

class DogFoodCalculatorProvider extends ChangeNotifier {
  DogProfile? _profile;
  double? _dailyCalories;
  double? _foodGrams;
  double? _waterMl;

  // Mapea LifeStage → factor MER/RER
  static const _lifeStageFactors = {
    LifeStage.puppyYoung: 3.0,
    LifeStage.puppyOld: 2.0,
    LifeStage.adultIntact: 1.8,
    LifeStage.adultNeutered: 1.6,
    LifeStage.senior: 1.2,
  };

  //factor de raza/tamaño (kcal/kg relativo)
  static const _sizeFactors = {
    DogSize.small: 1.2, // rango alto para small
    DogSize.medium: 1.0, // base
    DogSize.large: 0.8, // rango bajo para large
  };

  void setProfile(DogProfile profile) {
    _profile = profile;
    _calculate();
    notifyListeners();
  }

  void _calculate() {
    if (_profile == null) return;
    final w = _profile!.weightKg;

    // 1) RER
    final rer = 70 * pow(w, 0.75);

    // 2) MER
    final lsf = _lifeStageFactors[_profile!.lifeStage]!;
    final sf = _sizeFactors[_profile!.size]!;
    _dailyCalories = rer * lsf * sf;

    // 3) Alimento en gramos
    _foodGrams = _dailyCalories! / _profile!.kcalPerGram;

    // 4) Agua en ml
    _waterMl = w * 50;
  }

  double? get dailyCalories => _dailyCalories;
  double? get foodGrams => _foodGrams;
  double? get waterMl => _waterMl;
}
