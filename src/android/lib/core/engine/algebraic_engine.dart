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
}
