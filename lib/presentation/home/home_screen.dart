import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_pet/domain/model/dog_profile.dart';
import 'package:app_pet/presentation/home/provider/home_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final weightController = TextEditingController();

  LifeStage selectedLifeStage = LifeStage.adultNeutered;
  DogSize selectedSize = DogSize.medium;
  String selectedBreed = 'Labrador Retriever';

  // Mapas para etiquetas humanizadas
  final lifeStageLabels = {
    LifeStage.puppyYoung: 'Cachorro (<4 meses)',
    LifeStage.puppyOld: 'Cachorro (≥4 meses)',
    LifeStage.adultIntact: 'Adulto intacto',
    LifeStage.adultNeutered: 'Adulto esterilizado',
    LifeStage.senior: 'Senior (>7 años)',
  };

  final sizeLabels = {
    DogSize.small: 'Pequeño',
    DogSize.medium: 'Mediano',
    DogSize.large: 'Grande',
  };

  String result = '';

  void calculateFood() {
    final weight = double.tryParse(weightController.text);
    if (weight == null || weight <= 0) {
      setState(() => result = 'Por favor ingresa un peso válido.');
      return;
    }

    // Crear perfil y calcular con Provider
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

Tamaño: ${sizeLabels[selectedSize]}
Edad:   ${lifeStageLabels[selectedLifeStage]}

Calorías diarias: $kcal kcal
Alimento:         $grams g/día
Agua:             $water ml/día
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Calculadora de alimento para perros'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Peso
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Peso del perro (kg)',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Tamaño del perro:'),
              DropdownButton<DogSize>(
                value: selectedSize,
                onChanged: (v) => setState(() => selectedSize = v!),
                items:
                    DogSize.values.map((sz) {
                      return DropdownMenuItem(
                        value: sz,
                        child: Text(sizeLabels[sz]!),
                      );
                    }).toList(),
              ),

              // Edad / etapa de vida (enum LifeStage)
              const SizedBox(height: 8),
              const Text('Edad del perro:'),

              DropdownButton<LifeStage>(
                value: selectedLifeStage,
                onChanged: (v) => setState(() => selectedLifeStage = v!),
                items:
                    LifeStage.values.map((ls) {
                      return DropdownMenuItem(
                        value: ls,
                        child: Text(lifeStageLabels[ls]!),
                      );
                    }).toList(),
              ),

              // Raza (string)
              const SizedBox(height: 16),
              // Botón de cálculo
              Center(
                child: ElevatedButton(
                  onPressed: calculateFood,
                  child: const Text('Calcular'),
                ),
              ),

              const SizedBox(height: 24),
              // Resultados formateados
              Text(result, style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
