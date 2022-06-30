use <../_utils_v2/_round/polyround.scad>
use <../_utils_v2/fillet.scad>
use <../_utils_v2/m3-m8.scad>
use <ptfe_fix.scad>

cmd="";

// outer,height,inner
bearings = [
 [10,4,5] //mr105zz
,[11,5,5] //685zz
,[10,4,3] //623zz
,[9,3,5] //mr95
];
bearing_index=0;

filament_diameter=2;
filament_cut=3;

bearing_left_tr=[-bearings[bearing_index][0]/2-filament_diameter/2,0,-bearings[bearing_index][1]/2];
bearing_right_tr=[bearings[bearing_index][0]/2+filament_diameter/2,0,-bearings[bearing_index][1]/2];

bearing_xy=1;
bearing_pad=[8-2,4-2];
bearing_inner_add=1;

spring=[5.2,8];//[3.6,8];
spring_yz=0.6;
bearing_pad_sub=0.4;
spring_xadd=3;
spring_xin=3-2;
spring_tr=[bearing_right_tr.x+spring_xadd,0,bearing_right_tr.z-bearing_pad[0]/2-bearing_pad_sub/2-0.5];

bounding_xy=[17,19,9+spring[1]+spring_xadd,19];
bounding_xy_switch=[13];
bounding_z=[9,3];
bounding_top=[6];
opticalswitch_tr=[bounding_xy[2],0,-0.6];
opticalswitch_rot=[-90,0,90];

flag_body_zsub=0.6;// 0.2 - fail
flag_xadd=2+3;
flag_offs=[0.2,0.4,0.2];
flag_dim=[7+flag_xadd,1.4,5.5];
flag_tr=[opticalswitch_tr.x-flag_dim.x+flag_xadd,-flag_dim.y/2,bounding_z[1]-flag_body_zsub-flag_dim.z];
flag_fix=2;

spring_optical_switch=4;

ptfe_fix_top=[0,7,0];
ptfe_fix_bottom=[0,-7,0];
fitting_offs=[0.2+0.2,0.2+0.2];
fitting_offs_top=[0.2,0.2];
fitting_cube_offs=[2,0.2];

bearing_rod_diff=0;

stand_thickness=[4];

fix_coord_diff=4.5;//4.3;
fix_coord=[
	  [-bounding_xy[0]+4.5,bounding_xy[1]-fix_coord_diff,bounding_z[1]+bounding_top[0]]
	 ,[-bounding_xy[0]+4.5,-bounding_xy[3]+fix_coord_diff,bounding_z[1]+bounding_top[0]]
	 
	 ,[bounding_xy[2]+1,bounding_xy[1]-fix_coord_diff,bounding_z[1]+bounding_top[0]]
	 ,[bounding_xy[2]+1,-bounding_xy[3]+fix_coord_diff,bounding_z[1]+bounding_top[0]]
];

module proto_opticalswitch_()
{
	color ("blue")
	translate ([-2-3/2,0,-4.6-7.5])
		import ("proto/optical_switch.stl");
}

module proto_opticalswitch()
{
	rotate (opticalswitch_rot)
		proto_opticalswitch_();
}

module opticalswitch_cut(top=false)
{
	translate (opticalswitch_tr)
	rotate(opticalswitch_rot)
		os_cut(offs=[top?0:40,10,spring_optical_switch],top=top);
}

module os_cut(offs=[0,0,0],top)
{
	offsall=0.2;
	board_th=2.7;
	board_h=10.6;
	tr=[-20-0.1,-board_h/2,-board_th-9.9];
	
	translate(tr)
	{
		translate([-offsall,-offs[0]-offsall,-offs[1]])
			cube ([33.2+offsall*2,board_h+offs[0]+offsall*2,board_th+offs[1]]);
		jack=[6,board_h,10];
		translate([-offsall,-offs[0]-offsall,-jack.z])
			cube ([jack.x+offsall*2,jack.y+offs[0]+offsall*2,jack.z]);
	}
	opto_bottom=[24.8,6.2,board_th+2.6];
	opto_bottom_tr=[-opto_bottom.x/2,-opto_bottom.y/2,tr.z];
	translate ([opto_bottom_tr.x-offsall,opto_bottom_tr.y-offs[0]-offsall,opto_bottom_tr.z])
		cube([opto_bottom.x+offsall*2,opto_bottom.y+offs[0]+offsall*2,opto_bottom.z+offs[2]]);
	opto_top=[12.6,opto_bottom.y,board_th+10];
	opto_top_tr=[-opto_top.x/2,-opto_top.y/2,tr.z];
	translate ([opto_top_tr.x-offsall,opto_top_tr.y-offs[0]-offsall,opto_top_tr.z])
		cube([opto_top.x+offsall*2,opto_top.y+offs[0]+offsall*2,opto_top.z+offsall]);
	
