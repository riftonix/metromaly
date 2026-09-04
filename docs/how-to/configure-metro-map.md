# Configure the Metro Map

The map screen is implemented by `apps/client/metro_map/metro_map.tscn` and `apps/client/metro_map/metro_map.gd`.

## Replace the Map Image

1. Place the SVG resource in `apps/client/assets/metro_map/`.
2. Change the `MAP_TEXTURE` constant path in `metro_map.gd`.
3. Set `REFERENCE_SIZE` to the dimensions of the new image coordinate system.

The current resource at `apps/client/assets/metro_map/metro_map.svg` uses a `1280 x 1500` area, so the script contains:

```gdscript
const REFERENCE_SIZE := Vector2(1280.0, 1500.0)
```

## Change the Background

Change `BACKGROUND_COLOR`. Before drawing the map, the script fills the entire `Control` area with this color.

## Add a Test Label

Add a dictionary containing text and coordinates to `STATION_LABELS`:

```gdscript
{"title": "Station name", "position": Vector2(842.0, 320.0)}
```

Coordinates use the `REFERENCE_SIZE` coordinate system and scale with the map. Labels use the Godot fallback font, size `20`, and `TEXT_COLOR`.

## Preserve Responsive Scaling

The `_draw()` method selects the smaller scale factor from the window width and height. This preserves the aspect ratio and fits the entire map within the available area. The `resized` signal queues a redraw after the screen dimensions change.
