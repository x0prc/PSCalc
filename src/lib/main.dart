import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/calculator/application/calc_controller.dart';
import 'features/calculator/application/settings_controller.dart';
import 'features/calculator/domain/basic_domain.dart';
import 'features/calculator/domain/business_domain.dart';
import 'features/calculator/domain/finance_domain.dart';
import 'features/calculator/domain/fx_domain.dart';
import 'features/calculator/domain/realestate_domain.dart';
import 'features/calculator/domain/investments.dart';
import 'features/calculator/domain/date_domain.dart';
import 'features/calculator/domain/cs_domain.dart';
import 'features/calculator/domain/nav_domain.dart';
import 'features/calculator/domain/jewellery_domain.dart';
import 'features/calculator/domain/construction_domain.dart';
import 'core/services/storage_service.dart';
import 'features/calculator/presentation/calc_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  await storage.init();

  final allDomains = [
    BasicDomain(),
    BusinessDomain(),
    FinanceDomain(),
    FxDomain(),
    RealEstateDomain(),
    InvestmentDomain(),
    DateDomain(),
    CsDomain(),
    NavDomain(),
    JewelleryDomain(),
    ConstructionDomain(),
  ];

  runApp(PSCalcApp(
    storage: storage,
    allDomains: allDomains,
  ));
}

class PSCalcApp extends StatelessWidget {
  final StorageService storage;
  final List<dynamic> allDomains;

  const PSCalcApp({
    super.key,
    required this.storage,
    required this.allDomains,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsController(storage),
        ),
        ChangeNotifierProvider(
          create: (_) => CalcController(
            storage: storage,
            allDomains: allDomains.cast(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'PSCalc',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const CalcScreen(),
      ),
    );
  }
}
