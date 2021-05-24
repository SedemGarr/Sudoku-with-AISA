import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'friends_screen.dart';
import 'dart:math' as math;

class FriendsScreenView extends FriendsScreenState {
  Widget buildTopNavBar() {
    return Container(
        child: Row(
      children: [
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
        )),
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
                  'requests (${myRequests.length})',
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
                autofocus: true,
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
      child: isSearching ? buildSearching() : buildRequests(),
    );
  }

  Widget buildRequests() {
    return Container(
      child: Flexible(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 20),
          child: myRequests.length == 0
              ? Container(
                  child: Padding(
                  padding: EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                      top: MediaQuery.of(context).size.height * 1 / 4),
                  child: Text(
                    'no requests',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(color: appTheme.themeColor),
                  ),
                ))
              : ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      color: appTheme.themeColor,
                      child: ListTile(
                          dense: true,
                          leading: CircularProfileAvatar(
                            myRequests[index].requester.profileUrl,
                            radius: 20,
                            backgroundColor:
                                isDark ? Colors.grey[900] : Colors.white,
                            initialsText: Text(
                              getInitials(myRequests[index].requester.username),
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
                            myRequests[index].requester.username,
                            style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDark ? Colors.grey[900] : Colors.white),
                          ),
                          subtitle: Text(
                            '${myRequests[index].requester.username} wants to be friends',
                            style: GoogleFonts.lato(
                              color: isDark ? Colors.grey[900] : Colors.white,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: Icon(
                                    LineIcons.check,
                                    color: isDark
                                        ? Colors.grey[900]
                                        : Colors.white,
                                  ),
                                  onPressed: () {
                                    showAcceptRequestDialog(myRequests[index],
                                        myRequests[index].requester, context);
                                  }),
                              Transform.rotate(
                                angle: -math.pi / 4,
                                child: IconButton(
                                    icon: Icon(
                                      LineIcons.plus,
                                      color: isDark
                                          ? Colors.grey[900]
                                          : Colors.white,
                                    ),
                                    onPressed: () {
                                      showDenyRequestDialog(myRequests[index],
                                          myRequests[index].requester, context);
                                    }),
                              ),
                            ],
                          )),
                    );
                  },
                  itemCount: myRequests.length,
                ),
        ),
      ),
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
                if (searchTerm != '' &&
                    searchTerm != user.username &&
                    foundUsers.length == 0) {
                  return Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 8.0,
                              right: 8.0,
                              top: MediaQuery.of(context).size.height * 1 / 4),
                          child: Text(
                            'no results found for $searchTerm',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(color: appTheme.themeColor),
                          ),
                        )
                      ],
                    ),
                  );
                }
                return Container(
                  child: ListView.builder(
                      itemCount: foundUsers.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          color: appTheme.themeColor,
                          child: ListTile(
                            dense: true,
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
                            subtitle: Text(
                              hasSentUserRequestPending(foundUsers[index])
                                  ? '${foundUsers[index].username} wants to be friends'
                                  : hasRequestPending(foundUsers[index])
                                      ? 'your request is pending'
                                      : isFriend(index)
                                          ? 'you are friends'
                                          : 'you and ${foundUsers[index].username} are not friends',
                              style: GoogleFonts.lato(
                                color: isDark ? Colors.grey[900] : Colors.white,
                              ),
                            ),
                            trailing: hasSentUserRequestPending(
                                    foundUsers[index])
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                          icon: Icon(
                                            LineIcons.check,
                                            color: isDark
                                                ? Colors.grey[900]
                                                : Colors.white,
                                          ),
                                          onPressed: () {
                                            showAcceptRequestDialog(
                                                myRequests[index],
                                                myRequests[index].requester,
                                                context);
                                          }),
                                      Transform.rotate(
                                        angle: -math.pi / 4,
                                        child: IconButton(
                                            icon: Icon(
                                              LineIcons.plus,
                                              color: isDark
                                                  ? Colors.grey[900]
                                                  : Colors.white,
                                            ),
                                            onPressed: () {
                                              showDenyRequestDialog(
                                                  myRequests[index],
                                                  myRequests[index].requester,
                                                  context);
                                            }),
                                      ),
                                    ],
                                  )
                                : hasRequestPending(foundUsers[index])
                                    ? CircularProgressIndicator(
                                        strokeWidth: 1,
                                        backgroundColor: appTheme.themeColor,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(isDark
                                                ? Colors.grey[900]
                                                : Colors.white),
                                      )
                                    : IconButton(
                                        icon: Icon(
                                          isFriend(index)
                                              ? LineIcons.userFriends
                                              : LineIcons.userPlus,
                                          color: isDark
                                              ? Colors.grey[900]
                                              : Colors.white,
                                        ),
                                        onPressed: isFriend(index)
                                            ? () {
                                                showUnFriendDialog(
                                                    foundUsers[index], context);
                                              }
                                            : () {
                                                showSendRequestDialog(
                                                    foundUsers[index], context);
                                              },
                                      ),
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
        child: StreamBuilder(
          stream: databaseProvider.getRequests(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            processRequestsData(snapshot);
            if (!snapshot.hasData || snapshot.data == null) {
              return Container();
            }
            return Scaffold(
              key: scaffoldKey,
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
            );
          },
        ));
  }
}
