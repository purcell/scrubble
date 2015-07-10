// global jQuery, document
jQuery(function(){
  var SELECTED = "selected";

  var trayLetters = trayTiles().map(function() {
    return $(this).data('letter');
  });

  //////////////////////////////////////////////////////////////////////
  // Event wiring
  //////////////////////////////////////////////////////////////////////

  $(document).on('click', '.board-square:not(:has(".tile"))', function(ev) {
    squareClicked($(this));
  });

  function squareClicked(square) {
    var board = square.closest(".board");
    board.find(".board-square").removeClass(SELECTED);
    square.addClass(SELECTED);
  }

  $(document).on('keyup', function(ev) {
    if (!hasModifier(ev)) {
      $(".board-square.selected").first().each(function(){
        var square = $(this);
        var entered = alphabetChar(ev);
        if (entered) {
          if (letterEntered(square, entered)) {
            square.removeClass(SELECTED);
          }
        }
      });
    }
  });

  function hasModifier(ev) {
    return (ev.metaKey || ev.altKey || ev.ctrlKey);
  }

  function alphabetChar(ev) {
    return (ev.key.match(/^[a-zA-Z]$/)) ? ev.key.toUpperCase() : null;
  }

  //////////////////////////////////////////////////////////////////////
  // Data
  //////////////////////////////////////////////////////////////////////

  function trayTiles() {
    return $(".tray-square .tile");
  }

  //////////////////////////////////////////////////////////////////////
  // Interactions
  //////////////////////////////////////////////////////////////////////

  function letterEntered(square, letter) {
    console.log(letter + " entered at " + square.data("position"));
  }
});
