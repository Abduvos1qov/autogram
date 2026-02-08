import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';

/// Safe scaffold with consistent styling

class SafeScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;
  final bool extendBody;
  final bool resizeToAvoidBottomInset;
  final SystemUiOverlayStyle? systemOverlayStyle;

  const SafeScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
    this.extendBody = false,
    this.resizeToAvoidBottomInset = true,
    this.systemOverlayStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (systemOverlayStyle != null) {
      SystemChrome.setSystemUIOverlayStyle(systemOverlayStyle!);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      extendBody: extendBody,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}

/// Scaffold with custom app bar

class AppBarScaffold extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final Color? appBarBackgroundColor;
  final bool centerTitle;
  final double? elevation;
  final PreferredSizeWidget? bottom;

  const AppBarScaffold({
    super.key,
    this.title,
    this.titleWidget,
    required this.body,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.appBarBackgroundColor,
    this.centerTitle = true,
    this.elevation,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarBackgroundColor,
        title: titleWidget ??
            (title != null
                ? Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null),
        centerTitle: centerTitle,
        elevation: elevation ?? 0,
        leading: leading ??
            (showBackButton && Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBackPressed ?? () => Navigator.pop(context),
                  )
                : null),
        actions: actions,
        bottom: bottom,
      ),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Full-screen scaffold (for Reels, video players, etc.)

class FullScreenScaffold extends StatelessWidget {
  final Widget body;
  final Widget? overlayWidget;
  final Color? backgroundColor;
  final SystemUiOverlayStyle overlayStyle;

  const FullScreenScaffold({
    super.key,
    required this.body,
    this.overlayWidget,
    this.backgroundColor,
    this.overlayStyle = SystemUiOverlayStyle.light,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: backgroundColor ?? AppColors.black,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            body,
            if (overlayWidget != null) overlayWidget!,
          ],
        ),
      ),
    );
  }
}
