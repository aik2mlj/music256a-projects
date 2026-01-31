@import "shapes.ck"

// Toolbar: Drawing tools and color picker =============================================

public class TPlane extends GGen {
    // a convenient plane class for toolbar setup
    GPlane g --> this;
    FlatMaterial mat;
    g.mat(mat);

    fun TPlane(vec2 pos, float scale, vec3 color, float depth) {
        @(pos.x, pos.y, depth) => this.pos;
        scale => this.sca;
        color => mat.color;
    }

    fun vec3 color() { return mat.color(); }

    fun void color(vec3 c) { mat.color(c); }
}

public class ColorPicker extends GGen {
    // color picker
    TPlane g --> this;
    vec3 color;
    0.5 => float icon_offset;
    // [Color.SKYBLUE, Color.BEIGE, Color.MAGENTA, Color.LIGHTGRAY] @=> vec3 presets[];
    // int idx;

    Mouse @mouse;
    DrawEvent @drawEvent;

    fun ColorPicker(Mouse @m, DrawEvent @d) {
        m @=> this.mouse;
        d @=> this.drawEvent;

        C.TOOLBAR_SIZE => g.sca;
        @(icon_offset, C.DOWN_GLB + (C.TOOLBAR_PADDING + C.TOOLBAR_SIZE) / 2, -1) => g.pos;
        nextColor();
    }

    fun void nextColor() {
        // (idx + 1) % presets.size() => idx;
        // presets[idx] => g.color;
        @(Math.random2f(0, 360), Math.random2f(0, 1), Math.random2f(0, 1)) => vec3 hsv;
        Color.hsv2rgb(hsv) => color;
        color => g.color;
        color => this.drawEvent.color;
    }

    fun int isHovered() {
        g.scaWorld() => vec3 worldScale; // get dimensions
        worldScale.x / 2.0 => float halfWidth;
        worldScale.y / 2.0 => float halfHeight;
        g.posWorld() => vec3 pos; // get position

        return (mouse.pos.x > pos.x - halfWidth && mouse.pos.x < pos.x + halfWidth &&
                mouse.pos.y > pos.y - halfHeight && mouse.pos.y < pos.y + halfHeight);
    }

    fun void pick() {
        while (true) {
            GG.nextFrame() => now;
            if (GWindow.mouseLeftDown() && this.isHovered()) {
                this.nextColor();
            }
        }
    }
}

public class Draw extends GGen {
    0 => static int NONE;   // not clicked
    1 => static int ACTIVE; // clicked
    0 => int state;

    Mouse @mouse;
    DrawEvent @drawEvent;

    TPlane icon_bg --> this;

    fun @construct(Mouse @m, DrawEvent @d) {
        m @=> this.mouse;
        d @=> this.drawEvent;

        C.TOOLBAR_SIZE => icon_bg.sca;
        C.COLOR_ICONBG_NONE => icon_bg.color;
    }

    fun int isHovered() {
        icon_bg @=> GGen @g;
        g.scaWorld() => vec3 worldScale; // get dimensions
        worldScale.x / 2.0 => float halfWidth;
        worldScale.y / 2.0 => float halfHeight;
        g.posWorld() => vec3 pos; // get position

        return (mouse.pos.x > pos.x - halfWidth && mouse.pos.x < pos.x + halfWidth &&
                mouse.pos.y > pos.y - halfHeight && mouse.pos.y < pos.y + halfHeight);
    }

    fun int isHoveredToolbar() {
        // if the mouse is hovered on toolbar
        return mouse.pos.y < C.DOWN;
    }

    fun void waitActivate() {
        // block if not activated
        while (drawEvent.isNone() || drawEvent.isActive() && drawEvent.draw != this) {
            GG.nextFrame() => now;
            C.COLOR_ICONBG_NONE => this.icon_bg.color;
            NONE => state;
        }
        // activated, change icon_bg color
        C.COLOR_ICONBG_ACTIVE => this.icon_bg.color;
    }

    // polymorphism placeholder
    fun Shape @createShape(vec2 start, vec2 end) {
        <<< "Warning: calling the default createShape, returning a null pointer!" >>>;
        return null;
    }

    fun void draw() {
        vec2 start, end;

        while (true) {
            GG.nextFrame() => now;

            this.waitActivate();

            if (state == NONE && GWindow.mouseLeftDown() && !isHoveredToolbar()) {
                ACTIVE => state;
                drawEvent.incDepth();
                this.mouse.pos => start;
            } else if (state == ACTIVE && GWindow.mouseLeftUp()) {
                NONE => state;
                this.mouse.pos => end;

                createShape(start, end) @=> Shape @shape;
                <<< "draw", drawEvent.length >>>;
                shape @=> drawEvent.shapes[drawEvent.length++];
                shape --> GG.scene();
            }
        }
    }
}

