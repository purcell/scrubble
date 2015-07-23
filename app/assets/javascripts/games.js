// global window
(function(m, document, _){
  "use strict";

  var CSRF_TOKEN = document.querySelector('meta[name="csrf-token"]').attributes.content.value;

  var XHR_CONFIG = function(xhr) {
    xhr.setRequestHeader('X-CSRF-Token', CSRF_TOKEN);
  };

  function makeErrorHandler(actionDescription) {
    return function(response) {
      alert("Error " + actionDescription +
            (response && response.errors ? ":\n" + response.errors.join("\n") : ''));
    };
  }

  //////////////////////////////////////////////////////////////////////
  // Models
  //////////////////////////////////////////////////////////////////////

  function combineClasses(classes) {
    return _.compact(classes).join(" ");
  }

  function makeGame(initial) {
    var game = {
      selectBoardSquare: function(square) {
        if (!square.tile) {
          maybePlaySelectedTile(square);
        }
      },

      replaceTiles: function() {
        game.placedTiles.forEach(replaceTile);
      },

      toggleTile: function(tile) {
        return replaceTile(tile) || toggleSelectTrayTile(tile);
      },

      submitPlacedTiles: function() {
        var data = _.compact(_.map(allSquares(), (function(sq) {
          if(_.include(game.placedTiles, sq.tile)) {
            return { x: sq.position.x, y: sq.position.y,
                     letter: sq.tile.letter, blank: sq.tile.blank };
          }
        })));
        m.request({ method: "POST", url: "/games/" + game.game_id + "/placements",
                    data: { played_tiles: data }, config: XHR_CONFIG })
          .then(updateGame, makeErrorHandler("submitting placement"));
      },

      swapTiles: function() {
        m.request({ method: "POST", url: ("/games/" + game.game_id + "/tile_swaps"),
                    data: { tiles: game.selectedTrayTiles }, config: XHR_CONFIG })
          .then(updateGame, makeErrorHandler("swapping tiles"));
      },

      passTurn: function() {
        m.request({ method: "POST", url: ("/games/" + game.game_id + "/turn_passes"),
                    config: XHR_CONFIG })
          .then(updateGame, makeErrorHandler("passing the turn"));
      }
    };

    return updateGame(initial);

    function updateGame(data) {
      return _.extend(game, {
        placedTiles: [],
        selectedTrayTiles: []
      }, data);
    }

    function maybePlaySelectedTile(square) {
      if (game.selectedTrayTiles.length == 1) {
        placeTile(game.selectedTrayTiles[0], square);
        return true;
      }
      return false;
    }

    function toggleSelectTrayTile(tile) {
      if (_.include(game.selectedTrayTiles, tile)) {
        _.remove(game.selectedTrayTiles, tile);
      } else {
        game.selectedTrayTiles.push(tile);
      }
    }

    function allSquares() {
      return _.flatten(game.board.rows);
    }

    function readLetter() {
      var letter = prompt("Which letter?");
      return letter.match(/^[a-zA-Z]$/) ? letter.toUpperCase() : null;
    }

    function placeTile(tileToPlace, square) {
      if (square && !square.tile && _.include(game.tray, tileToPlace)) {
        if (tileToPlace.blank) {
          var letter = readLetter();
          if (!letter) return;
          tileToPlace.letter = letter;
        }
        game.placedTiles.push(tileToPlace);
        game.tray[_.indexOf(game.tray, tileToPlace)] = null;
        square.tile = tileToPlace;
        game.selectedBoardSquare = null;
        game.selectedTrayTiles = [];
        return true;
      }
    }

    function replaceTile(tile) {
      if (_.include(game.placedTiles, tile)) {
        allSquares().map(function(square) {
          if (square.tile == tile) {
            square.tile = null;
            game.placedTiles = _.without(game.placedTiles, tile);
            game.tray[_.indexOf(game.tray, null)] = tile;
          }
        });
        return true;
      }
    }
  }

  //////////////////////////////////////////////////////////////////////
  // Components
  //////////////////////////////////////////////////////////////////////

  var Game = {
    controller: function(game) {
    },
    view: function(ctrl, game) {
      return m(".game",
               [
                 m.component(Board, game),
                 m.component(Tray, game),
                 m(".score", ["Your score is ", m("strong", game.score)])
               ]
              );
    }
  };

  var Tile = {
    view: function(ctrl, tile, selected, showIfBlank)  {
      return m(".tile",
               {
                 class: combineClasses([
                   tile.blank && 'tile-blank',
                   selected && 'selected'
                 ]),
                 onclick: function(ev) { game.toggleTile(tile); ev.preventDefault(); }
               },
               [
                 (!tile.blank || showIfBlank) ? tile.letter : " ",
                 m(".tile-face-value", tile.face_value)
               ]);
    }
  };

  var Board = {
    view: function(ctrl, game) {
      return m(".board",
               game.board.rows.map(function(row) {
                 return m(".board-row",
                          row.map(function(square) {
                            return m(".board-square",
                                     {
                                       class: combineClasses([
                                         "word-multiplier-" + square.word_multiplier,
                                         "letter-multiplier-" + square.letter_multiplier
                                       ]),
                                       onclick: _.wrap(square, game.selectBoardSquare)
                                     },
                                     (square.tile && m.component(Tile, square.tile, false, true)));
                          }));
               }));
    }
  };

  var Tray = {
    view: function(ctrl, game) {
      var anyPlaced = (game.placedTiles.length !== 0);
      var anySelected = (game.selectedTrayTiles.length !== 0);
      return m(".tray",
               [
                 m(".tray-frame",
                   game.tray.map(function(tile) {
                     return m(".tray-square", tile && m.component(Tile, tile, _.include(game.selectedTrayTiles, tile)));
                   })),
                 m("p",
                   [
                     m("button", { href: '#', onclick: game.replaceTiles,
                                   disabled: !anyPlaced }, "Clear play"),
                     m("button", { href: '#', onclick: game.submitPlacedTiles,
                                   disabled: !anyPlaced }, "Play tiles"),
                     m("button", { href: '#', onclick: game.swapTiles,
                                   disabled: !anySelected }, "Swap tiles"),
                     m("button", { href: '#', onclick: game.passTurn }, "Pass")
                   ]
                  )
               ]);
    }
  };

  //////////////////////////////////////////////////////////////////////
  // Set-up
  //////////////////////////////////////////////////////////////////////

  var game = makeGame(JSON.parse(document.getElementById("game").dataset.game));

  m.module(document.querySelector("#game"), m.component(Game, game));

})(window.m, window.document, window._);
