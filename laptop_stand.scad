/* [Size Variables] */
// Total width. Distance from left to right
Total_Width = 280; // [10:1:400]
// Height of the laptops bearing in the front
Front_Height = 20; // [10:1:400]
// Height of the laptops bearing in the back
Back_Height = 150; // [10:1:400]
// The depth of the laptop from front to back
Laptop_Depth = 230; // [10:1:400]
// Height of the laptop in the front so it fits under the nose
Laptop_Height = 20; // [1:1:50]
// Width of the left and right feet
Feet_Width = 20;    // [10:1:50]

/* [ Other Dimensions ] */
nose_thickness = 4;   // [1:1:20]
nose_length = 6;      // [1:1:20]
frame_thickness = 6;  // [4:1:50]
circle_diameter = 10; // [2:1:50]
circle_distance = 2;  // [1:1:20]

/* [ Advanced ] */
frame_thickness_back = 15; // [6:1:30]
dovetail_height=20;        // [5:1:40]
dovetail_min_width=3;      // [1:1:10]
dovetail_max_width=6;      // [2:1:15]
dovetail_depth=6;          // [3:1:20]
dovetail_clearance=0.2;



echo(angle);
angle = asin((Back_Height-Front_Height)/Laptop_Depth);
feet_depth = Laptop_Depth*cos(angle);
steigung = (Back_Height-Front_Height)/feet_depth;

echo(feet_depth);
circle_count_x = floor((feet_depth-frame_thickness_back-frame_thickness)/(circle_diameter+circle_distance));
circle_count_y = floor((Back_Height-(2*frame_thickness))/(circle_diameter+circle_distance));

echo(circle_count_x)
echo(angle);


module dovetail(max_width=10, min_width=6, depth=10, height=20) {
    p1 = [-min_width/2, 0];
    p2 = [-max_width/2, depth];
    p3 = [max_width/2, depth];
    p4 = [min_width/2, 0];
    
    linear_extrude(height = height, center = false, convexity = 10, twist = 0) {
        polygon(points=[p1,p2,p3,p4]);
    }
}



module base_stand() {
    p1 = [0,0];
    p2 = [feet_depth,0];
    p3 = [feet_depth,Front_Height];
    p4 = [p3[0], p3[1]+(Laptop_Height+nose_thickness)/cos(angle)];
    p5 = [p4[0]-(nose_length+nose_thickness)*cos(angle),   p4[1]+(nose_length+nose_thickness)*sin(angle)];
    p6 = [p5[0]-nose_thickness*sin(angle), p5[1]-nose_thickness*cos(angle)];
    p7 = [p6[0]+nose_length*cos(angle), p6[1]-nose_length*sin(angle)];
    p8 = [p7[0]-Laptop_Height*sin(angle),  p7[1]-Laptop_Height*cos(angle)]; 
    p9 = [0,Back_Height];

    i1 = [p1[0]+frame_thickness_back, p1[1]+frame_thickness];
    i2 = [p2[0]-frame_thickness, p2[1]+frame_thickness];
    i3 = [p3[0]-frame_thickness, p3[1]-frame_thickness*cos(angle)];
    i4 = [p9[0]+frame_thickness_back, p9[1]-frame_thickness/cos(angle)-frame_thickness_back*tan(angle)];

    difference() {
        union() {
            linear_extrude(height = Feet_Width, center = false, convexity = 10, twist = 0) {
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

        dv_max_incl_clear=dovetail_max_width+dovetail_clearance;
        dv_min_incl_clear=dovetail_min_width+dovetail_clearance;

        translate([frame_thickness_back/2,0,Feet_Width]) rotate(-90, [1,0,0]) {
            dovetail(max_width=dv_max_incl_clear, min_width=dv_min_incl_clear, depth=dovetail_depth, height=dovetail_height);
        }
        dv_diff = (dv_max_incl_clear+frame_thickness_back)/2*tan(angle);
        translate([frame_thickness_back/2,Back_Height-dovetail_height-dv_diff,Feet_Width]) rotate(-90, [1,0,0]) {
            dovetail(max_width=dv_max_incl_clear, min_width=dv_min_incl_clear,  depth=dovetail_depth, height=Back_Height);
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


translate([(frame_thickness_back-2)+1,-Total_Width/2,0]) {
    rotate(a = 90, v = [0, 0, 1]) {
        connector();
    }
}


translate([-1,-Total_Width/2,0]) {
    rotate(a = 90, v = [0, 0, 1]) {
        connector();
    }
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
        translate([-feet_depth/2,0,-Total_Width/2]) {
            translate([0,0,Total_Width+Feet_Width/2]) {
                mirror([0,0,1]) {
                    base_stand();
                }
            }
        }
    }
}

