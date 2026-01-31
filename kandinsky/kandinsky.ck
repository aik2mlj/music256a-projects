//-----------------------------------------------------------------------------
// name: kandinsky.ck
// desc: abstract painting sonified
//
// author: Lejun Min  (https://aik2.site)
// date: Fall 2024
//-----------------------------------------------------------------------------
@import "draw.ck"

// mitigate the weird bug that static values only become valid after class instantiation
C _con;

// Initialize Mouse Manager ===================================================
Mouse mouse;
spork ~ mouse.selfUpdate(); // start updating mouse position

// Scene setup ================================================================
GG.scene() @=> GScene @scene;
GG.windowed(1280, 720);
GG.camera() @=> GCamera @cam;
cam.orthographic(); // Orthographic camera mode for 2D scene

// light
GG.scene().light() @=> GLight light;
0. => light.intensity;

// bloom
GG.outputPass() @=> OutputPass output_pass;
GG.renderPass() --> BloomPass bloom_pass --> output_pass;
bloom_pass.threshold(5);
bloom_pass.intensity(1);
bloom_pass.input(GG.renderPass().colorOutput());
output_pass.input(bloom_pass.colorOutput());

// white background
TPlane background --> scene;
C.WIDTH => background.scaX;
C.HEIGHT_GLB => background.scaY;
-90 => background.posZ;
@(1., 1., 1.) * 5 => background.color;

DrawEvent drawEvent;
// polymorphism
Draw @draws[4];
LineDraw lineDraw(mouse, drawEvent) @=> draws[0];
CircleDraw circleDraw(mouse, drawEvent) @=> draws[1];
PlaneDraw planeDraw(mouse, drawEvent) @=> draws[2];
Eraser eraser(mouse, drawEvent) @=> draws[3];
for (auto draw : draws) {
    draw --> GG.scene();
    spork ~ draw.draw();
}
spork ~ select_drawtool(mouse, draws, drawEvent);

ColorPicker colorPicker(mouse, drawEvent) --> scene;
spork ~ colorPicker.pick();

PlayLine playline(mouse, drawEvent) --> scene;
spork ~ playline.play();


fun void select_drawtool(Mouse @m, Draw draws[], DrawEvent @drawEvent) {
    while (true) {
        GG.nextFrame() => now;
        for (auto draw : draws) {
            if (GWindow.mouseLeftDown() && draw.isHovered()) {
                // clicked on this drawtool
                if (drawEvent.isNone() || drawEvent.isActive() && drawEvent.draw != draw) {
                    // was inactive / switch activation
                    <<< "activate" >>>;
                    drawEvent.setActive(draw);
                    // drawEvent.broadcast();
                } else if (drawEvent.isActive() && drawEvent.draw == draw) {
                    // deactivate
                    <<< "deactivate" >>>;
                    drawEvent.setNone();
                    // drawEvent.broadcast();
                }
                break;
            }
        }
    }
}


while (true) {
    GG.nextFrame() => now;
}