	if (!top)
	{
		screw=20;
		for (i=[[-9.6,180],[9.5,180]])
		translate([i.x,0,tr.z])
		{
			m3_screw(screw);
			translate ([0,0,screw-6])
			rotate ([0,0,i.y])
				m3_square_nut();
		}
	}
}

//proto_opticalswitch_();
//os_cut(offs=[0,0,4]);

module proto_bearing(index)
{
	color ("yellow")
	difference()
	{
		cylinder (d=bearings[index][0],h=bearings[index][1],$fn=30);
		translate ([0,0,-0.1])
			cylinder (d=bearings[index][2],h=bearings[index][1]+0.2,$fn=30);
	}
}
module proto(ptfe_fix=true)
{
	color ("red")
	rotate ([90,0,0])
	translate ([0,0,-50])
		cylinder (d=filament_diameter,h=100,$fn=16);
	translate (bearing_left_tr)
		proto_bearing(bearing_index);
	translate (bearing_right_tr)
		proto_bearing(bearing_index);
	translate (opticalswitch_tr)
		proto_opticalswitch();
	translate(spring_tr)
	color ("orange")
	rotate ([0,90,0])
		cylinder (d=spring[0],h=spring[1],$fn=60);
	
	if (ptfe_fix)
	color ("orange")
	{
		translate(ptfe_fix_top)
		rotate ([-90,0,0])
			fitting();
		translate(ptfe_fix_bottom)
		rotate ([90,0,0])
			fitting();
	}
}

module main_fix(op="")
{
	screw=20;
	in=4;
	if (op=="addtop"||op=="addbottom"||op=="addbottom2")
	{
		layer=0.2;
		for (c=fix_coord)
		{
			translate (c)
			rotate ([180,0,0])
			{
				if (op=="addtop")
					translate ([0,0,m3_washer_thickness()])
						cylinder (d=7,h=layer,$fn=60);
				if (op=="addbottom")
					translate ([0,0,screw-in-layer])
						cylinder (d=8,h=layer,$fn=60);
			}
		}
		for (cc=[0,2])
		{
			c=fix_coord[cc];
			translate (c)
			rotate ([180,0,0])
			{
				if (op=="addbottom2")
					translate ([0,0,screw-in-layer])
						cylinder (d=8,h=layer,$fn=60);
			}
		}
	}
	else
	{
		for (c=fix_coord)
		{
			translate (c)
			rotate ([180,0,0])
			{
				m3_screw(screw);
				m3_washer();
				translate ([0,0,screw-in])
					m3_nut(h=50);
			}
		}
	}
}

module body_cube(dim,cut=2)
{
	//cube (dim);
	linear_extrude(dim.z)
	polygon(polyRound([
		 [0,0,cut]
		,[dim.x,0,cut]
		,[dim.x,dim.y,cut]
		,[0,dim.y,cut]
	],1));
}

