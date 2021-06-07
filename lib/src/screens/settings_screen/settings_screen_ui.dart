import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:sudoku/src/components/loading_widget.dart';
import 'package:sudoku/src/models/theme.dart';
import 'settings_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

class SettingsScreenView extends SettingsScreenState {
  Widget buildThemeSelectorRow() {
    List<Widget> listOfThemeWidgets = [];

    AppTheme.themes.forEach((theme) {
      listOfThemeWidgets.add(Expanded(
        child: GestureDetector(
          onTap: () {
            setTheme(theme);
          },
          child: AspectRatio(
            aspectRatio: 1.7,
            child: Container(
              decoration: BoxDecoration(
                  color: theme.themeColor,
                  border: Border.all(
                      width: 2,
                      color: this.appTheme.themeColor == theme.themeColor
                          ? isDark
                              ? Colors.white
                              : Colors.grey[900]
                          : theme.themeColor)),
            ),
          ),
        ),
      ));
    });

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: listOfThemeWidgets,
        ),
      ],
    );
  }

  Widget buildCustomThemeColorWidget() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text('primary', style: GoogleFonts.roboto(color: appTheme.themeColor)),
            CircleColorPicker(
              textStyle: GoogleFonts.roboto(color: appTheme.themeColor, fontSize: 24, fontWeight: FontWeight.bold),
              onChanged: (colors) {},
              controller: circleColorPickerThemeColorController,
              onEnded: (colors) {
                setCustomThemeColor(colors);
              },
              size: const Size(240, 240),
              strokeWidth: 4,
              thumbSize: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCustomPartnerColorWidget() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'secondary',
              style: GoogleFonts.roboto(color: appTheme.partnerColor),
            ),
            CircleColorPicker(
              textStyle: GoogleFonts.roboto(color: appTheme.themeColor, fontSize: 24, fontWeight: FontWeight.bold),
              onChanged: (colors) {},
              controller: circleColorPickerPartnerColorController,
              onEnded: (colors) {
                setCustomPartnerColor(colors);
              },
              size: const Size(240, 240),
              strokeWidth: 4,
              thumbSize: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAppearanceSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'appearance',
          style: GoogleFonts.quicksand(fontSize: 16, color: appTheme.themeColor, fontWeight: FontWeight.bold),
        ),
        ListTile(
          leading: GestureDetector(
            onTap: () {
              showHelpSnackBar(0);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info,
                  color: appTheme.themeColor,
                ),
              ],
            ),
          ),
          title: Text(
            'dark mode',
            style: GoogleFonts.roboto(
              color: appTheme.themeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            isDark ? 'dark mode is enabled' : 'dark mode is disabled',
            style: GoogleFonts.roboto(
              color: appTheme.themeColor,
            ),
          ),
          trailing: Switch(
            value: isDark,
            onChanged: (value) {
              setState(() {
                isDark = value;
              });
              setDarkMode(value);
            },
            activeTrackColor: appTheme.themeColor[300],
            activeColor: appTheme.themeColor,
            inactiveThumbColor: appTheme.themeColor,
            inactiveTrackColor: appTheme.themeColor,
          ),
        ),
        user.hasCompletedGame
            ? ExpansionTile(
                leading: GestureDetector(
                  onTap: () {
                    showHelpSnackBar(2);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info,
                        color: appTheme.themeColor,
                      ),
                    ],
                  ),
                ),
                title: Text(
                  'select theme',
                  style: GoogleFonts.roboto(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'select a theme for the entire app',
                  style: GoogleFonts.roboto(
                    color: appTheme.themeColor,
                  ),
                ),
                children: [
                  isChoosingCustomColor
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: buildThemeSelectorRow(),
                        ),
                  isChoosingCustomColor
                      ? Column(
                          children: [buildCustomThemeColorWidget(), buildCustomPartnerColorWidget()],
                        )
                      : Container(),
                  TextButton(
                      onPressed: () {
                        toggleCustomTheme();
                      },
                      child: Text(
                        isChoosingCustomColor ? 'choose a preset' : 'choose your own color',
                        style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: appTheme.themeColor),
                      ))
                ],
              )
            : Container()
      ],
    );
  }

  Widget buildGamplaySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'gameplay',
          style: GoogleFonts.quicksand(fontSize: 16, color: appTheme.themeColor, fontWeight: FontWeight.bold),
        ),
        ListTile(
          leading: GestureDetector(
            onTap: () {
              showHelpSnackBar(3);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info,
                  color: appTheme.themeColor,
                ),
              ],
            ),
          ),
          title: Text(
            'obvious error assistance',
            style: GoogleFonts.roboto(color: appTheme.themeColor, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            hasTrainingWheels ? 'obvious errors are highlighted' : 'obvious errors aren\'t highlighted',
            style: GoogleFonts.roboto(
              color: appTheme.themeColor,
            ),
          ),
          trailing: Switch(
            value: hasTrainingWheels,
            onChanged: (value) {
              setState(() {
                hasTrainingWheels = value;
              });
              setTrainingwheels(value);
            },
            activeTrackColor: appTheme.themeColor[300],
            activeColor: appTheme.themeColor,
            inactiveThumbColor: appTheme.themeColor,
            inactiveTrackColor: appTheme.themeColor,
          ),
        ),
        ListTile(
          leading: GestureDetector(
            onTap: () {
              showHelpSnackBar(4);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info,
                  color: appTheme.themeColor,
                ),
              ],
            ),
          ),
          title: Text(
            'screen timeout',
            style: GoogleFonts.roboto(color: appTheme.themeColor, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            enableWakelock ? 'screen will lock after a period of inactivity' : 'screen will not lock after a period of inactivity',
            style: GoogleFonts.roboto(
              color: appTheme.themeColor,
            ),
          ),
          trailing: Switch(
            value: enableWakelock,
            onChanged: (value) {
              setState(() {
                enableWakelock = value;
              });
              setWakelock(value);
            },
            activeTrackColor: appTheme.themeColor[300],
            activeColor: appTheme.themeColor,
            inactiveThumbColor: appTheme.themeColor,
            inactiveTrackColor: appTheme.themeColor,
          ),
        ),
        user.hasCompletedGame
            ? ExpansionTile(
                leading: GestureDetector(
                  onTap: () {
                    showHelpSnackBar(5);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info,
                        color: appTheme.themeColor,
                      ),
                    ],
                  ),
                ),
                title: Text(
                  'difficulty level',
                  style: GoogleFonts.roboto(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'for free-play and multiplayer',
                  style: GoogleFonts.roboto(
                    color: appTheme.themeColor,
                  ),
                ),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                            label: (freePlayDifficulty + 1).toString(),
                            value: freePlayDifficulty == 6 ? 0.0 : freePlayDifficulty.toDouble(),
                            min: 0,
                            max: 5,
                            divisions: 5,
                            activeColor: appTheme.themeColor,
                            inactiveColor: appTheme.themeColor[200],
                            onChanged: user.freePlayDifficulty == 6
                                ? null
                                : (value) {
                                    setFreePlaydifficulty(value);
                                  }),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Column(
                          children: [
                            Text(
                              'random?',
                              style: GoogleFonts.roboto(
                                color: appTheme.themeColor,
                              ),
                            ),
                            Checkbox(
                              focusColor: appTheme.themeColor,
                              hoverColor: appTheme.themeColor,
                              value: freePlayDifficulty == 6,
                              onChanged: (value) {
                                setFreePlaydifficultyToRandom();
                              },
                              activeColor: appTheme.themeColor,
                              checkColor: AppTheme.getLightOrDarkModeTheme(isDark),
                            )
                          ],
                        ),
                      )
                    ],
                  )
                ],
              )
            : Container(),
        user.hasCompletedGame
            ? ExpansionTile(
                leading: GestureDetector(
                  onTap: () {
                    showHelpSnackBar(6);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info,
                        color: appTheme.themeColor,
                      ),
                    ],
                  ),
                ),
                title: Text(
                  'board patterns',
                  style: GoogleFonts.roboto(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'select a cell arrangment pattern',
                  style: GoogleFonts.roboto(
                    color: appTheme.themeColor,
                  ),
                ),
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ChoiceChip(
                            avatar: Icon(
                              LineIcons.dice,
                              color: AppTheme.getLightOrDarkModeTheme(isDark),
                            ),
                            label: Text('random'),
                            labelStyle: GoogleFonts.roboto(color: AppTheme.getLightOrDarkModeTheme(isDark), fontWeight: FontWeight.bold),
                            backgroundColor: appTheme.themeColor,
                            selected: preferedPattern == 'Random',
                            selectedColor: appTheme.themeColor[900],
                            elevation: 0,
                            disabledColor: appTheme.themeColor,
                            onSelected: (value) {
                              setBoardPatterns('Random');
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ChoiceChip(
                            avatar: Icon(
                              LineIcons.seedling,
                              color: AppTheme.getLightOrDarkModeTheme(isDark),
                            ),
                            label: Text('spring'),
                            labelStyle: GoogleFonts.roboto(color: AppTheme.getLightOrDarkModeTheme(isDark), fontWeight: FontWeight.bold),
                            backgroundColor: appTheme.themeColor,
                            selected: preferedPattern == 'spring',
                            selectedColor: appTheme.themeColor[900],
                            elevation: 0,
                            disabledColor: appTheme.themeColor,
                            onSelected: (value) {
                              setBoardPatterns('spring');
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ChoiceChip(
                            avatar: Icon(
                              LineIcons.sunAlt,
                              color: AppTheme.getLightOrDarkModeTheme(isDark),
                            ),
                            label: Text('summer'),
                            labelStyle: GoogleFonts.roboto(color: AppTheme.getLightOrDarkModeTheme(isDark), fontWeight: FontWeight.bold),
                            backgroundColor: appTheme.themeColor,
                            selected: preferedPattern == 'summer',
                            selectedColor: appTheme.themeColor[900],
                            elevation: 0,
                            disabledColor: appTheme.themeColor,
                            onSelected: (value) {
                              setBoardPatterns('summer');
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ChoiceChip(
                            avatar: Icon(
                              LineIcons.leaf,
                              color: AppTheme.getLightOrDarkModeTheme(isDark),
                            ),
                            label: Text('fall'),
                            labelStyle: GoogleFonts.roboto(color: AppTheme.getLightOrDarkModeTheme(isDark), fontWeight: FontWeight.bold),
                            backgroundColor: appTheme.themeColor,
                            selected: preferedPattern == 'fall',
                            selectedColor: appTheme.themeColor[900],
                            elevation: 0,
                            disabledColor: appTheme.themeColor,
                            onSelected: (value) {
                              setBoardPatterns('fall');
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ChoiceChip(
                            avatar: Icon(
                              LineIcons.snowflake,
                              color: AppTheme.getLightOrDarkModeTheme(isDark),
                            ),
                            label: Text('winter'),
                            labelStyle: GoogleFonts.roboto(color: AppTheme.getLightOrDarkModeTheme(isDark), fontWeight: FontWeight.bold),
                            backgroundColor: appTheme.themeColor,
                            selected: preferedPattern == 'winter',
                            selectedColor: appTheme.themeColor[900],
                            elevation: 0,
                            disabledColor: appTheme.themeColor,
                            onSelected: (value) {
                              setBoardPatterns('winter');
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )
            : Container(),
      ],
    );
  }

  Widget buildAudioSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'sound',
          style: GoogleFonts.quicksand(fontSize: 16, color: appTheme.themeColor, fontWeight: FontWeight.bold),
        ),
        ListTile(
          leading: GestureDetector(
            onTap: () {
              showHelpSnackBar(7);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info,
                  color: appTheme.themeColor,
                ),
              ],
            ),
          ),
          title: Text(
            'AISA\'s dialog',
            style: GoogleFonts.roboto(color: appTheme.themeColor, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            audioEnabled ? 'audio dialog from AISA is enabled' : 'AISA is muted',
            style: GoogleFonts.roboto(
              color: appTheme.themeColor,
            ),
          ),
          trailing: Switch(
            value: audioEnabled,
            onChanged: (value) {
              setState(() {
                audioEnabled = value;
              });
              setAudio(value);
            },
            activeTrackColor: appTheme.themeColor[300],
            activeColor: appTheme.themeColor,
            inactiveThumbColor: appTheme.themeColor,
            inactiveTrackColor: appTheme.themeColor,
          ),
        ),
      ],
    );
  }

  Widget buildSocialSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'social',
          style: GoogleFonts.quicksand(fontSize: 16, color: appTheme.themeColor, fontWeight: FontWeight.bold),
        ),
        ListTile(
          leading: GestureDetector(
            onTap: () {
              showHelpSnackBar(8);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info,
                  color: appTheme.themeColor,
                ),
              ],
            ),
          ),
          title: Text(
            'multiplayer visibility',
            style: GoogleFonts.roboto(color: appTheme.themeColor, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            isFriendly ? 'anyone can invite you to multiplayer games' : 'only friends can invite you to multiplayer games',
            style: GoogleFonts.roboto(
              color: appTheme.themeColor,
            ),
          ),
          trailing: Switch(
            value: isFriendly,
            onChanged: (value) {
              setState(() {
                isFriendly = value;
              });
              setFriendly(value);
            },
            activeTrackColor: appTheme.themeColor[300],
            activeColor: appTheme.themeColor,
            inactiveThumbColor: appTheme.themeColor,
            inactiveTrackColor: appTheme.themeColor,
          ),
        ),
      ],
    );
  }

  Widget buildAdvancedSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'advanced',
          style: GoogleFonts.quicksand(fontSize: 16, color: appTheme.themeColor, fontWeight: FontWeight.bold),
        ),
        ExpansionTile(
          leading: GestureDetector(
            onTap: () {
              showHelpSnackBar(9);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info,
                  color: appTheme.themeColor,
                ),
              ],
            ),
          ),
          title: Text(
            'restart single-player',
            style: GoogleFonts.roboto(color: appTheme.themeColor, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'reset single-player progress',
            style: GoogleFonts.roboto(
              color: appTheme.themeColor,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                  onPressed: () {
                    showRestartGameDialog(context);
                  },
                  child: Text(
                    'restart',
                    style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: appTheme.themeColor),
                  )),
            )
          ],
        ),
        ExpansionTile(
          leading: GestureDetector(
            onTap: () {
              showHelpSnackBar(10);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info,
                  color: appTheme.themeColor,
                ),
              ],
            ),
          ),
          title: Text(
            'delete account',
            style: GoogleFonts.roboto(color: appTheme.themeColor, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'permantently delete your account',
            style: GoogleFonts.roboto(
              color: appTheme.themeColor,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                  onPressed: () {
                    showDeleteAccountDialog(context);
                  },
                  child: Text(
                    'delete account',
                    style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: appTheme.themeColor),
                  )),
            )
          ],
        ),
      ],
    );
  }

  Widget buildUsernameEditingForm() {
    return Container(
      child: Form(
          key: formKey,
          child: Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
              child: TextFormField(
                autofocus: true,
                initialValue: user.username,
                style: GoogleFonts.quicksand(color: appTheme.themeColor),
                keyboardType: TextInputType.text,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                cursorColor: appTheme.themeColor,
                decoration: InputDecoration(
                  errorStyle: GoogleFonts.quicksand(color: appTheme.themeColor),
                  errorBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: appTheme.themeColor, width: 1)),
                  focusColor: appTheme.themeColor,
                  labelStyle: GoogleFonts.quicksand(color: appTheme.themeColor),
                  focusedBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: appTheme.themeColor, width: 1)),
                  labelText: 'username',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please enter a username';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    temporaryUsername = value;
                  });
                },
              ),
            ),
          )),
    );
  }

  Widget buildProfileSection(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PopupMenuButton(
                color: AppTheme.getLightOrDarkModeTheme(isDark),
                elevation: 1,
                child: CircularProfileAvatar(
                  user.profileUrl, //sets image path, it should be a URL string. default value is empty string, if path is empty it will display only initials
                  radius: MediaQuery.of(context).size.width * 0.1, // sets radius, default 50.0
                  backgroundColor: appTheme.themeColor,
                  // sets background color, default Colors.white
                  // borderWidth:
                  //     10, // sets border, default 0.0
                  initialsText: Text(
                    getInitials(user.username),
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: AppTheme.getLightOrDarkModeTheme(isDark),
                    ),
                  ), // sets initials text, set your own style, default Text('')
                  borderColor: Colors.transparent, // sets border color, default Colors.white
                  elevation: 0.0, // sets elevation (shadow of the profile picture), default value is 0.0
                  foregroundColor: Colors.transparent, //sets foreground colour, it works if showInitialTextAbovePicture = true , default Colors.transparent
                  cacheImage: true, // allow widget to cache image against provided url
                  // sets on tap
                  showInitialTextAbovePicture: false, // setting it true will show initials text above profile picture, default false
                ),
                onSelected: (value) {
                  handlePopupSelection(value, context);
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: 1,
                      child: Text(
                        'take a photo',
                        style: GoogleFonts.roboto(
                          color: appTheme.themeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text(
                        'choose from gallery',
                        style: GoogleFonts.roboto(
                          color: appTheme.themeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    user.profileUrl != ''
                        ? PopupMenuItem(
                            value: 3,
                            child: Text(
                              'view photo',
                              style: GoogleFonts.roboto(
                                color: appTheme.themeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                    user.profileUrl != ''
                        ? PopupMenuItem(
                            value: 4,
                            child: Text(
                              'remove photo',
                              style: GoogleFonts.roboto(
                                color: appTheme.themeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ];
                },
              ),
              isEditing
                  ? buildUsernameEditingForm()
                  : GestureDetector(
                      onTap: () {
                        enableEditing();
                      },
                      child: Text(
                        user.username,
                        style: GoogleFonts.quicksand(color: appTheme.themeColor, fontSize: 20),
                      ),
                    ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Divider(
              color: appTheme.themeColor,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: AppTheme.getLightOrDarkModeTheme(isDark),
          elevation: 0,
          title: Text(
            'settings',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              color: appTheme.themeColor,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(
                LineIcons.arrowLeft,
                color: appTheme.themeColor,
              ),
              onPressed: () {
                goToHomeScreen();
              }),
          actions: [
            isEditing
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                          onTap: () {
                            if (formKey.currentState.validate()) {
                              setUsername();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'save',
                              style: GoogleFonts.roboto(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                            ),
                          )),
                      GestureDetector(
                          onTap: () {
                            disableEditing();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'cancel',
                              style: GoogleFonts.roboto(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                            ),
                          )),
                    ],
                  )
                : Container()
          ],
        ),
        body: Container(
          color: AppTheme.getLightOrDarkModeTheme(isDark),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: widgetOpacity,
                child: isLoading
                    ? LoadingWidget(
                        appTheme: appTheme,
                        isDark: isDark,
                      )
                    : Column(
                        children: [
                          buildProfileSection(context),
                          Expanded(
                            child: ListView(
                              children: [
                                buildAppearanceSettings(),
                                Divider(
                                  color: appTheme.themeColor,
                                ),
                                buildGamplaySettings(),
                                Divider(
                                  color: appTheme.themeColor,
                                ),
                                buildAudioSettings(),
                                Divider(
                                  color: appTheme.themeColor,
                                ),
                                buildSocialSettings(),
                                Divider(
                                  color: appTheme.themeColor,
                                ),
                                buildAdvancedSettings(),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
