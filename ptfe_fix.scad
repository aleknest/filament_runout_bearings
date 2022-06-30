use <../_utils_v2/fillet.scad>
use <../_utils_v2/threads.scad>

base_diameter=12;
function fitting_base_diameter()=base_diameter;
screw_diameter_diameter = base_diameter;
base_length=2;
tube_diameter=4.5;
screw_length=12;
slot_thickness=1.5;

h=12.6;
hh=2.9;

module fitting_nut()
{
	translate ([0,0,h])
	difference()
	{
		cylinder (d=17.33,h=8,$fn=6);
		translate ([0,0,-0.5])
		metric_thread (diameter=base_diameter, pitch=1.6, length=screw_length, internal=true, n_starts=1,
							  thread_size=2.0, groove=false, square=false, rectangle=0,
							  angle=30, taper=0.2, leadin=0, leadfac=1.0);
	}
}
module pc4_add()
{
	metric_thread (diameter=screw_diameter_diameter, pitch=1.6, length=screw_length, internal=false, n_starts=1,
						  thread_size=2.0, groove=false, square=false, rectangle=0,
						  angle=30, taper=0.2, leadin=1, leadfac=1.0);
}

module pc4_sub_slot()
{
	for (a=[60,180,300])
	rotate ([0,0,a])
	translate ([0,0,base_length])
	{
		cut=0.5;
		cut_offs=0.18;
		linear_extrude(40)
		polygon([
			 [-slot_thickness/2-cut/2,0]
			,[-slot_thickness/2-cut/2,tube_diameter/2-cut+cut_offs]
			,[-slot_thickness/2,tube_diameter/2+cut_offs]
			,[-slot_thickness/2,20]
			,[slot_thickness/2,20]
			,[slot_thickness/2,tube_diameter/2+cut_offs]
			,[slot_thickness/2+cut/2,tube_diameter/2-cut+cut_offs]
			,[slot_thickness/2+cut/2,0]
		]);
	}
}

module pc4_sub_filament()
{
	cut1=1;
	translate ([0,0,-base_length])
	translate ([0,0,-50])
	{
		cylinder (d=tube_diameter,h=100,$fn=80);
	}
	translate ([0,0,screw_length-cut1+0.01])
		cylinder (d1=tube_diameter,d2=tube_diameter+cut1,h=cut1,$fn=80);
}
module pc4_sub()
{
	translate ([0,0,-base_length])
	{
		pc4_sub_slot();
		cut2=0.6;
		intersection()
		{
			translate ([0,0,base_length-cut2])
				cylinder (d1=tube_diameter,d2=tube_diameter+cut2,h=cut2+0.01,$fn=80);
			translate ([0,0,-10])
				pc4_sub_slot();
		}
	}
}

module fitting_main(offs=[0,0])
{
	cylinder (d=12+offs[0]*2,h=h,$fn=100);
	translate([0,0,-offs[1]])
		cylinder (d=16+offs[0]*2,h=3.6+offs[1]*2,$fn=100);
	translate ([0,0,h-hh-offs[1]])
		cylinder (d=16+offs[0]*2,h=hh+offs[1]*2,$fn=100);
}

module fitting_cube(offs=[0,0],top=true)
{
	xy=16+offs[0]*2;
	tr=top?[-xy/2,-xy/2,-offs[1]]:[-xy/2,0,-offs[1]];
	translate (tr)
		cube ([xy,xy/2,h+offs[1]*2]);
}

module fitting()
{
	difference()
	{
		union()
		{
			fitting_main();
			translate ([0,0,h])
			difference()
			{
				pc4_add();
				pc4_sub();
				pc4_sub_filament();
			}
		}
		translate ([0,0,-1])
			cylinder (d=3,h=50,$fn=50);
	}
}

module nofitting(dd)
{
	difference()
	{
		fitting_main();
		translate ([0,0,-0.1])
		union()
		fillet(r=4,steps=16)
		{
			hh=h+0.2;
			cylinder (d1=dd,d2=8,h=hh,$fn=50);
			translate([0,0,hh-0.1])
				cylinder (d=16,h=0.1,$fn=50);
		}
	}
}

//fitting_main(offs=[1,1]);
//fitting_cube(offs=[1,1]);
//fitting();
//fitting_nut();
nofitting(dd=3);