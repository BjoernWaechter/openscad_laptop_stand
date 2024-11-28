/* [Size Variables] */
// Total width. Distance from left to right
Total_Width = 250; // [10:1:400]
// Height of the laptops bearing in the front
Front_Height = 150; // [10:1:400]
// Height of the laptops bearing in the back
Back_Height = 150; // [10:1:400]
// The depth of the laptop from front to back
Laptop_Depth = 196; // [10:1:400]
// Height of the laptop in the front so it fits under the nose
Laptop_Height = 18; // [1:1:50]
// Width of the left and right feet
Feet_Width = 20;    // [10:1:50]

/* [ Other Dimensions ] */
// Thickness of the nose holding the front of the laptop
nose_thickness = 4;   // [1:1:20]
// Length of the nose holding the front of the laptop
nose_length = 6;      // [1:1:20]
// Thickness of the frame.
frame_thickness = 3;  // [4:1:50]
// Diameter of the holes
circle_diameter = 10; // [2:1:50]
// Distance from one hole to the next
circle_distance = 2;  // [1:1:20]

/* [ Advanced ] */
// Thickness of the back frame. Has to big greater than "dovetail max width"
frame_thickness_back = 12; // [6:1:30]
// Height of the dovtail and the connectors
dovetail_height=20;        // [5:1:40]
// Min width of the dovetail and thickness of the connectors
dovetail_min_width=3;      // [1:1:10]
// Max width of the dovtail
dovetail_max_width=6;      // [2:1:15]
// depth of the dovtail. Should be less than "Feet Width"
dovetail_depth=6;          // [3:1:20]
// Clearance between the male and female part of the dove tail
dovetail_clearance=0.2;    // [0:0.01:0.5]



angle = asin((Back_Height-Front_Height)/Laptop_Depth);
top_length = Laptop_Depth+nose_thickness+Laptop_Height*tan(angle);

feet_depth = top_length*cos(angle);
steigung = (Back_Height-Front_Height)/feet_depth;

circle_count_x = floor((feet_depth-frame_thickness_back-frame_thickness)/(circle_diameter+circle_distance));
circle_count_y = floor((Back_Height-(2*frame_thickness))/(circle_diameter+circle_distance));


dv_max_incl_clear=dovetail_max_width+dovetail_clearance;
dv_min_incl_clear=dovetail_min_width+dovetail_clearance;
dovetail_depth_incl_clear=dovetail_depth+dovetail_clearance;
dv_diff = (dv_max_incl_clear+frame_thickness_back)/2*tan(angle);

module dovetail(max_width=10, min_width=6, depth=10, height=20) {
    p1 = [-min_width/2, 0];
    p2 = [-max_width/2, depth];
    p3 = [max_width/2, depth];
    p4 = [min_width/2, 0];
    
    linear_extrude(height = height, center = false, convexity = 10, twist = 0) {
        polygon(points=[p1,p2,p3,p4]);
    }
}

function normalize (v) = v / norm(v);
function sgn(a, b) = sign(a[0] * b[1] - a[1] * b[0]);

module polyedge(points,$fn=$fn) {

    polygon(points=[for (L1 = [
        for (i = [1 : len(points)])
        let(
            f = $fn == 0 ? 10 : $fn,
            A = points[(i - 1)],
            B = points[(i + 0) % len(points)],
            C = points[(i + 1) % len(points)],

            r = B[2],
            S = [B[0], B[1]],
            a = normalize([A[0] - B[0], A[1] - B[1]]),
            b = normalize([C[0] - B[0], C[1] - B[1]]))

             (len(B) == 2 || B[2] == 0)
                ? [ S ]
                : (r < 0 
                    ? [ S - a * r, S - b * r ]
                    : [let(
                        w = r * sqrt(2 / (1 - a * b) - 1),
                        X = a * w,
                        Y = b * w,
                        M = (a + b) * (r / sqrt(1 - pow(a * b, 2))),
                        b1 = atan2(X[1] - M[1], X[0] - M[0]),
                        b2 = atan2(Y[1] - M[1], Y[0] - M[0]),
                        phi = sgn(a, b) * (sgn(a, b) * (b1 - b2) + 360) % 360,
                        segs = ceil(abs(phi) * f / 360)) 
                            for (j = [0 : segs]) 
                                B + M + [
                                    r * cos(b1 - j / segs * phi), 
                                    r * sin(b1 - j / segs * phi)]])]) for (L2 = L1) L2]); 
}

