import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'friends_screen.dart';

class FriendsScreenView extends FriendsScreenState {
  Widget buildTopNavBar() {
    return Container(
        child: Row(
      children: [
        Expanded(
            child: GestureDetector(
          onTap: () {
            viewFriends();
          },
          child: Container(
            color: isViewingFriends ? appTheme.themeColor : null,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'your friends',
                  style: GoogleFonts.lato(
                      color: isViewingFriends
                          ? isDark
                              ? Colors.grey[900]
                              : Colors.white
                          : appTheme.themeColor,
                      fontWeight: isViewingFriends
                          ? FontWeight.bold
                          : FontWeight.normal),
                ),
              ),
            ),
          ),
        )),
        Expanded(
            child: GestureDetector(
          onTap: () {
            search();
          },
          child: Container(
            color: isSearching ? appTheme.themeColor : null,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'find people',
                  style: GoogleFonts.lato(
                      color: isSearching
                          ? isDark
                              ? Colors.grey[900]
                              : Colors.white
                          : appTheme.themeColor,
                      fontWeight:
                          isSearching ? FontWeight.bold : FontWeight.normal),
                ),
              ),
            ),
          ),
        ))
      ],
    ));
  }

  Widget buildFindPeopleForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
          key: formKey,
          child: Row(
            children: [
              Expanded(
                  child: TextFormField(
                cursorColor: appTheme.themeColor,
                keyboardType: TextInputType.text,
                style: GoogleFonts.lato(color: appTheme.themeColor),
                decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: appTheme.themeColor)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: appTheme.themeColor)),
                    hintText: 'enter a username',
                    hintStyle: GoogleFonts.lato(color: appTheme.themeColor)),
                onChanged: (value) {
                  setState(() {
                    searchTerm = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please enter a username';
                  }
                  return null;
                },
              )),
            ],
          )),
    );
  }

  Widget buildContents(BuildContext context) {
    return Container(
      child: isSearching ? buildSearching() : Container(),
    );
  }

  Widget buildSearching() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildFindPeopleForm(),
          Flexible(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder(
              stream: databaseProvider.getUsers(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return Container();
                }
                processFindUserData(snapshot);
                return Container(
                  child: ListView.builder(
                      itemCount: foundUsers.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          dense: true,
                          tileColor: appTheme.themeColor,
                          leading: CircularProfileAvatar(
                            foundUsers[index].profileUrl,
                            radius: 20,
                            backgroundColor:
                                isDark ? Colors.grey[900] : Colors.white,
                            initialsText: Text(
                              getInitials(foundUsers[index].username),
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: appTheme.themeColor,
                              ),
                            ),
                            borderColor: Colors.transparent,
                            elevation: 0.0,
                            foregroundColor: Colors.transparent,
                            cacheImage: true,
                            showInitialTextAbovePicture: false,
                          ),
                          title: Text(
                            foundUsers[index].username,
                            style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDark ? Colors.grey[900] : Colors.white),
                          ),
                        );
                      }),
                );
              },
            ),
          ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          title: Text(
            'friends',
            style: GoogleFonts.lato(
              color: appTheme.themeColor,
            ),
          ),
          leading: IconButton(
              icon: Icon(
                LineIcons.arrowLeft,
                color: appTheme.themeColor,
              ),
              onPressed: () {
                goToMultiplayerLobbyScreen();
              }),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          color: isDark ? Colors.grey[900] : Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                buildTopNavBar(),
                buildContents(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
