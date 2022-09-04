// Copyright: Jetty, 2015
// License: Creative Commons:  Attribution, Non-Commercial, Share-alike: CC BY-NC-SA
// https://creativecommons.org/licenses/by-nc-sa/2.0/

// Helmholtz Coil Design for 3D Printing.  Also this shows statistics about the coil generated, including the
// amount of field generated for a given number of wraps and current.

// Note: The coil diameter  + 2 * flange height must not exceed the width  of the 3D printer bed, and
// 		 The coil radius must not exceed the depth of the 3D printer bed.

// When winding the coils, both coils are wound in the same direction and mounted in the same direction, i.e. the current
// and magentic field in both coils is in the same axis.

// This will also do the calculation to figure out the magentic field strength
// Look in the output of openscad for "Helmholtz Coil Configuration Statistics" 
// Units are predominately nanoTesla (nT), as the earths field is generally measured in nT for magnetometers, if you need Gauss:
// 		1 Guass = 100,000nanoTesla

// Earths field is approximate +/-50,000nT, therefore the coil needs to be capable of at least that if cancelling the earths fields is required
// Kp Index 9 (highest for Aurora) is 500nT difference

// Printing:
//		If the diameter of the coil fits on the printer bed, then print 3 (CompleteCoil), otherwise if the radius of the coil
//		fits on the printed bed, then print 1 and 2 (the coil halves)
//
//		Coil halves - 10% infill, 2 shells and full support (including exterior)
//		table - 5% infill, 2 shells
//		Everything else, 10% infill, 2 shells
//
// Assembly:
//		Note the bottom of each coil has a small hole for the wire to go through, when assembling coil halves, make sure you have that
//		hole in each assembled coil.


// All the following settings are metric except coilOhmsPerThousandFeet and control the magnetic strength, size of
// the coil and statistics for the coil, they need to be set correctly
coilRadius						= 130;		// Coil Radius in mm's
coilLayersNum                   = 8;
coilWiresNum                    = 6;

wireDiamNominal  = 1.2;
wireDiam				= wireDiamNominal + 0.1;		// Wire diameter in mm's, note this includes insulation (insulation thickness varies)
windingSpaceAdditional					= 0.3;		// Fudge factor in mm's to add to the space for the coil to allow for 3D printer inaccuracy	
coilFormerFlangeHeight			= wireDiam * coilLayersNum + 3.0;		// The height of the flange
coilFormerFlangeWidth			= 3.0;		// The width of the flange

// Wire hooks
hookRadius = 2 * wireDiam + windingSpaceAdditional;

// These settings effect general coil geometry
coilOuterRingPercentage			= 1 - 0.15;	// The size of the outer ring based on a percentage of the radius
coilInnerRingPercentage			= 0.20;		// The size of the inner ring based on a percentage of the radius
coilWireEnterRotationAngle      = 0;

// These settings effect parts of the total object
coilRetainerThickness			= 4;
coilRetainerWidth				= 10;
coilRetainerDepth				= 7;

platformThickness		= 7;
platformWidth			= 1.5 * coilRadius;		// It would make sense to make this wide enough to place the mounting posts outside of the coil for magnetic field uniformity reasons

wallUserHeight			= 20;
wallUserThickness		= 4;
wallUserHoleDiam		= 5.5;

tableHeightAdd				= 10;			// The height of the table can be increased by a positive number here
tableThickness				= 3;
tablePostDiameter			= 10;
tablePostReinforcementFudge	= 0.3;			// Post reinforcement diameter fudge factor for fit
tablePostReinforcementDiameter	= tablePostDiameter + 5 * 2; 
tablePostReinforcementHeight	= 10;



// DO NOT CHANGE THESE SETTINGS !
coilWindingWidth	= wireDiam * (coilWiresNum + 0.5) + windingSpaceAdditional;	// The space for the wire to fit in on the former

manifoldCorrection 				= .1;