module base_stand() {
    p1 = [0,0];
    p2 = [feet_depth,0];
    p3 = [feet_depth,Front_Height];
    p4 = [p3[0], p3[1]+(Laptop_Height+nose_thickness)/cos(angle), 2]; 
    p5 = [p4[0]-(nose_length+nose_thickness)*cos(angle),   p4[1]+(nose_length+nose_thickness)*sin(angle), 2];
    p6 = [p5[0]-nose_thickness*sin(angle), p5[1]-nose_thickness*cos(angle),1];
    p7 = [p6[0]+nose_length*cos(angle), p6[1]-nose_length*sin(angle)];
    p8 = [p7[0]-Laptop_Height*sin(angle),  p7[1]-Laptop_Height*cos(angle)]; 
    p9 = [0,Back_Height];

    i1 = [p1[0]+frame_thickness_back, p1[1]+frame_thickness];
    i2 = [p2[0]-frame_thickness, p2[1]+frame_thickness];
    i3 = [p3[0]-frame_thickness, p3[1]-frame_thickness*cos(angle)];
    i4 = [p9[0]+frame_thickness_back, p9[1]-frame_thickness/cos(angle)-frame_thickness_back*tan(angle)];

    difference() {
        union() {
            difference() {
                linear_extrude(height = Feet_Width, center = false, convexity = 10, twist = 0) {
                    polyedge(points=[p1,p2,p3,p4,p5,p6,p7,p8,p9]);
                }
                translate([0,0,-1]) {
                    linear_extrude(height = Feet_Width+2, center = false, convexity = 10, twist = 0) {
                        polygon(points=[i1,i2,i3,i4]);
                    }
                }
            }
            
            $fn = 12;
            linear_extrude(height = 2, center = false, convexity = 10, twist = 0) {
                difference() {
                    polyedge(points=[p1,p2,p3,p4,p5,p6,p7,p8,p9]);
                    union() {
                        for ( sy = [0:1:circle_count_y-1]) {
                            for ( sx = [0:1:circle_count_x-1]) {
                                translate([
                                frame_thickness_back+circle_diameter/2+sx*(circle_diameter+circle_distance),
                                frame_thickness+circle_diameter/2+sy*(circle_diameter+circle_distance),
                                0
                                ]) circle(d=circle_diameter);
                            }
                        }
                    }
                }
            }
        }

        translate([frame_thickness_back/2, 0, Feet_Width]) rotate(-90, [1,0,0]) {
            dovetail(max_width=dv_max_incl_clear, min_width=dv_min_incl_clear, depth=dovetail_depth_incl_clear, height=dovetail_height+dovetail_clearance);
        }
        
        translate([frame_thickness_back/2, Back_Height-dovetail_height-dv_diff, Feet_Width]) rotate(-90, [1,0,0]) {
            dovetail(max_width=dv_max_incl_clear, min_width=dv_min_incl_clear,  depth=dovetail_depth_incl_clear, height=Back_Height);
        }
    }
    
}

module connector() {
    connector_length=Total_Width-2*Feet_Width;
    union () {
        cube([connector_length, dovetail_min_width, dovetail_height]);
        translate([0,dovetail_min_width/2,0]) rotate(a = 90, v = [0, 0, 1]) {
            dovetail(max_width=dovetail_max_width, min_width=dovetail_min_width,  depth=dovetail_depth, height=dovetail_height);
        }
        translate([connector_length,dovetail_min_width/2,0]) rotate(a = -90, v = [0, 0, 1]) {
        dovetail(max_width=dovetail_max_width, min_width=dovetail_min_width,  depth=dovetail_depth, height=dovetail_height);
    }
    }

    
}


translate([-(Total_Width-Feet_Width*2)/2,(feet_depth-frame_thickness_back-dovetail_min_width)/2,0]) {
    connector();
}

translate([-(Total_Width-Feet_Width*2)/2,(feet_depth-frame_thickness_back-dovetail_min_width)/2,Back_Height-dovetail_height-dv_diff+dovetail_clearance]) {
    connector();
}


rotate(a = 90, v = [1, 0, 0]) {
    rotate(a = -90, v = [0, 1, 0]) {
        translate([-feet_depth/2,0,-Total_Width/2]) {
            base_stand();
        }
    }
}



rotate(a = 90, v = [1, 0, 0]) {
    rotate(a = -90, v = [0, 1, 0]) {
        translate([-feet_depth/2,0,-Total_Width/2-Feet_Width/2]) {
            translate([0,0,Total_Width+Feet_Width/2]) {
                mirror([0,0,1]) {
                    base_stand();
                }
            }
        }
    }
}

