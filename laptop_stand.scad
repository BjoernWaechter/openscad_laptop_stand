/* [Size Variables] */
total_width = 200; // [10:1:400]
front_height = 40; // [10:1:400]
back_height = 110; // [10:1:400]
laptop_depth = 230; // [10:1:400]
laptop_height = 20; // [1:1:50]

/* [ Other Dimensions ] */
nose_thickness = 6;   // [1:1:20]
nose_length = 6;      // [1:1:20]
feet_width = 20;      // [10:1:50]
frame_thickness = 6;  // [4:1:50]


angle = asin((back_height-front_height)/laptop_depth);
feet_depth = laptop_depth*cos(angle);
steigung = (back_height-front_height)/feet_depth;


circle_diameter = 10;

echo(angle);
module base_stand() {
    p1 = [0,0];
    p2 = [feet_depth,0];
    p3 = [feet_depth,front_height];
    p4 = [p3[0]+(laptop_height+nose_thickness)*sin(angle), p3[1]+(laptop_height+nose_thickness)*cos(angle)];
    p5 = [p4[0]-(nose_length+nose_thickness)*cos(angle),   p4[1]+(nose_length+nose_thickness)*sin(angle)];
    p6 = [p5[0]-nose_thickness*sin(angle), p5[1]-nose_thickness*cos(angle)];
    p7 = [p6[0]+nose_length*cos(angle), p6[1]-nose_length*sin(angle)];
    p8 = [p7[0]-laptop_height*sin(angle),  p7[1]-laptop_height*cos(angle)]; 
    p9 = [0,back_height];

    i1 = [p1[0]+frame_thickness, p1[1]+frame_thickness];
    i2 = [p2[0]-frame_thickness, p2[1]+frame_thickness];
    i3 = [p3[0]-frame_thickness, p3[1]-frame_thickness*cos(angle)];
    i4 = [p9[0]+frame_thickness, p9[1]-frame_thickness/cos(angle)-frame_thickness*tan(angle)];

    union() {
        linear_extrude(height = feet_width, center = false, convexity = 10, twist = 0) {
            polygon(points=[p1,p2,p3,p4,p5,p6,p7,p8,p9,
                        i1,i2,i3,i4],
                paths=[[0,1,2,3,4,5,6,7,8],[9,10,11,12]]
                );
        }
        linear_extrude(height = 2, center = false, convexity = 10, twist = 0) {
            difference() {
                polygon(points=[p1,p2,p3,p4,p5,p6,p7,p8,p9]);
                union() {
                    for ( y = [0:1:18]) {
                        for ( x = [0:1:20]) {
                            translate([
                              frame_thickness+circle_diameter/2+x*(circle_diameter+2),
                              frame_thickness+circle_diameter/2+y*(circle_diameter+2),
                              0
                            ]) circle(d=circle_diameter);
                        }
                    }
                }
            }
        }
    }
}

color( "gray") {
    rotate(a = 90, v = [1, 0, 0]) {
        rotate(a = -90, v = [0, 1, 0]) {
            translate([-feet_depth/2,0,-total_width/2]) {
                base_stand();
                translate([0,0,total_width+feet_width/2]) {
                    mirror([0,0,1]) {
                        base_stand();
                    }
                }
            }
        }
    }
}

color( "gray") {
    rotate(a = 90, v = [1, 0, 0]) {
        rotate(a = -90, v = [0, 1, 0]) {
            translate([-feet_depth/2,0,-total_width/2]) {
                base_stand();
            }
        }
    }
}

color( "gray") {
    rotate(a = 90, v = [1, 0, 0]) {
        rotate(a = -90, v = [0, 1, 0]) {
            translate([-feet_depth/2,0,-total_width/2]) {
                translate([0,0,total_width+feet_width/2]) {
                    mirror([0,0,1]) {
                        base_stand();
                    }
                }
            }
        }
    }
}