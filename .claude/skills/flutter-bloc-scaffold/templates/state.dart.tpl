import 'package:equatable/equatable.dart';

// TODO: import any entities the loaded state should carry, e.g.:
// import '../../domain/entities/{{feature}}.dart';

abstract class {{Feature}}State extends Equatable {
  const {{Feature}}State();

  @override
  List<Object?> get props => [];
}

class {{Feature}}Initial extends {{Feature}}State {
  const {{Feature}}Initial();
}

class {{Feature}}Loading extends {{Feature}}State {
  final String? message;
  const {{Feature}}Loading({this.message});

  @override
  List<Object?> get props => [message];
}

class {{Feature}}Loaded extends {{Feature}}State {
  // TODO: replace with the actual payload, e.g.:
  // final List<{{Feature}}> items;
  // const {{Feature}}Loaded(this.items);
  // @override
  // List<Object?> get props => [items];
  const {{Feature}}Loaded();
}

class {{Feature}}Error extends {{Feature}}State {
  final String message;
  const {{Feature}}Error(this.message);

  @override
  List<Object?> get props => [message];
}
