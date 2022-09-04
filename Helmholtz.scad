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

wireDiamNominal                 = 1.2;
wireDiam				        = wireDiamNominal + 0.1;		// Wire diameter in mm's, note this includes insulation (insulation thickness varies)
windingFudge			= 0.3;		// Fudge factor in mm's to add to the space for the coil to allow for 3D printer inaccuracy	
coilWindingWidth	            = wireDiam * (coilWiresNum + 0.5) + windingFudge;	// The space for the wire to fit in on the former
coilWindingHeight               = wireDiam * coilLayersNum;
coilWindingRadiusInner          = coilRadius - coilWindingHeight / 2;
coilFlangeHeightPad             = 3.0;
coilFlangeHeight			    = coilWindingHeight / 2 + coilFlangeHeightPad;
coilFlangeWidth		        	= 3.0;		// The width of the flange

// These settings effect parts of the total object
retainerThickness			= 4;
retainerWidth				= 10;
retainerDepth				= 7;

platformThickness		= 7;
platformWidth			= 1.5 * coilRadius;		// It would make sense to make this wide enough to place the mounting posts outside of the coil for magnetic field uniformity reasons

wallUserHeight			= 20;
wallUserThickness		= 4;
wallUserHoleDiam		= 5.5;

tableHeightAdd				= 10;			// The height of the table can be increased by a positive number here
tableThickness				= 3;
tablePostDiameter			= 10;
cylinderReinforcementFudge	= 0.3;			// Post reinforcement diameter fudge factor for fit
cylinderReinforcementDiameter	= tablePostDiameter + 5 * 2; 
cylinderReinforcementHeight	= 10;



manifoldCorrection 				= .1;

coilHomogeneousDiam				= coilRadius * 2/3;
coilTotalThickness		= coilWindingWidth + coilFlangeWidth * 2;




retainerPlatformLength = coilRadius + coilTotalThickness + retainerThickness * 2;



retainerAngleStep           = 30;
retainerLocationAngles		= [-1.5 * retainerAngleStep, 1.5 * retainerAngleStep, 2.5 * retainerAngleStep, 3.5 * retainerAngleStep, 4.5 * retainerAngleStep];
retainerLocationAnglesBlock	= [-retainerAngleStep / 2, retainerAngleStep / 2];

platformOffsetZ			= - (coilRadius + coilFlangeHeight + platformThickness / 2);
wallUserWidth			= (coilRadius - (coilWindingWidth + coilFlangeWidth)) - 4;


wallUserHoleOffset		    = 15; 


tablePostOffset				= [coilRadius * 0.25, 0, 0];

$fn = 80;


//retainersAllFlat();
//retainersAll();
platform();
//platformTable();
fullHelmholtzCoil();

//coilHelmholtzFlat();


module platformTable()
{
    tableOffset				= [0, 0, -(tableThickness / 2 + coilHomogeneousDiam / 2) + tableHeightAdd];
	postHeight				= tableOffset[2] - platformOffsetZ + (platformThickness + tableThickness) / 2;
	postHeightOffset 		= platformOffsetZ + (postHeight - platformThickness) / 2;
    
    tableDimensions			= [wallUserWidth, coilHomogeneousDiam, tableThickness ];

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
	postReinforcementOffsetZ = platformOffsetZ + (platformThickness + cylinderReinforcementHeight) / 2;
    
    retainerFaceY = (coilRadius + coilFlangeHeight) * sin(retainerLocationAnglesBlock[1]);
    
    // Wire hooks
    hookRadius = 2 * wireDiam + windingFudge;
    
    module wallUser()
    {
        wallUserOffset = [0, ( platformWidth - wallUserThickness ) / 2, ( wallUserHeight + platformThickness ) / 2 - manifoldCorrection];
        
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
        
        translate([0, retainerFaceY + (platformWidth / 2 - retainerFaceY) / 2, platformThickness / 2 - manifoldCorrection])
        rotate([90, 0, 0])
        torus(hookRouter, hookHalfWidth, 180);
    }
    
    module platformRetainer(angle, hole=false)
    {
        rotate( [angle, 0, 0] )
        translate( [0, 0, -(coilRadius + coilFlangeHeight + retainerDepth / 2)] )
        retainer();
    }
    
    module tableReinforcement()
    {
        translate( [0, 0, postReinforcementOffsetZ] )
        donut( outerRadius=cylinderReinforcementDiameter / 2,
           innerRadius = tablePostDiameter / 2 + cylinderReinforcementFudge,
           height=cylinderReinforcementHeight );
    }
    
    module reinforcementFloorCut()
    {
        translate( [0, 0, postReinforcementOffsetZ - platformThickness / 2] )
        cylinder( r=tablePostDiameter / 2 + cylinderReinforcementFudge,
                  h=platformThickness + cylinderReinforcementHeight + manifoldCorrection * 2,
                  center=true ); 
    }

    module platformFilled()
    {
        union()
		{
			translate( [0, 0, platformOffsetZ] )
			{
				cube( [retainerPlatformLength, platformWidth, platformThickness], center=true );
                wallUser();
                wireHooks();
			}
            
