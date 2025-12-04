import 'package:chikitsha_munshi/screens/home/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// void main() {
//   runApp(const HealthToolsApp());
// }

class HealthToolsApp extends StatelessWidget {
  const HealthToolsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF0E9384),
      scaffoldBackgroundColor: const Color(0xFFF7F9FA),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chikitsha Munshi – Health Tools',
      theme: theme,
      home: const HealthToolsHomePage(),
      routes: {
        BMIPage.route: (_) => const BMIPage(),
        DiabetesRiskPage.route: (_) => const DiabetesRiskPage(),
        BloodPressurePage.route: (_) => const BloodPressurePage(),
      },
    );
  }
}

/// Home page listing all tools
class HealthToolsHomePage extends StatelessWidget {
  const HealthToolsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Health Tools'),
        automaticallyImplyLeading: true, // shows back only if possible
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ToolCard(
            icon: Icons.monitor_weight,
            title: 'BMI Calculator',
            subtitle: 'Check your Body Mass Index and see guidance.',
            onTap: () => Navigator.pushNamed(context, BMIPage.route),
          ),
          _ToolCard(
            icon: Icons.bloodtype,
            title: 'Diabetes Risk Quiz',
            subtitle: 'Quick questionnaire to estimate diabetes risk.',
            onTap: () => Navigator.pushNamed(context, DiabetesRiskPage.route),
          ),
          _ToolCard(
            icon: Icons.favorite,
            title: 'Blood Pressure Checker',
            subtitle: 'Classify your BP reading and get awareness tips.',
            onTap: () => Navigator.pushNamed(context, BloodPressurePage.route),
          ),
          const SizedBox(height: 12),
          const _DisclaimerCard(),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  icon,
                  size: 28,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'These tools are for general awareness only and are not a substitute for professional medical advice. Always consult a qualified provider for diagnosis and treatment.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------- BMI PAGE ---------------------------------
class BMIPage extends StatefulWidget {
  static const route = '/bmi';
  const BMIPage({super.key});

  @override
  State<BMIPage> createState() => _BMIPageState();
}

class _BMIPageState extends State<BMIPage> {
  final _formKey = GlobalKey<FormState>();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  double? _bmi;
  String? _category;
  String? _advice;

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    if (!_formKey.currentState!.validate()) return;

    final heightCm = double.parse(_heightCtrl.text);
    final weightKg = double.parse(_weightCtrl.text);
    final heightM = heightCm / 100.0;
    final bmi = weightKg / (heightM * heightM);

    final cat = _bmiCategory(bmi);
    final advice = _bmiAdvice(cat);

    setState(() {
      _bmi = bmi;
      _category = cat;
      _advice = advice;
    });
  }

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    if (bmi < 35) return 'Obesity Class I';
    if (bmi < 40) return 'Obesity Class II';
    return 'Obesity Class III';
  }

  String _bmiAdvice(String category) {
    switch (category) {
      case 'Underweight':
        return 'Consider nutrition-focused evaluation. Suggested labs: CBC, Thyroid Profile (T3/T4/TSH), Vitamin B12, Vitamin D.';
      case 'Normal':
        return 'Maintain balanced diet and regular activity. Annual basic screening recommended.';
      case 'Overweight':
        return 'Focus on diet and activity. Suggested labs: Lipid Profile, Fasting Blood Sugar, HbA1c, Liver Function Tests.';
      case 'Obesity Class I':
      case 'Obesity Class II':
      case 'Obesity Class III':
        return 'Medical guidance advised. Suggested labs: Comprehensive Metabolic Panel, Lipid Profile, HbA1c, Thyroid Profile.';
      default:
        return '';
    }
  }

  Color _categoryColor(String? category) {
    switch (category) {
      case 'Underweight':
        return Colors.blueGrey;
      case 'Normal':
        return Colors.green;
      case 'Overweight':
        return Colors.orange;
      case 'Obesity Class I':
      case 'Obesity Class II':
      case 'Obesity Class III':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BMI Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _heightCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Height (cm)',
                                hintText: 'e.g., 170',
                                prefixIcon: Icon(Icons.height),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^[0-9]*\.?[0-9]*$'),
                                ),
                              ],
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Enter height';
                                final x = double.tryParse(v);
                                if (x == null || x < 50 || x > 300)
                                  return 'Enter valid height (50–300)';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _weightCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Weight (kg)',
                                hintText: 'e.g., 65',
                                prefixIcon: Icon(Icons.monitor_weight),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^[0-9]*\.?[0-9]*$'),
                                ),
                              ],
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Enter weight';
                                final x = double.tryParse(v);
                                if (x == null || x < 10 || x > 500)
                                  return 'Enter valid weight (10–500)';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.calculate),
                          label: const Text('Calculate BMI'),
                          onPressed: _calculateBMI,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_bmi != null) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Your BMI',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          Chip(
                            label: Text(_category!),
                            backgroundColor: _categoryColor(
                              _category,
                            ).withOpacity(0.12),
                            side: BorderSide(color: _categoryColor(_category)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _bmi!.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _advice ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const _BMITable(),
            ],
          ],
        ),
      ),
    );
  }
}

