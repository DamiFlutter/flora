import 'package:flora/constants/images.dart';
import 'package:flutter/material.dart';

class Users {
  final String name;
  final String image;
  final int time;
  final String messages;

  Users(
      {required this.name,
      required this.image,
      required this.time,
      required this.messages});
}

List<Users> users = [
  Users(name: 'Mary Mary', image: woman, time: 12, messages: 'Hello i am here'),
  Users(name: 'Mary Mary', image: woman, time: 20, messages: 'Hello i am here'),
  Users(name: 'Mary Mary', image: woman, time: 12, messages: 'Hello i am here'),
  Users(name: 'Mary Mary', image: woman, time: 14, messages: 'Hello i am here'),
  Users(name: 'Mary Mary', image: woman, time: 18, messages: 'Hello i am here'),
  Users(name: 'Mary Mary', image: woman, time: 6, messages: 'Hello i am here'),
];
