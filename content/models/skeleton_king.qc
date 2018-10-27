// Created by Crowbar 0.24.0.0

$modelname "heroes/skeleton_king/skeleton_king.mdl"

$model "default" "skeleton_king_reference.smd" {

	flexfile "skeleton_king.vta" 
	{
		defaultflex frame 0
		flex "lowerLipsPart" frame 1
		flex "lowerLipDepressor" frame 2
		flex "lowerLipFunneler" frame 3
		flex "jawThrust" frame 4
		flex "jawSuck" frame 5
		flex "jawSidewaysL" frame 6
		flex "jawSidewaysR" frame 7
		flex "jawOpen" frame 8
	}

	flexcontroller default range 0 1 innerBrowRaiser
	flexcontroller default range 0 1 outerBrowRaiser
	flexcontroller default range 0 1 browLowerer
	flexcontroller default range -1 1 eyeDownAndUp
	flexcontroller default range -1 1 eyeRightAndLeft
	flexcontroller default range -1 1 eyeClosedAndLidRaiser
	flexcontroller default range 0 1 squint
	flexcontroller default range 0 1 cheekRaiser
	flexcontroller default range 0 1 dimpler
	flexcontroller default range 0 1 noseWrinkler
	flexcontroller default range 0 1 nostrilDilator
	flexcontroller default range -1 1 upperLipsTowardAndPart
	flexcontroller default range 0 1 phonemeFV
	flexcontroller default range 0 1 phonemeBMP
	flexcontroller default range -1 1 lowerLipsTowardAndPart
	flexcontroller default range 0 1 upperLipRaiser
	flexcontroller default range -1 1 lowerLipDepressorAndChinRaiser
	flexcontroller default range -1 1 lipCornerDepressorAndSharpLipPuller
	flexcontroller default range 0 1 lipPressor
	flexcontroller default range 0 1 lipCornerPuller
	flexcontroller default range 0 1 lipStretcher
	flexcontroller default range 0 1 lipPuckerer
	flexcontroller default range 0 1 upperLipFunneler
	flexcontroller default range 0 1 lowerLipFunneler
	flexcontroller default range 0 1 lowerLipSuck
	flexcontroller default range -1 1 lipSideways
	flexcontroller default range -1 1 jawSuckAndThrust
	flexcontroller default range -1 1 jawSideways
	flexcontroller default range 0 1 jawOpen
	flexcontroller default range 0 1 jawClencher

	localvar innerBrowRaiser
	localvar outerBrowRaiser
	localvar browLowerer
	localvar eyeUp
	localvar eyeDown
	localvar eyeLeft
	localvar eyeRight
	localvar upperLidRaiser
	localvar eyeClosed
	localvar squint
	localvar cheekRaiser
	localvar dimpler
	localvar noseWrinkler
	localvar nostrilDilator
	localvar upperLipsToward
	localvar lowerLipsToward
	localvar upperLipsPart
	localvar upperLipRaiser
	localvar chinRaiser
	localvar lipCornerDepressor
	localvar lipPressor
	localvar sharpLipPuller
	localvar lipCornerPuller
	localvar lipStretcher
	localvar lipPuckerer
	localvar upperLipFunneler
	localvar lowerLipSuck
	localvar lipSidewaysL
	localvar lipSidewaysR
	localvar phonemeBMP
	localvar phonemeFV
	localvar jawClencher
	localvar eyeClosed__eyeUp
	localvar eyeClosed__eyeDown
	localvar jawOpen__lipCornerPuller
	localvar lipPuckerer__lowerLipFunneler
	localvar lipPuckerer__upperLipFunneler
	%innerBrowRaiser = innerBrowRaiser
	%outerBrowRaiser = outerBrowRaiser
	%browLowerer = browLowerer
	%eyeUp =  max(eyeDownAndUp, 0)
	%eyeDown =  min(eyeDownAndUp, 0) * -1
	%eyeLeft =  max(eyeRightAndLeft, 0)
	%eyeRight =  min(eyeRightAndLeft, 0) * -1
	%upperLidRaiser =  max(eyeClosedAndLidRaiser, 0)
	%eyeClosed =  min(eyeClosedAndLidRaiser, 0) * -1
	%squint = squint
	%cheekRaiser = cheekRaiser
	%dimpler = dimpler
	%noseWrinkler = noseWrinkler
	%nostrilDilator = nostrilDilator
	%upperLipsToward =  max(( min(upperLipsTowardAndPart, 0) * -1 -  min(upperLipsTowardAndPart, 0) * -1 * 1 * phonemeFV +  min(upperLipsTowardAndPart, 0) * -1 * 1 * phonemeBMP), 0)
	%lowerLipsToward =  max(( min(lowerLipsTowardAndPart, 0) * -1 -  min(lowerLipsTowardAndPart, 0) * -1 * 1 * phonemeFV +  min(lowerLipsTowardAndPart, 0) * -1 * 1 * phonemeBMP), 0)
	%upperLipsPart =  max(( max(upperLipsTowardAndPart, 0) -  max(upperLipsTowardAndPart, 0) * 1 * phonemeFV +  max(upperLipsTowardAndPart, 0) * 1 * phonemeBMP), 0)
	%lowerLipsPart =  max(( max(lowerLipsTowardAndPart, 0) -  max(lowerLipsTowardAndPart, 0) * 1 * phonemeFV +  max(lowerLipsTowardAndPart, 0) * 1 * phonemeBMP), 0)
	%upperLipRaiser =  max((upperLipRaiser - upperLipRaiser * 1 * phonemeFV + upperLipRaiser * 1 * phonemeBMP), 0)
	%lowerLipDepressor =  max(( min(lowerLipDepressorAndChinRaiser, 0) * -1 -  min(lowerLipDepressorAndChinRaiser, 0) * -1 * 1 * phonemeFV +  min(lowerLipDepressorAndChinRaiser, 0) * -1 * 1 * phonemeBMP), 0)
	%chinRaiser =  max(( max(lowerLipDepressorAndChinRaiser, 0) -  max(lowerLipDepressorAndChinRaiser, 0) * 1 * phonemeFV +  max(lowerLipDepressorAndChinRaiser, 0) * 1 * phonemeBMP), 0)
	%lipCornerDepressor =  min(lipCornerDepressorAndSharpLipPuller, 0) * -1
	%lipPressor = lipPressor
	%sharpLipPuller =  max(lipCornerDepressorAndSharpLipPuller, 0)
	%lipCornerPuller = lipCornerPuller
	%lipStretcher = lipStretcher
	%lipPuckerer = lipPuckerer
	%upperLipFunneler =  max((upperLipFunneler - upperLipFunneler * 1 * phonemeFV + upperLipFunneler * 1 * phonemeBMP), 0)
	%lowerLipFunneler =  max((lowerLipFunneler - lowerLipFunneler * 1 * phonemeFV + lowerLipFunneler * 1 * phonemeBMP), 0)
	%lowerLipSuck = lowerLipSuck
	%lipSidewaysL =  max(lipSideways, 0)
	%lipSidewaysR =  min(lipSideways, 0) * -1
	%jawThrust =  max(( max(jawSuckAndThrust, 0) -  max(jawSuckAndThrust, 0) * 0.5 * phonemeFV +  max(jawSuckAndThrust, 0) * 1 * phonemeBMP), 0)
	%jawSuck =  max(( min(jawSuckAndThrust, 0) * -1 -  min(jawSuckAndThrust, 0) * -1 * 0.5 * phonemeFV +  min(jawSuckAndThrust, 0) * -1 * 1 * phonemeBMP), 0)
	%jawSidewaysL =  max(( max(jawSideways, 0) -  max(jawSideways, 0) * 0.7 * phonemeFV +  max(jawSideways, 0) * 0.7 * phonemeBMP), 0)
	%jawSidewaysR =  max(( min(jawSideways, 0) * -1 -  min(jawSideways, 0) * -1 * 0.7 * phonemeFV +  min(jawSideways, 0) * -1 * 0.7 * phonemeBMP), 0)
	%jawOpen =  max((jawOpen - jawOpen * 1 * phonemeFV + jawOpen * 1 * phonemeBMP), 0)
	%phonemeBMP = phonemeBMP
	%phonemeFV = phonemeFV
	%jawClencher = jawClencher
	%eyeClosed__eyeUp =  min(eyeClosedAndLidRaiser, 0) * -1 *  max(eyeDownAndUp, 0)
	%eyeClosed__eyeDown =  min(eyeClosedAndLidRaiser, 0) * -1 *  min(eyeDownAndUp, 0) * -1
	%jawOpen__lipCornerPuller =  max((jawOpen - jawOpen * 1 * phonemeFV + jawOpen * 1 * phonemeBMP), 0) * lipCornerPuller
	%lipPuckerer__lowerLipFunneler = lipPuckerer *  max((lowerLipFunneler - lowerLipFunneler * 1 * phonemeFV + lowerLipFunneler * 1 * phonemeBMP), 0)
	%lipPuckerer__upperLipFunneler = lipPuckerer *  max((upperLipFunneler - upperLipFunneler * 1 * phonemeFV + upperLipFunneler * 1 * phonemeBMP), 0)
}

