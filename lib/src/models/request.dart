import 'package:flutter/material.dart';
import 'package:sudoku/src/models/user.dart';

class Request {
  String id;
  String createdOn;
  Users requester;
  Users requestee;
  String requesterId;
  String requesteeId;

  Request(
      {@required this.id,
      @required this.createdOn,
      @required this.requestee,
      @required this.requesteeId,
      @required this.requesterId,
      @required this.requester});

  Request.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdOn = json['createdOn'];
    requesteeId = json['requesteeId'];
    requesteeId = json['requesteeId'];
    requestee = Users.fromJson(json['requestee']);
    requester = Users.fromJson(json['requester']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['createdOn'] = this.createdOn;
    data['requesteeId'] = this.requesteeId;
    data['requesterId'] = this.requesterId;
    data['requestee'] = this.requestee.toJson();
    data['requester'] = this.requester.toJson();

    return data;
  }
}
