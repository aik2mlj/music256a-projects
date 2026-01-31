public class C {
    16.0 / 9.0 => static float ASPECT;
    6.6 => static float HEIGHT_GLB; // global height
    HEIGHT_GLB * ASPECT => static float WIDTH;
    -WIDTH / 2 => static float LEFT;
    WIDTH / 2 => static float RIGHT;
    -HEIGHT_GLB / 2 => static float DOWN_GLB; // global bottom
    HEIGHT_GLB / 2 => static float UP;

    // toolbar
    0.4 => static float TOOLBAR_SIZE;
    0.1 => static float TOOLBAR_PADDING;
    HEIGHT_GLB - TOOLBAR_SIZE - TOOLBAR_PADDING => static float HEIGHT; // the height of the canvas
    DOWN_GLB + TOOLBAR_SIZE + TOOLBAR_PADDING => static float DOWN;     // the bottom of the canvas

    // color
    @(242., 169., 143.) / 255. * 3 => static vec3 COLOR_ICONBG_ACTIVE;
    @(2, 2, 2) => static vec3 COLOR_ICONBG_NONE;
    @(.2, .2, .2) => static vec3 COLOR_ICON;
}

<<< C.SPEED >>>;
C con;
<<< C.SPEED >>>;
