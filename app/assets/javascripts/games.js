// global window
(function(m, document, _){
  "use strict";

  //////////////////////////////////////////////////////////////////////
  // Models
  //////////////////////////////////////////////////////////////////////

  var Game = function(data) {
    this.board = data.board;
    this.tray = data.tray;
    this.selectedSquare = null;
    var playedTiles = [];

    this.onSelectSquare = function(square) {
      this.selectedSquare = square;
    }.bind(this);

    this.onEnterLetter = function(letter) {
      var square = this.selectedSquare;
      if (!(square && !square.tile)) {
        return;
      }
      var foundAt = _.findIndex(this.tray, function(t) { return t && t.letter == letter; });
      if (foundAt != -1) {
        var tileToPlay = this.tray[foundAt];
        playedTiles.push(tileToPlay);
        this.tray[foundAt] = null;
        square.tile = tileToPlay;
        this.selectedSquare = null;
      }
    }.bind(this);
  };

  //////////////////////////////////////////////////////////////////////
  // Components
  //////////////////////////////////////////////////////////////////////

  var Tile = {
    view: function(ctrl, tile)  {
      return m(".tile",
               {class: tile.blank && 'tile-blank'},
               [
                 tile.letter,
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
                                       onclick: function() { game.onSelectSquare(square); }
                                     },
                                     (square.tile && m.component(Tile, square.tile)));
                          }));
               }));
    }
  };

  var Tray = {
    view: function(ctrl, game) {
      return m(".tray",
               m(".tray-frame",
                 game.tray.map(function(tile) {
                   return m(".tray-square", tile && m.component(Tile, tile));
                 })));
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
      game.onEnterLetter(ev.key.toUpperCase());
      m.endComputation();
      ev.preventDefault();
    }
  });

})(window.m, window.document, window._);
