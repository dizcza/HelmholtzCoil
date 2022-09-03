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
//		Platform - 5% infill, 2 shells
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

coilWireDiameter				= 1.3;		// Wire diameter in mm's, note this includes insulation (insulation thickness varies)
coilWireFudge					= 0.3;		// Fudge factor in mm's to add to the space for the coil to allow for 3D printer inaccuracy	
coilFormerFlangeHeight			= coilWireDiameter * coilLayersNum + 3.0;		// The height of the flange
coilFormerFlangeWidth			= 3.0;		// The width of the flange

// These settings effect general coil geometry
coilOuterRingPercentage			= 1 - 0.15;	// The size of the outer ring based on a percentage of the radius
coilInnerRingPercentage			= 0.20;		// The size of the inner ring based on a percentage of the radius
coilWireSourceRotationAngle     = 8;

// These settings effect parts of the total object
coilRetainerThickness			= 3;
coilRetainerWidth				= 10;
coilRetainerDepth				= 7;

coilMountingBlockThickness		= 7;
coilMountingBlockWidth			= 210;		// It would make sense to make this wide enough to place the mounting posts outside of the coil for magnetic field uniformity reasons
mountingPostBlockHeight			= 25;
mountingPostBlockThickness		= 4;
mountingPostDiameter			= 5.5;
platformHeightAdd				= 10;			// The height of the table can be increased by a positive number here
platformThickness				= 3;
platformPostDiameter			= 10;
platformPostReinforcementFudge	= 0.3;			// Post reinforcement diameter fudge factor for fit
platformPostReinforcementDiameter	= platformPostDiameter + 5 * 2; 
platformPostReinforcementHeight	= 10;



// DO NOT CHANGE THESE SETTINGS !
coilFormerWireSpaceThickness	= coilWireDiameter * (coilWiresNum + 0.5) + coilWireFudge;	// The space for the wire to fit in on the former

manifoldCorrection 				= .1;

coilUsableDiameter				= coilRadius * 2/3;
coilUsableLength				= coilRadius; 
coilFormerTotalThickness		= coilFormerWireSpaceThickness + coilFormerFlangeWidth * 2;
coilSpokeRotationAngles			= [22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5];
coilSpokeLength					= coilRadius - (coilUsableDiameter / 2) - 2.0;
coilSpokeDimensions				= [0.075 * coilRadius, coilSpokeLength, coilFormerTotalThickness];
coilSpokeOffset					= [0, (coilUsableDiameter + coilSpokeLength) / 2 + 1.0, 0];
coilFormerFlangeOffset			= [0, 0, (coilFormerWireSpaceThickness + coilFormerFlangeWidth) / 2];

coilOffset1						= [0, 			  0,   			   coilRadius / 2];
coilOffset2						= [coilOffset1[0], coilOffset1[1], - coilOffset1[2]];
coilRetainerDimensions			= [coilUsableLength + coilFormerTotalThickness + coilRetainerThickness * 2, coilRetainerWidth, coilRetainerDepth];
coilRetainerBlockDimensions		= [coilRetainerThickness, coilRetainerWidth, coilRetainerThickness];
coilRetainerBlockOffset1		= [(coilFormerTotalThickness + coilRetainerThickness) / 2,
								   0,
								  (coilRetainerDimensions[2] + coilRetainerBlockDimensions[2]) / 2]; 
coilRetainerBlockOffset2		= [- coilRetainerBlockOffset1[0], coilRetainerBlockOffset1[1], coilRetainerBlockOffset1[2]];
retainerAngleStep               = 30;
coilRetainerLocationAngles		= [-1.5 * retainerAngleStep, 1.5 * retainerAngleStep, 2.5 * retainerAngleStep, 3.5 * retainerAngleStep, 4.5 * retainerAngleStep];
coilRetainerLocationAnglesBlock	= [-retainerAngleStep / 2, retainerAngleStep / 2];
coilMountingBlockDimensions		= [coilRetainerDimensions[0], coilMountingBlockWidth, coilMountingBlockThickness];
coilMountingBlockOffset			= [0, 0, - (coilRadius + coilFormerFlangeHeight + coilMountingBlockDimensions[2] / 2) ];
mountingPostBlockWidth			= (coilRadius - (coilFormerWireSpaceThickness + coilFormerFlangeWidth)) - 4;
mountingPostBlockDimensions		= [mountingPostBlockWidth, mountingPostBlockThickness, mountingPostBlockHeight];
mountingPostBlockOffset			= [0, ( coilMountingBlockDimensions[1] - mountingPostBlockDimensions[1] ) / 2,
								   ( mountingPostBlockDimensions[2] + coilMountingBlockDimensions[2] ) / 2];
mountingPostOffset1				= [15, 0, 0]; 
mountingPostOffset2				= [-mountingPostOffset1[0], mountingPostOffset1[1], mountingPostOffset1[2]];
platformDimensions				= [mountingPostBlockWidth, coilUsableDiameter, platformThickness ];
platformOffset					= [0, 0, -(platformThickness / 2 + coilUsableDiameter / 2) + platformHeightAdd];
platformPostOffset				= [coilRadius * 0.25, 0, 0];

$fn = 80;


//coilRetainersAllFlat();
coilRetainersAll();
coilMountingBlock();
//platform();
fullHelmholtzCoil();

