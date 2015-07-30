// global window
(function(m, document, _, window){
  "use strict";

  var CSRF_TOKEN = document.querySelector('meta[name="csrf-token"]').attributes.content.value;

  var XHR_CONFIG = function(xhr) {
    xhr.setRequestHeader('X-CSRF-Token', CSRF_TOKEN);
  };

  function notify(message) {
    if (("Notification" in window) && Notification.permission !== 'denied')
      Notification.requestPermission(function() {
        if (Notification.permission === "granted")
          new Notification(message);
      });
  }

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

  function makeGame(initial, gamePath) {
    var game = {
      selectBoardSquare: function(square) {
        if (game.my_turn && !square.tile) {
          maybePlaySelectedTile(square);
        }
      },

      replaceTiles: function() {
        game.placedTiles.forEach(replaceTile);
      },

      toggleTile: function(tile) {
        if (game.my_turn)
          return replaceTile(tile) || toggleSelectTrayTile(tile);
      },

      submitPlacedTiles: function() {
        submitAction("placements", {
          played_tiles: _.compact(_.map(allSquares(), (function(sq) {
            if(_.include(game.placedTiles, sq.tile)) {
              return { x: sq.position.x, y: sq.position.y,
                       letter: sq.tile.letter, blank: sq.tile.blank };
            }
          })))
        }, "submitting placement");
      },

      swapTiles: function() {
        submitAction("tile_swaps", { tiles: game.selectedTrayTiles }, "swapping tiles");
      },

      passTurn: function() {
        submitAction("turn_passes", {}, "passing the turn");
      },

      onAsyncUpdate: function(data) {
        m.startComputation();
        withNotificationIfMyTurn(function() {
          updateGame(data);
        });
        m.endComputation();
      }
    };

    return updateGame(initial);

    function submitAction(relativePath, data, description) {
      m.request({ method: "POST", url: gamePath + "/" + relativePath,
                  data: data, config: XHR_CONFIG })
        .then(updateGame, makeErrorHandler(description));
    }

    function updateGame(data) {
      return _.extend(game, {
        placedTiles: [],
        selectedTrayTiles: []
      }, data);
    }

    function withNotificationIfMyTurn(f) {
      var previousPlayer = game.turn_player_name;
      f();
      if (game.turn_player_name != previousPlayer && game.my_turn)
        notify("Scrubble game: it is your turn to play");
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
                 m.component(Controls, game),
                 m.component(Scores, game)
               ]
              );
    }
  };

  var Scores = {
    view: function(ctrl, game) {
      return m("table.scores",
               [
                 m("thead", m("tr", [m("th", "Player"), m("th", "Score")])),
                 m("tbody",
                   game.scores.map(function(entry) {
                     var name = entry[0];
                     var score = entry[1];
                     return m("tr.score",
                              {class: combineClasses([
                                name == game.turn_player_name && "active",
                                name == game.player_name && "current"
                              ])},
                              [m("td", name), m("td", score)]);
                   }))
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
      return m(".tray",
               m(".tray-frame",
                 game.tray.map(function(tile) {
                   return m(".tray-square", tile && m.component(Tile, tile, _.include(game.selectedTrayTiles, tile)));
                 }))
              );
    }
  };

  var Controls = {
    view: function(ctrl, game) {
      var anyPlaced = (game.placedTiles.length !== 0);
      var anySelected = (game.selectedTrayTiles.length !== 0);
      return m(".controls",
              game.my_turn ?
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
                    ) : null)
    }
  };

  //////////////////////////////////////////////////////////////////////
  // Set-up
  //////////////////////////////////////////////////////////////////////

  function setup(element) {
    var game = makeGame(JSON.parse(element.dataset.game),
                        document.location.pathname);

    var socket = new WebSocket("ws://" + document.location.host + document.location.pathname + "/watch");
    socket.onmessage = function(event) {
      console.log("Received websocket event " + JSON.stringify(event));
      game.onAsyncUpdate(JSON.parse(event.data));
    };
    window.addEventListener("beforeunload", function() { socket.close(); });

    m.module(element, m.component(Game, game));
  }


  var gameElement = document.querySelector("#game");
  if (gameElement) {
    setup(gameElement);
  }

})(window.m, window.document, window._, window);
