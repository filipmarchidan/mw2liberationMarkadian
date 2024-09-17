#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	level.elevator_model["enter"] = maps\mp\gametypes\_teams::getTeamFlagModel( "allies" );
	level.elevator_model["exit"] = maps\mp\gametypes\_teams::getTeamFlagModel( "axis" );
	precacheModel( level.elevator_model["enter"] );
	precacheModel( level.elevator_model["exit"] );
	wait 1.05;
	switch(GetDvar("mapname")) {
		case "mp_estate":
			estate_objects();
			break;
	

		

	}
}




estate_objects()
{
CreateWalls((370.033,1353.43,190.125), ( 447.76,1335.02,205.86));
CreateWalls((810.223,864.847,190.125), ( 804.381,839.727,190.125));
CreateWalls((837.764,955.113,232.125), (837.237,945.577,232.125));
CreateWalls((472.94,224.071,182.125), (-40.9565,347.918,142.125));
CreateWalls((4.93913,365.023,185.125), (50.4807,495.822,182.125));
CreateWalls((170.649,1162.89,230.125), (65.0954,1240.72,230.125));
CreateWalls((285.589,1178.8,230.125), (-360.776,1104.37,230.125));
CreateWalls((-391.063,1007.79,230.125), ( -374.517,903.566,230.125));
CreateWalls((47.9594,573.061,319.125), (34.0901,529.451,330.325));

CreateRamps((102.424,872.762,334.125), (-358.109,1049.17,311.742));
CreateRamps((-358.109,1049.17,311.742), (-233.891,1205.44,324.049));
CreateRamps((-358.109,1049.17,311.742), (-335.396,818.581,317.807));


mgTurret = spawnTurret( "misc_turret", (-315,1102.27,330.334), "pavelow_minigun_mp" );mgTurret setModel( "weapon_minigun" );mgTurret.angles = (0, 87, 0);
mgTurret2 = spawnTurret( "misc_turret", (-339,933.074,321.568), "pavelow_minigun_mp" );mgTurret setModel( "weapon_minigun" );mgTurret.angles = (0, 87, 0);
mgTurret3 = spawnTurret( "misc_turret", (-272.782,1137.33,190.125), "sentry_minigun_mp" );mgTurret setModel( "sentry_minigun" );mgTurret.angles = (0, 87, 0);
mgTurret4 = spawnTurret( "misc_turret", (-341.096,938.622,190.125), "sentry_minigun_mp" );mgTurret setModel( "sentry_minigun" );mgTurret.angles = (0, 87, 0);






}



/************************************************************************************
*  Building functions, credits to Killingdyl for making this
*************************************************************************************/

CreateBlocks(pos, angle)
{
        block = spawn("script_model", pos );
        block setModel("com_plasticcase_friendly");
        block.angles = angle;
        block Solid();
        block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
        wait 0.01;
}

CreateDoors(open, close, angle, size, height, hp, range) 
{ 
	level.doorwait = 0.7;
        offset = (((size / 2) - 0.5) * -1); 
        center = spawn("script_model", open ); 
        for(j = 0; j < size; j++){ 
                door = spawn("script_model", open + (((0, 30, 0) * offset))*1.5); 
                door setModel("com_plasticcase_enemy"); 
                door Solid(); 
                door CloneBrushmodelToScriptmodel( level.airDropCrateCollision ); 
                door EnableLinkTo(); 
                door LinkTo(center); 
                for(h = 1; h < height; h++){ 
                        door = spawn("script_model", open + (((0, 30, 0) * offset)*1.5) - ((55, 0, 0) * h)); 
                        door setModel("com_plasticcase_enemy"); 
                        door Solid(); 
                        door CloneBrushmodelToScriptmodel( level.airDropCrateCollision ); 
                        door EnableLinkTo(); 
                        door LinkTo(center); 
                } 
                offset += 1; 
        } 
        center.angles = angle; 
        center.state = "open"; 
        center.hp = hp; 
        center.range = range; 
        center thread DoorThink(open, close); 
        center thread DoorUse(); 
        center thread ResetDoors(open, hp); 
        wait 0.01; 
} 
 