module main_top()
{
	tr=[-bounding_xy[0],-bounding_xy[3],bounding_z[1]];
	dim=[bounding_xy[0]+bounding_xy[2]+bounding_xy_switch[0],bounding_xy[1]+bounding_xy[3],bounding_top[0]];
	union()
	{
		difference()
		{
			union()
			{
				translate (tr)
					body_cube (dim);
				
				difference()
				{
					translate([0,0,0.2])
					translate(ptfe_fix_top)
					rotate ([-90,0,0])
						fitting_cube(offs=[fitting_cube_offs.x-0.2,fitting_cube_offs.y-0.2],top=true);
					translate ([0,dim.y,-dim.z])
					translate (tr)
						cube ([dim.x,dim.y,dim.z*2]);
					translate ([-dim.x/2,-dim.y/2,dim.z])
					translate (tr)
						cube ([dim.x*2,dim.y*2,dim.z]);
				}
				difference()
				{
					translate([0,0,0.2])
					translate(ptfe_fix_bottom)
					rotate ([90,0,0])
						fitting_cube(offs=[fitting_cube_offs.x-0.2,fitting_cube_offs.y-0.2],top=false);
					translate ([0,-dim.y,-dim.z])
					translate (tr)
						cube ([dim.x,dim.y,dim.z*2]);
					translate ([-dim.x/2,-dim.y/2,dim.z])
					translate (tr)
						cube ([dim.x*2,dim.y*2,dim.z]);
				}
			}
			translate(ptfe_fix_top)
			rotate ([-90,0,0])
				fitting_main(offs=fitting_offs_top);
			translate(ptfe_fix_bottom)
			rotate ([90,0,0])
				fitting_main(offs=fitting_offs_top);
			
			hull()
			{
				dd=bearings[bearing_index][0]+bearing_xy;
				cut=2;
				for (tr=[bearing_left_tr,bearing_right_tr])
					translate ([tr.x,tr.y,bounding_z[1]-0.01])
						cylinder (d1=dd,d2=dd+cut,h=bounding_top[0]+0.02,$fn=60);
			}
			
			opticalswitch_cut(top=true);
			main_fix();
		}
		dd=bearings[bearing_index][2]-bearing_rod_diff;
		cut=3;
		hull()
		{
			hull()
			{
				translate ([-bounding_xy[0]+dd/2,bearing_left_tr.y,bounding_z[1]])
					cylinder (d1=dd-cut,d2=dd-cut,h=bounding_top[0],$fn=60);
				translate ([bearing_left_tr.x,bearing_left_tr.y,bounding_z[1]])
					cylinder (d1=dd-cut,d2=dd-cut,h=bounding_top[0],$fn=60);
			}
			hull()
			{
				translate ([bounding_xy[2],bearing_right_tr.y,bounding_z[1]])
					cylinder (d1=dd-cut,d2=dd-cut,h=bounding_top[0],$fn=60);
				translate ([bearing_right_tr.x-filament_cut,bearing_right_tr.y,bounding_z[1]])
					cylinder (d1=dd-cut,d2=dd-cut,h=bounding_top[0],$fn=60);
			}
		}
		main_fix(op="addtop");
	}
}

module main_bottom()
{
	dd=bearings[bearing_index][0]+bearing_xy;
	union()
	{
		difference()
		{
			translate ([-bounding_xy[0],-bounding_xy[3],-bounding_z[0]])
				body_cube ([bounding_xy[0]+bounding_xy[2]+bounding_xy_switch[0]
					,bounding_xy[1]+bounding_xy[3]
					,bounding_z[0]+bounding_z[1]]);
			
			rotate ([90,0,0])
			translate ([0,0,-50])
				cylinder (d=filament_cut,h=100,$fn=16);
			
			translate (bearing_left_tr)
			translate ([0,0,-bearing_pad[0]])
				cylinder (d=bearings[bearing_index][0]+bearing_xy
					,h=bearings[bearing_index][1]+bearing_pad[0]+10,$fn=60);
			translate (bearing_right_tr)
			translate ([0,0,-bearing_pad[0]])
			{
				hull()
				for (x=[-filament_diameter,0])
					translate([x,0,0])
						cylinder (d=dd
							,h=bearings[bearing_index][1]+bearing_pad[0]+10,$fn=60);
			}
			
			translate ([bearing_right_tr.x,-dd/2,bearing_right_tr.z-bearing_pad[0]])
				cube ([spring[1]+spring_xadd+0.2,dd,100]);
			
			spring_in=2;
			translate(spring_tr)
			rotate ([0,90,0])
			fillet(r=1,steps=$preview?4:16)
			{
				cylinder (d=spring[0]+spring_yz,h=spring[1]+spring_in,$fn=60);
				translate([0,0,spring[1]-0.01])
					cylinder (d=spring[0]+spring_yz+2,h=0.01,$fn=60);
			}

			hull()
			for (z=[0,20])
			translate([0,0,z])
			translate(spring_tr)
			rotate ([0,90,0])
				cylinder (d=spring[0]+spring_yz,h=spring[1]+spring_in-1,$fn=60);
			translate ([flag_tr.x-flag_offs.x,flag_tr.y-flag_offs.y,flag_tr.z-flag_offs.z])
				cube([flag_dim.x+flag_offs.x*2,flag_dim.y+flag_offs.y*2,20]);
			
			opticalswitch_cut();
			
			translate(ptfe_fix_top)
			rotate ([-90,0,0])
			{
				fitting_main(offs=fitting_offs);
				fitting_cube(offs=fitting_cube_offs,top=true);
			}
			translate(ptfe_fix_bottom)
			rotate ([90,0,0])
			{
				fitting_main(offs=fitting_offs);
				fitting_cube(offs=fitting_cube_offs,top=false);
			}
			
			main_fix();
		}

