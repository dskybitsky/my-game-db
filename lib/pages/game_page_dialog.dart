import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_game_db/i18n/strings.g.dart';
import 'package:my_game_db/models/game/game.dart';
import 'package:my_game_db/models/optional.dart';
import 'package:my_game_db/state/game/games_bloc.dart';
import 'package:my_game_db/widgets/game/game_platforms_choice.dart';
import 'package:my_game_db/widgets/ui/spacer.dart';

class GamePageDialog extends StatefulWidget {
  const GamePageDialog({ required this.game });

  final Game game;

  @override
  State<GamePageDialog> createState() => _GamePageDialogState();
}

class _GamePageDialogState extends State<GamePageDialog> {
  late TextEditingController _titleController;
  late TextEditingController _franchiseController;
  late TextEditingController _editionController;
  late TextEditingController _yearController;
  late TextEditingController _thumbUrlController;
  late Set<GamePlatform> _platforms;
  
  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.game.title);
    _franchiseController = TextEditingController(text: widget.game.franchise);
    _editionController = TextEditingController(text: widget.game.edition);
    _yearController = TextEditingController(text: widget.game.year?.toString());
    _thumbUrlController = TextEditingController(text: widget.game.thumbUrl);
    _platforms = Set.from(widget.game.platforms);
  }

  @override
  void dispose() {
    super.dispose();

    _titleController.dispose();
    _franchiseController.dispose();
    _editionController.dispose();
    _yearController.dispose();
    _thumbUrlController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t.ui.gamePage.dialogTitle),
      content: _buildContent(context),
      actions: [
        TextButton(
          child: Text(t.ui.general.cancelButton),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          onPressed: () {
            context.read<GamesBloc>().add(
              SaveGame(game: widget.game.copyWith(
                title: Optional(_titleController.text),
                franchise: Optional(_franchiseController.text),
                edition: Optional(_editionController.text),
                year: Optional(int.tryParse(_yearController.text)),
                thumbUrl: Optional(_thumbUrlController.text),
                platforms: Optional(_platforms),
              ))
            );
            Navigator.pop(context);
          },
          child: Text(t.ui.general.saveButton),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: t.ui.gamePage.titleLabel,
            ),
          ),
          VSpacer(),
          TextField(
            controller: _franchiseController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: t.ui.gamePage.franchiseLabel,
            ),
          ),
          VSpacer(),
          TextField(
            controller: _yearController,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: t.ui.gamePage.yearLabel,
            ),
          ),
          VSpacer(),
          TextField(
            controller: _editionController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: t.ui.gamePage.editionLabel,
            ),
          ),
          VSpacer(),
          TextField(
            controller: _thumbUrlController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: t.ui.gamePage.thumbUrlLabel,
            ),
          ),
          VSpacer(),
          GamePlatformsChoice(
            value: _platforms,
            onChanged: (value) {
              setState((){ 
                _platforms = value;
              });
            },
          ),
        ],
      ),
    );
  }
}