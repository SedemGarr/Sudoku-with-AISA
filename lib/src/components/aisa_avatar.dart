import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class AISAAvatar extends StatefulWidget {
  AISAAvatar({@required this.color});

  final MaterialColor color;

  @override
  _AISAAvatarState createState() => _AISAAvatarState();
}

class _AISAAvatarState extends State<AISAAvatar> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: MediaQuery.of(context).size.height * 1 / 3,
          child: Icon(
            LineIcons.robot,
            color: widget.color,
            size: constraint.biggest.width * 0.65,
          ),
        ),
      );
    });
  }
}
