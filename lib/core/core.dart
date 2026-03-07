/// Core module barrel export
/// Contains shared utilities, configurations, and base classes

// Config
export 'config/env_config.dart';
export 'config/app_config.dart';

// Constants
export 'constants/api_endpoints.dart';
export 'constants/storage_keys.dart';
export 'constants/asset_paths.dart';
export 'constants/app_constants.dart';

// Errors
export 'errors/exceptions.dart';
export 'errors/failures.dart';
export 'errors/error_handler.dart';

// Network
export 'network/api_client.dart';
export 'network/network_info.dart';
export 'network/api_response.dart';

// Database
export 'database/database_helper.dart';

// Services
export 'services/storage_service.dart';
export 'services/secure_storage_service.dart';

// Utils
export 'utils/formatters.dart';
export 'utils/validators.dart';
export 'utils/helpers.dart';
export 'utils/logger.dart';

// Extensions
export 'extensions/context_extensions.dart';
export 'extensions/string_extensions.dart';
export 'extensions/datetime_extensions.dart';
export 'extensions/num_extensions.dart';

// Theme
export 'theme/app_theme.dart';
export 'theme/app_colors.dart';
export 'theme/app_typography.dart';
export 'theme/app_spacing.dart';

// Widgets
export 'widgets/widgets.dart';

// Mixins
export 'mixins/repository_mixin.dart';

// UseCases
export 'usecases/usecase.dart';