		translate ([bearing_left_tr.x,bearing_left_tr.y,-bounding_z[0]])
			cylinder (d=bearings[bearing_index][2]-bearing_rod_diff
					,h=bounding_z[0]+bounding_z[1],$fn=60);
		
		translate (bearing_left_tr)
		translate ([0,0,-bearing_pad[0]])
		fillet(r=bearing_pad[1],steps=$preview?4:32)
		{
			cylinder (d=bearings[bearing_index][2]+bearing_inner_add,h=bearing_pad[0],$fn=60);
			translate ([0,0,-0.1])
				cylinder (d=bearings[bearing_index][2]+bearing_inner_add+bearing_pad[1]*2,h=0.1,$fn=60);
		}
		
		main_fix(op="addbottom");
	}
}

module flag()
{
	translate (flag_tr)
	{
		cube(flag_dim);
		translate ([0,-flag_fix+0.01,0])
			cube([flag_dim.y,flag_fix,flag_dim.z]);
	}
}

module flag_body()
{
	dd=bearings[bearing_index][0]+bearing_xy-0.4-0.4;
	bottom_cut=1;
	difference()
	{
		union()
		{
			translate (bearing_right_tr)
			translate ([0,0,-bearing_pad[0]])
			{
				fillet(r=bearing_pad_sub,steps=4)
				{
					hh=bearing_pad[0]-bearing_pad_sub;
					hull()
					{
						union()
						{
							translate ([0,0,bottom_cut-0.01])
								cylinder (d=dd,h=hh-bottom_cut,$fn=60);
							cylinder (d1=dd-bottom_cut*2,d2=dd,h=bottom_cut,$fn=60);					
						}
						translate ([dd/2-0.1,-dd/2,0])
						{
							dim=[0.1,dd,hh];
							translate ([0.1,0,0])
							rotate([0,-90,0])
							linear_extrude(0.1)
							polygon([
								 [0,bottom_cut]
								,[bottom_cut,0]
								,[dim.z,0]
								,[dim.z,dim.y]
								,[bottom_cut,dim.y]
								,[0,dim.y-bottom_cut]
							]);
						}
					}
					cylinder (d=bearings[bearing_index][2]+bearing_inner_add,h=bearing_pad[0],$fn=60);
				}
			}
			translate ([bearing_right_tr.x,bearing_right_tr.y,bearing_right_tr.z])
				cylinder (d=bearings[bearing_index][2]-bearing_rod_diff
						,h=bounding_z[1]-bearing_right_tr.z-flag_body_zsub,$fn=60);
			difference()
			{
				translate ([bearing_right_tr.x+spring_xadd,-dd/2,bearing_right_tr.z-bearing_pad[0]])
				{
					dim=[spring[1],dd,bounding_z[1]-bearing_right_tr.z+bearing_pad[0]-flag_body_zsub];
					//cube (dim);
					translate ([dim.x,0,0])
					rotate([0,-90,0])
					linear_extrude(dim.x)
					polygon([
						 [0,bottom_cut]
						,[bottom_cut,0]
						,[dim.z,0]
						,[dim.z,dim.y]
						,[bottom_cut,dim.y]
						,[0,dim.y-bottom_cut]
					]);
				}
				
				translate (bearing_right_tr)
				translate ([0,0,-bearing_pad_sub])
							cylinder (d=bearings[bearing_index][0]+bearing_xy
								,h=bearings[bearing_index][1]+bearing_pad[0]+10,$fn=60);
			}				
		}
		
		translate(spring_tr)
		rotate ([0,90,0])
		translate ([0,0,-spring_xin])
			cylinder (d=spring[0]+spring_yz,h=spring[1]+spring_xin+0.1,$fn=60);
		offs=[0.2,0.2,0.2];
		translate ([flag_tr.x-offs.x,flag_tr.y-offs.y,flag_tr.z-offs.z])
		{
			cube([flag_dim.x+offs.x*2,flag_dim.y+offs.y*2,20]);
			translate ([0,-flag_fix+0.01,0])
				cube([flag_dim.y+offs.x*2,flag_fix,20]);

		}
	}
}


