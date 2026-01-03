import 'package:flutter/material.dart';
import 'core/engine/number.dart';
import 'core/engine/rpn_engine.dart';
import 'core/engine/algebraic_engine.dart';

void main() => runApp(const PSCalcApp());

class PSCalcApp extends StatelessWidget {
  const PSCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PSCalc',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const CoreTestScreen(),
    );
  }
}

class CoreTestScreen extends StatefulWidget {
  const CoreTestScreen({super.key});

  @override
  State<CoreTestScreen> createState() => _CoreTestScreenState();
}

class _CoreTestScreenState extends State<CoreTestScreen> {
  final algebraicEngine = AlgebraicEngine();
  final rpnEngine = RpnEngine();
  String _output = 'Ready';

  void _testAlg() {
    try {
      final res = algebraicEngine.evaluate('(1+2)*3');
      setState(() => _output = 'ALG: ${res.toString()}');
    } catch (e) {
      setState(() => _output = 'ALG Error: $e');
    }
  }

  void _testRpn() {
    try {
      rpnEngine.clear();
      rpnEngine.pushNumber(CalcNumber.fromString('3'));
      rpnEngine.pushNumber(CalcNumber.fromString('4'));
      rpnEngine.applyOp(RpnOp.add);
      final res = rpnEngine.state.stack.last;
      setState(() => _output = 'RPN: ${res.toString()}');
    } catch (e) {
      setState(() => _output = 'RPN Error: $e');
    }
  }

  void _testSymbolic() {
    try {
      algebraicEngine.evaluate('sin(1)');
      setState(() => _output = 'Symbolic allowed! (should not happen)');
    } catch (e) {
      setState(() => _output = 'Symbolic blocked ✓: $e');
    }
  }

  void _testOverflow() {
    try {
      final res = algebraicEngine.evaluate('1e200');
      setState(() => _output = 'Overflow not detected! (should throw)');
    } catch (e) {
      setState(() => _output = 'Overflow handled ✓: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PSCalc Core Engine Test')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _output,
              style: const TextStyle(fontSize: 24, fontFamily: 'monospace'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _testAlg,
                  child: const Text('Test ALG\n(1+2)*3'),
                ),
                ElevatedButton(
                  onPressed: _testRpn,
                  child: const Text('Test RPN\n3 4 +'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _testSymbolic,
                  child: const Text('Test Symbolic\nsin(1)'),
                ),
                ElevatedButton(
                  onPressed: _testOverflow,
                  child: const Text('Test Overflow\n1e200'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
