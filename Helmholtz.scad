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

FUDGE_SIDE                      = 0.3;
COIL_RADIUS_REFERENCE           = 130;
SCALE_FACTOR                    = coilRadius / COIL_RADIUS_REFERENCE;
SCALE_FACTOR_SQRT               = getScaleFactor();

wireDiamNominal                 = 1.2;
wireDiam				        = wireDiamNominal + 0.1;		// Wire diameter in mm's, note this includes insulation (insulation thickness varies)
windingFudge			= FUDGE_SIDE;		// Fudge factor in mm's to add to the space for the coil to allow for 3D printer inaccuracy	
coilWindingWidth	            = wireDiam * (coilWiresNum + 0.5) + windingFudge;	// The space for the wire to fit in on the former
coilWindingHeight               = wireDiam * coilLayersNum;
coilFlangeHeightPad             = 3.0;
coilFlangeWidth		        	= max(2.0, 3.0 * SCALE_FACTOR_SQRT);

// Bottom winding begins
coilWindingRadiusInner          = coilRadius - coilWindingHeight / 2;

// Physical size of the coil
coilFlangeRadius                = coilWindingRadiusInner + coilWindingHeight + coilFlangeHeightPad;

coilHomogeneousDiam				= coilRadius * 2/3;
coilTotalThickness		= coilWindingWidth + coilFlangeWidth * 2;


coilOuterRingThickness = 0.15 * coilWindingRadiusInner;
coilInnerRingThickness = 0.3 * coilHomogeneousDiam;

coilOuterRingBottomRadius = coilWindingRadiusInner - coilOuterRingThickness;

coilHomogeneousRingCenterRadius = coilHomogeneousDiam / 2 + coilInnerRingThickness / 2;

coilFlangeOffset			= [0, 0, (coilWindingWidth + coilFlangeWidth) / 2];

// These settings effect parts of the total object
retainerCoilHolderThickness	= max(2.0, 5.0 * SCALE_FACTOR);
retainerCoilHolderHeight    = (coilFlangeRadius - coilOuterRingBottomRadius) / 2;
retainerWidth				= max(4.0, 10.0 * SCALE_FACTOR);
retainerDepth				= max(2.0, 7.0 * SCALE_FACTOR_SQRT);

platformThickness		= 7.0 * SCALE_FACTOR_SQRT;
platformLength			= 2.0 * coilFlangeRadius;

wallUserThickness		= max(3.0, 4.0 * SCALE_FACTOR_SQRT);
wallUserHoleDiam		= 4.5 + FUDGE_SIDE;  // M4 nut

tableThickness				= coilInnerRingThickness;
pillarDiam			= 10 * SCALE_FACTOR_SQRT;


manifoldCorrection 				= .1;

cylinderReinforcementFudge	= FUDGE_SIDE;
cylinderReinforcementDiameter	= pillarDiam + 10 * SCALE_FACTOR_SQRT; 
cylinderReinforcementHeight	= 10 * SCALE_FACTOR_SQRT;

retainerLength         = coilRadius + coilTotalThickness + 2 * retainerCoilHolderThickness;

platformPad            = 10 * SCALE_FACTOR_SQRT;
platformWidth         = retainerLength + 2 * platformPad;

retainerAngleStep           = 30;
retainerLocationAngles		= [-1.5 * retainerAngleStep, 1.5 * retainerAngleStep, 2.5 * retainerAngleStep, 3.5 * retainerAngleStep, 4.5 * retainerAngleStep];
retainerLocationAnglesBlock	= [-retainerAngleStep / 2, retainerAngleStep / 2];

platformCenterZ			= - (coilFlangeRadius + platformThickness / 2);


retainerCenterY = coilFlangeRadius * sin(0.5 * retainerAngleStep);
pillarOutsideCenterY = coilFlangeRadius * sin(retainerAngleStep);

TABLE_INSIDE = coilRadius >= 150;
pillarCenterX = getPillarCenterX();
pillarCenterY = TABLE_INSIDE ? retainerCenterY / 2 : pillarOutsideCenterY;
tableCenterZ			= -(tableThickness / 2 + coilHomogeneousDiam / 2) + 0.15 * coilHomogeneousDiam;

