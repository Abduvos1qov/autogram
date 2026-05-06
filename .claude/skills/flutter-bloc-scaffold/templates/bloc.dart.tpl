import 'package:autogram/core/utils/app_logger.dart';
{{useCaseImports}}
import 'package:flutter_bloc/flutter_bloc.dart';

import '{{feature}}_event.dart';
import '{{feature}}_state.dart';

class {{Feature}}Bloc extends Bloc<{{Feature}}Event, {{Feature}}State> {
{{useCaseFields}}

  {{Feature}}Bloc({
{{useCaseConstructorParams}}
  })  : {{useCaseConstructorAssignments}},
        super(const {{Feature}}Initial()) {
{{eventBindings}}
  }

  Future<void> _onRequested(
    {{Feature}}Requested event,
    Emitter<{{Feature}}State> emit,
  ) async {
    AppLogger.info('{{Feature}}: Requested');
    emit(const {{Feature}}Loading());

    // TODO: replace with actual use case call.
    // final result = await _<useCase>UseCase(<UseCase>Params(/* ... */));
    // result.fold(
    //   (failure) => emit({{Feature}}Error(failure.message)),
    //   (data) => emit({{Feature}}Loaded(data)),
    // );
  }

  void _onErrorCleared(
    {{Feature}}ErrorCleared event,
    Emitter<{{Feature}}State> emit,
  ) {
    emit(const {{Feature}}Initial());
  }
}
