import 'package:fluent_ui/fluent_ui.dart';

class MainScreenContext extends InheritedWidget {
  const MainScreenContext({
    super.key,
    required this.appBarTitleNotifier,
    required this.appBarActionsNotifier,
    required this.appBarBackTapHandlerNotifier,
    required super.child,
  });

  final ValueNotifier<String?> appBarTitleNotifier;
  final ValueNotifier<Widget?> appBarActionsNotifier;
  final ValueNotifier<VoidCallback?> appBarBackTapHandlerNotifier;
  
  static MainScreenContext? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainScreenContext>();
  }

  static MainScreenContext of(BuildContext context) {
    final MainScreenContext? result = maybeOf(context);
    
    assert(result != null, 'No MainScreenContext found in context');
    
    return result!;
  }

  @override
  bool updateShouldNotify(MainScreenContext oldWidget) {
    return true;
  }
}

mixin MainScreenContextUpdateMixin<T extends StatefulWidget> on State<T> {
  void updateScreenContext(void Function(MainScreenContext mainScreenContext) callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool shouldUpdate = mounted && (
        ModalRoute.of(context)?.isCurrent ?? false
      );

      if (shouldUpdate) {
        MainScreenContext mainScreenContext = MainScreenContext.of(context);
        callback(mainScreenContext);
      }
    });
  }
}