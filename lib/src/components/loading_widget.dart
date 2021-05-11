import 'package:flutter/material.dart';
import 'package:sudoku/src/models/theme.dart';

class LoadingWidget extends StatefulWidget {
  final bool isDark;
  final AppTheme appTheme;

  LoadingWidget({@required this.appTheme, @required this.isDark});

  @override
  _LoadingWidgetState createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              backgroundColor: widget.isDark ? Colors.grey[900] : Colors.white,
              valueColor:
                  AlwaysStoppedAnimation<Color>(widget.appTheme.themeColor),
            ),
          ],
        ),
      ],
    );
  }
}
