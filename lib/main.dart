import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_game_db/i18n/strings.g.dart';
import 'package:my_game_db/models/game/game_repository.dart';
import 'package:my_game_db/models/game/hive_game.dart';
import 'package:my_game_db/models/game/hive_game_repository.dart';
import 'package:my_game_db/models/games_view/games_view_repository.dart';
import 'package:my_game_db/models/games_view/hive_games_view.dart';
import 'package:my_game_db/models/games_view/hive_games_view_repository.dart';
import 'package:my_game_db/models/preferences/hive_preferences.dart';
import 'package:my_game_db/models/preferences/hive_preferences_repository.dart';
import 'package:my_game_db/models/preferences/preferences_repository.dart';
import 'package:my_game_db/state/game/games_bloc.dart';
import 'package:my_game_db/state/games_view/games_views_bloc.dart';
import 'package:my_game_db/pages/home_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

import 'state/preferences/preferences_bloc.dart';

void main() async {
  SystemTheme.accentColor.load();

  WidgetsFlutterBinding.ensureInitialized();

  LocaleSettings.useDeviceLocale();

  await _initHive();
  await _initWindow();

  runApp(MyApp());
}

Future<void> _initHive() async {
  Hive.registerAdapter(HiveGameAdapter());
  Hive.registerAdapter(HivePreferencesAdapter());
  Hive.registerAdapter(HiveGamesViewAdapter());
  Hive.registerAdapter(HiveGamesFilterAdapter());
  Hive.registerAdapter(HiveGamesFilterPlatformsPredicateAdapter());
  Hive.registerAdapter(HiveGamesFilterBeatenPredicateAdapter());
  Hive.registerAdapter(HiveGamesFilterHowLongToBeatPredicateAdapter());
  Hive.registerAdapter(HiveGamesFilterTagsPredicateAdapter());

  await Hive.initFlutter();
}

Future<void> _initWindow() async {
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(800, 600),
    minimumSize: Size(600, 400),
    center: true,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    const seedColor = Colors.deepPurple;

    return MaterialApp(
      title: 'My Game DB',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        )
      ),
      home: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<GameRepository>(
            create: (context) => HiveGameRepository(),
          ),
          RepositoryProvider<GamesViewRepository>(
            create: (context) => HiveGamesViewRepository(),
          ),
          RepositoryProvider<PreferencesRepository>(
            create: (context) => HivePreferencesRepository(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<GamesBloc>(
              create: (context) => GamesBloc(
                gameRepository: context.read<GameRepository>(),
              )..add(LoadGames()),
            ),
            BlocProvider<GamesViewsBloc>(
              create: (context) => GamesViewsBloc(
                gamesViewRepository: context.read<GamesViewRepository>(),
              )..add(LoadGamesViews()),
            ),
            BlocProvider<PreferencesBloc>(
              create: (context) => PreferencesBloc(
                preferencesRepository: context.read<PreferencesRepository>(),
              )..add(LoadPrefernces()),
            ),
          ],
          child: HomePage(),
        ),
      ),
    );
  }
}