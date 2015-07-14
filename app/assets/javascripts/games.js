// global window
(function(m, document, _){
  "use strict";

  //////////////////////////////////////////////////////////////////////
  // Models
  //////////////////////////////////////////////////////////////////////

  function makeGame(data) {
    var state = _.extend({ selectedSquare: null }, data);
    var playedTiles = [];

    function mapSquares(f) {
      state.board.rows.forEach(function(row) {
        row.forEach(f);
      });
    }

    function readLetter() {
      var letter = prompt("Which letter?");
      return letter.match(/^[a-zA-Z]$/) ? letter.toUpperCase() : null;
    }

    function placeTile(tileToPlace) {
      var square = state.selectedSquare;
      if (!(square && !square.tile)) {
        return;
      }
      if (tileToPlace.blank) {
        var letter = readLetter();
        if (!letter) return;
        tileToPlace.letter = letter;
      }
      playedTiles.push(tileToPlace);
      state.tray[_.indexOf(state.tray, tileToPlace)] = null;
      square.tile = tileToPlace;
      state.selectedSquare = null;
    }

    function replaceTile(tile) {
      if (_.include(playedTiles, tile)) {
        mapSquares(function(square) {
          if (square.tile == tile) {
            square.tile = null;
            playedTiles = _.without(playedTiles, tile);
            state.tray[_.indexOf(state.tray, null)] = tile;
          }
        });
      }
    }

    var game = _.extend(state, {
      selectSquare: function(square) {
        if (!square.tile) {
          state.selectedSquare = square;
        }
      },

      replaceTiles: function() {
        playedTiles.forEach(replaceTile);
      },

      tileClicked: function(tile) {
        if (_.include(playedTiles, tile)) {
          replaceTile(tile);
          return true;
        } else if (_.include(state.tray, tile)) {
          placeTile(tile);
          return true;
        } else {
          return false;
        }
      }
    });
    return game;
  }

  //////////////////////////////////////////////////////////////////////
  // Components
  //////////////////////////////////////////////////////////////////////

  var Tile = {
    view: function(ctrl, tile, showIfBlank)  {
      return m(".tile",
               {
                 class: tile.blank && 'tile-blank',
                 onclick: function(ev) { if (game.tileClicked(tile)) ev.preventDefault(); }
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

  var game = makeGame(JSON.parse(document.getElementById("game").dataset.game));

  m.module(document.querySelector("#board"), m.component(Board, game));
  m.module(document.querySelector("#tray"), m.component(Tray, game));

})(window.m, window.document, window._);
