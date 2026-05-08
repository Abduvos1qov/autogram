// Payment feature module barrel export.

// Domain — Entities & Enums
export 'domain/entities/billing_cycle.dart';
export 'domain/entities/boost_package.dart';
export 'domain/entities/payment.dart';
export 'domain/entities/payment_gateway.dart';
export 'domain/entities/payment_product.dart';
export 'domain/entities/payment_request.dart';
export 'domain/entities/payment_status.dart';

// Domain — Repositories
export 'domain/repositories/payment_repository.dart';

// Domain — Services
export 'domain/services/payment_gateway_service.dart';

// Domain — Use cases
export 'domain/usecases/cancel_payment_usecase.dart';
export 'domain/usecases/create_payment_usecase.dart';
export 'domain/usecases/get_payment_status_usecase.dart';
export 'domain/usecases/watch_payment_status_usecase.dart';

// Data — Models
export 'data/models/payment_model.dart';

// Data — Datasources
export 'data/datasources/payment_remote_datasource.dart';

// Data — Repositories
export 'data/repositories/payment_repository_impl.dart';

// Data — Services
export 'data/services/click_payment_gateway_service_impl.dart';
export 'data/services/mock_payment_gateway_service.dart';

// Presentation — Bloc
export 'presentation/bloc/payment_bloc.dart';
export 'presentation/bloc/payment_event.dart';
export 'presentation/bloc/payment_state.dart';

// Presentation — Screens
export 'presentation/screens/payment_screen.dart';
export 'presentation/screens/payment_webview_screen.dart';
export 'presentation/screens/seat_management_screen.dart';

// Presentation — Widgets
export 'presentation/widgets/payment_status_view.dart';
export 'presentation/widgets/payment_summary_card.dart';
export 'presentation/widgets/seat_quantity_selector.dart';
