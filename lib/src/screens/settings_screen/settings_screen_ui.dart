import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
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

  Widget buildAppearanceSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'appearance',
          style: GoogleFonts.lato(
              fontSize: 16,
              color: appTheme.themeColor,
              fontWeight: FontWeight.bold),
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
            style: GoogleFonts.lato(
              color: appTheme.themeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            isDark ? 'dark mode is enabled' : 'dark mode is disabled',
            style: GoogleFonts.lato(
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
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey[300],
          ),
        ),
        !user.hasCompletedGame
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
                  style: GoogleFonts.lato(
                      color: appTheme.themeColor, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'select a theme for the entire app',
                  style: GoogleFonts.lato(
                    color: appTheme.themeColor,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: buildThemeSelectorRow(),
                  )
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
          style: GoogleFonts.lato(
              fontSize: 16,
              color: appTheme.themeColor,
              fontWeight: FontWeight.bold),
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
            style: GoogleFonts.lato(
                color: appTheme.themeColor, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            hasTrainingWheels
                ? 'obvious errors aren\'t highlighted'
                : 'obvious errors are highlighted',
            style: GoogleFonts.lato(
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
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey[300],
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
            style: GoogleFonts.lato(
                color: appTheme.themeColor, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            enableWakelock
                ? 'screen will lock after a period of inactivity'
                : 'screen will not lock after a period of inactivity',
            style: GoogleFonts.lato(
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
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey[300],
          ),
        ),
        !user.hasCompletedGame
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
                  style: GoogleFonts.lato(
                      color: appTheme.themeColor, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'for free-play and multiplayer',
                  style: GoogleFonts.lato(
                    color: appTheme.themeColor,
                  ),
                ),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                            label: freePlayDifficulty.toString(),
                            value: freePlayDifficulty == 10
                                ? 0.0
                                : freePlayDifficulty.toDouble(),
                            min: 0,
                            max: 5,
                            divisions: 5,
                            activeColor: appTheme.themeColor,
                            inactiveColor: appTheme.themeColor[200],
                            onChanged: user.freePlayDifficulty == 10
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
                              style: GoogleFonts.lato(
                                color: appTheme.themeColor,
                              ),
                            ),
                            Checkbox(
                              focusColor: appTheme.themeColor,
                              hoverColor: appTheme.themeColor,
                              value: freePlayDifficulty == 10,
                              onChanged: (value) {
                                setFreePlaydifficultyToRandom();
                              },
                              activeColor: appTheme.themeColor,
                              checkColor:
                                  isDark ? Colors.grey[900] : Colors.white,
                            )
                          ],
                        ),
                      )
                    ],
                  )
                ],
              )
            : Container(),
        !user.hasCompletedGame
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
                  style: GoogleFonts.lato(
                      color: appTheme.themeColor, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'select a cell arrangment pattern',
                  style: GoogleFonts.lato(
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
                              color: isDark ? Colors.grey[900] : Colors.white,
                            ),
                            label: Text('random'),
                            labelStyle: GoogleFonts.lato(
                                color: isDark ? Colors.grey[900] : Colors.white,
                                fontWeight: FontWeight.bold),
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
                              color: isDark ? Colors.grey[900] : Colors.white,
                            ),
                            label: Text('spring'),
                            labelStyle: GoogleFonts.lato(
                                color: isDark ? Colors.grey[900] : Colors.white,
                                fontWeight: FontWeight.bold),
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
                              color: isDark ? Colors.grey[900] : Colors.white,
                            ),
                            label: Text('summer'),
                            labelStyle: GoogleFonts.lato(
                                color: isDark ? Colors.grey[900] : Colors.white,
                                fontWeight: FontWeight.bold),
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
                              color: isDark ? Colors.grey[900] : Colors.white,
                            ),
                            label: Text('fall'),
                            labelStyle: GoogleFonts.lato(
                                color: isDark ? Colors.grey[900] : Colors.white,
                                fontWeight: FontWeight.bold),
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
                              color: isDark ? Colors.grey[900] : Colors.white,
                            ),
                            label: Text('winter'),
                            labelStyle: GoogleFonts.lato(
                                color: isDark ? Colors.grey[900] : Colors.white,
                                fontWeight: FontWeight.bold),
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
          style: GoogleFonts.lato(
              fontSize: 16,
              color: appTheme.themeColor,
              fontWeight: FontWeight.bold),
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
            style: GoogleFonts.lato(
                color: appTheme.themeColor, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            audioEnabled
                ? 'audio dialog from AISA is enabled'
                : 'AISA is muted',
            style: GoogleFonts.lato(
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
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey[300],
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
          style: GoogleFonts.lato(
              fontSize: 16,
              color: appTheme.themeColor,
              fontWeight: FontWeight.bold),
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
            style: GoogleFonts.lato(
                color: appTheme.themeColor, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            isFriendly
                ? 'you\'ll show up in searches'
                : 'you won\'t show up in searches',
            style: GoogleFonts.lato(
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
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey[300],
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
          style: GoogleFonts.lato(
              fontSize: 16,
              color: appTheme.themeColor,
              fontWeight: FontWeight.bold),
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
            style: GoogleFonts.lato(
                color: appTheme.themeColor, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'reset single-player progress',
            style: GoogleFonts.lato(
              color: appTheme.themeColor,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                  splashColor: appTheme.themeColor,
                  onPressed: () {
                    showRestartGameDialog(context);
                  },
                  child: Text(
                    'restart',
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        color: appTheme.themeColor),
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
            style: GoogleFonts.lato(
                color: appTheme.themeColor, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'permantently delete your account',
            style: GoogleFonts.lato(
              color: appTheme.themeColor,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                  splashColor: appTheme.themeColor,
                  onPressed: () {
                    showDeleteAccountDialog(context);
                  },
                  child: Text(
                    'delete account',
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        color: appTheme.themeColor),
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
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.1),
              child: TextFormField(
                autofocus: true,
                initialValue: user.username,
                style: GoogleFonts.lato(color: appTheme.themeColor),
                keyboardType: TextInputType.text,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                cursorColor: appTheme.themeColor,
                decoration: InputDecoration(
                  errorStyle: GoogleFonts.lato(color: appTheme.themeColor),
                  errorBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          BorderSide(color: appTheme.themeColor, width: 1)),
                  focusColor: appTheme.themeColor,
                  labelStyle: GoogleFonts.lato(color: appTheme.themeColor),
                  focusedBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          BorderSide(color: appTheme.themeColor, width: 1)),
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

  Widget buildProfileSection() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PopupMenuButton(
                color: isDark ? Colors.grey[900] : Colors.white,
                elevation: 1,
                child: CircularProfileAvatar(
                  user.profileUrl, //sets image path, it should be a URL string. default value is empty string, if path is empty it will display only initials
                  radius: MediaQuery.of(context).size.width *
                      0.1, // sets radius, default 50.0
                  backgroundColor: appTheme.themeColor,
                  // sets background color, default Colors.white
                  // borderWidth:
                  //     10, // sets border, default 0.0
                  initialsText: Text(
                    getInitials(user.username),
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: isDark ? Colors.grey[900] : Colors.white,
                    ),
                  ), // sets initials text, set your own style, default Text('')
                  borderColor: Colors
                      .transparent, // sets border color, default Colors.white
                  elevation:
                      0.0, // sets elevation (shadow of the profile picture), default value is 0.0
                  foregroundColor: Colors
                      .transparent, //sets foreground colour, it works if showInitialTextAbovePicture = true , default Colors.transparent
                  cacheImage:
                      true, // allow widget to cache image against provided url
                  // sets on tap
                  showInitialTextAbovePicture:
                      false, // setting it true will show initials text above profile picture, default false
                ),
                onSelected: (value) {
                  handlePopupSelection(value);
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: 1,
                      child: Text(
                        'take a photo',
                        style: GoogleFonts.lato(
                          color: appTheme.themeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text(
                        'choose from gallery',
                        style: GoogleFonts.lato(
                          color: appTheme.themeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    user.profileUrl != ''
                        ? PopupMenuItem(
                            value: 3,
                            child: Text(
                              'remove photo',
                              style: GoogleFonts.lato(
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
                        style: GoogleFonts.lato(
                            color: appTheme.themeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
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
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          elevation: 0,
          title: Text(
            'settings',
            style: GoogleFonts.lato(
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
                              style: GoogleFonts.lato(
                                  color: appTheme.themeColor,
                                  fontWeight: FontWeight.bold),
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
                              style: GoogleFonts.lato(
                                  color: appTheme.themeColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          )),
                    ],
                  )
                : Container()
          ],
        ),
        body: Container(
          color: isDark ? Colors.grey[900] : Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: isLoading
                  ? LoadingWidget(
                      appTheme: appTheme,
                      isDark: isDark,
                    )
                  : Column(
                      children: [
                        buildProfileSection(),
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
    );
  }
}
