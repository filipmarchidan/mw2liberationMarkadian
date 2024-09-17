
main()
{
	maps\mp\mp_estate_precache::main();
	maps\createart\mp_estate_art::main();
//	maps\mp\mp_terminal_fx::main();
	maps\mp\_load::main();
	
	maps\mp\_compass::setupMiniMap( "compass_map_mp_estate" );
	setdvar( "compassmaxrange", "2000" );
	
	
	VisionSetNaked( "mp_estate" );
	
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.22 );
	setdvar( "r_lightGridContrast", .6 );
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";
}