import 'package:flutter/material.dart';
import 'package:sudoku/src/models/user.dart';

class Invitation {
  String createdOn;
  Users inviter;
  Users invitee;

  Invitation(
      {@required this.createdOn,
      @required this.invitee,
      @required this.inviter});

  Invitation.fromJson(Map<String, dynamic> json) {
    createdOn = json['createdOn'];
    invitee = Users.fromJson(json['invitee']);
    inviter = Users.fromJson(json['inviter']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdOn'] = this.createdOn;
    data['invitee'] = this.invitee.toJson();
    data['inviter'] = this.inviter.toJson();

    return data;
  }
}