$lod 1
{
	replacemodel "skeleton_king_reference.smd" "skeleton_king_model_lod1.smd"
}

$cdmaterials ""

$attachment "attach_attack2" "wrist_L" 0 0 0 rotate 90 9.3 0
$attachment "attach_left_eye" "Head_1" 12.5 5 2 rotate 0 0 0
$attachment "attach_right_eye" "Head_1" 12.5 -5 2 rotate 0 0 0
$attachment "attach_attack1" "weapon0_0" 90 0 0 rotate 90 0 0
$attachment "attach_hitloc" "Spine_1" 0 0 0 rotate 90 0 0

$surfaceprop "default"

$contents "solid"

// $hboxset "default"
// $hbox 0 "knee_R" -45.626026 -9.004707 -19.489473 0.518798 6.260005 8.989336
// $hbox 0 "thigh_R" -54.82658 -10.148213 -15.205212 1.508785 13.044955 5.559582
// $hbox 0 "knee_L" -2.419586 -6.260005 -8.989336 37.607857 9.004707 19.489473
// $hbox 0 "thigh_L" -1.508785 -13.044956 -5.559582 54.82658 10.148213 15.205212
// $hbox 0 "wrist_L" 1.609188 -0.231826 -13.356263 32.570133 20.278435 13.431863
// $hbox 0 "elbow_L" -0.880603 -5.133938 -8.733679 46.888077 7.118487 8.310656
// $hbox 0 "bicep_L" -4.83534 -7.030313 -4.953558 47.069481 8.236646 7.696204
// $hbox 0 "Head_1" -7.207597 -12.25117 -13.198928 18.327381 12.25117 10.975594
// $hbox 0 "wrist_R" -29.58037 -13.93572 -21.84869 4.555855 4.288078 9.539963
// $hbox 0 "elbow_R" -42.628483 -11.744237 -13.070015 -6.9725 13.206901 12.027733
// $hbox 0 "bicep_R" -50.006435 -9.551687 -12.312733 4.831851 9.146742 9.449199
// $hbox 0 "Spine_2" -27.249331 -31.400137 -27.735199 23.399021 34.325527 21.756407
// $hbox 0 "Root_0" -21.741137 -25.811378 -18.757244 17.179993 26.350054 16.148325
// $hboxset "feet"
// $hbox 0 "ankle_R" -36.33263 -6.802569 -2.204985 3.127173 9.523061 9.874845
// $hbox 0 "ankle_L" -3.127173 -9.400684 -8.51121 36.33263 7.438845 6.16966
// $hboxset "hands"
// $hbox 0 "wrist_L" 1.609188 -0.231826 -13.356263 32.570133 20.278435 13.431863
// $hbox 0 "wrist_R" -29.58037 -13.93572 -21.84869 4.555855 4.288078 9.539963
// $hboxset "head"
// $hbox 0 "Head_1" -7.207597 -12.25117 -13.198928 18.327381 12.25117 10.975594
// $hboxset "weapon"
// $hbox 0 "weapon0_0" -37.616154 -33.833279 -7.127395 173.606247 30.681601 7.070781
// $hboxset "select_low"
// $hbox 0 "Root_0" -64.984711 -82.925163 -100.83741 71.063416 83.463837 64.834953
// $hboxset "select_high"
// $hbox 0 "Root_0" -23.588985 -33.536781 10.141841 32.042152 36.462173 73.794479
// $hbox 0 "Root_0" -23.126696 -38.212212 -101.941833 30.707855 38.750889 9.483846
// $skipboneinbbox

// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "Root_0" "" 0 101.460457 -9.034349 0 -1.570796 -1.570796 0 0 0 0 0 0
// $definebone "thigh_L" "Root_0" -1.212748 16.497816 -3.68644 1.153368 1.39144 1.331647 0 0 0 0 0 0
// $definebone "Spine_0" "Root_0" -1.033484 0 5.457817 -3.141593 -1.445077 -3.141592 0 0 0 0 0 0
// $definebone "thigh_R" "Root_0" -1.212748 -16.497816 -3.68644 -2.158937 -1.362285 1.996996 0 0 0 0 0 0
// $definebone "knee_L" "thigh_L" 46.744495 -0.000004 0.000006 0 0.186207 0 0 0 0 0 0 0
// $definebone "ankle_L" "knee_L" 42.475494 0.000011 -0.000001 0.197817 -1.403124 -0.311883 0 0 0 0 0 0
// $definebone "toeBase_L" "ankle_L" 18.37998 0 -0.000003 -0.034226 -0.31045 0.009097 0 0 0 0 0 0
// $definebone "Spine_1" "Spine_0" 17.587128 0.000001 0.000002 0 0.14615 0 0 0 0 0 0 0
// $definebone "Spine_2" "Spine_1" 16.394096 0.000001 -0.000002 0 0.15194 0 0 0 0 0 0 0
// $definebone "Spine_3" "Spine_2" 15.520416 0.000001 0.000004 0 0.044053 0 0 0 0 0 0 0
// $definebone "clavicle_L" "Spine_3" 3.932022 8.840167 2.902016 1.570796 0.339843 1.790469 0 0 0 0 0 0
// $definebone "cape1_0" "Spine_3" -3.597977 18.953482 10.28278 3.133451 0.026795 2.846561 0 0 0 0 0 0
// $definebone "Head_0" "Spine_3" 9.031311 -0.000001 -0.000008 0 0.186174 0 0 0 0 0 0 0
// $definebone "clavicle_R" "Spine_3" 3.932007 -8.840164 2.902008 -1.570796 -0.339843 1.351124 0 0 0 0 0 0
// $definebone "Cloak2_0" "Spine_3" -7.275818 0.50577 19.813637 3.119137 0.12779 2.967154 0 0 0 0 0 0
// $definebone "bicep_L" "clavicle_L" 17.160509 0 -0.000031 -1.398621 0.824046 0.398083 0 0 0 0 0 0
// $definebone "Cloak4_0" "clavicle_L" 26.684914 3.299606 -0.370117 1.168458 0.91082 -0.03972 0 0 0 0 0 0
// $definebone "elbow_L" "bicep_L" 35.136627 0.000023 -0.000008 0 0.831764 0 0 0 0 0 0 0
// $definebone "wrist_L" "elbow_L" 36.404068 -0.000008 -0.000013 0.016043 0.175563 -0.11195 0 0 0 0 0 0
// $definebone "pinky_0_L" "wrist_L" 11.314045 8.570045 11.029976 1.570796 -0.002781 0.896145 0 0 0 0 0 0
// $definebone "index_0_L" "wrist_L" 18.791302 5.043465 -1.833687 1.570797 -0.028949 0.77879 0 0 0 0 0 0
// $definebone "thumb_0_L" "wrist_L" 6.829914 0.406792 -4.480139 1.570797 0.644694 0.926513 0 0 0 0 0 0
// $definebone "mid_0_L" "wrist_L" 17.250927 6.916939 2.920704 1.570797 -0.145467 0.679184 0 0 0 0 0 0
// $definebone "ring_0_L" "wrist_L" 15.992558 8.026726 7.682457 1.570797 -0.103179 0.845173 0 0 0 0 0 0
// $definebone "pinky_1_L" "pinky_0_L" 7.205826 0.000008 0.000011 0 0 0 0 0 0 0 0 0
// $definebone "index_1_L" "index_0_L" 8.099846 0.000002 0.000004 0 0 0 0 0 0 0 0 0
// $definebone "thumb_1_L" "thumb_0_L" 10.301208 0.000008 0.000008 0 0 0 0 0 0 0 0 0
// $definebone "mid_1_L" "mid_0_L" 8.934273 0.000001 0 0 0 0 0 0 0 0 0 0
// $definebone "ring_1_L" "ring_0_L" 8.110962 -0.000005 0.000004 0 0 0 0 0 0 0 0 0
// $definebone "Cloak4_1" "Cloak4_0" 32.466995 -0.000008 -0.000004 -0.029574 -0.062836 0.046542 0 0 0 0 0 0
// $definebone "cape1_1" "cape1_0" 45.711754 -0.000011 0.000008 -0.035663 -0.182712 -0.101029 0 0 0 0 0 0
// $definebone "Cloak3_0" "cape1_1" 34.163963 -0.000008 0 3.141592 -1.568499 2.950967 0 0 0 0 0 0
// $definebone "Head_1" "Head_0" 12.009491 0 0 0 1.168199 0 0 0 0 0 0 0
// $definebone "jaw_M" "Head_1" 5.655488 -0.000004 -1.005554 1.570797 0 1.570796 0 0 0 0 0 0
// $definebone "bicep_R" "clavicle_R" -17.160501 -0.000004 0.000031 -1.467591 0.857713 0.403214 0 0 0 0 0 0
// $definebone "ShoulderPad6_0" "clavicle_R" -8.865585 -4.422146 -7.852722 2.916846 0.211143 1.862765 0 0 0 0 0 0
// $definebone "elbow_R" "bicep_R" -35.690369 0.000008 0.000011 0 0.863532 0 0 0 0 0 0 0
// $definebone "wrist_R" "elbow_R" -38.508881 -0.000015 -0.000008 0.094147 0.149653 -0.067464 0 0 0 0 0 0
// $definebone "weapon0_0" "wrist_R" -36.933022 -12.416977 -24.98811 0.766349 -0.758462 2.890127 0 0 0 0 0 0
// $definebone "mid_0_R" "wrist_R" -14.607508 -1.921059 -7.931192 1.140007 -0.148777 0.389324 0 0 0 0 0 0
// $definebone "thumb_0_R" "wrist_R" -5.13271 -2.031532 3.486744 2.985342 0.573139 0.388889 0 0 0 0 0 0
// $definebone "mid_1_R" "mid_0_R" -8.242065 -0.000004 0 0 0.44375 0 0 0 0 0 0 0
// $definebone "mid_2_R" "mid_1_R" -6.169243 0.000011 -0.000019 0 0 0 0 0 0 0 0 0
// $definebone "thumb_1_R" "thumb_0_R" -8.950581 -0.000004 0.000008 0.000001 0.842009 0.000001 0 0 0 0 0 0
// $definebone "thumb_2_R" "thumb_1_R" -5.783875 -0.000004 0.000004 0 0 0 0 0 0 0 0 0
// $definebone "Cloak2_1" "Cloak2_0" 42.402855 0.000004 -0.000008 -0.00365 -0.02875 -0.046685 0 0 0 0 0 0
// $definebone "knee_R" "thigh_R" -46.744507 0.000004 -0.000003 0 0.278221 0 0 0 0 0 0 0
// $definebone "ankle_R" "knee_R" -42.47554 -0.000011 -0.00001 0.406799 -1.406279 -0.566789 0 0 0 0 0 0
// $definebone "toeBase_R" "ankle_R" -18.379982 0.000008 -0.00002 -0.034226 -0.310449 0.009096 0 0 0 0 0 0

