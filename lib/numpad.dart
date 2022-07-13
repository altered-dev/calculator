import 'dart:math';

import 'package:calculator/history_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';

class Numpad extends StatefulWidget {
  const Numpad({Key? key, this.onEntryAdded}) : super(key: key);

  final void Function(HistoryEntry entry)? onEntryAdded;

  @override
  State<StatefulWidget> createState() => _NumpadState();
}

class _NumpadState extends State<Numpad> {
  var _result = "";

  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.none,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            textAlign: TextAlign.right,

            style: Theme.of(context).textTheme.headline2
              ?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Text(
            _result,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
        const SizedBox(height: 16),
        MediaQuery.of(context).orientation == Orientation.portrait
          ? keyboard()
          : horizontalKeyboard(),
      ],
    );
  }

  Widget keyboard({double ratio = 1}) {
    return AspectRatio(
      aspectRatio: ratio,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  textKeyButton('('),
                  textKeyButton(')'),
                  textKeyButton('%'),
                  deleteKeyButton(),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  textKeyButton('1'),
                  textKeyButton('2'),
                  textKeyButton('3'),
                  textKeyButton('÷'),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  textKeyButton('4'),
                  textKeyButton('5'),
                  textKeyButton('6'),
                  textKeyButton('×'),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  textKeyButton('7'),
                  textKeyButton('8'),
                  textKeyButton('9'),
                  textKeyButton('-'),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  textKeyButton('0'),
                  textKeyButton('.'),
                  resultKeyButton(),
                  textKeyButton('+'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget horizontalKeyboard() {
    return AspectRatio(
      aspectRatio: 3,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        textKeyButton('^'),
                        textKeyButton('!'),
                        textKeyButton('| x |', 'abs('),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        textKeyButton('sin', 'sin('),
                        textKeyButton('cos', 'cos('),
                        textKeyButton('tan', 'tan('),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        textKeyButton('log', 'log('),
                        textKeyButton('ln', 'ln('),
                        textKeyButton('√', 'sqrt('),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        textKeyButton('π', pi.toString()),
                        textKeyButton('e', e.toString()),
                        textKeyButton('³√', 'cbrt('),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          keyboard(ratio: 1.75),
        ]
      ),
    );
  }

  Widget keyButton(String key, void Function()? onPressed) {
    return Expanded(
      child: TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1000),
          ),
          minimumSize: const Size(0, 1000),
        ),
        onPressed: onPressed,
        child: Text(
          key,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
    );
  }

  Widget textKeyButton(String key, [String? actual]) {
    return keyButton(key, () => setState(() {
      addChar(actual ?? key);
      computeResult();
    }));
  }

  Widget deleteKeyButton() {
    return Expanded(
      child: TextButton(
        onPressed: () => setState(() {
          removeChar();
          computeResult();
        }),
        onLongPress: () => setState(() {
          _result = "";
          _controller.clear();
        }),
        child: const Icon(Icons.backspace_outlined),
      ),
    );
  }

  Widget resultKeyButton() {
    return keyButton('=', () => setState(() {
      computeResult(warn: true);
      if (_controller.text != '' && _result != '' && _controller.text != _result && _result != 'Error') {
        widget.onEntryAdded?.call(
          HistoryEntry(_controller.text, _result)
        );
      }
      _controller.clear();
      _controller.text = _result;
      _result = "";
    }));
  }

  void addChar(String key) {
    if (_controller.text == "Error") {
      _controller.clear();
    }
    if (_controller.selection.end == -1) {
      _controller.value = _controller.value.copyWith(
        text: _controller.value.text + key,
      );
    } else {
      _controller.value = _controller.value.copyWith(
        text: _controller.value.text.replaceRange(
            _controller.selection.start,
            _controller.selection.end,
            key
        ),
        selection: TextSelection.collapsed(
            offset: _controller.selection.start + key.length
        ),
      );
    }
  }

  void removeChar() {
    if (_controller.text == "Error") {
      _controller.clear();
    }
    if (_controller.text.isEmpty) {
      return;
    }
    if (_controller.selection.end == -1) {
      _controller.value = _controller.value.copyWith(
        text: _controller.text.substring(0, _controller.text.length - 1),
      );
    } else {
      _controller.value = _controller.value.copyWith(
        text: _controller.selection.start == _controller.selection.end
          ? _controller.text.replaceRange(
          _controller.selection.start - 1,
          _controller.selection.start, ''
          )
          : _controller.text.replaceRange(
            _controller.selection.start,
            _controller.selection.end, ''
          ),
        selection: TextSelection.collapsed(
            offset: _controller.selection.start == _controller.selection.end
                ? _controller.selection.start - 1
                : _controller.selection.end - _controller.selection.start
        ),
      );
    }
  }

  void computeResult({bool warn = false, String? value}) {
    value ??= _controller.text;
    value = value
      .replaceAll('Error', '')
      .replaceAll('cbrt(', 'root(3, ');
    if (value.isEmpty) {
      _result = "";
      return;
    }
    try {
      var parser = Parser();
      var expression = parser.parse(
        value
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
      );
      _result = expression.evaluate(EvaluationType.REAL, ContextModel()).toString();
      if (_result.endsWith(".0")) {
        _result = _result.substring(0, _result.length - 2);
      }
    } on Error {
      _result = warn ? "Error" : "";
    } on FormatException catch (e) {
      if (e.message == "Mismatched parenthesis.") {
        var diff = _countCharacter(value, '(') - _countCharacter(value, ')');
        if (diff > 0) {
          value += ')' * diff;
        } else {
          value = '(' * -diff + value;
        }
        computeResult(warn: warn, value: value);
      }
    }
  }

  int _countCharacter(String input, String character) {
    var count = 0;
    for (var i = 0; i < input.length; i++) {
      if (input[i] == character) {
        count++;
      }
    }
    return count;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}