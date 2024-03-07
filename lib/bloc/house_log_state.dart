part of 'house_log_bloc.dart';

class HouseLogState extends Equatable {
  final DateTime dateTime;
  final String description;
  final double amount;
  final String houseId;
  final File imageFile;
  const HouseLogState(
      {required this.dateTime,
      required this.description,
      required this.amount,
      required this.houseId,
      required this.imageFile});

  @override
  List<Object> get props => [dateTime, description, amount];
}
