import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class MonthYear extends Equatable {
  final int month;
  final String year;
  late String greaterThan;
  late String lessThan;

  MonthYear({
    required this.month,
    required this.year,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [month, year];
}
