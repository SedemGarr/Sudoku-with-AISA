import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:image_crop/image_crop.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';

class ImageCropper extends StatefulWidget {
  final File image;
  final Users user;
  final AppTheme appTheme;

  ImageCropper({@required this.image, @required this.user, @required this.appTheme});

  @override
  _ImageCropperState createState() => _ImageCropperState();
}

class _ImageCropperState extends State<ImageCropper> {
  final key = GlobalKey<CropState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void hideSavingDialog() {
    Navigator.pop(context);
  }

  void cancel() {
    Navigator.pop(context);
  }

  void cropImage() async {
    final area = this.key.currentState.area;
    final scale = this.key.currentState.scale;
    if (area == null) {
      return; // cannot crop, widget is not setup.
    }

    final sampleImage = await ImageCrop.sampleImage(
      file: widget.image,
      preferredSize: (1000 / scale).round(),
    );

    final croppedFile = await ImageCrop.cropImage(file: sampleImage, area: area);

    Navigator.pop(context, croppedFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.getLightOrDarkModeTheme(widget.user.isDark),
        leading: IconButton(
          icon: Icon(
            LineIcons.check,
            color: widget.appTheme.themeColor,
          ),
          onPressed: () {
            cropImage();
          },
          color: widget.appTheme.themeColor,
        ),
        title: Text(
          'crop photo',
          style: GoogleFonts.roboto(color: widget.appTheme.themeColor, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(
              LineIcons.times,
              color: widget.appTheme.themeColor,
            ),
            onPressed: () => cancel(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppTheme.getLightOrDarkModeTheme(widget.user.isDark),
              child: Crop.file(
                widget.image,
                key: this.key,
              ),
            ),
          )
        ],
      ),
    );
  }
}
