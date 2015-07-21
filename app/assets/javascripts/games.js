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

  function makeGame(initial) {
    var game = {
      selectSquare: function(square) {
        if (!square.tile) {
          game.selectedSquare = square;
        }
      },

      replaceTiles: function() {
        game.placedTiles.forEach(replaceTile);
      },

      toggleTile: function(tile) {
        return replaceTile(tile) || placeTile(tile);
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
      }
    };

    return updateGame(initial);

    function updateGame(data) {
      return _.extend(game, { selectedSquare: null, placedTiles: [] }, data);
    }

    function allSquares() {
      return _.flatten(game.board.rows);
    }

    function readLetter() {
      var letter = prompt("Which letter?");
      return letter.match(/^[a-zA-Z]$/) ? letter.toUpperCase() : null;
    }

    function placeTile(tileToPlace) {
      var square = game.selectedSquare;
      if (square && !square.tile && _.include(game.tray, tileToPlace)) {
        if (tileToPlace.blank) {
          var letter = readLetter();
          if (!letter) return;
          tileToPlace.letter = letter;
        }
        game.placedTiles.push(tileToPlace);
        game.tray[_.indexOf(game.tray, tileToPlace)] = null;
        square.tile = tileToPlace;
        game.selectedSquare = null;
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
    controller: function(ctrl, tile, showIfBlank) {
      self.clicked = function(ev) {
        if (game.toggleTile(tile))
          ev.preventDefault();
      };
    },
    view: function(ctrl, tile, showIfBlank)  {
      return m(".tile",
               {
                 class: tile.blank && 'tile-blank',
                 onclick: function(ev) { if (game.toggleTile(tile)) ev.preventDefault(); }
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
                                       class: [
                                         "word-multiplier-" + square.word_multiplier,
                                         "letter-multiplier-" + square.letter_multiplier,
                                         game.selectedSquare == square ? "selected" : ""
                                       ].join(" "),
                                       onclick: _.wrap(square, game.selectSquare)
                                     },
                                     (square.tile && m.component(Tile, square.tile, true)));
                          }));
               }));
    }
  };

  var Tray = {
    view: function(ctrl, game) {
      var anyPlaced = (game.placedTiles.length !== 0);
      return m(".tray",
               [
                 m(".tray-frame",
                   game.tray.map(function(tile) {
                     return m(".tray-square", tile && m.component(Tile, tile));
                   })),
                 m("p",
                   [
                     m("button", { href: '#', onclick: game.replaceTiles,
                                   disabled: !anyPlaced }, "Clear play"),
                     m("button", { href: '#', onclick: game.submitPlacedTiles,
                                   disabled: !anyPlaced }, "Play tiles")
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