coilUsableDiameter				= coilRadius * 2/3;
coilTotalThickness		= coilWindingWidth + coilFormerFlangeWidth * 2;
coilSpokeRotationAngles			= [22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5];
coilSpokeLength					= coilRadius - (coilUsableDiameter / 2) - 2.0;
coilSpokeDimensions				= [0.075 * coilRadius, coilSpokeLength, coilTotalThickness];
coilSpokeOffset					= [0, (coilUsableDiameter + coilSpokeLength) / 2 + 1.0, 0];
coilFormerFlangeOffset			= [0, 0, (coilWindingWidth + coilFormerFlangeWidth) / 2];

coilOffset1						= [0, 			  0,   			   coilRadius / 2];
coilOffset2						= [coilOffset1[0], coilOffset1[1], - coilOffset1[2]];
coilRetainerDimensions			= [coilRadius + coilTotalThickness + coilRetainerThickness * 2, coilRetainerWidth, coilRetainerDepth];
coilRetainerBlockDimensions		= [coilRetainerThickness, coilRetainerWidth, coilRetainerThickness];
coilRetainerBlockOffset1		= [(coilTotalThickness + coilRetainerThickness) / 2,
								   0,
								  (coilRetainerDimensions[2] + coilRetainerBlockDimensions[2]) / 2]; 
coilRetainerBlockOffset2		= [- coilRetainerBlockOffset1[0], coilRetainerBlockOffset1[1], coilRetainerBlockOffset1[2]];
retainerAngleStep               = 30;
coilRetainerLocationAngles		= [-1.5 * retainerAngleStep, 1.5 * retainerAngleStep, 2.5 * retainerAngleStep, 3.5 * retainerAngleStep, 4.5 * retainerAngleStep];
coilRetainerLocationAnglesBlock	= [-retainerAngleStep / 2, retainerAngleStep / 2];
platformDimensions		= [coilRetainerDimensions[0], platformWidth, platformThickness];
platformOffset			= [0, 0, - (coilRadius + coilFormerFlangeHeight + platformDimensions[2] / 2) ];
wallUserWidth			= (coilRadius - (coilWindingWidth + coilFormerFlangeWidth)) - 4;


wallUserHoleOffset		    = 15; 
tableDimensions				= [wallUserWidth, coilUsableDiameter, tableThickness ];
tableOffset					= [0, 0, -(tableThickness / 2 + coilUsableDiameter / 2) + tableHeightAdd];
tablePostOffset				= [coilRadius * 0.25, 0, 0];


$fn = 80;


//coilRetainersAllFlat();
//coilRetainersAll();
platform();
//platformTable();
fullHelmholtzCoil();

//coilHelmholtzFlat();


module platformTable()
{
	postHeight				= tableOffset[2] - platformOffset[2] + (platformDimensions[2] + tableThickness) / 2;
	postHeightOffset 		= platformOffset[2] + (postHeight - platformDimensions[2]) / 2;

	translate( tableOffset )
		cube( tableDimensions, center=true );

	translate( tablePostOffset )
		translate( [0, 0, postHeightOffset] )
			cylinder( r=tablePostDiameter / 2, h=postHeight, center=true );

	translate( -tablePostOffset )
		translate( [0, 0, postHeightOffset] )
			cylinder( r=tablePostDiameter / 2, h=postHeight, center=true );
}


module platform()
{
	postReinforcementOffsetZ	= platformOffset[2] + (platformDimensions[2] + tablePostReinforcementHeight) / 2;
    
    retainer1Y = (coilRadius + coilFormerFlangeHeight) * sin(coilRetainerLocationAnglesBlock[1]);
    
    module wallUser()
    {
        wallUserOffset = [0, ( platformDimensions[1] - wallUserThickness ) / 2, ( wallUserHeight + platformDimensions[2] ) / 2];
        