public class LineDraw extends Draw {
    GLines icon --> this;
    -0.5 => float icon_offset;

    fun @construct(Mouse @m, DrawEvent @d) {
        Draw(m, d);

        0.03 => icon.width;
        C.COLOR_ICON => icon.color;
        [@(icon_offset - (C.TOOLBAR_SIZE - C.TOOLBAR_PADDING) / 2, C.DOWN_GLB + C.TOOLBAR_PADDING),
         @(icon_offset + (C.TOOLBAR_SIZE - C.TOOLBAR_PADDING) / 2, C.DOWN_GLB + C.TOOLBAR_SIZE)] => icon.positions;

        @(icon_offset, C.DOWN_GLB + (C.TOOLBAR_PADDING + C.TOOLBAR_SIZE) / 2, -1) => icon_bg.pos;
    }

    fun Shape @createShape(vec2 start, vec2 end) {
        // generate a new line
        return new Line(start, end, drawEvent.color, 0.1, drawEvent.depth);
    }
}


public class CircleDraw extends Draw {
    GCircle icon --> this;
    FlatMaterial mat;
    icon.mat(mat);
    0 => float icon_offset;

    fun @construct(Mouse @m, DrawEvent @d) {
        Draw(m, d);

        C.COLOR_ICON => mat.color;
        @(icon_offset, C.DOWN_GLB + (C.TOOLBAR_PADDING + C.TOOLBAR_SIZE) / 2, 0) => icon.pos;
        C.TOOLBAR_SIZE - C.TOOLBAR_PADDING => icon.sca;

        @(icon_offset, C.DOWN_GLB + (C.TOOLBAR_PADDING + C.TOOLBAR_SIZE) / 2, -1) => icon_bg.pos;
    }

    fun Shape @createShape(vec2 start, vec2 end) {
        (end - start) => vec2 r;
        Math.sqrt(r.x * r.x + r.y * r.y) => float radius;

        // generate a new circle
        return new Circle(start, radius, drawEvent.color, drawEvent.depth);
    }
}

public class PlaneDraw extends Draw {
    TPlane icon --> this;
    -1 => float icon_offset;

    fun @construct(Mouse @m, DrawEvent @d) {
        Draw(m, d);

        C.COLOR_ICON => icon.color;
        @(icon_offset, C.DOWN_GLB + (C.TOOLBAR_PADDING + C.TOOLBAR_SIZE) / 2, 0) => icon.pos;
        C.TOOLBAR_SIZE - C.TOOLBAR_PADDING => icon.sca;

        @(icon_offset, C.DOWN_GLB + (C.TOOLBAR_PADDING + C.TOOLBAR_SIZE) / 2, -1) => icon_bg.pos;
    }

    fun Shape @createShape(vec2 start, vec2 end) {
        // generate a new plane
        return new Plane(start, end, drawEvent.color, drawEvent.depth);
    }
}

public class Eraser extends Draw {
    GLines icon_0 --> this;
    GLines icon_1 --> this;
    1 => float icon_offset;

    fun @construct(Mouse @m, DrawEvent @d) {
        Draw(m, d);

        0.08 => icon_0.width;
        0.08 => icon_1.width;
        C.COLOR_ICON => icon_0.color;
        C.COLOR_ICON => icon_1.color;
        [@(icon_offset - (C.TOOLBAR_SIZE - C.TOOLBAR_PADDING) / 2, C.DOWN_GLB + C.TOOLBAR_PADDING),
         @(icon_offset + (C.TOOLBAR_SIZE - C.TOOLBAR_PADDING) / 2, C.DOWN_GLB + C.TOOLBAR_SIZE)] => icon_0.positions;
        [@(icon_offset - (C.TOOLBAR_SIZE - C.TOOLBAR_PADDING) / 2, C.DOWN_GLB + C.TOOLBAR_SIZE),
         @(icon_offset + (C.TOOLBAR_SIZE - C.TOOLBAR_PADDING) / 2,
           C.DOWN_GLB + C.TOOLBAR_PADDING)] => icon_1.positions;

        @(icon_offset, C.DOWN_GLB + (C.TOOLBAR_PADDING + C.TOOLBAR_SIZE) / 2, -1) => icon_bg.pos;
    }

