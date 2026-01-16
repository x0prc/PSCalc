import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../application/calc_controller.dart';

class CalcScreen extends StatefulWidget {
  const CalcScreen({super.key});

  @override
  State<CalcScreen> createState() => _CalcScreenState();
}

class _CalcScreenState extends State<CalcScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CalcController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('PSCalc'),
            actions: [
              Text(controller.activeDomain.shortLabel),
              const SizedBox(width: 16),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerRight,
                  child: Text(
                    controller.display,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ),
              // TODO: Add calculator button grid
              const Text('Calculator buttons will go here'),
            ],
          ),
        );
      },
    );
  }
}