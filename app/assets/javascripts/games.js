// global window
(function(m, document, _){
  "use strict";

  //////////////////////////////////////////////////////////////////////
  // Models
  //////////////////////////////////////////////////////////////////////

  var Game = function(data) {
    var state = _.extend({ selectedSquare: null }, data);
    var playedTiles = [];

    function mapSquares(f) {
      state.board.rows.forEach(function(row) {
        row.forEach(f);
      });
    }

    var game = _.extend(state, {
      selectSquare: function(square) {
        state.selectedSquare = square;
      },

      enterLetter: function(letter) {
        var square = state.selectedSquare;
        if (!(square && !square.tile)) {
          return;
        }
        var foundAt = _.findIndex(state.tray, function(t) { return t && !t.blank && t.letter == letter; });
        if (foundAt == -1)
          foundAt = _.findIndex(state.tray, function(t) { return t && t.blank; });
        if (foundAt != -1) {
          var tileToPlay = state.tray[foundAt];
          if (tileToPlay.blank)
            tileToPlay.letter = letter;
          playedTiles.push(tileToPlay);
          state.tray[foundAt] = null;
          square.tile = tileToPlay;
          state.selectedSquare = null;
        }
      },

      replaceTile: function(tile) {
        if (_.include(playedTiles, tile)) {
          mapSquares(function(square) {
            if (square.tile == tile) {
              square.tile = null;
              playedTiles = _.without(playedTiles, tile);
              state.tray[_.indexOf(state.tray, null)] = tile;
            }
          });
        }
      },

      replaceTiles: function() {
        playedTiles.forEach(game.replaceTile);
      }
    });
    return game;
  };

  //////////////////////////////////////////////////////////////////////
  // Components
  //////////////////////////////////////////////////////////////////////

  var Tile = {
    view: function(ctrl, tile, showIfBlank)  {
      return m(".tile",
               {class: tile.blank && 'tile-blank'},
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
                                       onclick: function() { game.selectSquare(square); }
                                     },
                                     (square.tile && m.component(Tile, square.tile, true)));
                          }));
               }));
    }
  };

  var Tray = {
    view: function(ctrl, game) {
      return [m(".tray",
                m(".tray-frame",
                  game.tray.map(function(tile) {
                    return m(".tray-square", tile && m.component(Tile, tile));
                  }))),
              m("a", { href: '#', onclick: game.replaceTiles }, "Replace tiles")];
    }
  };

  //////////////////////////////////////////////////////////////////////
  // Set-up
  //////////////////////////////////////////////////////////////////////

  var game = new Game(JSON.parse(document.getElementById("game").dataset.game));

  m.module(document.querySelector("#board"), m.component(Board, game));
  m.module(document.querySelector("#tray"), m.component(Tray, game));

  document.addEventListener("keyup", function(ev) {
    if (!(ev.metaKey || ev.altKey || ev.ctrlKey) &&
        ev.key.match(/^[a-zA-Z]$/)) {
      m.startComputation();
      game.enterLetter(ev.key.toUpperCase());
      m.endComputation();
      ev.preventDefault();
    }
  });

})(window.m, window.document, window._);
