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
coilFlangeHeightPad             = 3.0;
coilFlangeWidth		        	= 3.0;		// The width of the flange

// Bottom winding begins
coilWindingRadiusInner          = coilRadius - coilWindingHeight / 2;

// Physical size of the coil
coilFlangeRadius                = coilWindingRadiusInner + coilWindingHeight + coilFlangeHeightPad;

coilHomogeneousDiam				= coilRadius * 2/3;
coilTotalThickness		= coilWindingWidth + coilFlangeWidth * 2;


coilOuterRingThickness = 0.15 * coilWindingRadiusInner;
coilInnerRingThickness = 0.3 * coilHomogeneousDiam;

coilOuterRingBottomRadius = coilWindingRadiusInner - coilOuterRingThickness;

coilHomogeneousCenterRadius = coilHomogeneousDiam / 2 + coilInnerRingThickness / 2;

// These settings effect parts of the total object
retainerCoilHolderThickness	= 5;
retainerCoilHolderHeight    = (coilFlangeRadius - coilOuterRingBottomRadius) / 2;
retainerWidth				= 10;
retainerDepth				= 7;

platformThickness		= 7;
platformWidth			= 1.5 * coilRadius;		// It would make sense to make this wide enough to place the mounting posts outside of the coil for magnetic field uniformity reasons

wallUserHeight			= 20;
wallUserThickness		= 4;
wallUserHoleDiam		= 5.5;

tableThickness				= coilInnerRingThickness;
tablePostDiameter			= 10;


manifoldCorrection 				= .1;

cylinderReinforcementFudge	= 0.3;
cylinderReinforcementDiameter	= tablePostDiameter + 5 * 2; 
cylinderReinforcementHeight	= 10;


retainerPlatformLength = coilRadius + coilTotalThickness + retainerCoilHolderThickness * 2;

retainerAngleStep           = 30;
retainerLocationAngles		= [-1.5 * retainerAngleStep, 1.5 * retainerAngleStep, 2.5 * retainerAngleStep, 3.5 * retainerAngleStep, 4.5 * retainerAngleStep];
retainerLocationAnglesBlock	= [-retainerAngleStep / 2, retainerAngleStep / 2];

platformOffsetZ			= - (coilFlangeRadius + platformThickness / 2);


retainerFaceY = coilFlangeRadius * sin(0.5 * retainerAngleStep);
retainerFaceYOutside = coilFlangeRadius * sin(retainerAngleStep);

TABLE_INSIDE = coilRadius >= 150;
tablePostOffsetX = 0.2 * coilRadius;
tablePostOffsetY = TABLE_INSIDE ? retainerFaceY / 2 : retainerFaceYOutside;
tableOffsetZ			= -(tableThickness / 2 + coilHomogeneousDiam / 2) + 0.15 * coilHomogeneousDiam;

tableCoilPad            = 3;
tableWidth              = retainerPlatformLength - 2 * (coilTotalThickness + 2 * retainerCoilHolderThickness + tableCoilPad);
tableHoleY              = sqrt(pow(coilHomogeneousCenterRadius, 2) - pow(tableOffsetZ, 2));
tableHoleSize = tableThickness / (2 * sqrt(2));


coilTableSupportLen = retainerPlatformLength;

wallUserWidth		= tableWidth;
wallUserHoleOffset		    = 15; 


$fn = 80;


//retainersAllFlat();
retainersAll();
platform();
platformTable();
fullHelmholtzCoil();

//coilHelmholtzFlat();

drawCoilTableSupportOnScene();


module drawCoilTableSupportOnScene() {
    for (flipY = [-1, 1]) {
        translate([0, flipY * tableHoleY, tableOffsetZ])
        drawCoilTableSupport(length=coilTableSupportLen + 20, fudge=-0.4);
    }
}


module drawCoilTableSupport(length=coilTableSupportLen, fudge=0) {
    rotate([45, 0, 0])
    cube([length + 2 * manifoldCorrection, tableHoleSize + fudge, tableHoleSize + fudge], center=true);
}


module platformTable()
{
	postHeight				= tableOffsetZ - platformOffsetZ + (platformThickness + tableThickness) / 2;
	postHeightOffset 		= platformOffsetZ + (postHeight - platformThickness) / 2;
    
    tableSizeY = max(coilHomogeneousDiam, 2 * tablePostOffsetY + 2 * cylinderReinforcementDiameter);
    
    tableDimensions			= [tableWidth, tableSizeY, tableThickness ];
    tableMaterialThickness  = 4;
    tableCutDimensions      = [tableDimensions[0] - 2 * tableMaterialThickness, tableDimensions[1] - 2 * tableMaterialThickness, tableDimensions[2] - 2 * tableMaterialThickness];
    
    echo(">>> tableMaterialThickness ", tableThickness);
    
    difference() {
        union() {
            translate( [0, 0, tableOffsetZ] )
            difference() {
                cube( tableDimensions, center=true );
                if (tableThickness >= 3 * tableMaterialThickness) {
                    cube( tableCutDimensions, center=true );
                }
            }

            for (flipY = [-1, 1]) {
                for (flipX = [-1, 1]) {
                    translate( [flipX * tablePostOffsetX, flipY * tablePostOffsetY, postHeightOffset] )
                    cylinder( r=tablePostDiameter / 2, h=postHeight - manifoldCorrection, center=true );
                }
            }
        }
        
        for (flipY = [-1, 1]) {
            translate([0, flipY * tableHoleY, tableOffsetZ])
            drawCoilTableSupport(fudge=0.2);
        }
    }

}