module stand(length)
{
	color ("gray")
	translate ([25,-18.23,-9.0])
	rotate ([0,0,90])
		import ("proto/filament_runout_sensor_stand.stl");
	/*
	translate ([0,0,-stand_thickness[0]])
	{
		#translate ([-bounding_xy[0],-bounding_xy[3],-bounding_z[0]])
			body_cube ([bounding_xy[0]+bounding_xy[2]+bounding_xy_switch[0]
				,bounding_xy[1]+bounding_xy[3]
				,stand_thickness[0]]);
	}
	*/
}

module slot_fix()
{
	out=15;
	thickness=5;
	thickness_up=3;
	m5offs=7;
	ff=1;
	
	union()
	{
		difference()
		{
			union()
			{
				w=bounding_xy[0]+bounding_xy[2]+bounding_xy_switch[0]+out*2;
				translate ([-bounding_xy[0]-out
							,bounding_xy[1]-20
							,-bounding_z[0]-thickness])
					body_cube ([w,20,thickness+thickness_up],cut=4);
			}
			translate ([0,0,-thickness+ff])
				main_fix();
			
			for (x=[-bounding_xy[0]-out+m5offs,bounding_xy[2]+bounding_xy_switch[0]+out-m5offs])
				translate ([x,bounding_xy[1]-10,-bounding_z[0]])
				rotate ([0,180,0])
					m5n_screw_washer(thickness=thickness, diff=2, washer_out=8,tnut=true);
		}
		translate ([0,0,-thickness+ff])
			main_fix(op="addbottom2");
	}
}

module slot_fix_v()
{
	//88888888
	out=20;
	thickness=5;
	thickness_up=3;
	m5offs=7;
	ff=1;
	union()
	{
		difference()
		{
			w=bounding_xy[0]+bounding_xy[2]+bounding_xy_switch[0]+out;
			h=bounding_xy[1]+bounding_xy[3];
			z=thickness+thickness_up;
			union()
			{
				translate ([-bounding_xy[0]-out
							,-bounding_xy[1]
							,-bounding_z[0]-thickness-thickness_up-0.1])
					body_cube ([w,h,z],cut=2);
			}
			for (y=[bounding_xy[1]-m5offs,-bounding_xy[3]+m5offs])
				translate ([-bounding_xy[0]-out+10,y,-bounding_z[0]])
				rotate ([0,180,0])
					m5n_screw_washer(thickness=z, diff=2, washer_out=8,tnut=true);
			translate ([0,0,-thickness+ff])
				main_fix();
		}
		translate ([0,0,-thickness+ff])
			main_fix(op="addbottom");
	}
}

module list(s)
{
	echo(str("list:",s));
}

if (cmd=="list")
{
	list("main/bottom");
	list("main/top");
	list("main/flag");
	list("main/body_flag");
	list("main/fitting");
	list("main/fitting_nut");
	list("main/nofitting");
	list("main/slot_fix");
	list("main/slot_fix_v");
}
if (cmd=="main/top")
{
	rotate ([180,0,0])
		main_top();
}
if (cmd=="main/bottom")
{
	main_bottom();
}
if (cmd=="main/flag")
{
	rotate ([-90,0,0])
		flag();
}
if (cmd=="main/body_flag")
{
	flag_body();
}
if (cmd=="main/fitting")
{
	fitting();
}
if (cmd=="main/fitting_nut")
{
	fitting_nut();
}
if (cmd=="main/nofitting")
{
	nofitting(dd=filament_cut);
}
if (cmd=="main/slot_fix")
{
	slot_fix();
}
if (cmd=="main/slot_fix_v")
{
	slot_fix_v();
}

if (cmd=="")
{
	//proto(ptfe_fix=false);
	//main_top();
	//flag_body();
	//flag();
	//fitting();
	
	//main_bottom();
	//slot_fix();
	slot_fix_v();
	
	//stand(length=100);
	//nofitting(dd=filament_cut);
}