tableCoilPad            = max(1.0, 3.0 * SCALE_FACTOR_SQRT);
tableWidth              = retainerLength - 2 * (coilTotalThickness + 2 * retainerCoilHolderThickness + tableCoilPad);
tableHoleY              = sqrt(pow(coilHomogeneousRingCenterRadius, 2) - pow(tableCenterZ, 2));
tableHoleSize = tableThickness / (2 * sqrt(2));


HorizontalBarSupportLen = retainerLength;
HorizontalBarSupportLenPadded = HorizontalBarSupportLen + 20 * SCALE_FACTOR_SQRT;

tablePillarPad = tableThickness / 3;

pillarHeight				= tableCenterZ - platformCenterZ + (platformThickness + tableThickness) / 2 - tablePillarPad;
pillarCenterZ 		= platformCenterZ + (pillarHeight - platformThickness) / 2;

pillarRadius = pillarDiam / 2;
pillarMaterialThickness = max(2.0, pillarRadius * 0.35);
pillarRadiusCut = pillarRadius - pillarMaterialThickness;

$fn = 80;

function getScaleFactor() = coilRadius > COIL_RADIUS_REFERENCE ? pow(SCALE_FACTOR, 0.75) : SCALE_FACTOR;

function getPillarCenterX() = let (centerX = 0.5 * (coilRadius / 2 - coilTotalThickness / 2 - retainerCoilHolderThickness)) centerX > 1.5 * cylinderReinforcementDiameter ? centerX : 0;

function getPillarFlipSingsX() = pillarCenterX > 0 ? [-1, 1] : [1];


partnum = 0;

if (partnum == 0) {
    echo(">>> Physical coil diameter (same as platform length) ", 2 * coilFlangeRadius);
    echo(">>> Platform width ", platformWidth);

    drawPlatform();
    drawPlatformTable();
    drawRetainersOnScene();
    drawHelmholtzCoilsOnScene();
    drawHorizontalBarSupportOnScene();
    drawTablePillarsOnScene();
}

/* FLAT COILS */
if (partnum == 1) bottomHalfHelmholtzCoil();
if (partnum == 2) topHalfHelmholtzCoil();
if (partnum == 3) drawHelmholtzCoilFlat();

/* FLAT REST OF THE MODELS */
if (partnum == 4) drawHorizontalBarSupportFlat();
if (partnum == 5) drawRetainersFlat();
if (partnum == 6) drawTablePillarsFlat();
if (partnum == 7) drawPlatformTableFlat();
if (partnum == 8) drawPlatformFlat();

if (partnum == 9) drawTestParts();


module drawPlatformTableFlat() {
    rotate([180, 0, 0])
    translate([0, 0, -tableCenterZ])
    drawPlatformTable();
}


module drawPlatformFlat() {
    translate([0, 0, -platformCenterZ])
    drawPlatform();
}


module drawTestParts() {
    
    module testCoilHorizontalBarReinforcement() {
        testLength = coilTotalThickness / 2 + retainerCoilHolderThickness;
        
        translate([30, 20, 0])
        intersection() {
            rotate([0, 0, 45])
            translate([tableCenterZ, -tableHoleY, 0])
            helmholtzSingleCoil();
            
            cube([0.55 * coilInnerRingThickness, 0.55 * coilInnerRingThickness, testLength], center=true);
        }
        
        translate([0, -30, 0])
        rotate([-45, 0, 0])
        drawHorizontalBarSupport(length=testLength);
    }
    
    module testWireHook() {
        translate([0, 20, -platformCenterZ])
        intersection() {
            drawPlatform();
            
            translate( [0, 0, platformCenterZ + platformThickness] )
            cube( [10, 20, 12], center=true );
        }
    }
    
    module testReinforcementCylinderAndPillar() {
        cylinderThickness = cylinderReinforcementDiameter / 2 - pillarDiam / 2;
        cylinderRadius = cylinderReinforcementDiameter / 2 - cylinderThickness / 2;
        translate([0, 50, 0])
        drawReinforcementCylinder(outerRadius=cylinderRadius);
        
        translate([0, -15, 0])
        intersection() {
            drawPillar();
            cube([pillarDiam, pillarDiam, cylinderReinforcementHeight], center=true);
        }
    }
    
