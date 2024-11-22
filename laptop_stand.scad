/* [Size Variables] */
total_width = 280; // [10:1:400]
front_height = 100; // [10:1:400]
back_height = 220; // [10:1:400]
laptop_depth = 230; // [10:1:400]
laptop_height = 18; // [1:1:50]

/* [ Other Dimensions ] */
nose_thickness = 6;   // [1:1:20]
nose_length = 6;      // [1:1:20]
feet_width = 20;      // [10:1:50]
frame_thickness = 6;  // [4:1:50]


frame_thickness_back = 15;
circle_diameter = 10;
circle_distance = 2;


joint_height=12;
joint_diameter=8;
joint_reduction=1;
joint_clearance=0.2;

connector_thickness=3;


echo(angle);
angle = asin((back_height-front_height)/laptop_depth);
feet_depth = laptop_depth*cos(angle);
steigung = (back_height-front_height)/feet_depth;

echo(feet_depth);
circle_count_x = floor((feet_depth-frame_thickness_back-frame_thickness)/(circle_diameter+circle_distance));
circle_count_y = floor((back_height-(2*frame_thickness))/(circle_diameter+circle_distance));

echo(circle_count_x)
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

    i1 = [p1[0]+frame_thickness_back, p1[1]+frame_thickness];
    i2 = [p2[0]-frame_thickness, p2[1]+frame_thickness];
    i3 = [p3[0]-frame_thickness, p3[1]-frame_thickness*cos(angle)];
    i4 = [p9[0]+frame_thickness_back, p9[1]-frame_thickness/cos(angle)-frame_thickness_back*tan(angle)];

    difference() {
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
                        for ( y = [0:1:circle_count_y-1]) {
                            for ( x = [0:1:circle_count_x-1]) {
                                translate([
                                frame_thickness_back+circle_diameter/2+x*(circle_diameter+circle_distance),
                                frame_thickness+circle_diameter/2+y*(circle_diameter+circle_distance),
                                0
                                ]) circle(d=circle_diameter);
                            }
                        }
                    }
                }
            }
        }
        translate([(frame_thickness_back-2)/2,joint_height/2,feet_width/2]) {
            rotate(-90, [1,0,0]) {
                cylinder(h = joint_height, r1 = joint_diameter/2, r2 = (joint_diameter-joint_reduction)/2, center = true);
            }
        }
        cube([frame_thickness_back-2,connector_thickness,feet_width]);
        translate([0, back_height-connector_thickness, 0]) {
            rotate(-angle,[0,0,1]) {
                translate([+10,0,0]) {
                    cube([frame_thickness_back+2,connector_thickness,feet_width]);  
                    translate([(frame_thickness_back-2)/2, -joint_height/2+connector_thickness, feet_width/2]) {
                        rotate(90, [1,0,0]) {
                            cylinder(h = joint_height, r1 = joint_diameter/2, r2 = (joint_diameter-joint_reduction)/2, center = true);
                        }
                    }  
                }
            }
        }
    }
    
}

module connector() {
    cube([total_width,frame_thickness_back-2,connector_thickness]);
    translate ([feet_width/2,(frame_thickness_back-2)/2,joint_height/2]) {
        cylinder(h = joint_height, r1 = joint_diameter/2-joint_clearance, r2 = (joint_diameter-joint_reduction)/2-joint_clearance, center = true);
    }
    translate ([total_width-feet_width/2,(frame_thickness_back-2)/2,joint_height/2]) {
        cylinder(h = joint_height, r1 = joint_diameter/2-joint_clearance, r2 = (joint_diameter-joint_reduction)/2-joint_clearance, center = true);
    }
}



color("gray") {
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
color("gray") {
    translate([(frame_thickness_back-2)+1,-total_width/2,0]) {
        rotate(a = 90, v = [0, 0, 1]) {
            connector();
        }
    }
}
color("gray") {
    translate([-1,-total_width/2,0]) {
        rotate(a = 90, v = [0, 0, 1]) {
            connector();
        }
    }
}
color("gray") {
    rotate(a = 90, v = [1, 0, 0]) {
        rotate(a = -90, v = [0, 1, 0]) {
            translate([-feet_depth/2,0,-total_width/2]) {
                base_stand();
                
            }
        }
    }
}

color("gray") {
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