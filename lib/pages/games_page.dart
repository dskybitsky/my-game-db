import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamorrah/i18n/strings.g.dart';
import 'package:gamorrah/models/game/game.dart';
import 'package:gamorrah/models/preferences/preferences.dart';
import 'package:gamorrah/state/preferences/preferences_bloc.dart';
import 'package:gamorrah/widgets/game/games_filter_dialog.dart';
import 'package:gamorrah/widgets/game/games_list.dart';
import 'package:gamorrah/state/game/games_bloc.dart';
import 'package:gamorrah/widgets/game/games_navigator.dart';
import 'package:gamorrah/widgets/game/games_preset_dialog.dart';
import 'package:gamorrah/widgets/ui/hspacer.dart';
import 'package:gamorrah/widgets/ui/space_size.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({ 
    required this.status,
    this.preset,
  });

  final GameStatus status;
  final GamesPreset? preset;

  @override
  State<GamesPage> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesPage> {
  late TextEditingController _searchController;
  late GamesFilter _filter;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController(text: '');
    _filter = widget.preset?.filter ?? GamesFilter();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GamesBloc, GamesState>(
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

  Widget _buildContent(BuildContext context, GamesState state) {
    final games = _getGamesList(state);

    return Builder(
      builder: (context) {
        if (state.games.isEmpty) {
          return Center(
            child: Text(t.ui.general.emptyText),
          );
        }

        return Scaffold(
          // padding: EdgeInsets.zero,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Center(child: GamesList(games: games)),
          ),
          // bottomBar: Container(
          //   alignment: Alignment.centerRight,
          //   padding: EdgeInsets.only(top: 8, bottom: 8, right: 24),
          //   child: Text(
          //     t.ui.gamesPage.gamesTotalText(count: games.length),
          //     // style: FluentTheme.of(context).typography.caption,
          //   ),
          // ),
        );
      },
    );
  }

  Widget _buildActions(BuildContext context, GamesState state) {
    final searchWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 256,
          child: TextField(
            controller: _searchController,
            // placeholder: t.ui.gamesPage.searchPlaceholder,
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
      ],
    );
    
    final filterWidget = Tooltip(
      message: t.ui.gamesPage.filterButton,
      child: IconButton(
        icon: _filter.isEmpty
          ? Icon(Icons.filter)
          : Icon(Icons.filter, color: Colors.blue),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => GamesFilterDialog(
              filter: _filter,
              onChanged: (value) {
                setState(() {
                  _filter = value;
                });
              },
            ),
            useRootNavigator: false,
          );
        },
      )
    );

    final savePresetWidget = Tooltip(
      message: t.ui.gamesPage.savePresetButton,
      child: IconButton(
        icon: Icon(Icons.save),
        onPressed: _filter.isEmpty ? null : () {
          showDialog(
            context: context,
            builder: (context) => GamesPresetDialog(
              onChanged: (value) {
                context.read<PreferencesBloc>()
                  .add(SaveGamesPreset(
                    gamesPreset: GamesPreset(
                      name: value, 
                      status: widget.status,
                      filter: _filter
                    )
                  ));
              },
            ),
            useRootNavigator: false,
          );
        },
      )
    );

    final createGameWidget = Tooltip(
      message: t.ui.gamesPage.addGameButton,
      child: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () {
          final game = Game.create(
            title: t.ui.gamesPage.defaultGameTitle, 
            thumbUrl: null,
            status: widget.status,
          );

          context.read<GamesBloc>().add(SaveGame(game: game));

          GamesNavigator.goGame(context, id: game.id);
        },
      )
    );
      
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        HSpacer(size: SpaceSize.xxxl),
        searchWidget,
        HSpacer(size: SpaceSize.s),
        filterWidget,
        HSpacer(size: SpaceSize.s),
        savePresetWidget,
        HSpacer(size: SpaceSize.l),
        createGameWidget,
        HSpacer(size: SpaceSize.xl),
      ]
    );
  }

  List<Game> _getGamesList(GamesState state) {
    final searchText = _searchController.text;

    final games = state.games
      .where((game) {
        if (game.status != widget.status) {
          return false;
        }

        if (game.parentId != null) {
          return false;
        }

        return (
          (searchText == '' || game.title.contains(RegExp(searchText, caseSensitive: false)))
          && _filter.matches(game)
        );
      })
      .toList();

    games.sort((Game gameA, Game gameB) {
      final franchisedTitleA = gameA.franchise ?? gameA.title;
      final franchisedTitleB = gameB.franchise ?? gameB.title;
              
      if (franchisedTitleA == franchisedTitleB) {
        final franchisedIndexA = gameA.index ?? gameA.year ?? 0;
        final franchisedIndexB = gameB.index ?? gameB.year ?? 0;
                  
        return franchisedIndexA.compareTo(franchisedIndexB);
      }
              
      return franchisedTitleA.compareTo(franchisedTitleB);
    });

    return games;
  }

  String _getTitle() {
    switch (widget.status) {
      case GameStatus.backlog:
        return t.types.gameStatus.backlog;
      case GameStatus.playing:
        return t.types.gameStatus.playing;
      case GameStatus.finished:
        return t.types.gameStatus.finished;
      case GameStatus.wishlist:
        return t.types.gameStatus.wishlist;
    }
  }
}