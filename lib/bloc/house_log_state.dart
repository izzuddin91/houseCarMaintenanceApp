part of 'house_log_bloc.dart';

class HouseLogState extends Equatable {
  final DateTime dateTime;
  final String description;
  final double amount;
  final String houseId;
  final String id;
  final File imageFile;
  final String imageLink;
  final List<bool> logType;
  const HouseLogState({
    required this.dateTime,
    required this.description,
    required this.amount,
    required this.houseId,
    required this.id,
    required this.imageFile,
    required this.imageLink,
    required this.logType,
  });

  @override
  List<Object> get props => [dateTime, description, amount, logType];
}