module platform()
{

	postReinforcementOffsetZ = platformOffsetZ + (platformThickness + cylinderReinforcementHeight) / 2;
    

    
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
        
        translate([0, retainerFaceYOutside, platformThickness / 2 - manifoldCorrection])
        rotate([90, 0, 0])
        torus(hookRouter, hookHalfWidth, 180);
    }
    
    module platformRetainer(angle, hole=false)
    {
        rotate( [angle, 0, 0] )
        translate( [0, 0, -(coilFlangeRadius + retainerDepth / 2)] )
        retainer();
    }
    
    module drawPlatformRetainers()
    {
        platformRetainer(retainerLocationAnglesBlock[0]);
        difference() {
            platformRetainer(retainerLocationAnglesBlock[1]);
            translate( [0, 0, platformOffsetZ] )
            translate([0, retainerFaceY, platformThickness / 2 + hookRadius / 2 - manifoldCorrection])
            cube([2 * hookRadius, retainerWidth * 2, hookRadius], center=true);
        }
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
    
    module postReinforcement(reinforce)
    {
        for (flipX = [-1, 1]) {
            for (flipY = [-1, 1]) {
                translate( [flipX * tablePostOffsetX, flipY * tablePostOffsetY, 0] )
                if (reinforce) {
                    tableReinforcement();
                }
                else {
                    reinforcementFloorCut();
                }
            }
        }
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
            
            drawPlatformRetainers();
   
			// Post reinforcement
            postReinforcement(true);
		}
    }

	difference()
	{
		platformFilled();

		// Remove holes in coil mounting block for post reinforcement
        postReinforcement(false);
	}
}



module retainersAllFlat()

{
    coilNumRetainers = len(retainerLocationAngles);
    retainersPad = 3.0;
	for ( retainerNum = [1:coilNumRetainers] ) {
        translate( [0, retainerNum * (retainerWidth + retainersPad), 0] )
        retainer();
    }
}



module retainersAll()

{
	for ( angle = retainerLocationAngles ) {
		rotate( [angle, 0, 0] )
        translate( [0, 0, -(coilFlangeRadius + retainerDepth / 2)] )
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
    retainerBlockDimensions		= [retainerCoilHolderThickness - 2 * manifoldCorrection, retainerWidth, retainerCoilHolderHeight];
    
    retainerBlockOffset1		= [(coilTotalThickness + retainerCoilHolderThickness) / 2, 0, (retainerDepth + retainerCoilHolderHeight) / 2];
    retainerBlockOffset2		= [- retainerBlockOffset1[0], retainerBlockOffset1[1], retainerBlockOffset1[2]];
    
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
        helmholtzCoil();

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
   
    coilSpokeLength				= coilWindingRadiusInner - coilOuterRingThickness / 2 - coilHomogeneousDiam / 2 - coilInnerRingThickness / 2;

    coilSpokeOffset				= [0, (coilHomogeneousDiam + coilSpokeLength + coilInnerRingThickness) / 2, 0];
    
    coilFlangeOffset			= [0, 0, (coilWindingWidth + coilFlangeWidth) / 2];
    
    module coilWireHole()
    {
        // Account for Litz wire soldering. Make the radius twice larger.
        holeRadius = wireDiam + windingFudge;
        trenchWidth = wireDiam * coilLayersNum + windingFudge;
        h = coilFlangeWidth + manifoldCorrection * 2;
        translate([trenchWidth / 2, 0, 0])
        intersection() {
            cylinder(r=trenchWidth / 2, h=h, center = true);
            cube([trenchWidth, 2 * holeRadius, h], center=true);
        }
    }


    module drawCoilSolid()
    {
        union()
		{
			// Print the outer ring (where the coil gets wrapped around)
			donut( outerRadius=coilWindingRadiusInner, innerRadius = coilOuterRingBottomRadius, height=coilWindingWidth ); 

			// Print the inner ring (homogeneous volume)
			donut( outerRadius=coilHomogeneousDiam / 2 + coilInnerRingThickness,
				   innerRadius = coilHomogeneousDiam / 2,
			 	   height=coilTotalThickness ); 
	
			// Print left and right coil flanges
			{
				translate( coilFlangeOffset )
					donut( outerRadius=coilFlangeRadius,
						   innerRadius = coilOuterRingBottomRadius,
						   height=coilFlangeWidth );

				translate( -coilFlangeOffset )
					donut( outerRadius=coilFlangeRadius,
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
            
            drawCoilTableReinforcement();
		}
    }
    
    module drawCoilTableReinforcement() {
        cubeReinforcementSize = 0.6 * coilInnerRingThickness;
        
        for (flipZ = [-1, 1]) {
            for (flipY = [-1, 1]) {
                translate([-tableOffsetZ, flipY * tableHoleY, flipZ * (coilTotalThickness / 2 + retainerCoilHolderThickness / 2 - manifoldCorrection)])
                rotate([0, 0, 45])
                cube([cubeReinforcementSize, cubeReinforcementSize, retainerCoilHolderThickness], center=true);
            }
        }
    }


	difference()
	{
        drawCoilSolid();
        
		translate( [coilWindingRadiusInner, 0, (coilWindingWidth + coilFlangeWidth) / 2] )
        coilWireHole();
        
        for (flipY = [-1, 1]) {
            translate([-tableOffsetZ, flipY * tableHoleY, 0])
            rotate([0, 90, 0])
            drawCoilTableSupport();
        }
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
	