$sectionframes 30 119




$sequence "BindPose" "skeleton_king_anims\BindPose.smd" {
	fps 30
}

$sequence "attack" "skeleton_king_anims\attack.smd" {
	fps 30
	activity "ACT_DOTA_ATTACK" 1
	{ event AE_CL_CREATE_PARTICLE_EFFECT 14 "SKELETON_KING_WEAPON_BLUR start_at_origin" }
}

$sequence "attack2" "skeleton_king_anims\attack2.smd" {
	fps 30
	activity "ACT_DOTA_ATTACK" 1
	{ event AE_CL_CREATE_PARTICLE_EFFECT 14 "SKELETON_KING_WEAPON_BLUR_REVERSE start_at_origin" }
}

$sequence "death" "skeleton_king_anims\death.smd" {
	fps 30
	activity "ACT_DOTA_DIE" 1
}

$sequence "hellfire" "skeleton_king_anims\hellfire.smd" {
	fps 30
	activity "ACT_DOTA_CAST_ABILITY_1" 1
}

$sequence "idle" "skeleton_king_anims\idle.smd" {
	fps 30
	activity "ACT_DOTA_IDLE" 10
	loop
}

$sequence "run" "skeleton_king_anims\run.smd" {
	fps 30
	activity "ACT_DOTA_RUN" 1
	loop
	{ event AE_CL_PLAYSOUND 9 "Hero_SkeletonKing.Footsteps" }
	{ event AE_CL_PLAYSOUND 21 "Hero_SkeletonKing.Footsteps" }
}