DoorThink(open, close) 
{ 
        while(1) 
        { 
                if(self.hp > 0){ 
                        self waittill ( "triggeruse" , player ); 
                        if(player.team == "axis"){ 
                                if(self.state == "open"){ 
                                        self MoveTo(close, level.doorwait); 
                                        wait level.doorwait; 
                                        self.state = "close"; 
                                        continue; 
                                } 
                                if(self.state == "close"){ 
                                        self MoveTo(open, level.doorwait); 
                                        wait level.doorwait; 
                                        self.state = "open"; 
                                        continue; 
                                } 
                        } 
                        if(player.team == "allies"){ 
                                if(self.state == "close"){ 
                                        self.hp--; 
                                        player iPrintlnBold("HIT"); 
                                        wait 1; 
                                        continue; 
                                } 
                        } 
                } else { 
                        if(self.state == "close"){ 
                            self MoveTo(open, level.doorwait); 
                        } 
                        self.state = "broken"; 
                        wait .5; 
						self delete();
                } 
        } 
} 
 
DoorUse(range) 
{ 
        self endon("disconnect"); 
        while(1) 
        { 
                foreach(player in level.players) 
                { 
                        if(Distance(self.origin, player.origin) <= self.range){ 
                                if(player.team == "axis"){ 
                                        if(self.state == "open"){ 
                                                player.hint = "Press ^3[{+activate}] ^7to ^2Close ^7the door"; 
                                        } 
                                        if(self.state == "close"){ 
                                                player.hint = "Press ^3[{+activate}] ^7to ^2Open ^7the door"; 
                                        } 
                                        if(self.state == "broken"){ 
                                                player.hint = "^1Door is Broken"; 
                                        } 
                                } 
                                if(player.team == "allies"){ 
                                        if(self.state == "close"){ 
                                                player.hint = "Press ^3[{+activate}] ^7to ^2Attack ^7the door"; 
                                        } 
                                        if(self.state == "broken"){ 
                                                player.hint = "^1Door is Broken"; 
                                        } 
                                } 
                                if(player maps\mp\gametypes\_rank::isButtonPressed("X")){ 
                                        self notify( "triggeruse" , player); 
                                } 
                        } 
                } 
                wait .045; 
        } 
}
 
CreateElevator(enter, exit, angle, notantycamp) 
{ 
		if(!isDefined(notantycamp)) notantycamp = true;
		if(notantycamp) {
			flag = spawn( "script_model", enter ); 
			flag setModel( level.elevator_model["enter"] ); 
			wait 0.01; 
			flag = spawn( "script_model", exit ); 
			flag setModel( level.elevator_model["exit"] ); 
		}
        wait 0.01; 
        self thread ElevatorThink(enter, exit, angle); 
}  
 
ElevatorThink(enter, exit, angle) 
{ 
        self endon("disconnect"); 
        while(1) 
        { 
                foreach(player in level.players) 
                { 
                        if(Distance(enter, player.origin) <= 90){ 
                                player SetOrigin(exit); 
                                player SetPlayerAngles(angle); 
                        } 
                } 
                wait .25; 
        } 
}  
 
ResetDoors(open, hp) 
{ 
        while(1) 
        { 
                level waittill("RESETDOORS"); 
                self.hp = hp; 
                self MoveTo(open, level.doorwait); 
                self.state = "open"; 
        } 
} 

CreateRamps(top, bottom)
{
        D = Distance(top, bottom);
        blocks = roundUp(D/30);
        CX = top[0] - bottom[0];
        CY = top[1] - bottom[1];
        CZ = top[2] - bottom[2];
        XA = CX/blocks;
        YA = CY/blocks;
        ZA = CZ/blocks;
        CXY = Distance((top[0], top[1], 0), (bottom[0], bottom[1], 0));
        Temp = VectorToAngles(top - bottom);
        BA = (Temp[2], Temp[1] + 90, Temp[0]);
        for(b = 0; b < blocks; b++){
                block = spawn("script_model", (bottom + ((XA, YA, ZA) * B)));
                block setModel("com_plasticcase_friendly");
                block.angles = BA;
                block Solid();
                block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
                wait 0.01;
        }
        block = spawn("script_model", (bottom + ((XA, YA, ZA) * blocks) - (0, 0, 5)));
        block setModel("com_plasticcase_friendly");
        block.angles = (BA[0], BA[1], 0);
        block Solid();
        block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
        wait 0.01;
}