            platformRetainer(retainerLocationAnglesBlock[0]);
            difference() {
                platformRetainer(retainerLocationAnglesBlock[1]);
                translate( [0, 0, platformOffsetZ] )
                translate([0, retainerFaceY, platformThickness / 2 + hookRadius / 2 - manifoldCorrection])
                cube([2 * hookRadius, retainerWidth * 2, hookRadius], center=true);
            }
   
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



module retainersAllFlat()

{
    coilNumRetainers = len(retainerLocationAngles);
    retainersPad = 3.0;
	for ( retainerNum = [1:coilNumRetainers] )
			translate( [0, retainerNum * (retainerWidth + retainersPad), 0] )
				retainer();
}



module retainersAll()

{
	for ( angle = retainerLocationAngles ) {
		rotate( [angle, 0, 0] )
        translate( [0, 0, -(coilRadius + coilFlangeHeight + retainerDepth / 2)] )
        retainer();
    }
}



module retainer()
{
	cube( [retainerPlatformLength, retainerWidth, retainerDepth], center=true );
	translate( [coilRadius / 2, 0, 0] )
		retainerBlocks();
	translate( [-coilRadius / 2, 0, 0] )
		retainerBlocks();
}


module retainerBlocks()
{
    retainerBlockDimensions		= [retainerThickness, retainerWidth, retainerThickness];
    
    retainerBlockOffset1		= [(coilTotalThickness + retainerThickness) / 2, 0, (retainerDepth + retainerThickness) / 2];
    retainerBlockOffset2		= [- coilTotalThickness, retainerBlockOffset1[1], retainerBlockOffset1[2]];
    
	translate( retainerBlockOffset1 )
		cube( retainerBlockDimensions, center=true );

	translate( retainerBlockOffset2 )
		cube( retainerBlockDimensions, center=true );
}



module fullHelmholtzCoil()
{
	rotate( [0, 90, 0] )
	{
		translate( [0, 0, coilRadius / 2] )
        rotate( [180, 0, 0] )
            *helmholtzCoil();
		translate( [0, 0, -coilRadius / 2] )
            %helmholtzCoil();

		// Show the usable array grayed out
		// cylinder( r=coilHomogeneousDiam / 2, h=coilRadius, center = true );	
	}
}



module coilHelmholtzFlat()
{
    helmholtzCoil();
}



module helmholtzCoil()
{
    coilOuterRingThickness = 0.15 * coilWindingRadiusInner;
    coilInnerRingThickness = 0.2 * coilHomogeneousDiam;
    
    coilOuterRingBottomRadius = coilWindingRadiusInner - coilOuterRingThickness;
    
    coilSpokeLength				= coilWindingRadiusInner - coilOuterRingThickness / 2 - coilHomogeneousDiam / 2 - coilInnerRingThickness / 2;

    coilSpokeOffset				= [0, (coilHomogeneousDiam + coilSpokeLength + coilInnerRingThickness) / 2, 0];
    
    coilFlangeOffset			= [0, 0, (coilWindingWidth + coilFlangeWidth) / 2];
    
    module coilWireHole()
    {
        // Account for Litz wire soldering. Make the radius twice larger.
        hole_radius = wireDiam + windingFudge;
        trench_width = wireDiam * coilLayersNum + windingFudge;
        h = coilFlangeWidth + manifoldCorrection * 2;
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
			donut( outerRadius=coilWindingRadiusInner, innerRadius = coilOuterRingBottomRadius, height=coilWindingWidth ); 

			// Print the inside inner ring (where the inside marks the usable volume)
			donut( outerRadius=coilHomogeneousDiam / 2 + coilInnerRingThickness,
				   innerRadius = coilHomogeneousDiam / 2,
			 	   height=coilTotalThickness ); 
	
			// Print the coil top outer ring retainer
			{
				translate( coilFlangeOffset )
					donut( outerRadius=coilRadius + coilFlangeHeight,
						   innerRadius = coilOuterRingBottomRadius,
						   height=coilFlangeWidth );

				// Print the coil bottom outer ring retainer
				translate( -coilFlangeOffset )
					donut( outerRadius=coilRadius + coilFlangeHeight,
						   innerRadius = coilOuterRingBottomRadius,
						   height=coilFlangeWidth ); 
			}
            
            coilSpokeNum = 8;
            coilSpokeAngleStep = 360 / coilSpokeNum;
            coilSpokeAngleStart = coilSpokeAngleStep / 2;
            coilSpokeDimensions	= [0.075 * coilRadius, coilSpokeLength, coilTotalThickness];

			for ( angle = [coilSpokeAngleStart:coilSpokeAngleStep:360-coilSpokeAngleStart] ) {
				rotate( [0, 0, angle] )
                translate( coilSpokeOffset )
                cube( coilSpokeDimensions, center=true);
            }
		}


		translate( [coilRadius, 0, (coilWindingWidth + coilFlangeWidth) / 2] )
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
	

