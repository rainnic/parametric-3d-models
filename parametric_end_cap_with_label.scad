//
// Parametric Plug Cap with Label
// Adapted by Nicola Rainiero (https://nicolarainiero.altervista.org/en/category/3d-printing/
//
// Based on existing OpenSCAD models (credits to original authors).
// Original sources:
// - https://www.thingiverse.com/thing:894357
//
// Modifications:
// - Added parametric text label on the top surface
// - Adjusted dimensions and tolerances
//

width = 91.6;         // Inner width of the plug
depth = 60.0;         // Inner depth of the plug
height = 2.4;         // Thickness of the plug cover
label = "label";            // Number/text to display on top of the plug

plugHeight = 14;      // Plug height
plugWall = 2;         // Wall thickness
plugRound = 2;
tolerance = 0.4;
wall = 6;             // Thickness of outer walls
round = 3;
plugDistance = 2;
plugDistanceHeight = 0; // Set to 0 to remove protrusions

plugWallSpacer = 1;   // Extra spacing for plug openings
minWallBlock = 15;

/* [Hidden] */

// Calculate external plug dimensions including wall thickness
outerWidth = width + 2 * wall;
outerDepth = depth + 2 * wall;

plugWidth = width - 2 * tolerance;
plugDepth = depth - 2 * tolerance;

plugWidthReal = width;
plugDepthReal = depth;

module cap() {
    // Draw the plug cover with external dimensions
    translate([outerWidth / 2, outerDepth / 2, height / 2]) {
        roundedBox([outerWidth, outerDepth, height], round, true);
    }

    // Draw the inner plug body with cutouts
    translate([wall + tolerance, wall + tolerance, height]) {
        difference() {
            translate([plugWidth / 2, plugDepth / 2, plugHeight / 2]) {
                roundedBox([plugWidth, plugDepth, plugHeight], plugRound, true);

                // Add protrusions (if enabled)
                for (move = [1:plugHeight / plugDistance]) {
                    translate([0, 0, move * plugDistance - plugHeight / 2]) {
                        roundedBox([plugWidthReal, plugDepthReal, plugDistanceHeight], plugRound, true);
                    }
                }
            }

            // Internal cutouts
            translate([plugWall, plugWall, 0])
                cube([plugWidth - (2 * plugWall), plugDepth - 2 * plugWall, plugHeight], center = false);
            translate([plugWall, -tolerance - 5, 0])
                cube([plugWallSpacer, plugDepth + 10, plugHeight], center = false);
            translate([plugWidth - plugWall - plugWallSpacer, -tolerance - 5, 0])
                cube([plugWallSpacer, plugDepth + 10, plugHeight], center = false);

            if ((plugWidthReal / 2) > minWallBlock) {
                translate([plugWidthReal / 2 - plugWallSpacer, -tolerance - 5, 0])
                    cube([plugWallSpacer, plugDepthReal + 10, plugHeight], center = false);
            }

            translate([-tolerance - 5, plugWall, 0])
                cube([plugWidth + 10, plugWallSpacer, plugHeight], center = false);
            translate([-tolerance - 5, plugDepth - plugWall - plugWallSpacer, 0])
                cube([plugWidth + 10, plugWallSpacer, plugHeight], center = false);

            if ((plugDepthReal / 2) > minWallBlock) {
                translate([-tolerance - 5, plugDepthReal / 2 - plugWallSpacer, 0])
                    cube([plugWidthReal + 10, plugWallSpacer, plugHeight], center = false);
            }
        }
    }

    // Add parametric text label on the top surface
    translate([outerWidth / 2, outerDepth / 2, height ])
        linear_extrude(height = 1)
            text(str(label), size = 20, valign = "center", halign = "center", font = "Arial");
}

/*
 * roundedBox([width, height, depth], float radius, bool sidesonly);
 * Example usage:
 * roundedBox([20, 30, 40], 5, true);
 */
module roundedBox(size, radius, sidesonly) {
    rot = [[0, 0, 0], [90, 0, 90], [90, 90, 0]];
    if (sidesonly) {
        cube(size - [2 * radius, 0, 0], true);
        cube(size - [0, 2 * radius, 0], true);
        for (x = [radius - size[0] / 2, -radius + size[0] / 2], y = [radius - size[1] / 2, -radius + size[1] / 2]) {
            translate([x, y, 0]) {
                cylinder(r = radius, h = size[2], center = true);
            }
        }
    } else {
        cube([size[0], size[1] - radius * 2, size[2] - radius * 2], center = true);
        cube([size[0] - radius * 2, size[1], size[2] - radius * 2], center = true);
        cube([size[0] - radius * 2, size[1] - radius * 2, size[2]], center = true);
        for (axis = [0:2]) {
            for (x = [radius - size[axis] / 2, -radius + size[axis] / 2], y = [radius - size[(axis + 1) % 3] / 2, -radius + size[(axis + 1) % 3] / 2]) {
                rotate(rot[axis]) {
                    translate([x, y, 0]) {
                        cylinder(h = size[(axis + 2) % 3] - 2 * radius, r = radius, center = true);
                    }
                }
            }
        }
        for (x = [radius - size[0] / 2, -radius + size[0] / 2], y = [radius - size[1] / 2, -radius + size[1] / 2], z = [radius - size[2] / 2, -radius + size[2] / 2]) {
            translate([x, y, z]) sphere(radius);
        }
    }
}

cap();
