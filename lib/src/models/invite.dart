import 'package:flutter/material.dart';
import 'package:sudoku/src/models/user.dart';

class Invite {
  String id;
  String gameId;
  String createdOn;
  Users inviter;
  Users invitee;
  String inviterId;
  String inviteeId;

  Invite(
      {@required this.id,
      @required this.gameId,
      @required this.createdOn,
      @required this.invitee,
      @required this.inviteeId,
      @required this.inviterId,
      @required this.inviter});

  Invite.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    gameId = json['gameId'];
    createdOn = json['createdOn'];
    inviteeId = json['inviteeId'];
    inviteeId = json['inviteeId'];
    invitee = Users.fromJson(json['invitee']);
    inviter = Users.fromJson(json['inviter']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['gameId'] = this.gameId;
    data['createdOn'] = this.createdOn;
    data['inviteeId'] = this.inviteeId;
    data['inviterId'] = this.inviterId;
    data['invitee'] = this.invitee.toJson();
    data['inviter'] = this.inviter.toJson();

    return data;
  }
}