$sequence "run_injured" "skeleton_king_anims\run_injured.smd" {
	fps 30
	activity "ACT_DOTA_RUN" 1
	loop
}

$sequence "run_chase" "skeleton_king_anims\run_chase.smd" {
	fps 30
	activity "ACT_DOTA_RUN" 1
	loop
}

$sequence "stun" "skeleton_king_anims\stun.smd" {
	fps 30
	activity "ACT_DOTA_DISABLED" 1
	loop
}

$sequence "crit" "skeleton_king_anims\crit.smd" {
	fps 30
	activity "ACT_DOTA_ATTACK_EVENT" 1
	{ event AE_CL_CREATE_PARTICLE_EFFECT 14 "SKELETON_KING_WEAPON_BLUR_CRITICAL start_at_origin" }
}

$sequence "idle_alt" "skeleton_king_anims\idle_alt.smd" {
	fps 30
	activity "ACT_DOTA_IDLE_RARE" 1
	loop
}

$sequence "flail" "skeleton_king_anims\flail.smd" {
	fps 30
	activity "ACT_DOTA_FLAIL" 1
	loop
}

$sequence "spawn" "skeleton_king_anims\spawn.smd" {
	fps 30
	activity "ACT_DOTA_SPAWN" 1
}

$sequence "death_sim" "skeleton_king_anims\death_sim.smd" {
	fps 24
}

