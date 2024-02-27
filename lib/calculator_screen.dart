import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'button_values.dart';
import 'package:clay_containers/clay_containers.dart';


class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with WidgetsBindingObserver {
  ThemeMode _currentTheme = ThemeMode.system;
  String number1 = ""; // . 0-9
  String operand = ""; // + - * /
  String number2 = ""; // . 0-9

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    updateTheme();
  }

  void updateTheme() {
    final Brightness systemBrightness =
    MediaQuery.platformBrightnessOf(context);
    setState(() {
      _currentTheme = systemBrightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: _currentTheme == ThemeMode.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: MaterialApp(
        theme: ThemeData.light(), // Set your light theme here
        darkTheme: ThemeData.dark(), // Set your dark theme here
        themeMode: _currentTheme,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Calculator'),
            actions: [buildThemeToggle()],
          ),
          backgroundColor: _currentTheme == ThemeMode.dark
              ? const Color(0xFF262626)
              : Colors.white,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // output
                Expanded(
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Container(
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "$number1$operand$number2".isEmpty
                            ? "0"
                            : "$number1$operand$number2",
                        style: TextStyle(
                          fontSize: 100,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                          fontWeight: FontWeight.bold,
                          color: _currentTheme == ThemeMode.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ),
                // buttons
                Wrap(
                  children: Btn.buttonValues
                      .map(
                        (value) => SizedBox(
                      width: value == Btn.n0
                          ? MediaQuery.of(context).size.width / 2
                          : (MediaQuery.of(context).size.width / 4),
                      height: MediaQuery.of(context).size.width / 4,
                      child: buildButton(value),
                    ),
                  )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButton(value) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Stack(
        children: [
          // Base ClayContainer without negative depth
          ClayContainer(
            color: _currentTheme == ThemeMode.dark
                ? const Color(0xFF262626)
                : const Color(0xFFd8d9c1),
            borderRadius: 100,
            emboss: true,
            spread: 5,
            child: InkWell(
              onTap: () => onBtnTap(value),
              child: Center(
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    fontWeight: FontWeight.normal,
                    fontSize: 35,
                    color: isOperand(value)
                        ? Colors.orange
                        : _currentTheme == ThemeMode.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ),
          if (value == Btn.n0)
          // Overlay with a second ClayContainer for the 0 button with negative depth
            ClayContainer(
              color: _currentTheme == ThemeMode.dark
                  ? const Color(0xFF262626)
                  : const Color(0x80d8d9c1),
              // Use the correct color based on the current theme
              borderRadius: 50,
              depth: -15,
              child: InkWell(
                onTap: () => onBtnTap(value),
                child: Center(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                      fontWeight: FontWeight.normal,
                      fontSize: 40,
                      color: isOperand(value)
                          ? Colors.orange
                          : _currentTheme == ThemeMode.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool isOperand(String value) {
    return [
      Btn.add,
      Btn.subtract,
      Btn.multiply,
      Btn.divide,
      Btn.calculate,
      Btn.dot
    ].contains(value);
  }

  void onBtnTap(String value) {
    if (value == Btn.del) {
      delete();
      return;
    }

    if (value == Btn.clr) {
      clearAll();
      return;
    }

    if (value == Btn.per) {
      convertToPercentage();
      return;
    }

    if (value == Btn.calculate) {
      calculate();
      return;
    }
    if (isOperand(value)){
      handleOperand(value);

    }
    else {
      appendValue(value);
    }


  }

  void handleOperand(String value) {
    // Check if there's a valid expression to calculate before appending the operand
    if (number1.isNotEmpty && operand.isNotEmpty && number2.isNotEmpty) {
      calculate(); // Calculate the result before appending the new operand
      setState(() {
        operand = value; // Set the new operand
      });
    } else if (number1.isNotEmpty) {
      setState(() {
        operand = value; // Set the operand if it's the first one
      });
    }
  }
  // ##############
  // calculates the result
  void calculate() {
    if (number1.isEmpty) return;
    if (operand.isEmpty) return;
    if (number2.isEmpty) return;

    final double num1 = double.parse(number1);
    final double num2 = double.parse(number2);

    var result = 0.0;
    switch (operand) {
      case Btn.add:
        result = num1 + num2;
        break;
      case Btn.subtract:
        result = num1 - num2;
        break;
      case Btn.multiply:
        result = num1 * num2;
        break;
      case Btn.divide:
        result = num1 / num2;
        break;
      default:
    }

    setState(() {
      number1 = result.toString();

      if (number1.endsWith(".0")) {
        number1 = number1.substring(0, number1.length - 2);
      }

      operand = "";
      number2 = "";
    });
  }

  // ##############
  // converts output to %
  void convertToPercentage() {
    // ex: 434+324
    if (number1.isNotEmpty && operand.isNotEmpty && number2.isNotEmpty) {
      // calculate before conversion
      calculate();
    }

    if (operand.isNotEmpty) {
      // cannot be converted
      return;
    }

    final number = double.parse(number1);
    setState(() {
      number1 = "${(number / 100)}";
      operand = "";
      number2 = "";
    });
  }

  // ##############
  // clears all output
  void clearAll() {
    setState(() {
      number1 = "";
      operand = "";
      number2 = "";
    });
  }

  // ##############
  // delete one from the end
  void delete() {
    if (number2.isNotEmpty) {
      // 12323 => 1232
      number2 = number2.substring(0, number2.length - 1);
    } else if (operand.isNotEmpty) {
      operand = "";
    } else if (number1.isNotEmpty) {
      number1 = number1.substring(0, number1.length - 1);
    }

    setState(() {});
  }

  // #############
  // appends value to the end
  void appendValue(String value) {
    // number1 opernad number2
    // 234       +      5343

    // if is operand and not "."
    if (value != Btn.dot && int.tryParse(value) == null) {
      // operand pressed
      if (operand.isNotEmpty && number2.isNotEmpty) {
        // TODO calculate the equation before assigning new operand
        calculate();
      }
      operand = value;
    }
    // assign value to number1 variable
    else if (number1.isEmpty || operand.isEmpty) {
      // check if value is "." | ex: number1 = "1.2"
      if (value == Btn.dot && number1.contains(Btn.dot)) return;
      if (value == Btn.dot && (number1.isEmpty || number1 == Btn.n0)) {
        // ex: number1 = "" | "0"
        value = "0.";
      }
      number1 += value;
    }
    // assign value to number2 variable
    else if (number2.isEmpty || operand.isNotEmpty) {
      // check if value is "." | ex: number1 = "1.2"
      if (value == Btn.dot && number2.contains(Btn.dot)) return;
      if (value == Btn.dot && (number2.isEmpty || number2 == Btn.n0)) {
        // number1 = "" | "0"
        value = "0.";
      }
      number2 += value;
    }

    setState(() {});
  }

  IconButton buildThemeToggle() {
    return IconButton(
      icon: Icon(
        _currentTheme == ThemeMode.dark ? Icons.brightness_7 : Icons.brightness_4,
        color: _currentTheme == ThemeMode.dark ? Colors.white : Colors.black,
      ),
      onPressed: toggleTheme,
    );
  }

  void toggleTheme() {
    setState(() {
      _currentTheme = _currentTheme == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }
}

