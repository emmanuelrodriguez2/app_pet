import 'package:app_pet/domain/model/dog_profile.dart';
import 'package:app_pet/presentation/home/provider/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  static const routeName = '/nutrition';

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final weightController = TextEditingController();

  LifeStage selectedLifeStage = LifeStage.adultNeutered;
  DogSize selectedSize = DogSize.medium;

  final lifeStageLabels = const {
    LifeStage.puppyYoung: 'Cachorro (<4 meses)',
    LifeStage.puppyOld: 'Cachorro (>=4 meses)',
    LifeStage.adultIntact: 'Adulto intacto',
    LifeStage.adultNeutered: 'Adulto esterilizado',
    LifeStage.senior: 'Senior (>7 anos)',
  };

  final sizeLabels = const {
    DogSize.small: 'Pequeno',
    DogSize.medium: 'Mediano',
    DogSize.large: 'Grande',
  };

  String result = '';

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  void calculateFood() {
    final weight = double.tryParse(weightController.text);
    if (weight == null || weight <= 0) {
      setState(() => result = 'Por favor ingresa un peso valido.');
      return;
    }

    final profile = DogProfile(
      weightKg: weight,
      lifeStage: selectedLifeStage,
      size: selectedSize,
    );

    final provider = Provider.of<DogFoodCalculatorProvider>(
      context,
      listen: false,
    );

    provider.setProfile(profile);

    final kcal = provider.dailyCalories?.toStringAsFixed(0);
    final grams = provider.foodGrams?.toStringAsFixed(0);
    final water = provider.waterMl?.toStringAsFixed(0);

    setState(() {
      result = '''
Tamanio: ${sizeLabels[selectedSize]}
Edad: ${lifeStageLabels[selectedLifeStage]}

Calorias diarias: $kcal kcal
Alimento: $grams g/dia
Agua: $water ml/dia
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F4),
      appBar: AppBar(
        title: const Text('Calculadora de alimento'),
        backgroundColor: const Color(0xFFF0EEE9),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nutricion diaria',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF865228),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Calcula porciones recomendadas segun peso, edad y tamano.',
              style: TextStyle(color: Color(0xFF3D494C)),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: const Color(0xFFBCC9CD).withOpacity(0.4)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Peso del perro (kg)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<DogSize>(
                      value: selectedSize,
                      decoration: const InputDecoration(
                        labelText: 'Tamano del perro',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedSize = value);
                        }
                      },
                      items: DogSize.values.map((size) {
                        return DropdownMenuItem(
                          value: size,
                          child: Text(sizeLabels[size]!),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<LifeStage>(
                      value: selectedLifeStage,
                      decoration: const InputDecoration(
                        labelText: 'Etapa de vida',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedLifeStage = value);
                        }
                      },
                      items: LifeStage.values.map((stage) {
                        return DropdownMenuItem(
                          value: stage,
                          child: Text(lifeStageLabels[stage]!),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: calculateFood,
                        icon: const Icon(Icons.calculate),
                        label: const Text('Calcular'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFC8837),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (result.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3EE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(result, style: const TextStyle(fontSize: 16, height: 1.4)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
