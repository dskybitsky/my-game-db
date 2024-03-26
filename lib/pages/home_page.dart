import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamorrah/i18n/strings.g.dart';
import 'package:gamorrah/models/game/game.dart';
import 'package:gamorrah/state/preferences/preferences_bloc.dart';
import 'package:gamorrah/state/state_phase.dart';
import 'package:gamorrah/widgets/game/games_navigator.dart';

class HomePage extends StatefulWidget {

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageDestination {
  _HomePageDestination({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final Widget icon;
  final Widget child;
}

class _HomePageState extends State<HomePage> {
  int _destinationIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferencesBloc, PreferencesState>(
      builder: (context, state) {
        if (state.phase.isInitial) {
          return Container();
        }

        if (state.phase.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.phase.isError) {
          return Center(
            child: Text(t.ui.general.errorText),
          );
        }
        
        return _buildContent(context, state);
      },
    );
  }

  Widget _buildContent(BuildContext context, PreferencesState preferencesState) {
    final destinations = _getDestinations(preferencesState);
    final selectedDestination = destinations[_destinationIndex];

    return Row(
      children: [
        NavigationRail(
          destinations: destinations.map((destination) => NavigationRailDestination(
            icon: destination.icon, 
            label: Text(destination.title),
          )).toList(), 
          selectedIndex: _destinationIndex,
          labelType: NavigationRailLabelType.all,
          onDestinationSelected: (index) {
            setState(() => _destinationIndex = index);
          },
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: selectedDestination.child,
        ),
      ],
    );
  }

  List<_HomePageDestination> _getDestinations(PreferencesState state) {
    return [
      _getGamesDestination(GameStatus.backlog, state),
      _getGamesDestination(GameStatus.playing, state),
      _getGamesDestination(GameStatus.finished, state),
      _getGamesDestination(GameStatus.wishlist, state),
    ];
  }

  _HomePageDestination _getGamesDestination(GameStatus status, PreferencesState state) {
    final icon = switch (status) {
      GameStatus.backlog => const Icon(Icons.history),
      GameStatus.playing => const Icon(Icons.play_arrow),
      GameStatus.finished => const Icon(Icons.done),
      GameStatus.wishlist => const Icon(Icons.redeem),
    };

    final title = switch (status) {
      GameStatus.backlog => t.types.gameStatus.backlog,
      GameStatus.playing => t.types.gameStatus.playing,
      GameStatus.finished => t.types.gameStatus.finished,
      GameStatus.wishlist => t.types.gameStatus.wishlist,
    };

    return _HomePageDestination(
      icon: icon, 
      title: title,
      child: GamesNavigator(key: Key('games:$status'), status: status),
    );
  }
}