    fun void draw() {
        vec2 pos;
        while (true) {
            GG.nextFrame() => now;

            this.waitActivate();

            if (state == NONE && GWindow.mouseLeftDown() && !isHoveredToolbar()) {
                ACTIVE => state;
                this.mouse.pos => pos;
            } else if (state == ACTIVE && GWindow.mouseLeftUp()) {
                NONE => state;

                for (drawEvent.length - 1 => int i; i >= 0; --i) {
                    if (drawEvent.shapes[i].isHovered(mouse)) {
                        // detached from scene
                        drawEvent.shapes[i] --< GG.scene();
                        // stop playing
                        drawEvent.shapes[i].stop();
                        // move forward
                        for (i => int j; j < drawEvent.length - 1; ++j) {
                            drawEvent.shapes[j + 1] @=> drawEvent.shapes[j];
                        }
                        // decrease length
                        drawEvent.length--;
                        // just erase one shape
                        break;
                    }
                }
            }
        }
    }
}

public class DrawEvent extends Event {
    0 => static int NONE;   // no drawtool selected
    1 => static int ACTIVE; // drawtool selected
    0 => int state;
    Draw @draw;           // reference to the selected drawtool
    vec3 color;           // selected color
    -50 => float depth; // current depth of the drawed object

    // all the drawed shapes
    Shape @shapes[1000];
    0 => int length;

    fun int isNone() { return state == NONE; }

    fun int isActive() { return state == ACTIVE; }

    fun void setNone() {
        NONE => this.state;
        null @=> draw;
    }

    fun void setActive(Draw @d) {
        ACTIVE => this.state;
        d @=> draw;
    }

    fun void incDepth() { depth + 0.001 => depth; }

    fun int touchX(float x, float speed) {
        false => int touched;
        for (int i; i < length; ++i) {
            shapes[i].touchX(x, speed) => int tmp;
            touched || tmp => touched;
        }
        return touched;
    }

    fun int touchY(float y, float speed) {
        false => int touched;
        for (int i; i < length; ++i) {
            shapes[i].touchY(y, speed) => int tmp;
            touched || tmp => touched;
        }
        return touched;
    }
}

public class PlayLine extends GGen {
    GLines line --> this;
    @(0, 0, 0) => line.color;
    0.01 => line.width;
    line.positions([@(C.LEFT, C.DOWN), @(C.LEFT, C.UP)]);
    2 => float speed;

    0 => static int X_AXIS;
    1 => static int Y_AXIS;
    0 => int axis;

    Mouse @mouse;
    DrawEvent @drawEvent;

    fun PlayLine(Mouse @m, DrawEvent @d) {
        m @=> mouse;
        d @=> drawEvent;
    }

    fun int isHoveredToolbar() {
        // if the mouse is hovered on toolbar
        return mouse.pos.y < C.DOWN;
    }

    fun play() {
        while (true) {
            GG.nextFrame() => now;

            // use mouse wheels to change speed!
            GWindow.scrollY() * 0.5 +=> speed;
            GG.dt() * speed => float t;

            if (drawEvent.isNone() && GWindow.mouseLeftDown() && !isHoveredToolbar()) {
                // drawing not activated, can change playline position by left click
                if (axis == X_AXIS)
                    mouse.pos.x + C.WIDTH / 2 => line.posX;
                else
                    mouse.pos.y + C.HEIGHT - C.HEIGHT_GLB / 2 => line.posY;
            }

            if (GWindow.mouseRightDown()) {
                // right click to switch the sweeping axis!
                if (axis == X_AXIS) {
                    // switching to Y axis
                    0 => line.posX;
                    line.positions([@(C.LEFT, C.DOWN), @(C.RIGHT, C.DOWN)]);
                } else {
                    // switching to X axis
                    0 => line.posY;
                    line.positions([@(C.LEFT, C.DOWN), @(C.LEFT, C.UP)]);
                }
                !axis => axis;
            }

            if (axis == X_AXIS) {
                t => line.translateX;

                if (line.posX() > C.WIDTH)
                    0 => line.posX;
                else if (line.posX() < 0)
                    C.WIDTH => line.posX;

                line.posX() - C.WIDTH / 2 => float x;

                drawEvent.touchX(x, speed);
            } else {
                t => line.translateY;

                if (line.posY() > C.HEIGHT)
                    0 => line.posY;
                else if (line.posY() < 0)
                    C.HEIGHT => line.posY;

                line.posY() + C.HEIGHT_GLB / 2 - C.HEIGHT => float y;

                drawEvent.touchY(y, speed);
            }
        }
    }
}
