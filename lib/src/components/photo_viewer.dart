import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sudoku/src/components/loading_widget.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';
import 'dart:math' as math;

class ViewPhotoWidget extends StatefulWidget {
  final String photoUrl;
  final String username;
  final Users user;
  final AppTheme appTheme;

  ViewPhotoWidget({Key key, @required this.user, @required this.username, @required this.photoUrl, @required this.appTheme}) : super(key: key);

  @override
  _ViewPhotoWidgetState createState() => _ViewPhotoWidgetState();
}

class _ViewPhotoWidgetState extends State<ViewPhotoWidget> {
  void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.getLightOrDarkModeTheme(widget.user.isDark),
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              goBack(context);
            },
            icon: Icon(
              LineIcons.arrowLeft,
              color: widget.appTheme.themeColor,
            )),
        title: Text(
          widget.username == widget.user.username ? 'you' : widget.username,
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: widget.appTheme.themeColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: Container(
        color: AppTheme.getLightOrDarkModeTheme(widget.user.isDark),
        child: PhotoView(
          imageProvider: NetworkImage(widget.photoUrl),
          enableRotation: true,
          backgroundDecoration: BoxDecoration(
            color: AppTheme.getLightOrDarkModeTheme(widget.user.isDark),
          ),
          initialScale: PhotoViewComputedScale.contained * 1,
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.contained * 1.5,
          loadingBuilder: (context, event) {
            return Center(
              child: LoadingWidget(
                appTheme: widget.appTheme,
                isDark: widget.user.isDark,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Transform.rotate(
                  angle: -math.pi / 4,
                  child: Icon(
                    LineIcons.plus,
                    color: widget.appTheme.themeColor,
                  )),
            );
          },
        ),
      ),
    );
  }
}