CreateGrids(corner1, corner2, angle)
{
        W = Distance((corner1[0], 0, 0), (corner2[0], 0, 0));
        L = Distance((0, corner1[1], 0), (0, corner2[1], 0));
        H = Distance((0, 0, corner1[2]), (0, 0, corner2[2]));
        CX = corner2[0] - corner1[0];
        CY = corner2[1] - corner1[1];
        CZ = corner2[2] - corner1[2];
        ROWS = roundUp(W/55);
        COLUMNS = roundUp(L/30);
        HEIGHT = roundUp(H/20);
        XA = CX/ROWS;
        YA = CY/COLUMNS;
        ZA = CZ/HEIGHT;
        center = spawn("script_model", corner1);
        for(r = 0; r <= ROWS; r++){
                for(c = 0; c <= COLUMNS; c++){
                        for(h = 0; h <= HEIGHT; h++){
                                block = spawn("script_model", (corner1 + (XA * r, YA * c, ZA * h)));
                                block setModel("com_plasticcase_friendly");
                                block.angles = (0, 0, 0);
                                block Solid();
                                block LinkTo(center);
                                block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
                                wait 0.01;
                        }
                }
        }
        center.angles = angle;
}

CreateWalls(start, end)
{
        D = Distance((start[0], start[1], 0), (end[0], end[1], 0));
        H = Distance((0, 0, start[2]), (0, 0, end[2]));
        blocks = roundUp(D/55);
        height = roundUp(H/30);
        CX = end[0] - start[0];
        CY = end[1] - start[1];
        CZ = end[2] - start[2];
        XA = (CX/blocks);
        YA = (CY/blocks);
        ZA = (CZ/height);
        TXA = (XA/4);
        TYA = (YA/4);
        Temp = VectorToAngles(end - start);
        Angle = (0, Temp[1], 90);
        for(h = 0; h < height; h++){
                block = spawn("script_model", (start + (TXA, TYA, 10) + ((0, 0, ZA) * h)));
                block setModel("com_plasticcase_friendly");
                block.angles = Angle;
                block Solid();
                block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
                wait 0.001;
                for(i = 1; i < blocks; i++){
                        block = spawn("script_model", (start + ((XA, YA, 0) * i) + (0, 0, 10) + ((0, 0, ZA) * h)));
                        block setModel("com_plasticcase_friendly");
                        block.angles = Angle;
                        block Solid();
                        block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
                        wait 0.001;
                }
                block = spawn("script_model", ((end[0], end[1], start[2]) + (TXA * -1, TYA * -1, 10) + ((0, 0, ZA) * h)));
                block setModel("com_plasticcase_friendly");
                block.angles = Angle;
                block Solid();
                block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
                wait 0.001;
        }
}

CreateCluster(amount, pos, radius)
{
        for(i = 0; i < amount; i++)
        {
                half = radius / 2;
                power = ((randomInt(radius) - half), (randomInt(radius) - half), 500);
                block = spawn("script_model", pos + (0, 0, 1000) );
                block setModel("com_plasticcase_friendly");
                block.angles = (90, 0, 0);
                block PhysicsLaunchServer((0, 0, 0), power);
                block Solid();
                block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
                block thread ResetCluster(pos, radius);
                wait 0.05;
        }
}

ResetCluster(pos, radius)
{
        wait 5;
        self RotateTo(((randomInt(36)*10), (randomInt(36)*10), (randomInt(36)*10)), 1);
        level waittill("RESETCLUSTER");
        self thread CreateCluster(1, pos, radius);
        self delete();
}


roundUp( floatVal )
{
        if ( int( floatVal ) != floatVal )
                return int( floatVal+1 );
        else
                return int( floatVal );
}