    module testCoilRetainer() {
        translate([30, 0, 0])
        rotate([90, 0, 0])
        intersection() {
            translate([coilRadius / 2, 0, 0])
            drawRetainer();
            translate([0, 0, retainerCoilHolderHeight / 2 + retainerCoilHolderThickness / 2])
            cube([coilTotalThickness + retainerCoilHolderThickness + 2 * FUDGE_SIDE, retainerWidth, retainerCoilHolderHeight + retainerCoilHolderThickness], center=true);
        }
    }
    
    module testCoilHalfer() {
        cutSize = [30, 50, 50];
        
        translate([-40, coilRadius, 0])
        intersection() {
            bottomHalfHelmholtzCoil();
            translate([0, -coilRadius, 0])
            cube(cutSize, center=true);
        }
        
        translate([0, 65, 0])
        intersection() {
            topHalfHelmholtzCoil();
            translate([0, -coilRadius, 0])
            cube(cutSize, center=true);
        }
    }
    
    module testWallBananaPlugHole() {
        bananaPlugWallSpace = 1.5;
        translate([-20, -20, 0])
        difference() {
            cube([wallUserHoleDiam + 2 * bananaPlugWallSpace, wallUserHoleDiam + 2 * bananaPlugWallSpace, wallUserThickness], center=true);
            cylinder(r=wallUserHoleDiam / 2, h = wallUserThickness + 2 * manifoldCorrection, center = true);
        }
    }
    
    testCoilHorizontalBarReinforcement();
    testWireHook();
    testReinforcementCylinderAndPillar();
    testCoilRetainer();
    testCoilHalfer();
    testWallBananaPlugHole();
}


module drawHorizontalBarSupportFlat(extraCount=2) {
    for (i = [1 : 2 + extraCount]) {
        translate([0, i * 1.5 *  tableHoleSize, 0])
        rotate([-45, 0, 0])
        drawHorizontalBarSupport(length=HorizontalBarSupportLenPadded);
    }
    
}


module drawHorizontalBarSupportOnScene() {
    for (flipY = [-1, 1]) {
        translate([0, flipY * tableHoleY, tableCenterZ])
        drawHorizontalBarSupport(length=HorizontalBarSupportLenPadded);
    }
}


module drawHorizontalBarSupport(length=HorizontalBarSupportLen, fudge=0) {
    rotate([45, 0, 0])
    cube([length + 2 * manifoldCorrection, tableHoleSize + fudge, tableHoleSize + fudge], center=true);
}


module drawPillar() {
    if (pillarRadiusCut >= 1) {
        donut(outerRadius=pillarRadius, innerRadius=pillarRadiusCut, height=pillarHeight);
    } else {
        cylinder(r=pillarRadius, h=pillarHeight, center=true);
    }
}


module drawTablePillarsFlat() {
    for (flipX = getPillarFlipSingsX()) {
        for (i = [1, 2]) {
            translate( [0, flipX * i * (3 * pillarRadius), 0] )
            rotate([0, 90, 0])
            drawPillar();
        }
    }
}


module drawTablePillarsOnScene() {
    for (flipX = getPillarFlipSingsX()) {
        for (flipY = [-1, 1]) {
            translate( [flipX * pillarCenterX, flipY * pillarCenterY, pillarCenterZ] )
            drawPillar();
        }
    }
}


module drawPlatformTable()
{

    tableSizeY = max(coilHomogeneousDiam + 2 * coilInnerRingThickness, 2 * pillarCenterY + 2 * cylinderReinforcementDiameter);
    
    tableDimensions			= [tableWidth, tableSizeY, tableThickness ];
    tableMaterialThickness  = 4.0;
    tableCutDimensions      = [tableDimensions[0] - 2 * tableMaterialThickness, 2 * pillarCenterY - cylinderReinforcementDiameter, tableDimensions[2] - 2 * tableMaterialThickness];
    
    module postReinforcement(reinforce)
    {
        for (flipX = getPillarFlipSingsX()) {
            for (flipY = [-1, 1]) {
                translate( [flipX * pillarCenterX, flipY * pillarCenterY, 0] )
                if (reinforce) {
                    translate( [0, 0, tableCenterZ - tableThickness / 2 - cylinderReinforcementHeight / 2 + manifoldCorrection] )
                    drawReinforcementCylinder();
                }
                else {
                    translate( [0, 0, tableCenterZ - tableThickness / 6] )
                    reinforcementFloorCut();
                }
            }
        }
    }
    