class _BMITable extends StatelessWidget {
  const _BMITable();
  @override
  Widget build(BuildContext context) {
    final rows = [
      ['< 18.5', 'Underweight'],
      ['18.5 – 24.9', 'Normal'],
      ['25.0 – 29.9', 'Overweight'],
      ['30.0 – 34.9', 'Obesity Class I'],
      ['35.0 – 39.9', 'Obesity Class II'],
      ['≥ 40.0', 'Obesity Class III'],
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BMI Categories',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(2),
              },
              children: [
                const TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'BMI',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Category',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                ...rows.map(
                  (r) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(r[0]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(r[1]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------- DIABETES RISK PAGE ---------------------------
class DiabetesRiskPage extends StatefulWidget {
  static const route = '/diabetes-risk';
  const DiabetesRiskPage({super.key});

  @override
  State<DiabetesRiskPage> createState() => _DiabetesRiskPageState();
}

class _DiabetesRiskPageState extends State<DiabetesRiskPage> {
  int _ageIndex = 1; // 0:<35, 1:35-44, 2:45-54, 3:55-64, 4:65+
  int _bmiIndex = 1; // 0:Normal, 1:Overweight, 2:Obese
  int _activityIndex = 1; // 0:High, 1:Moderate, 2:Low
  bool _familyHistory = false;
  bool _highBpHistory = false;

  int _score = 0;
  String _risk = '';
  String _advice = '';

  void _calculate() {
    int score = 0;
    // Simple, lightweight scoring inspired by common risk tools (not diagnostic)
    switch (_ageIndex) {
      case 0:
        score += 0;
        break;
      case 1:
        score += 1;
        break;
      case 2:
        score += 2;
        break;
      case 3:
        score += 3;
        break;
      case 4:
        score += 4;
        break;
    }
    switch (_bmiIndex) {
      case 0:
        score += 0; // normal
        break;
      case 1:
        score += 2; // overweight
        break;
      case 2:
        score += 4; // obese
        break;
    }
    switch (_activityIndex) {
      case 0:
        score += 0; // high
        break;
      case 1:
        score += 1; // moderate
        break;
      case 2:
        score += 2; // low
        break;
    }
    if (_familyHistory) score += 2;
    if (_highBpHistory) score += 2;

    String risk;
    String advice;
    if (score <= 3) {
      risk = 'Low';
      advice =
          'Maintain balanced diet and regular physical activity. Routine annual screening is advisable.';
    } else if (score <= 6) {
      risk = 'Moderate';
      advice =
          'Consider lifestyle improvements and screening. Suggested labs: Fasting Blood Sugar, HbA1c.';
    } else {
      risk = 'High';
      advice =
          'Consult a healthcare provider for evaluation. Suggested labs: HbA1c, Fasting Blood Sugar, Lipid Profile.';
    }

    setState(() {
      _score = score;
      _risk = risk;
      _advice = advice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diabetes Risk Quiz')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _RadioCard<int>(
              title: 'Age Group',
              value: _ageIndex,
              items: const [
                (0, '< 35 years'),
                (1, '35–44 years'),
                (2, '45–54 years'),
                (3, '55–64 years'),
                (4, '65+ years'),
              ],
              onChanged: (v) => setState(() => _ageIndex = v),
            ),
            _RadioCard<int>(
              title: 'Weight Status (self-assessed / recent BMI)',
              value: _bmiIndex,
              items: const [(0, 'Normal'), (1, 'Overweight'), (2, 'Obese')],
              onChanged: (v) => setState(() => _bmiIndex = v),
            ),
            _RadioCard<int>(
              title: 'Physical Activity',
              value: _activityIndex,
              items: const [
                (0, 'High (≥150 min/week)'),
                (1, 'Moderate (60–149 min/week)'),
                (2, 'Low (<60 min/week)'),
              ],
              onChanged: (v) => setState(() => _activityIndex = v),
            ),
            _SwitchCard(
              title: 'Family history of diabetes (parents/siblings)?',
              value: _familyHistory,
              onChanged: (v) => setState(() => _familyHistory = v),
            ),
            _SwitchCard(
              title: 'History of high blood pressure?',
              value: _highBpHistory,
              onChanged: (v) => setState(() => _highBpHistory = v),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.analytics),
                label: const Text('Calculate Risk'),
                onPressed: _calculate,
              ),
            ),
            if (_risk.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Your Risk',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          Chip(
                            label: Text(_risk),
                            backgroundColor: _riskColor(
                              _risk,
                            ).withOpacity(0.12),
                            side: BorderSide(color: _riskColor(_risk)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Score: $_score',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(_advice),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _riskColor(String risk) {
    switch (risk) {
      case 'Low':
        return Colors.green;
      case 'Moderate':
        return Colors.orange;
      case 'High':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _RadioCard<T> extends StatelessWidget {
  final String title;
  final T value;
  final List<(T, String)> items; // Dart 3 record type for brevity
  final ValueChanged<T> onChanged;
  const _RadioCard({
    super.key,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...items.map(
              (e) => RadioListTile<T>(
                dense: true,
                value: e.$1,
                groupValue: value,
                onChanged: (v) => onChanged(v as T),
                title: Text(e.$2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchCard extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchCard({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: Text(title)),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

// ------------------------ BLOOD PRESSURE CHECKER PAGE ----------------------
class BloodPressurePage extends StatefulWidget {
  static const route = '/bp-checker';
  const BloodPressurePage({super.key});

  @override
  State<BloodPressurePage> createState() => _BloodPressurePageState();
}

class _BloodPressurePageState extends State<BloodPressurePage> {
  final _formKey = GlobalKey<FormState>();
  final _sysCtrl = TextEditingController();
  final _diaCtrl = TextEditingController();

  String? _category;
  String? _advice;

  @override
  void dispose() {
    _sysCtrl.dispose();
    _diaCtrl.dispose();
    super.dispose();
  }

  void _classify() {
    if (!_formKey.currentState!.validate()) return;

    final sys = int.parse(_sysCtrl.text);
    final dia = int.parse(_diaCtrl.text);

    String cat;
    String advice;

    if (sys >= 180 || dia >= 120) {
      cat = 'Hypertensive Crisis';
      advice = 'Seek emergency care immediately.';
    } else if (sys >= 140 || dia >= 90) {
      cat = 'Hypertension Stage 2';
      advice =
          'Consult a healthcare provider. Suggested labs: Kidney function tests, Lipid profile, Blood sugar.';
    } else if ((sys >= 130 && sys <= 139) || (dia >= 80 && dia <= 89)) {
      cat = 'Hypertension Stage 1';
      advice =
          'Lifestyle changes recommended. Consider monitoring and evaluation.';
    } else if (sys >= 120 && sys <= 129 && dia < 80) {
      cat = 'Elevated';
      advice = 'Adopt heart-healthy habits and monitor regularly.';
    } else if (sys < 120 && dia < 80) {
      cat = 'Normal';
      advice = 'Great! Maintain healthy lifestyle.';
    } else {
      cat = 'Unclassified';
      advice = 'Check readings again or consult a provider.';
    }

    setState(() {
      _category = cat;
      _advice = advice;
    });
  }

  Color _bpColor(String? cat) {
    switch (cat) {
      case 'Normal':
        return Colors.green;
      case 'Elevated':
        return Colors.orange;
      case 'Hypertension Stage 1':
      case 'Hypertension Stage 2':
      case 'Hypertensive Crisis':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blood Pressure Checker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _sysCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Systolic (mmHg)',
                                hintText: 'e.g., 120',
                                prefixIcon: Icon(Icons.favorite_outline),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Enter systolic';
                                final x = int.tryParse(v);
                                if (x == null || x < 60 || x > 260)
                                  return 'Enter valid systolic (60–260)';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _diaCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Diastolic (mmHg)',
                                hintText: 'e.g., 80',
                                prefixIcon: Icon(Icons.favorite_outline),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Enter diastolic';
                                final x = int.tryParse(v);
                                if (x == null || x < 40 || x > 180)
                                  return 'Enter valid diastolic (40–180)';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.stacked_bar_chart),
                          label: const Text('Classify BP'),
                          onPressed: _classify,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_category != null) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Your BP Category',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          Chip(
                            label: Text(_category!),
                            backgroundColor: _bpColor(
                              _category,
                            ).withOpacity(0.12),
                            side: BorderSide(color: _bpColor(_category)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_advice ?? ''),
                    ],
                  ),
                ),
              ),
              const _BPTable(),
            ],
          ],
        ),
      ),
    );
  }
}

class _BPTable extends StatelessWidget {
  const _BPTable();
  @override
  Widget build(BuildContext context) {
    final rows = [
      ['<120 and <80', 'Normal'],
      ['120–129 and <80', 'Elevated'],
      ['130–139 or 80–89', 'Hypertension Stage 1'],
      ['≥140 or ≥90', 'Hypertension Stage 2'],
      ['≥180 or ≥120', 'Hypertensive Crisis'],
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BP Classification Reference',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.6),
                1: FlexColumnWidth(1.4),
              },
              children: [
                const TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Reading (mmHg)',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Category',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                ...rows.map(
                  (r) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(r[0]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(r[1]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