$sequence "workshop_anim_00" "skeleton_king_anims\workshop_anim_00.smd" {
	fps 30
}

$sequence "workshop_anim_01" "skeleton_king_anims\workshop_anim_01.smd" {
	fps 30
}

$sequence "workshop_anim_02" "skeleton_king_anims\workshop_anim_02.smd" {
	fps 30
}

$sequence "workshop_anim_03" "skeleton_king_anims\workshop_anim_03.smd" {
	fps 30
}

$sequence "workshop_anim_04" "skeleton_king_anims\workshop_anim_04.smd" {
	fps 30
}

$sequence "workshop_anim_05" "skeleton_king_anims\workshop_anim_05.smd" {
	fps 30
}

$sequence "workshop_anim_06" "skeleton_king_anims\workshop_anim_06.smd" {
	fps 30
}

$sequence "workshop_anim_07" "skeleton_king_anims\workshop_anim_07.smd" {
	fps 30
}

$sequence "workshop_anim_08" "skeleton_king_anims\workshop_anim_08.smd" {
	fps 30
}

$sequence "workshop_anim_09" "skeleton_king_anims\workshop_anim_09.smd" {
	fps 30
}

$sequence "attack_regalia_bonelord" "skeleton_king_anims\attack_regalia_bonelord.smd" {
	fps 30
	activity "ACT_DOTA_ATTACK" 2
	{ event AE_CL_CREATE_PARTICLE_EFFECT 14 "SKELETON_KING_WEAPON_BLUR start_at_origin" }
}