    module reinforcementFloorCut()
    {
        cylinder( r=pillarDiam / 2 + cylinderReinforcementFudge,
                  h=tableThickness - tablePillarPad + 2 * FUDGE_SIDE,
                  center=true ); 
    }
  
    difference() {
        union() {
            translate( [0, 0, tableCenterZ] )
            difference() {
                cube( tableDimensions, center=true );
                if (tableThickness >= 3 * tableMaterialThickness) {
                    cube( tableCutDimensions, center=true );
                }
            }
            
            postReinforcement(true);
        }
        
        postReinforcement(false);
        
        for (flipY = [-1, 1]) {
            translate([0, flipY * tableHoleY, tableCenterZ])
            drawHorizontalBarSupport(fudge=2 * FUDGE_SIDE);
        }
    }

}


module drawReinforcementCylinder(outerRadius=cylinderReinforcementDiameter / 2)
{
    donut( outerRadius=outerRadius,
       innerRadius = pillarDiam / 2 + cylinderReinforcementFudge,
       height=cylinderReinforcementHeight );
}


module drawPlatform()
{
	postReinforcementOffsetZ = platformCenterZ + (platformThickness + cylinderReinforcementHeight) / 2;
    
    // Wire hooks
    hookRadius = 2 * wireDiam + windingFudge;
    
    module wallUser()
    {
        wallUserHoleCenterX = 15;
        wallUserPad = max(10.0, 20.0 * SCALE_FACTOR);
        wallUserWidth = 2 * wallUserHoleCenterX + wallUserHoleDiam + 2 * wallUserPad;
        wallUserHeight = max(15.0, 20.0 * SCALE_FACTOR_SQRT);
        
        wallUserOffset = [0, ( platformLength - wallUserThickness ) / 2, ( wallUserHeight + platformThickness ) / 2 - manifoldCorrection];
        
        translate( wallUserOffset )
        difference()
        {
            cube( [wallUserWidth, wallUserThickness, wallUserHeight], center=true );
            holeHeight = wallUserThickness + manifoldCorrection * 2;

            // Mounting post holes
            translate( [wallUserHoleCenterX, 0, 0] )
                rotate( [90, 0, 0] )
                    cylinder( r=wallUserHoleDiam / 2, h = holeHeight, center=true );

            translate( [-wallUserHoleCenterX, 0, 0] )
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
        
        module hook(posX)
        {
            translate([posX, 0, platformThickness / 2 - manifoldCorrection])
            rotate([90, 0, 90])
            union() {
                torus(hookRouter, hookHalfWidth, hookAngle);
                translate([hookRouter * cos(hookAngle), hookRouter * sin(hookAngle), 0])
                sphere(r=hookHalfWidth);
            }
        }
        
        hookThickness = 4.0;
        hookHalfWidth = hookThickness / 2;
        padToCoil = 4.0;
        hooksNum = floor(5 * SCALE_FACTOR_SQRT);
        hookRouter = hookRadius + hookHalfWidth;
        rangeUsable = coilRadius - 2 * (coilTotalThickness / 2 + padToCoil + hookHalfWidth);
        
        // tight firmly
        hookAngle = 180 - asin((wireDiamNominal + hookHalfWidth) / hookRouter);
        
        if (rangeUsable > hookThickness) {
            hook(0);
        }
        
        if (hooksNum > 1) {
            rangeStep = rangeUsable / (hooksNum - 1);
            for (x = [-rangeUsable/2:rangeStep:rangeUsable/2]) {
                hook(x);
            }
        }
        
        enoughSpaceBetweenPillarsHoriz = 2 * hookRouter + hookThickness < 2 * pillarCenterX - cylinderReinforcementDiameter;
        
        if (enoughSpaceBetweenPillarsHoriz || TABLE_INSIDE) {
            // Wall user hook fits on the platform
            translate([0, pillarOutsideCenterY, platformThickness / 2 - manifoldCorrection])
            rotate([90, 0, 0])
            torus(hookRouter, hookHalfWidth, 180);
        }
        
        spaceToWall = platformLength / 2 - wallUserThickness / 2 - pillarOutsideCenterY - cylinderReinforcementDiameter / 2;

        if (spaceToWall > 30) {
            translate([0, pillarOutsideCenterY + cylinderReinforcementDiameter / 2 + spaceToWall / 3, platformThickness / 2 - manifoldCorrection])
            rotate([90, 0, 0])
            torus(hookRouter, hookHalfWidth, 180);
        }
    }
    
