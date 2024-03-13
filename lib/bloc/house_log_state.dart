part of 'house_log_bloc.dart';

class HouseLogState extends Equatable {
  final DateTime dateTime;
  final String description;
  final double amount;
  final String houseId;
  final String id;
  final File imageFile;
  final String imageLink;
  const HouseLogState(
      {required this.dateTime,
      required this.description,
      required this.amount,
      required this.houseId,
      required this.id,
      required this.imageFile,
      required this.imageLink});

  @override
  List<Object> get props => [dateTime, description, amount];
}
