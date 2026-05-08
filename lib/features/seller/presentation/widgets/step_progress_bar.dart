/// Re-export of the canonical [StepProgressBar] from the core widgets barrel.
///
/// The widget was promoted to `lib/core/widgets/feedback/step_progress_bar.dart`
/// so it can be shared between the seller upgrade flow and the auth
/// (forgot-password) flow. This file is preserved as a thin re-export to keep
/// existing seller imports working while parallel work proceeds elsewhere.
library;

export '../../../../core/widgets/feedback/step_progress_bar.dart';
