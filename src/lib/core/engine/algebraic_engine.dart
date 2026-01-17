import '../config/calc_policy.dart';
import 'number.dart';

enum TokenType { number, op, lParen, rParen }

class Token {
  final TokenType type;
  final String value;

  Token(this.type, this.value);
}

class AlgebraicEngine {
  /// Converts infix expression to tokens, enforcing numeric‑only policy.
  List<Token> _tokenize(String expr) {
    final tokens = <Token>[];
    final buf = StringBuffer();

    for (int i = 0; i < expr.length; i++) {
      final c = expr[i];
      if (c == ' ') continue;

      /// Reject symbolic math if not allowed.
      if (CalcPolicy.allowSymbolicMath == false &&
          !'0123456789.+-*/()'.contains(c)) {
        throw CalcError.parseError();
      }

      if ('0123456789.'.contains(c)) {
        buf.write(c);
      } else {
        if (buf.isNotEmpty) {
          tokens.add(Token(TokenType.number, buf.toString()));
          buf.clear();
        }
        if ('+-*/'.contains(c)) {
          tokens.add(Token(TokenType.op, c));
        } else if (c == '(') {
          tokens.add(Token(TokenType.lParen, c));
        } else if (c == ')') {
          tokens.add(Token(TokenType.rParen, c));
        } else {
          throw CalcError.parseError();
        }
      }
    }
    if (buf.isNotEmpty) {
      tokens.add(Token(TokenType.number, buf.toString()));
    }
    return tokens;
  }
  static final Map<String, int> _precedence = {
    '+': 1,
    '-': 1,
    '*': 2,
    '/': 2,
  };

  static bool _isOp(String c) => '+-*/'.contains(c);

  List<Token> _toRpn(List<Token> tokens) {
    final output = <Token>[];
    final ops = <Token>[];

    for (final t in tokens) {
      switch (t.type) {
        case TokenType.number:
          output.add(t);
          break;
        case TokenType.op:
          while (ops.isNotEmpty &&
              ops.last.type == TokenType.op &&
              _precedence[ops.last.value]! >= _precedence[t.value]!) {
            output.add(ops.removeLast());
          }
          ops.add(t);
          break;
        case TokenType.lParen:
          ops.add(t);
          break;
        case TokenType.rParen:
          while (ops.isNotEmpty && ops.last.type != TokenType.lParen) {
            output.add(ops.removeLast());
          }
          if (ops.isEmpty || ops.last.type != TokenType.lParen) {
            throw CalcError.parseError();
          }
          ops.removeLast();
          break;
      }
    }
    while (ops.isNotEmpty) {
      if (ops.last.type == TokenType.lParen) {
        throw CalcError.parseError();
      }
      output.add(ops.removeLast());
    }
    return output;
  }

  CalcNumber evaluate(String expr) {
    final tokens = _tokenize(expr);
    final rpn = _toRpn(tokens);
    final stack = <CalcNumber>[];

    for (final t in rpn) {
      if (t.type == TokenType.number) {
        stack.add(CalcNumber.fromString(t.value));
      } else if (t.type == TokenType.op) {
        if (stack.length < 2) throw CalcError.stackUnderflow();
        final b = stack.removeLast();
        final a = stack.removeLast();
        CalcNumber res;
        switch (t.value) {
          case '+':
            res = a + b;
            break;
          case '-':
            res = a - b;
            break;
          case '*':
            res = a * b;
            break;
          case '/':
            res = a / b;
            break;
          default:
            throw CalcError.parseError();
        }
        stack.add(res);
      }
    }
    if (stack.length != 1) throw CalcError.parseError();
    return stack.first;
  }
}
