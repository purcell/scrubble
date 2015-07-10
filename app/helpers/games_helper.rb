module GamesHelper

  def render_tile(tile)
    content_tag(
      "div",
      tile.letter.html_safe + content_tag("div", tile.face_value,
                                          class: "tile-face-value"),
      data: { letter: tile.letter },
      class: "tile #{"tile-blank" if tile.blank?}"
    )
  end
end
