import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sudoku/src/components/title_widget.dart';
import 'home_screen.dart';
import 'dart:math' as math;
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreenView extends HomeScreenState {
  Widget buildTitleWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TitleWidget(color: appTheme.themeColor),
    );
  }

  Widget buildTitleSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 175,
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            i.icon,
                            color: isUnlocked(user.difficultyLevel, i.id)
                                ? i.theme.themeColor
                                : Colors.grey,
                            size: constraint.biggest.height * 0.65,
                          ),
                          Text(
                            isUnlocked(user.difficultyLevel, i.id)
                                ? user.difficultyLevel > i.id
                                    ? 'complete'
                                    : i.difficultyName
                                : 'locked',
                            style: GoogleFonts.lato(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: isUnlocked(user.difficultyLevel, i.id)
                                    ? i.theme.themeColor
                                    : Colors.grey),
                          ),
                        ],
                      )),
                );
              },
            );
          },
        );
      }).toList(),
    );
  }

  Widget buildSinglePlayerStats(List<dynamic> stats, String id) {
    List listOfSinglePlayerStats =
        stats.where((element) => element['isSinglePlayer'] == true).toList();
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05),
        child: Column(
          children: [
            ListTile(
              title: Text(
                listOfSinglePlayerStats.length >= 54
                    ? 'game completed'
                    : 'has completed...',
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    color: isMe(id)
                        ? isDark
                            ? Colors.grey[900]
                            : Colors.white
                        : appTheme.themeColor),
              ),
              subtitle: Text(
                listOfSinglePlayerStats.length == 0
                    ? 'hasn\'t finished a level yet!'
                    : 'level ' +
                        listOfSinglePlayerStats[
                                listOfSinglePlayerStats.length - 1]['level']
                            .toString(),
                style: GoogleFonts.lato(
                    color: isMe(id)
                        ? isDark
                            ? Colors.grey[900]
                            : Colors.white
                        : appTheme.themeColor),
              ),
              trailing: listOfSinglePlayerStats.length == 0
                  ? null
                  : Text(
                      parseLevelTime(Duration(
                          seconds: listOfSinglePlayerStats[
                                  listOfSinglePlayerStats.length - 1]
                              ['timeTaken'])),
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
        ),
      ),
    );
  }

  Widget buildFreePlayStats(List<dynamic> stats, String id) {
    List listOfFreePlayStats =
        stats.where((element) => element['level'] == 300).toList();
    return listOfFreePlayStats.length > 0
        ? Container(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'free-play games played...',
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: isMe(id)
                              ? isDark
                                  ? Colors.grey[900]
                                  : Colors.white
                              : appTheme.themeColor),
                    ),
                    subtitle: Text(
                      listOfFreePlayStats.length.toString(),
                      style: GoogleFonts.lato(
                          color: isMe(id)
                              ? isDark
                                  ? Colors.grey[900]
                                  : Colors.white
                              : appTheme.themeColor),
                    ),
                  )
                ],
              ),
            ),
          )
        : Container();
  }

  Widget buildCoopMultiPlayerStats(List<dynamic> stats, String id) {
    List listOfMultiPlayerStats =
        stats.where((element) => element['isCoop']).toList();
    return listOfMultiPlayerStats.length > 0
        ? Container(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'multiplayer co-op games played...',
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: isMe(id)
                              ? isDark
                                  ? Colors.grey[900]
                                  : Colors.white
                              : appTheme.themeColor),
                    ),
                    subtitle: Text(
                      listOfMultiPlayerStats.length.toString(),
                      style: GoogleFonts.lato(
                          color: isMe(id)
                              ? isDark
                                  ? Colors.grey[900]
                                  : Colors.white
                              : appTheme.themeColor),
                    ),
                  )
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
              return Container();
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
                                color: isMe(leaderboard[index].id)
                                    ? appTheme.themeColor
                                    : Colors.transparent,
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
                                      child: CircularProfileAvatar(
                                        leaderboard[index].profileUrl,
                                        radius: 20,
                                        backgroundColor:
                                            isMe(leaderboard[index].id)
                                                ? isDark
                                                    ? Colors.grey[900]
                                                    : Colors.white
                                                : appTheme.themeColor,
                                        initialsText: Text(
                                          getInitials(
                                              leaderboard[index].username),
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
                                    leaderboard[index].score.toString() +
                                        ' points',
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: Icon(
                                                LineIcons.crown,
                                                color:
                                                    isMe(leaderboard[index].id)
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
                                        buildSinglePlayerStats(
                                            leaderboard[index].stats,
                                            leaderboard[index].id),
                                        buildFreePlayStats(
                                            leaderboard[index].stats,
                                            leaderboard[index].id),
                                        buildCoopMultiPlayerStats(
                                            leaderboard[index].stats,
                                            leaderboard[index].id)
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
          style: GoogleFonts.lato(
              fontWeight: FontWeight.bold, color: appTheme.themeColor),
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
        style: GoogleFonts.lato(
            fontWeight: FontWeight.bold, color: appTheme.themeColor),
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
          color: isDark ? Colors.grey[900] : Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                !isLeaderboardExpanded ? buildTitleWidget() : Container(),
                !isLeaderboardExpanded ? buildTitleSlider() : Container(),
                isLeaderboardExpanded ? buildFindMeButton() : Container(),
                buildLeaderboard(),
                buildMenuIconsRow()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