    module platformRetainer(angle, hole=false)
    {
        depthMax = coilFlangeRadius / cos(angle) - coilFlangeRadius + retainerWidth / 2 * tan(abs(angle));
        depth = max(retainerDepth, depthMax);
        intersection() {
            rotate( [angle, 0, 0] )
            translate( [0, 0, -(coilFlangeRadius + depth / 2)] )
            drawRetainer(length=platformWidth - 2 * manifoldCorrection, depth=depth);
            
            translate([0, 0, platformCenterZ / 2])
            cube( [platformWidth, platformLength, abs(platformCenterZ)], center=true );
        }
    }
    
    module drawPlatformRetainers()
    {
        platformRetainer(retainerLocationAnglesBlock[0]);
        difference() {
            platformRetainer(retainerLocationAnglesBlock[1]);
            translate( [0, 0, platformCenterZ] )
            translate([0, retainerCenterY, platformThickness / 2 + hookRadius / 2 - manifoldCorrection])
            cube([2 * hookRadius, retainerWidth * 2, hookRadius], center=true);
        }
    }
    

    module reinforcementFloorCut()
    {
        translate( [0, 0, postReinforcementOffsetZ - platformThickness / 2] )
        cylinder( r=pillarDiam / 2 + cylinderReinforcementFudge,
                  h=platformThickness + cylinderReinforcementHeight + manifoldCorrection * 2,
                  center=true ); 
    }
    