        translate( wallUserOffset )
        difference()
        {
            cube( [wallUserWidth, wallUserThickness, wallUserHeight], center=true );
            holeHeight = wallUserThickness + manifoldCorrection * 2;

            // Mounting post holes
            translate( [wallUserHoleOffset, 0, 0] )
                rotate( [90, 0, 0] )
                    cylinder( r=wallUserHoleDiam / 2, h = holeHeight, center=true );

            translate( [-wallUserHoleOffset, 0, 0] )
                rotate( [90, 0, 0] )
                    cylinder( r=wallUserHoleDiam / 2, h = holeHeight, center=true );
        }
    }
    
    module wireHooks()
    {
        
        module torus(radius, width, angle)
        {
            rotate_extrude(angle=angle, convexity=10)
            translate([radius, 0, 0])
            circle(r=width);
        }
        
        module hook(radius, width)
        {
            // tight firmly
            angle = 180 - asin((wireDiamNominal + hookHalfWidth) / hookRouter);
            union() {
                torus(radius, width, angle);
                translate([hookRouter * cos(angle), hookRouter * sin(angle), 0])
                sphere(r=hookHalfWidth);
            }
        }
        
        
        hookHalfWidth = 2.0;
        padToCoil = 3.0;
        hooksNum = 5;
        hookRouter = hookRadius + hookHalfWidth;
        rangeUsable = coilRadius - 2 * (coilTotalThickness / 2 + padToCoil + hookHalfWidth);
        rangeStep = rangeUsable / (hooksNum - 1);
        
        for (x = [-rangeUsable/2:rangeStep:rangeUsable/2]) {
            translate([x, 0, platformThickness / 2 - manifoldCorrection])
            rotate([90, 0, 90])
            hook(hookRouter, hookHalfWidth);
        }
        
        translate([0, retainer1Y + (platformWidth / 2 - retainer1Y) / 2, platformThickness / 2 - manifoldCorrection])
        rotate([90, 0, 0])
        torus(hookRouter, hookHalfWidth, 180);
    }
    
    module platformRetainer(angle, hole=false)
    {
        rotate( [angle, 0, 0] )
        translate( [0, 0, -(coilRadius + coilFormerFlangeHeight + coilRetainerDimensions[2] / 2)] )
        coilRetainer();
    }
    
    module tableReinforcement()
    {
        translate( [0, 0, postReinforcementOffsetZ] )
        donut( outerRadius=tablePostReinforcementDiameter / 2,
           innerRadius = tablePostDiameter / 2 + tablePostReinforcementFudge,
           height=tablePostReinforcementHeight );
    }
    
    module reinforcementFloorCut()
    {
        translate( [0, 0, postReinforcementOffsetZ - platformDimensions[2] / 2] )
        cylinder( r=tablePostDiameter / 2 + tablePostReinforcementFudge,
                  h=platformDimensions[2] + tablePostReinforcementHeight + manifoldCorrection * 2,
                  center=true ); 
    }

    module platformFilled()
    {
        union()
		{
			translate( platformOffset )
			{
				%cube( platformDimensions, center=true );
                wallUser();
                wireHooks();
			}
            
            platformRetainer(coilRetainerLocationAnglesBlock[0]);
            difference() {
                platformRetainer(coilRetainerLocationAnglesBlock[1]);
                translate( platformOffset )
                translate([0, retainer1Y, platformThickness / 2 + hookRadius / 2 - manifoldCorrection])
                cube([2 * hookRadius, coilRetainerWidth * 2, hookRadius], center=true);
            }
   //         translate( platformOffset )	cube( coilRetainerDimensions, center=true );

   
			// Post reinforcement
			*translate( tablePostOffset )
            tableReinforcement();
			*translate( -tablePostOffset )
            tableReinforcement();
		}
    }

	difference()
	{
		platformFilled();

		// Remove holes in coil mounting block for post reinforcement
		translate( tablePostOffset )
        *reinforcementFloorCut();
		translate( -tablePostOffset )
        *reinforcementFloorCut();
	}
}



module coilRetainersAllFlat()