$sequence "attack2_regalia_bonelord" "skeleton_king_anims\attack2_regalia_bonelord.smd" {
	fps 30
	activity "ACT_DOTA_ATTACK" 1
	{ event AE_CL_CREATE_PARTICLE_EFFECT 14 "SKELETON_KING_WEAPON_BLUR start_at_origin" }
}

$sequence "attack3_regalia_bonelord" "skeleton_king_anims\attack3_regalia_bonelord.smd" {
	fps 30
	activity "ACT_DOTA_ATTACK" 2
	{ event AE_CL_CREATE_PARTICLE_EFFECT 14 "SKELETON_KING_WEAPON_BLUR start_at_origin" }
}

$bonemerge "Root_0"
$bonemerge "thigh_L"
$bonemerge "Spine_0"
$bonemerge "thigh_R"
$bonemerge "knee_L"
$bonemerge "ankle_L"
$bonemerge "toeBase_L"
$bonemerge "Spine_1"
$bonemerge "Spine_2"
$bonemerge "Spine_3"
$bonemerge "clavicle_L"
$bonemerge "cape1_0"
$bonemerge "Head_0"
$bonemerge "clavicle_R"
$bonemerge "Cloak2_0"
$bonemerge "bicep_L"
$bonemerge "Cloak4_0"
$bonemerge "elbow_L"
$bonemerge "wrist_L"
$bonemerge "pinky_0_L"
$bonemerge "index_0_L"
$bonemerge "thumb_0_L"
$bonemerge "mid_0_L"
$bonemerge "ring_0_L"
$bonemerge "pinky_1_L"
$bonemerge "index_1_L"
$bonemerge "thumb_1_L"
$bonemerge "mid_1_L"
$bonemerge "ring_1_L"
$bonemerge "Cloak4_1"
$bonemerge "cape1_1"
$bonemerge "Cloak3_0"
$bonemerge "Head_1"
$bonemerge "bicep_R"
$bonemerge "ShoulderPad6_0"
$bonemerge "elbow_R"
$bonemerge "wrist_R"
$bonemerge "weapon0_0"
$bonemerge "mid_0_R"
$bonemerge "thumb_0_R"
$bonemerge "mid_1_R"
$bonemerge "mid_2_R"
$bonemerge "thumb_1_R"
$bonemerge "thumb_2_R"
$bonemerge "Cloak2_1"
$bonemerge "knee_R"
$bonemerge "ankle_R"
$bonemerge "toeBase_R"


$keyvalues
{
}
