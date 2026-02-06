import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/calculator/application/calc_controller.dart';
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
// import 'features/calculator/domain/trekking_domain.dart';  // TODO: Create this file
import 'features/calculator/presentation/calc_screen.dart';

void main() {
  runApp(const PSCalcApp());
}

class PSCalcApp extends StatelessWidget {
  const PSCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalcController(
        allDomains: [
          // CORE DOMAINS
          BasicDomain(),
          BusinessDomain(),
          FinanceDomain(),
          FxDomain(),
          RealEstateDomain(),
          InvestmentDomain(),
          DateDomain(),

          // SPECIALIZED
          CsDomain(),
          NavDomain(),
          JewelleryDomain(),
          ConstructionDomain(),
          // TrekkingDomain(),  // TODO: Create this domain
        ],
      ),
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
