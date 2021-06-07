import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sudoku/src/components/loading_widget.dart';
import 'package:sudoku/src/components/title_widget.dart';
import 'package:sudoku/src/models/theme.dart';
import 'home_screen.dart';
import 'dart:math' as math;
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreenView extends HomeScreenState {
  Widget buildTitleWidget() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      width: getTitleWidth(),
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.10),
      child: AnimatedOpacity(opacity: getTitleOpacity(), duration: Duration(milliseconds: 100), child: TitleWidget(color: appTheme.themeColor)),
    );
  }

  Widget buildTitleSlider() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      width: getTitleWidth(),
      child: AnimatedOpacity(
        opacity: getTitleOpacity(),
        duration: Duration(milliseconds: 100),
        child: CarouselSlider(
          options: CarouselOptions(
            //  height: 175,
            pauseAutoPlayOnManualNavigate: true,
            scrollDirection: Axis.horizontal,
            autoPlay: !user.hasCompletedGame,
            autoPlayInterval: Duration(seconds: 5),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            initialPage: user.difficultyLevel,
            enableInfiniteScroll: true,
          ),
          items: game.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return LayoutBuilder(
                  builder: (context, constraint) {
                    return GestureDetector(
                      onTap: isUnlocked(user.difficultyLevel, i.id)
                          ? user.difficultyLevel > i.id
                              ? () {}
                              : () {
                                  startGame();
                                }
                          : () {},
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  i.icon,
                                  color: isUnlocked(user.difficultyLevel, i.id) ? i.theme.themeColor : Colors.grey,
                                  size: constraint.biggest.height * 0.65,
                                ),
                                Text(
                                  isUnlocked(user.difficultyLevel, i.id)
                                      ? user.difficultyLevel > i.id
                                          ? 'complete'
                                          : i.difficultyName
                                      : 'locked',
                                  style: GoogleFonts.lato(
                                      fontSize: 16.0, fontWeight: FontWeight.bold, color: isUnlocked(user.difficultyLevel, i.id) ? i.theme.themeColor : Colors.grey),
                                ),
                              ],
                            ),
                          )),
                    );
                  },
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildSinglePlayerStats(List<dynamic> stats, String id) {
    List listOfSinglePlayerStats = stats.where((element) => element.isSinglePlayer == true).toList();
    List<Widget> spStats = [];

    listOfSinglePlayerStats.forEach((stat) {
      spStats.add(ListTile(
        dense: true,
        title: Text(
          stat.level.toString() + ' - ${parseDifficultyToString(stat.difficulty)}',
          style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              color: isMe(id)
                  ? isDark
                      ? Colors.grey[900]
                      : Colors.white
                  : appTheme.themeColor),
        ),
        trailing: Text(
          parseLevelTime(Duration(seconds: stat.timeTaken)),
          style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              color: isMe(id)
                  ? isDark
                      ? Colors.grey[900]
                      : Colors.white
                  : appTheme.themeColor),
        ),
      ));
    });

    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
        child: Column(
          children: [
            listOfSinglePlayerStats.length == 0
                ? ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LineIcons.user,
                            color: isMe(id)
                                ? isDark
                                    ? Colors.grey[900]
                                    : Colors.white
                                : appTheme.themeColor),
                      ],
                    ),
                    title: Text(
                      listOfSinglePlayerStats.length == 0
                          ? 'hasn\'t finished a story level yet!'
                          : listOfSinglePlayerStats.length >= 54
                              ? 'game completed'
                              : 'last story level',
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: isMe(id)
                              ? isDark
                                  ? Colors.grey[900]
                                  : Colors.white
                              : appTheme.themeColor),
                    ))
                : ExpansionTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LineIcons.user,
                            color: isMe(id)
                                ? isDark
                                    ? Colors.grey[900]
                                    : Colors.white
                                : appTheme.themeColor),
                      ],
                    ),
                    title: Text(
                      listOfSinglePlayerStats.length >= 54 ? 'game completed' : 'last story level: ',
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: isMe(id)
                              ? isDark
                                  ? Colors.grey[900]
                                  : Colors.white
                              : appTheme.themeColor),
                    ),
                    trailing: listOfSinglePlayerStats.length == 0
                        ? null
                        : Text(
                            listOfSinglePlayerStats[listOfSinglePlayerStats.length - 1].level.toString(),
                            style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                                color: isMe(id)
                                    ? isDark
                                        ? Colors.grey[900]
                                        : Colors.white
                                    : appTheme.themeColor),
                          ),
                    children: spStats,
                  )
          ],
        ),
      ),
    );
  }

  Widget buildFreePlayStats(List<dynamic> stats, String id) {
    List listOfFreePlayStats = stats.where((element) => element.level == 300).toList();
    return listOfFreePlayStats.length > 0
        ? Container(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                children: [
                  ExpansionTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LineIcons.star,
                            color: isMe(id)
                                ? isDark
                                    ? Colors.grey[900]
                                    : Colors.white
                                : appTheme.themeColor),
                      ],
                    ),
                    title: Text(
                      'free play games played: ',
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: isMe(id)
                              ? isDark
                                  ? Colors.grey[900]
                                  : Colors.white
                              : appTheme.themeColor),
                    ),
                    trailing: Text(
                      listOfFreePlayStats.length.toString(),
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: isMe(id)
                              ? isDark
                                  ? Colors.grey[900]
                                  : Colors.white
                              : appTheme.themeColor),
                    ),
                    children: [
                      ListTile(
                        dense: true,
                        title: Text(
                          'avergae time taken: ',
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              color: isMe(id)
                                  ? isDark
                                      ? Colors.grey[900]
                                      : Colors.white
                                  : appTheme.themeColor),
                        ),
                        trailing: Text(
                          parseLevelTime(Duration(seconds: getAverageTimeTaken(listOfFreePlayStats))).toString(),
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              color: isMe(id)
                                  ? isDark
                                      ? Colors.grey[900]
                                      : Colors.white
                                  : appTheme.themeColor),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                          'average difficulty: ',
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              color: isMe(id)
                                  ? isDark
                                      ? Colors.grey[900]
                                      : Colors.white
                                  : appTheme.themeColor),
                        ),
                        trailing: Text(
                          getAverageDifficulty(listOfFreePlayStats).toString(),
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              color: isMe(id)
                                  ? isDark
                                      ? Colors.grey[900]
                                      : Colors.white
                                  : appTheme.themeColor),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        : Container();
  }

  Widget buildCoopMultiPlayerStats(List<dynamic> stats, String id) {
    List listOfCoopStats = stats.where((element) => element.isCoop).toList();
    List listOfCompetitiveStats = stats.where((element) => element.isCompetitive).toList();

    return stats.where((element) => element.isCoop || element.isCompetitive).toList().length > 0
        ? Container(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                children: [
                  ExpansionTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LineIcons.users,
                            color: isMe(id)
                                ? isDark
                                    ? Colors.grey[900]
                                    : Colors.white
                                : appTheme.themeColor),
                      ],
                    ),
                    title: Text(
                      'multiplayer games played: ',
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: isMe(id)
                              ? isDark
                                  ? Colors.grey[900]
                                  : Colors.white
                              : appTheme.themeColor),
                    ),
                    trailing: Text(
                      (listOfCoopStats.length + listOfCompetitiveStats.length).toString(),
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: isMe(id)
                              ? isDark
                                  ? Colors.grey[900]
                                  : Colors.white
                              : appTheme.themeColor),
                    ),
                    children: [
                      ListTile(
                        dense: true,
                        title: Text(
                          'co-op games played: ',
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              color: isMe(id)
                                  ? isDark
                                      ? Colors.grey[900]
                                      : Colors.white
                                  : appTheme.themeColor),
                        ),
                        trailing: Text(
                          listOfCoopStats.length.toString(),
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              color: isMe(id)
                                  ? isDark
                                      ? Colors.grey[900]
                                      : Colors.white
                                  : appTheme.themeColor),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                          'competitive games win rate: ',
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              color: isMe(id)
                                  ? isDark
                                      ? Colors.grey[900]
                                      : Colors.white
                                  : appTheme.themeColor),
                        ),
                        trailing: Text(
                          (stats.where((element) => element.isCompetitive && element.wonGame).toList().length / listOfCompetitiveStats.length).toStringAsFixed(1) + '%',
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              color: isMe(id)
                                  ? isDark
                                      ? Colors.grey[900]
                                      : Colors.white
                                  : appTheme.themeColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        : Container();
  }

  Widget buildLeaderboard() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: StreamBuilder(
          stream: databaseProvider.getLeaderboard(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return Container(
                color: AppTheme.getLightOrDarkModeTheme(isDark),
                child: LoadingWidget(
                  appTheme: appTheme,
                  isDark: isDark,
                ),
              );
            }
            processLeaderboardStreamData(snapshot);
            return Container(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          return AutoScrollTag(
                            key: ValueKey(index),
                            controller: autoScrollController,
                            index: index,
                            child: Card(
                                elevation: 0,
                                color: isMe(leaderboard[index].id) ? appTheme.themeColor : Colors.transparent,
                                child: ExpansionTile(
                                  key: GlobalKey(),
                                  onExpansionChanged: (value) {
                                    if (!isLeaderboardExpanded) {
                                      setState(() {
                                        isLeaderboardExpanded = true;
                                      });
                                    }
                                  },
                                  leading: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          openPhoto(context, leaderboard[index].profileUrl, leaderboard[index].username);
                                        },
                                        child: CircularProfileAvatar(
                                          leaderboard[index].profileUrl,
                                          radius: 20,
                                          backgroundColor: isMe(leaderboard[index].id)
                                              ? isDark
                                                  ? Colors.grey[900]
                                                  : Colors.white
                                              : appTheme.themeColor,
                                          initialsText: Text(
                                            getInitials(leaderboard[index].username),
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.bold,
                                              color: isMe(leaderboard[index].id)
                                                  ? appTheme.themeColor
                                                  : isDark
                                                      ? Colors.grey[900]
                                                      : Colors.white,
                                            ),
                                          ),
                                          borderColor: Colors.transparent,
                                          elevation: 0.0,
                                          foregroundColor: Colors.transparent,
                                          cacheImage: true,
                                          showInitialTextAbovePicture: false,
                                        ),
                                      )),
                                  title: Text(
                                    leaderboard[index].username,
                                    style: GoogleFonts.lato(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isMe(leaderboard[index].id)
                                            ? isDark
                                                ? Colors.grey[900]
                                                : Colors.white
                                            : appTheme.themeColor),
                                  ),
                                  subtitle: Text(
                                    leaderboard[index].score == 1 ? leaderboard[index].score.toString() + ' point' : leaderboard[index].score.toString() + ' points',
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.bold,
                                        color: isMe(leaderboard[index].id)
                                            ? isDark
                                                ? Colors.grey[900]
                                                : Colors.white
                                            : appTheme.themeColor),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      isFirst(index)
                                          ? Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                              child: Icon(
                                                LineIcons.crown,
                                                color: isMe(leaderboard[index].id)
                                                    ? isDark
                                                        ? Colors.grey[900]
                                                        : Colors.white
                                                    : appTheme.themeColor,
                                              ),
                                            )
                                          : Container(),
                                      leaderboard[index].hasCompletedGame
                                          ? Icon(
                                              LineIcons.certificate,
                                              color: isMe(leaderboard[index].id)
                                                  ? isDark
                                                      ? Colors.grey[900]
                                                      : Colors.white
                                                  : appTheme.themeColor,
                                            )
                                          : Container()
                                    ],
                                  ),
                                  children: [
                                    Column(
                                      children: [
                                        buildSinglePlayerStats(leaderboard[index].stats, leaderboard[index].id),
                                        buildFreePlayStats(leaderboard[index].stats, leaderboard[index].id),
                                        buildCoopMultiPlayerStats(leaderboard[index].stats, leaderboard[index].id)
                                      ],
                                    )
                                  ],
                                )),
                          );
                        },
                        itemCount: leaderboard.length),
                  ),
                  buildExpandButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildExpandButton() {
    return TextButton(
        onPressed: toggleLeaderboardExpansion,
        child: Text(
          isLeaderboardExpanded ? 'collapse' : 'expand',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: appTheme.themeColor),
        ));
  }

  Widget buildMenuIconsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: Tooltip(
              message: 'sign out',
              decoration: BoxDecoration(color: appTheme.themeColor),
              child: IconButton(
                  icon: Icon(
                    LineIcons.walking,
                    color: appTheme.themeColor,
                  ),
                  onPressed: () {
                    showSignOutDialog(context);
                  }),
            ),
          ),
          Tooltip(
            message: 'multiplayer',
            decoration: BoxDecoration(color: appTheme.themeColor),
            child: IconButton(
                icon: Icon(
                  LineIcons.users,
                  color: appTheme.themeColor,
                ),
                onPressed: () {
                  goToMultiplayerLobbyScreen();
                }),
          ),
          Tooltip(
            message: 'settings',
            decoration: BoxDecoration(color: appTheme.themeColor),
            child: IconButton(
                icon: Icon(
                  LineIcons.cog,
                  color: appTheme.themeColor,
                ),
                onPressed: () {
                  goToSettingsScreen();
                }),
          )
        ],
      ),
    );
  }

  Widget buildFindMeButton() {
    return TextButton(
      onPressed: () {
        findMe();
      },
      child: Text(
        'find me',
        style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: appTheme.themeColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showExitDialog(context);
        return false;
      },
      child: Scaffold(
        key: scaffoldKey,
        body: Container(
          color: AppTheme.getLightOrDarkModeTheme(isDark),
          child: SafeArea(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: widgetOpacity,
              child: Column(
                children: [buildTitleWidget(), buildTitleSlider(), isLeaderboardExpanded ? buildFindMeButton() : Container(), buildLeaderboard(), buildMenuIconsRow()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