    module postReinforcement(reinforce)
    {
        for (flipX = getPillarFlipSingsX()) {
            for (flipY = [-1, 1]) {
                translate( [flipX * pillarCenterX, flipY * pillarCenterY, 0] )
                if (reinforce) {
                    translate( [0, 0, postReinforcementOffsetZ] )
                    drawReinforcementCylinder();
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
			translate( [0, 0, platformCenterZ] )
			{
				cube( [platformWidth, platformLength, platformThickness], center=true );
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



module drawRetainersFlat(extraCount=2)
{
    coilNumRetainers = len(retainerLocationAngles) + extraCount;
    retainersPad = 3.0;
	for ( retainerNum = [1:coilNumRetainers] ) {
        translate( [0, retainerNum * (retainerWidth + retainersPad), 0] )
        drawRetainer();
    }
}



module drawRetainersOnScene()
{
	for ( angle = retainerLocationAngles ) {
		rotate( [angle, 0, 0] )
        translate( [0, 0, -(coilFlangeRadius + retainerDepth / 2)] )
        drawRetainer();
    }
}



module drawRetainer(length=retainerLength, depth=retainerDepth)
{
	cube( [length, retainerWidth, depth], center=true );
	translate( [coilRadius / 2, 0, 0] )
		retainerBlocks();
	translate( [-coilRadius / 2, 0, 0] )
		retainerBlocks();
}


module retainerBlocks()
{
    retainerBlockDimensions		= [retainerCoilHolderThickness - 2 * FUDGE_SIDE, retainerWidth, retainerCoilHolderHeight];
    
    retainerBlockOffset1		= [(coilTotalThickness + retainerCoilHolderThickness) / 2 + FUDGE_SIDE, 0, (retainerDepth + retainerCoilHolderHeight) / 2 - manifoldCorrection];
    retainerBlockOffset2		= [- retainerBlockOffset1[0], retainerBlockOffset1[1], retainerBlockOffset1[2]];
    
	translate( retainerBlockOffset1 )
		cube( retainerBlockDimensions, center=true );

	translate( retainerBlockOffset2 )
		cube( retainerBlockDimensions, center=true );
}



module drawHelmholtzCoilsOnScene()
{
	rotate( [0, 90, 0] )
	{
		translate( [0, 0, coilRadius / 2] )
        rotate( [180, 0, 0] )
        helmholtzSingleCoil();
        
		translate( [0, 0, -coilRadius / 2] )
        helmholtzSingleCoil();

		// Show the usable array grayed out
		// cylinder( r=coilHomogeneousDiam / 2, h=coilRadius, center = true );	
	}
}



module drawHelmholtzCoilFlat()
{
    helmholtzSingleCoil();
}


module helmholtzCoilHalfer()
{
    coilHalferFlangeDimensions		= [coilFlangeRadius * 2,
								   coilFlangeRadius,
								   coilFlangeWidth + manifoldCorrection * 2];
    coilHalferWireSpaceDimensions		= [coilWindingRadiusInner * 2, coilWindingRadiusInner, coilWindingWidth + manifoldCorrection * 2];
    coilHalferWireSpaceOffset			= [0, coilWindingRadiusInner / 2, 0];
    coilHalferFlangeOffset1			= [0, coilFlangeRadius / 2 + manifoldCorrection,   coilFlangeOffset[2]];
    coilHalferFlangeOffset2			= [coilHalferFlangeOffset1[0], coilHalferFlangeOffset1[1], - coilFlangeOffset[2]];
    coilHalferRotataionFlangeAngle	= 7;
    
	// Slices a helmholtz coil in half for 3D printing
	rotate( [0, 0, -coilHalferRotataionFlangeAngle / 2] )
    translate( coilHalferWireSpaceOffset )
    cube( coilHalferWireSpaceDimensions, center = true );

	rotate( [0, 0, coilHalferRotataionFlangeAngle / 2] )
    translate( coilHalferFlangeOffset1 )
    cube( coilHalferFlangeDimensions, center = true );

	rotate( [0, 0, coilHalferRotataionFlangeAngle / 2] )
    translate( coilHalferFlangeOffset2 )
    cube( coilHalferFlangeDimensions, center = true );
}


module bottomHalfHelmholtzCoil()
{
	difference()
	{
		helmholtzSingleCoil();
        
        rotate( [0, 0, 90] )
		helmholtzCoilHalfer();
	}
}



module topHalfHelmholtzCoil()
{
	difference()
	{
		helmholtzSingleCoil();
        
        rotate( [0, 0, -90] )
        helmholtzCoilHalfer();
        
        drawCoilHorizontalBarReinforcement(fudge=2 * manifoldCorrection);
	}
}


module drawCoilHorizontalBarReinforcement(fudge=0) {
    cubeReinforcementSize = 0.6 * coilInnerRingThickness + fudge;
    
    for (flipZ = [-1, 1]) {
        for (flipY = [-1, 1]) {
            translate([-tableCenterZ, flipY * tableHoleY, flipZ * (coilTotalThickness / 2 + retainerCoilHolderThickness / 2 - manifoldCorrection)])
            rotate([0, 0, 45])
            cube([cubeReinforcementSize, cubeReinforcementSize, retainerCoilHolderThickness + fudge], center=true);
        }
    }
}


module helmholtzSingleCoil()
{
   
    coilSpokeLength				= coilWindingRadiusInner - coilOuterRingThickness / 2 - coilHomogeneousDiam / 2 - coilInnerRingThickness / 2;

    coilSpokeOffset				= [0, (coilHomogeneousDiam + coilSpokeLength + coilInnerRingThickness) / 2, 0];
    
    
    module coilWireEnterExitHole()
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
			donut( outerRadius=coilWindingRadiusInner, innerRadius = coilOuterRingBottomRadius, height=coilWindingWidth + 2 * manifoldCorrection ); 

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
            coilSpokeDimensions	= [0.075 * coilRadius, coilSpokeLength, coilTotalThickness - 2 * manifoldCorrection];

            
			for ( angle = [coilSpokeAngleStart:coilSpokeAngleStep:360-coilSpokeAngleStart] ) {
				rotate( [0, 0, angle] )
                translate( coilSpokeOffset )
                cube( coilSpokeDimensions, center=true);
            }
            
            drawCoilHorizontalBarReinforcement();
		}
    }


	difference()
	{
        drawCoilSolid();
        
		translate( [coilWindingRadiusInner, 0, (coilWindingWidth + coilFlangeWidth) / 2] )
        coilWireEnterExitHole();
        
        for (flipY = [-1, 1]) {
            translate([-tableCenterZ, flipY * tableHoleY, 0])
            rotate([0, 90, 0])
            drawHorizontalBarSupport(fudge=2 * FUDGE_SIDE);
        }
	}
}


module donut(outerRadius, innerRadius, height)
{
	difference()
	{
		cylinder( r=outerRadius, h = height, center = true);
		cylinder( r=innerRadius, h = height + 2 * manifoldCorrection, center = true);
	}
}