//coilHelmholtzFlat();


module platform()
{
	postHeight				= platformOffset[2] - coilMountingBlockOffset[2] + (coilMountingBlockDimensions[2] + platformThickness) / 2;
	postHeightOffset 		= coilMountingBlockOffset[2] + (postHeight - coilMountingBlockDimensions[2]) / 2;

	translate( platformOffset )
		cube( platformDimensions, center=true );

	translate( platformPostOffset )
		translate( [0, 0, postHeightOffset] )
			cylinder( r=platformPostDiameter / 2, h=postHeight, center=true );

	translate( -platformPostOffset )
		translate( [0, 0, postHeightOffset] )
			cylinder( r=platformPostDiameter / 2, h=postHeight, center=true );
}



module coilMountingBlock()
{
	postReinforcementOffsetZ	= coilMountingBlockOffset[2] + (coilMountingBlockDimensions[2] + platformPostReinforcementHeight) / 2;

	difference()
	{
		union()
		{
			translate( coilMountingBlockOffset )
			{
				cube( coilMountingBlockDimensions, center=true );

				translate( mountingPostBlockOffset )
					difference()
					{
						cube( mountingPostBlockDimensions, center=true );

						// Mounting post holes
						translate( mountingPostOffset1 )
							rotate( [90, 0, 0] )
								cylinder( r=mountingPostDiameter / 2, h = mountingPostBlockDimensions[1] + manifoldCorrection * 2, center=true );

						translate( mountingPostOffset2 )
							rotate( [90, 0, 0] )
								cylinder( r=mountingPostDiameter / 2, h = mountingPostBlockDimensions[1] + manifoldCorrection * 2, center=true );
					}
			}

			for ( coilRetainerLocationAngle = coilRetainerLocationAnglesBlock )
				rotate( [coilRetainerLocationAngle, 0, 0] )
					translate( [0, 0, -(coilRadius + coilFormerFlangeHeight + coilRetainerDimensions[2] / 2)] )
						coilRetainer();
			// Post reinforcement
			translate( platformPostOffset )
				translate( [0, 0, postReinforcementOffsetZ] )
					donut( outerRadius=platformPostReinforcementDiameter / 2,
						   innerRadius = platformPostDiameter / 2 + platformPostReinforcementFudge,
						   height=platformPostReinforcementHeight );

			translate( -platformPostOffset )
				translate( [0, 0, postReinforcementOffsetZ] )
					donut( outerRadius=platformPostReinforcementDiameter / 2,
						   innerRadius = platformPostDiameter / 2 + platformPostReinforcementFudge,
						   height=platformPostReinforcementHeight );
		}

		// Remove holes in coil mounting block for post reinforcement
		translate( platformPostOffset )
			translate( [0, 0, postReinforcementOffsetZ - coilMountingBlockDimensions[2] / 2] )
				cylinder( r=platformPostDiameter / 2 + platformPostReinforcementFudge,
					  	  h=coilMountingBlockDimensions[2] + platformPostReinforcementHeight + manifoldCorrection * 2,
					  	  center=true ); 

		translate( -platformPostOffset )
			translate( [0, 0, postReinforcementOffsetZ - coilMountingBlockDimensions[2] / 2] )
				cylinder( r=platformPostDiameter / 2 + platformPostReinforcementFudge,
					  	  h=coilMountingBlockDimensions[2] + platformPostReinforcementHeight + manifoldCorrection * 2,
					  	  center=true ); 
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
    rotate( [7, 0, 0] )
	rotate( [0, 90, 0] )
	{
		translate( coilOffset1 )
        rotate( [180, 0, 0] )
            helmholtzCoil();
		translate( coilOffset2 )
            helmholtzCoil();

		// Show the usable array grayed out
		// cylinder( r=coilUsableDiameter / 2, h=coilUsableLength, center = true );	
	}
}


module wireHole()
{
    // Account for Litz wire soldering. Make the radius twice larger.
    hole_radius = coilWireDiameter + coilWireFudge;
    trench_width = coilWireDiameter * coilLayersNum + coilWireFudge;
    h = coilFormerFlangeWidth + manifoldCorrection * 2;
    translate([trench_width / 2, 0, 0])
        intersection() {
            cylinder(r=trench_width / 2, h=h, center = true);
            cube([trench_width, 2 * hole_radius, h], center=true);
        }
}


module coilHelmholtzFlat()
{
    helmholtzCoil();
}



module helmholtzCoil()
{
	coilOuterRingThickness = coilOuterRingPercentage * coilRadius;

	difference()
	{
		union()
		{
			// Print the inside outer ring (where the coil gets wrapped around)
			donut( outerRadius=coilRadius, innerRadius = coilOuterRingThickness, height=coilFormerWireSpaceThickness ); 

			// Print the inside inner ring (where the inside marks the usable volume)
			donut( outerRadius=coilUsableDiameter / 2 + coilUsableDiameter * coilInnerRingPercentage,
				   innerRadius = coilUsableDiameter / 2,
			 	   height=coilFormerTotalThickness ); 
	
			// Print the coil top outer ring retainer
			//color( [1, 0, 0] )
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


		translate( [coilRadius, 0, (coilFormerWireSpaceThickness + coilFormerFlangeWidth) / 2] )
			%wireHole();
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
	