{
    coilNumRetainers = len(coilRetainerLocationAngles);
	for ( retainerNum = [1:coilNumRetainers] )
			translate( [0, retainerNum * (coilRetainerBlockDimensions[1] + 3), 0] )
				coilRetainer();
}



module coilRetainersAll()

{
	for ( coilRetainerLocationAngle = coilRetainerLocationAngles )
		rotate( [coilRetainerLocationAngle, 0, 0] )
			translate( [0, 0, -(coilRadius + coilFormerFlangeHeight + coilRetainerDimensions[2] / 2)] )
				coilRetainer();
}



module coilRetainer()
{
	cube( coilRetainerDimensions, center=true );
	translate( [coilOffset1[2], 0, 0] )
		coilRetainerBlocks();
	translate( [coilOffset2[2], 0, 0] )
		coilRetainerBlocks();
}


module coilRetainerBlocks()
{
	translate( coilRetainerBlockOffset1 )
		cube( coilRetainerBlockDimensions, center=true );

	translate( coilRetainerBlockOffset2 )
		cube( coilRetainerBlockDimensions, center=true );
}



module fullHelmholtzCoil()
{
    rotate( [coilWireEnterRotationAngle, 0, 0] )
	rotate( [0, 90, 0] )
	{
		translate( coilOffset1 )
        rotate( [180, 0, 0] )
            *helmholtzCoil();
		translate( coilOffset2 )
            %helmholtzCoil();

		// Show the usable array grayed out
		// cylinder( r=coilUsableDiameter / 2, h=coilRadius, center = true );	
	}
}



module coilHelmholtzFlat()
{
    helmholtzCoil();
}



module helmholtzCoil()
{
	coilOuterRingThickness = coilOuterRingPercentage * coilRadius;
    
    module coilWireHole()
    {
        // Account for Litz wire soldering. Make the radius twice larger.
        hole_radius = wireDiam + windingSpaceAdditional;
        trench_width = wireDiam * coilLayersNum + windingSpaceAdditional;
        h = coilFormerFlangeWidth + manifoldCorrection * 2;
        translate([trench_width / 2, 0, 0])
        intersection() {
            cylinder(r=trench_width / 2, h=h, center = true);
            cube([trench_width, 2 * hole_radius, h], center=true);
        }
    }

	difference()
	{
		union()
		{
			// Print the inside outer ring (where the coil gets wrapped around)
			donut( outerRadius=coilRadius, innerRadius = coilOuterRingThickness, height=coilWindingWidth ); 

			// Print the inside inner ring (where the inside marks the usable volume)
			donut( outerRadius=coilUsableDiameter / 2 + coilUsableDiameter * coilInnerRingPercentage,
				   innerRadius = coilUsableDiameter / 2,
			 	   height=coilTotalThickness ); 
	
			// Print the coil top outer ring retainer
			{
				translate( coilFormerFlangeOffset )
					donut( outerRadius=coilRadius + coilFormerFlangeHeight,
						   innerRadius = coilOuterRingThickness,
						   height=coilFormerFlangeWidth );

				// Print the coil bottom outer ring retainer
				translate( -coilFormerFlangeOffset )
					donut( outerRadius=coilRadius + coilFormerFlangeHeight,
						   innerRadius = coilOuterRingThickness,
						   height=coilFormerFlangeWidth ); 
			}

			for ( rotationAngle = coilSpokeRotationAngles )
				rotate( [0, 0, rotationAngle] )
					translate( coilSpokeOffset )
						cube( coilSpokeDimensions, center=true);
		}


		translate( [coilRadius, 0, (coilWindingWidth + coilFormerFlangeWidth) / 2] )
			%coilWireHole();
	}
}


module donut(outerRadius, innerRadius, height)
{
	difference()
	{
		cylinder( r=outerRadius, h = height, center = true);
		cylinder( r=innerRadius, h = height + 20 * manifoldCorrection, center = true);
	}
}
	

