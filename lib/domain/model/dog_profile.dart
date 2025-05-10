enum LifeStage {
  puppyYoung, // <4 meses
  puppyOld, // ≥4 meses
  adultIntact,
  adultNeutered,
  senior,
}

enum DogSize { small, medium, large }

class DogProfile {
  final double weightKg;
  final LifeStage lifeStage;
  final DogSize size;
  final double kcalPerGram;

  DogProfile({
    required this.weightKg,
    required this.lifeStage,
    required this.size,
    this.kcalPerGram = 3.5,
  });
}
