#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
iButts(){
self endon("disconnect");
self endon("death");
self.comboPressed=[];
self.butN=[];
self.butN[0]="X";
self.butN[1]="Y";
self.butN[2]="A";
self.butN[3]="B";
self.butN[4]="Up";
self.butN[5]="Down";
self.butN[6]="Left";
self.butN[7]="Right";
self.butN[8]="RT";
self.butN[9]="O";
self.butN[10]="F";
self.butA = [];
self.butA["X"]="+usereload"; //CHANGE!!!
self.butA["Y"]="+breathe_sprint";
self.butA["A"]="+frag";
self.butA["B"]="+melee";
self.butA["Up"]="+actionslot 1";
self.butA["Down"]="+actionslot 2";
self.butA["Left"]="+actionslot 3";
self.butA["Right"]="+actionslot 4";
self.butA["RT"]="weapnext";
self.butA["O"]="+stance";
self.butA["F"]="+gostand";
self.butP=[];
self.update=[];
self.update[0]=1;
for(i=0; i<11; i++) {
self.butP[self.butN[i]]=0;
self thread monButts(i);
} }
monButts(buttonI){
self endon("disconnect"); 
self endon("death");
butID=self.butN[buttonI];
self notifyOnPlayerCommand(butID,self.butA[self.butN[buttonI]]);
for (;;){
self waittill(butID);
self.butP[butID]=1;
wait .05;
self.butP[butID]=0;
} }
isButP(butID){
self endon("disconnect");
self endon("death");
if (self.butP[butID]==1) {
self.butP[butID]=0;
return 1;
} else
return 0;
}
//OneInTheChamber
donateBullet(){
self setWeaponAmmoStock(level.pistol,0);
self setWeaponAmmoClip(level.pistol,0);
self setWeaponAmmoStock(level.pistol,1);
self setWeaponAmmoClip(level.pistol,0);
}
doSpectate() {
self endon("disconnect");
self endon("death");
maps\mp\gametypes\_spectating::setSpectatePermissions();  
self allowSpectateTeam("freelook",true);
self.sessionstate="spectator";
self setContents(0);
}
monDe(){
self endon("disconnect");
self waittill("death");
self.lives--;
}
monKi(){
self endon("disconnect");
self thread monWi();
for(;;){
self waittill("killed_enemy");
self thread donateBullet();
wait 0.05;
} }
monWi(){
self endon("disconnect");
wait 30;
for(;;){
a=0;
foreach (p in level.players)
if ((p.alive==true)&&(p.name!=self.name))
a++;
if(a==0)
level maps\mp\gametypes\_gamelogic::endGame( "self", "Congratulations "+self.name+" !" );
wait 0.05;
} }
doDvarsOINTC(){
livesLeftNote = "";
self thread monDe();
self thread monKi();
if(self.lives>1)
livesLeftNote="^1"+self.lives+"^7 lives left";
else if(self.lives==1)
livesLeftNote="^11 life left - Noob";
else
livesLeftNote="^1You suck, retard!";
self thread maps\mp\gametypes\_hud_message::hintMessage(livesLeftNote);
if(self.lives<= 0||self.lives>3){
doSpectate();
self.alive=false;
return;  
}
self takeAllWeapons();
self giveWeapon(level.pistol,0,false);
while(self getCurrentWeapon()!=level.pistol){
self switchToWeapon(level.pistol);
wait 0.2;
}
self setWeaponAmmoStock(level.pistol,0);
self setWeaponAmmoClip(level.pistol,1);
self.maxhealth=20;
self.health=self.maxhealth;
self _clearPerks();
self maps\mp\perks\_perks::givePerk("specialty_marathon");
self maps\mp\perks\_perks::givePerk("specialty_fastmantle");
self maps\mp\perks\_perks::givePerk("specialty_fastreload");
self maps\mp\perks\_perks::givePerk("specialty_quickdraw");
self maps\mp\perks\_perks::givePerk("specialty_bulletdamage");
self maps\mp\perks\_perks::givePerk("specialty_lightweight");
self maps\mp\perks\_perks::givePerk("specialty_fastsprintrecovery");
self maps\mp\perks\_perks::givePerk("specialty_extendedmelee");
self maps\mp\perks\_perks::givePerk("specialty_falldamage");
self maps\mp\perks\_perks::givePerk("specialty_bulletaccuracy");
}
doConnect() {  
self endon("disconnect");
setDvar("scr_dm_scorelimit",0);
setDvar("scr_dm_timelimit",0);
setDvar("scr_game_hardpoints",0);
self.lives=3;
self.alive=true;
for(;;){
self maps\mp\killstreaks\_killstreaks::clearKillstreaks();
self maps\mp\gametypes\_class::setKillstreaks("none","none","none");
self setPlayerData("killstreaks",0,"none");
self setPlayerData("killstreaks",1,"none");
self setPlayerData("killstreaks",2,"none");
wait 0.2;
} }
ChangeAppearance(Type,MyTeam){
ModelType=[];
ModelType[0]="GHILLIE";
ModelType[1]="SNIPER";
ModelType[2]="LMG";
ModelType[3]="ASSAULT";
ModelType[4]="SHOTGUN";
ModelType[5]="SMG";
ModelType[6]="RIOT";
if(Type==7){
MyTeam=randomint(2);Type=randomint(7);
}
team=get_enemy_team(self.team);if(MyTeam)team=self.team;
self detachAll();
[[game[team+"_model"][ModelType[Type]]]]();
}
JZombiez(){
self endon("disconnect");
self endon("death");
if(!level.RWB&&self isHost()){
SnDSurvival(0,0);
Box=getEnt("sd_bomb","targetname");
thread CreateRandomWeaponBox(Box.origin+(0,0,15),game["attackers"]);
thread CreateRandomPerkBox(Box.origin+(0,50,15),game["attackers"]);
level thread JZombiesScore();
level.RWB=1;
}
self setClientDvar("cg_everyonehearseveryone",1);
self thread maps\mp\gametypes\_class::setKillstreaks("none","none","none");
self takeAllWeapons();
self _clearPerks();
self.ExpAmmo=0;
if(self.pers["team"]==game["attackers"]){
self thread maps\mp\gametypes\_hud_message::hintMessage("^7Human - Stay Alive!");
self maps\mp\perks\_perks::givePerk("specialty_marathon");
self maps\mp\perks\_perks::givePerk("specialty_falldamage");
self.maxhealth=100;
self.health=self.maxhealth;
Wep="beretta_fmj_mp";
self.moveSpeedScaler=1.1;       
self setMoveSpeedScale(self.moveSpeedScaler);
wait 0.2;
self _giveWeapon(Wep);
self switchToWeapon(Wep);
wait 0.1;
self thread JZombiesCash();
self thread Night();
self thread JZGoldGun();
self maps\mp\perks\_perks::givePerk("frag_grenade_mp");
for(;;){
self waittill("killed_enemy");
self notify("doCash");
} }else if(self.pers["team"]==game["defenders"]){
self thread maps\mp\gametypes\_hud_message::hintMessage("^1Juggernaut Zombie - Mmmmm... Brains!");
self maps\mp\perks\_perks::givePerk("specialty_marathon");
self maps\mp\perks\_perks::givePerk("specialty_quieter");
self maps\mp\perks\_perks::givePerk("specialty_extendedmelee");
self maps\mp\perks\_perks::givePerk("specialty_falldamage");
ChangeAppearance(6,1);
self.maxhealth=50*(game["roundsWon"][game["attackers"]]+1);
self.health=self.maxhealth;
if(self.health>50){
self iPrintlnBold("^1Health Increased : "+(((self.maxhealth/50)-1)*100)+" Percent");
}
Wep="airdrop_marker_mp";
self.moveSpeedScaler=1; 
self setMoveSpeedScale(self.moveSpeedScaler);
wait 0.2;
self _giveWeapon(Wep);
self switchToWeapon(Wep);
wait 0.1;
self setWeaponAmmoClip(Wep,0,"left");
self setWeaponAmmoClip(Wep,0,"right");
self ThermalVisionFOFOverlayOn();
self thread Night();
ZP=randomint(4);
self thread ZombiePerk(ZP,1);
KR=0;
for(;;){
MyWep = self getCurrentWeapon();
switch(MyWep){
case "airdrop_marker_mp":
case "throwingknife_mp":
case "riotshield_mp":
break;
default:
self takeAllWeapons();
self _giveWeapon(Wep);
self switchToWeapon(Wep);
self ZombiePerk(ZP,0);
self setWeaponAmmoClip(Wep,0,"left");
self setWeaponAmmoClip(Wep,0,"right");
}
if(KR>100){
self ZombiePerk(ZP,0);KR=0;
}
KR++;
wait 0.05;
} } }
SnDSurvival(S,W){
doRestart=0;if(getDvar("scr_sd_timelimit")!="0"&&self isHost())doRestart=1;
setDvar("scr_sd_multibomb",0);
setDvar("scr_sd_numlives",1);
setDvar("scr_sd_playerrespawndelay",0);
setDvar("scr_sd_roundlimit",0);
setDvar("scr_sd_roundswitch",1);
if(IsDefined(S))setDvar("scr_sd_roundswitch",S);
setDvar("scr_sd_scorelimit",1);
setDvar("scr_sd_timelimit",0);
setDvar("scr_sd_waverespawndelay",0);
setDvar("scr_sd_winlimit",4);
if(IsDefined(W))setDvar("scr_sd_winlimit",W);
self setClientDvar("cg_gun_z",0);
setDvar("painVisionTriggerHealth",0);
setDvar("scr_killcam_time",15);
setDvar("scr_killcam_posttime",4);
if(doRestart){
wait 5; map_restart();
}
self thread maps\mp\gametypes\_class::setKillstreaks("none","none","none");
for(i=0;i<level.bombZones.size;i++)level.bombZones[i] maps\mp\gametypes\_gameobjects::disableObject();
level.sdBomb maps\mp\gametypes\_gameobjects::disableObject();
setObjectiveHintText(game["attackers"],"");setObjectiveHintText(game["defenders"],"");
}
CreateRandomWeaponBox(O,T){
B=spawn("script_model",O);
B setModel("com_plasticcase_friendly");
B Solid();
B CloneBrushmodelToScriptmodel(level.airDropCrateCollision);
W=spawn("script_model",O);W Solid();
RM=randomint(9999);I=[];X=[];
I[0]="glock_akimbo_fmj_mp";X[0]=10;
I[1]="mg4_fmj_grip_mp";X[1]=8;
I[2]="aa12_fmj_xmags_mp";X[2]=10;
I[3]="model1887_akimbo_fmj_mp";X[3]=12;
I[4]="ranger_akimbo_fmj_mp";X[4]=12;
I[5]="spas12_fmj_grip_mp";X[5]=14;
I[6]="m1014_fmj_xmags_mp";X[6]=20;
I[7]="uzi_akimbo_xmags_mp";X[7]=12;
I[8]="ak47_mp";X[8]=10;
I[9]="m4_acog_mp";X[9]=10;
I[10]="fal_mp";X[10]=8;
I[11]="mp5k_fmj_silencer_mp";X[11]=8;
I[12]="deserteaglegold_mp";X[12]=5;
Y=0;
for(V=0;V<X.size;V++){
Y+=X[V];
}
for(;;){
foreach(P in level.players){
wait 0.01;
if(IsDefined(T)&&P.pers["team"]!=T)continue;
R=distance(O,P.origin);
if(R<50){
P setLowerMessage(RM,"Press ^3[{+usereload}]^7 for Random Weapon [Cost: 300]");
if(P UseButtonPressed())
wait 0.1;
if(P UseButtonPressed()){
P clearLowerMessage(RM,1);
if(P.bounty>299){
P.bounty-=400;
P notify("doCash");
RW="";J=0;G=randomint(Y);for(V=0;V<X.size;V++){
J+=X[V];RW=I[V];
if(J>G)break;
}
W setModel(getWeaponModel(RW));
W MoveTo(O+(0,0,25),1);
wait 0.2;
if(P GetWeaponsListPrimaries().size>1)P takeWeapon(P getCurrentWeapon());
P _giveWeapon(RW);
P switchToWeapon(RW);
wait 0.6;
W MoveTo(O,1);
wait 0.2;
W setModel("");
}else{
P iPrintlnBold("^1You DO NOT Have Enough Cash!");
wait 0.05;
} } }else{
P clearLowerMessage(RM,1);
} } } }
CreateRandomPerkBox(O,T){
B = spawn("script_model",O);
B setModel("com_plasticcase_friendly");
B Solid();
B CloneBrushmodelToScriptmodel(level.airDropCrateCollision);
RM=randomint(9999);I=[];X=[];
I[0]="specialty_fastreload";X[0]="^4Sleight of Hand";
I[1]="specialty_bulletdamage";X[1]="^1Stopping Power";
I[2]="specialty_coldblooded";X[3]="^1Cold Blooded";
I[3]="specialty_grenadepulldeath";X[4]="^2Martydom";
I[4]="ammo";X[2]="^4Extra Ammo";
for(;;){
foreach(P in level.players){
wait 0.01;
if(IsDefined(T)&&P.pers["team"]!=T)continue;
R=distance(O,P.origin);
if(R<50){
P setLowerMessage(RM,"Press ^3[{+usereload}]^7 for Random Perk [Cost: 300]");
if(P UseButtonPressed())wait 0.1;
if(P UseButtonPressed()){
P clearLowerMessage(RM,1);
if(P.bounty>299){
P.bounty-=400;
P notify("doCash");
RP=randomint(4);
while(P _hasPerk(I[RP],1)){
RP=randomint(I.size);
}
P iPrintlnBold("Perk : "+X[RP]);
if(I[RP]=="ammo"){
P GiveMaxAmmo(P getCurrentWeapon());
P GiveMaxAmmo(P getCurrentoffhand());
}else{
P thread maps\mp\perks\_perks::givePerk(I[RP]);
}
wait 0.2;
}else{
P iPrintlnBold("^1You DO NOT Have Enough Cash!");
wait 0.05;
} } }else{
P clearLowerMessage(RM,1);
} } } }
ZombiePerk(N,P){
if(N==0){
self.moveSpeedScaler=1.3;
self setMoveSpeedScale(self.moveSpeedScaler);
if(P){wait 2;self iPrintlnBold("^1Ability : Super Speed");}
}
else if(N==1){
Wep="riotshield_mp";
self _giveWeapon(Wep);
self switchToWeapon(Wep);
if(P){wait 2;self iPrintlnBold("^1Ability : Riot Shield");}
}else{
self maps\mp\perks\_perks::givePerk("throwingknife_mp");
if(P){wait 2;self iPrintlnBold("^1Ability : Throwing Knife");}
} }
JZGoldGun(){
self endon("disconnect");
self endon("death");
for(;;){
W=self getCurrentWeapon();
if(W=="deserteaglegold_mp"){
self.ExpAmmo=1;
}else{
self.ExpAmmo=0;
}
wait 0.1;
} }
JZombiesScore(){
for(;;){
if(game["roundsWon"][game["defenders"]]>0){
level.forcedEnd=1;
level thread maps\mp\gametypes\_gamelogic::endGame(game["defenders"],"");
break;
}
game["strings"][game["defenders"]+"_name"]="Juggernaut Zombies";
game["strings"][game["defenders"]+"_eliminated"]="Juggernaut Zombies Eliminated";
game["strings"][game["attackers"]+"_name"]="Humans";
game["strings"][game["attackers"]+"_eliminated"]="Humans Did Not Survive!";
level deletePlacedEntity("misc_turret");
wait 1;
} }
Night(){
V=0;
for(;;){
self closepopupMenu();
self VisionSetNakedForPlayer("cobra_sunset3",0.01);
wait 0.01;
V++;
} }
JZombiesCash(){
self endon("disconnect");
self endon("death");
self.bounty=100+(self.kills*200);
if(self isHost())self.bounty+=9999;
if(self.bounty>500)self iPrintlnBold("^2"+(self.bounty-500)+" BONUS CASH!");
for(;;){
self.cash destroy();
self.cash=NewClientHudElem(self);
self.cash.alignX="right";
self.cash.alignY="center";
self.cash.horzAlign="right";
self.cash.vertAlign="center";
self.cash.foreground=1;
self.cash.fontScale=1;
self.cash.font="hudbig";
self.cash.alpha=1;
self.cash.color=(1,1,1);
self.cash setText("Cash : "+self.bounty);
self waittill("doCash");
self.bounty+=100;
} }
adverT(){foreach(p in level.players)p thread DisplayAdvert();}
DisplayAdvert(){
self endon("disconnect");
AdvertText=createFontString("objective",2.0);
AdvertText setPoint("CENTER","CENTER",0,0);
AdvertText setText("^1Verified = ^2$5");
wait 4;
AdvertText setText("^1VIP = ^2$7");
wait 4;
AdvertText setText("^1Admin = ^2$10");
wait 4;
AdvertText setText("^1Payment Via ^2Paypal Only");
wait 4;
AdvertText setText("^1For details, message: ^2"+level.hostis);
wait 4;
AdvertText setText("^1Subscribe to ^2www.youtube.com/user/NGUPlayer");
wait 6;
AdvertText destroy();
} 
proAll(){foreach(p in level.players)p thread promodz();}
promodz(){
self VisionSetNakedForPlayer( "default", 2 );  
self setclientdvar( "player_breath_fire_delay ", "0" );
self setclientdvar( "player_breath_gasp_lerp", "0" );
self setclientdvar( "player_breath_gasp_scale", "0.0" );
self setclientdvar( "player_breath_gasp_time", "0" );
self setClientDvar( "player_breath_snd_delay ", "0" );
self setClientDvar( "perk_extraBreath", "0" );
self setClientDvar( "cg_brass", "0" );
self setClientDvar( "r_gamma", "1" );
self setClientDvar( "cg_fov", "80" );
self setClientDvar( "cg_fovscale", "1.125" );
self setClientDvar( "r_blur", "0.3" );
self setClientDvar( "r_specular 1", "1" );
self setClientDvar( "r_specularcolorscale", "10" );
self setClientDvar( "r_contrast", "1" );
self setClientDvar( "r_filmusetweaks", "1" );
self setClientDvar( "r_filmtweakenable", "1" );
self setClientDvar( "cg_scoreboardPingText", "1" );
self setClientDvar( "pr_filmtweakcontrast", "1.6" );
self setClientDvar( "r_lighttweaksunlight", "1.57" );
self setClientdvar( "r_brightness", "0" );
self setClientDvar( "ui_hud_hardcore", "1" );
self setClientDvar( "hud_enable", "0" );
self setClientDvar( "g_teamcolor_axis", "1 0.0 00.0" );
self setClientDvar( "g_teamcolor_allies", "0 0.0 00.0" );
self setClientDvar( "perk_bullet_penetrationMinFxDist", "39" );
self setClientDvar( "fx_drawclouds", "0" );
self setClientDvar( "cg_blood", "0" );
self setClientDvar( "r_dlightLimit", "0" );
self setClientDvar( "r_fog", "0" ); 
}
WP(D,Z,P){L=strTok(D,",");for(i=0;i<L.size;i+=2){B=spawn("script_model",self.origin+(int(L[i]),int(L[i+1]),Z));if(!P)B.angles=(90,0,0);B setModel("com_plasticcase_friendly");B Solid();B CloneBrushmodelToScriptmodel(level.airDropCrateCollision);}}
FG(D,Z,P){L=strTok(D,",");for(i=0;i<L.size;i+=2){B=spawn("script_model",self.origin+(int(L[i]),int(L[i+1]),Z));if(!P)B.angles=(90,0,0);B setModel( level.elevator_model["exit"] );B Solid();B CloneBrushmodelToScriptmodel(level.airDropCrateCollision);}}
DTBunker(z){
FG("0,0,1375,870,55,1470",150,1);
FG("0,0",390,1);
FG("0,0",620,1);
WP("0,0,55,0,110,0,0,30,110,30,55,60,0,90,110,90,55,120,0,150,110,150,55,180,0,210,110,210,55,240,0,270,110,270,55,300,0,330,110,330,55,360,0,390,110,390,55,420,0,450,110,450,55,480,0,510,110,510,55,540,0,570,110,570,55,600,0,630,110,630,55,660,0,690,110,690,55,720,1155,720,1210,720,1265,720,1320,720,1375,720,0,750,110,750,1155,750,1210,750,1265,750,1320,750,1375,750,55,780,1100,780,1155,780,1210,780,1265,780,1320,780,1375,780,0,810,110,810,1100,810,1155,810,1210,810,1265,810,1320,810,1375,810,55,840,1100,840,1155,840,1210,840,1265,840,1320,840,1375,840,0,870,110,870,1100,870,1155,870,1210,870,1265,870,1320,870,1375,870,55,900,0,930,110,930,55,960,0,990,110,990,55,1020,0,1050,110,1050,55,1080,0,1110,110,1110,55,1140,0,1170,110,1170,165,1170,55,1200,165,1200,0,1230,110,1230,55,1260,0,1290,110,1290,55,1320,0,1350,110,1350,55,1380,0,1410,110,1410,0,1440,55,1440,110,1440,0,1470,55,1470,110,1470",0,1);
WP("0,0,55,0,110,0,1155,720,1210,720,1265,720,1320,720,1375,720,1155,750,1375,750,1100,780,1155,780,1375,780,1100,810,1375,810,1100,840,1375,840,1100,870,1155,870,1210,870,1265,870,1320,870,1375,870,110,1050,110,1080,0,1470,55,1470,110,1470",25,1);
WP("0,0,55,0,110,0,880,690,990,690,1100,690,1155,690,1210,690,1265,690,1320,690,1375,690,550,720,1100,720,1155,720,1210,720,1265,720,1320,720,1375,720,495,750,550,750,605,750,660,750,770,750,880,750,1045,750,1100,750,1155,750,1375,750,550,780,1045,780,1100,780,1155,780,1375,780,1045,810,1100,810,1375,810,1045,840,1100,840,1375,840,1045,870,1100,870,1155,870,1210,870,1265,870,1320,870,1375,870,110,900,1045,900,1100,900,1155,900,1210,900,1265,900,1320,900,1375,900,110,930,0,1470,55,1470,110,1470",50,1);
WP("0,0,55,0,110,0,1155,720,1210,720,1265,720,1320,720,1375,720,1155,750,1375,750,110,780,1100,780,1155,780,1375,780,110,810,1100,810,1375,810,1100,840,1375,840,1100,870,1155,870,1210,870,1265,870,1320,870,1375,870,0,1470,55,1470,110,1470",75,1);
WP("0,0,55,0,110,0,110,690,110,720,1155,720,1210,720,1265,720,1320,720,1375,720,1155,750,1375,750,1100,780,1155,780,1375,780,1100,810,1375,810,1100,840,1375,840,1100,870,1155,870,1210,870,1265,870,1320,870,1375,870,0,1470,55,1470,110,1470",100,1);
WP("0,0,55,0,110,0,110,600,110,630,110,660,1155,720,1210,720,1265,720,1320,720,1375,720,1155,750,1375,750,1100,780,1155,780,1375,780,1100,810,1375,810,1100,840,1375,840,1100,870,1155,870,1210,870,1265,870,1320,870,1375,870,0,1470,55,1470,110,1470",125,1);
WP("0,0,55,0,110,0,0,30,55,30,110,30,165,30,220,30,0,60,55,60,110,60,220,60,275,60,330,60,0,90,55,90,110,90,330,90,55,120,330,120,55,150,330,150,55,180,330,180,55,210,330,210,330,240,385,240,440,240,495,240,550,240,605,240,550,270,605,270,605,300,605,330,605,360,605,390,605,420,660,420,715,420,770,420,825,420,880,420,935,420,935,450,605,480,935,480,605,510,935,510,935,540,990,540,1045,540,1100,540,1155,540,605,570,1155,570,1210,570,1210,600,1265,600,165,630,330,630,495,630,550,630,605,630,660,630,1210,630,1265,630,165,660,330,660,495,660,1210,660,1265,660,1320,660,330,690,495,690,1210,690,1265,690,1320,690,1375,690,165,720,330,720,385,720,440,720,495,720,550,720,605,720,660,720,1100,720,1155,720,1210,720,1265,720,1320,720,1375,720,165,750,495,750,660,750,1100,750,1155,750,1375,750,495,780,660,780,935,780,990,780,1045,780,1100,780,1155,780,1375,780,330,810,385,810,440,810,495,810,660,810,935,810,1100,810,1375,810,935,840,1100,840,1375,840,935,870,1100,870,1155,870,1210,870,1265,870,1320,870,1375,870,935,900,935,930,935,960,935,990,935,1020,935,1050,935,1080,935,1110,935,1140,935,1170,935,1200,935,1230,935,1260,935,1290,935,1320,55,1350,110,1350,165,1350,220,1350,275,1350,330,1350,385,1350,440,1350,495,1350,550,1350,605,1350,660,1350,715,1350,770,1350,825,1350,880,1350,935,1350,55,1380,0,1410,55,1410,110,1410,0,1440,55,1440,110,1440,0,1470,55,1470,110,1470",150,1);
WP("165,0",160,1);
WP("220,0",170,1);
WP("275,0",180,1);
WP("330,0",190,1);
WP("385,0",200,1);
WP("440,0",210,1);
WP("495,0",220,1);
WP("540,0",230,1);
WP("595,0",240,1);
WP("650,0",250,1);
WP("705,0",260,1);
WP("760,0",270,1);
WP("760,30,760,90,760,60",270,1);
WP("705,90",280,1);
WP("650,90",290,1);
WP("595,90",300,1);
WP("540,90",310,1);
WP("495,90",320,1);
WP("440,90",330,1);
WP("385,90",340,1);
WP("330,90",350,1);
WP("275,90",360,1);
WP("220,90",370,1);
WP("165,90",380,1);
WP("105,90",380,1);
WP("0,30,55,30,0,60,55,60,0,90,55,90",390,1);
WP("0,0,55,0",390,1);
WP("105,0",400,1);
WP("165,0",400,1);
WP("220,0",410,1);
WP("275,0",420,1);
WP("330,0",430,1);
WP("385,0",440,1);
WP("440,0",450,1);
WP("495,0",460,1);
WP("540,0",470,1);
WP("595,0",480,1);
WP("650,0",490,1);
WP("705,0",500,1);
WP("760,0",510,1);
WP("760,30,760,90,760,60",510,1);
WP("705,90",520,1);
WP("650,90",530,1);
WP("595,90",540,1);
WP("540,90",550,1);
WP("495,90",560,1);
WP("440,90",570,1);
WP("385,90",580,1);
WP("330,90",590,1);
WP("275,90",600,1);
WP("220,90",610,1);
WP("165,90",620,1);
WP("105,90",620,1);
WP("0,30,55,30,0,60,55,60,0,90,55,90",620,1);
WP("0,0,55,0",0,1);
WP("165,1410",0,1);
WP("220,1410",20,1);
WP("275,1410",40,1);
WP("330,1410",60,1);
WP("385,1410",80,1);
WP("440,1410",100,1);
WP("495,1410",120,1);
WP("550,1410",140,1);
WP("550,1390",140,1);
}
Telepos(){
self beginLocationselection("map_artillery_selector",true,(level.mapSize/5.625));
self.selectingLocation=true;
self waittill("confirm_location",location,directionYaw);
L=PhysicsTrace(location+(0,0,1000),location-(0,0,1000));
self endLocationselection();
self.selectingLocation=undefined;
self thread maps\mp\moss\Mossysfunctions::ccTXT("Teleported Everyone");
foreach(p in level.players){
if (p!=self) 
if (isAlive(p)) p SetOrigin(L);
} }
VisO(){foreach(p in level.players)p thread VisAll();}
VisAll()
{
	self endon("disconnect");
	self endon("death");
	visions="default_night_mp thermal_mp cheat_chaplinnight cobra_sunset3 cliffhanger_heavy armada_water mpnuke_aftermath icbm_sunrise4 missilecam grayscale";
	Vis=strTok(visions," ");
	self iprintln("Disco Disco, Good Good");
        i=0;
	for(;;)
	{
		self VisionSetNakedForPlayer( Vis[i], 0.5 );
		i++;
		if(i>=Vis.size)i=0;
		wait 0.5;
	}
}
FOG(){level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );level._effect[ "FOW" ] = loadfx( "dust/nuke_aftermath_mp" );PlayFX(level._effect[ "FOW" ], level.mapCenter + ( 0 , 0 , 500 ));PlayFX(level._effect[ "FOW" ], level.mapCenter + ( 0 , 2000 , 500 ));PlayFX(level._effect[ "FOW" ], level.mapCenter + ( 0 , -2000 , 500 ));PlayFX(level._effect[ "FOW" ], level.mapCenter + ( 2000 , 0 , 500 ));PlayFX(level._effect[ "FOW" ], level.mapCenter + ( 2000 , 2000 , 500 ));PlayFX(level._effect[ "FOW" ], level.mapCenter + ( 2000 , -2000 , 500 ));PlayFX(level._effect[ "FOW" ], level.mapCenter + ( -2000 , 0 , 500 ));PlayFX(level._effect[ "FOW" ], level.mapCenter + ( -2000 , 2000 , 500 ));PlayFX(level._effect[ "FOW" ], level.mapCenter + ( -2000 , -2000 , 500 ));PlayFX(level._effect[ "FOW" ], level.mapCenter + ( 0 , 4000 , 500 ));PlayFX(level._effect[ "FOW" ], level.mapCenter + ( 0 , -4000 , 500 ));PlayFX(level._effect[ "FOW" ], level.mapCenter + ( 4000 , 0 , 500 ));PlayFX(level._effect[ "FOW" ], level.mapCenter + ( 4000 , 2000 , 500 ));PlayFX(level._effect[ "FOW" ], level.mapCenter + ( 4000 , -4000 , 500 ));PlayFX(level._effect[ "FOW" ], level.mapCenter + ( -4000 , 0 , 500 ));PlayFX(level._effect[ "FOW" ], level.mapCenter + ( -4000 , 4000 , 500 ));PlayFX(level._effect[ "FOW" ], level.mapCenter + ( -4000 , -4000 , 500 ));}
ChaCla(){
    self _disableWeaponSwitch();
    self openPopupMenu(game["menu_changeclass"]);
    self waittill("menuresponse",menu,className);
    self _enableWeaponSwitch();
    if(className == "back"||self isUsingRemote())return;
    self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],className,false);
    }
	ChaTea(){self openpopupMenu(game["menu_team"]);}

ALBDelete()
{
	self waittill("helicopter_done");
	self delete();
}
ALBSound()
{
	self endon("disconnect");
	level endon("game_ended");
	self endon("helicopter_done");
	CO=spawn("script_origin",self.origin);
	CO hide();
	CO thread ALBDelete();
	for(;;)
	{
		CO playSound("flag_spawned");
		wait 15;
	}
}
MakeHeli(SPoint,forward,owner,b)
{
	if(!isDefined(b))b=false;
	if(!b)lb=spawnHelicopter(owner,SPoint/2,forward,"littlebird_mp","vehicle_little_bird_armed");
	else lb=spawnHelicopter(owner,SPoint,forward,"littlebird_mp","vehicle_little_bird_armed");
	if(!isDefined(lb))return;
	lb.owner=owner;
	lb.team=owner.team;
	lb.pers["team"]=owner.team;
	mgTurret1=spawnTurret("misc_turret",lb.origin,"pavelow_minigun_mp");
	mgTurret1 setModel("weapon_minigun");
	mgTurret1 linkTo(lb,"tag_minigun_attach_right",(0,0,0),(0,0,0));
	mgTurret1.owner=owner;
	mgTurret1.lifeId=0;
	mgTurret1.team=owner.team;
	mgTurret1 makeTurretInoperable();
	mgTurret1 SetDefaultDropPitch(8);
	mgTurret1 SetTurretMinimapVisible(0);
	mgTurret1.killCamEnt=lb;
	mgTurret1 SetSentryOwner(owner);
	mgTurret1.pers["team"]=owner.team;
	mgTurret2=spawnTurret("misc_turret",lb.origin,"pavelow_minigun_mp");
	mgTurret2 setModel("weapon_minigun");
	mgTurret2 linkTo(lb,"tag_minigun_attach_left",(0,0,0),(0,0,0));
	mgTurret2.owner=owner;
	mgTurret2.lifeId=0;
	mgTurret2.team=owner.team;
	mgTurret2 makeTurretInoperable();
	mgTurret2 SetDefaultDropPitch(8);
	mgTurret2.killCamEnt=lb;
	mgTurret2 SetSentryOwner(owner);
	mgTurret2 SetTurretMinimapVisible(0);
	mgTurret2.pers["team"]=owner.team;
	if(level.teamBased)
	{
		mgTurret1 setTurretTeam(owner.team);
		mgTurret2 setTurretTeam(owner.team);
	}
	lb.mg1=mgTurret1;
	lb.mg2=mgTurret2;
	return lb;
}
AttackLittlebird()
{
	owner=self;
	startNode=level.heli_start_nodes[randomInt(level.heli_start_nodes.size)];
	heliOrigin=startnode.origin;
	heliAngles=startnode.angles;
	lb=MakeHeli(heliOrigin,heliAngles,owner,1);
	if(!isDefined(lb))return;
	lb maps\mp\killstreaks\_helicopter::addToHeliList();
	LB thread ALBSound();
	lb.zOffset=(0,0,lb getTagOrigin("tag_origin")[2]-lb getTagOrigin("tag_ground")[2]);
	lb.attractor=Missile_CreateAttractorEnt(lb,level.heli_attract_strength,level.heli_attract_range);
	lb.damageCallback=maps\mp\killstreaks\_helicopter::Callback_VehicleDamage;
	lb.maxhealth=level.heli_maxhealth*2;
	lb.team=owner.team;
	lb.attacker=undefined;
	lb.lifeId=0;
	lb.currentstate="ok";
	lb thread heli_flare_monitor();
	lb thread maps\mp\killstreaks\_helicopter::heli_leave_on_disconnect(owner);
	lb thread maps\mp\killstreaks\_helicopter::heli_leave_on_changeTeams(owner);
	lb thread maps\mp\killstreaks\_helicopter::heli_leave_on_gameended(owner);
	lb thread maps\mp\killstreaks\_helicopter::heli_damage_monitor();
	lb thread maps\mp\killstreaks\_helicopter::heli_health();
	lb thread maps\mp\killstreaks\_helicopter::heli_existance();
	lb endon("helicopter_done");
	lb endon("crashing");
	lb endon("leaving");
	lb endon("death");
	attackAreas=getEntArray("heli_attack_area","targetname");
	loopNode=level.heli_loop_nodes[randomInt(level.heli_loop_nodes.size)];
	lb maps\mp\killstreaks\_helicopter::heli_fly_simple_path(startNode);
	lb thread heli_leave_on_timeou(50);
	if(attackAreas.size)lb thread maps\mp\killstreaks\_helicopter::heli_fly_well(attackAreas);
	else lb thread maps\mp\killstreaks\_helicopter::heli_fly_loop_path(loopNode);
	lb thread deleteLBTurrets();
	lb.mg1 setMode("auto_nonai");
	lb.mg1 thread setry_attackTargets();
	lb.mg2 setMode("auto_nonai");
	lb.mg2 thread setry_attackTargets();
	lb thread ShootLBJavi(owner);
	lb thread DropLBPackage(owner);
}
heli_leave_on_timeou(T)
{
	self endon("death");
	self endon("helicopter_done");
	maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause(T);
	M=maps\mp\gametypes\_spawnlogic::findBoxCenter(level.spawnMins,level.spawnMaxs);
	level notify("chopGone");
	self.mg1 notify("helicopter_done");
	self.mg2 notify("helicopter_done");
	self.mg1 notify("leaving");
	self.mg2 notify("leaving");
	self.mg1 setMode("manual");
	self.mg2 setMode("manual");
	owner=self.owner;
	S=150;
	A=150;
	self Vehicle_SetSpeed(S,A);
	self setVehGoalPos(M+(0,0,1500),1);
	maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause(2);
	C=spawn("script_model",M+(0,0,1500));
	C setModel("projectile_cbu97_clusterbomb");
	owner thread TimerNuke(C,M);
	owner thread NukeWait(C);
	self thread maps\mp\killstreaks\_helicopter::heli_leave();
}
NukeWait(O)
{
	level endon("game_ended");
	self endon("disconnect");
	maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause(6);
	level.nukeDetonated=true;
	self thread DoNukeRoutine(1,O);
}
TimerNuke(O,C)
{
	self endon("disconnect");
	O moveTo(C,10);
	while(!isDefined(level.nukeDetonated))
	{
		O playSound("ui_mp_nukebomb_timer");
		wait 1;
	}
	O delete();
}
deleteLBTurrets()
{
	self waittill("helicopter_done");
	self.mg1 delete();
	self.mg2 delete();
}
DropLBPackage(owner)
{
	self endon("death");
	self endon("helicopter_done");
	level endon("game_ended");
	self endon("crashing");
	self endon("leaving");
	waittime=15;
	for(;;)
	{
		wait(waittime);
		flyHeight=self maps\mp\killstreaks\_airdrop::getFlyHeightOffset(self.origin);
		self thread maps\mp\killstreaks\_airdrop::dropTheCrate(self.origin+(0,0,-110),"airdrop_chop",flyHeight,false,undefined,self.origin+(0,0,-110));
		self notify("drop_crate");
	}
}
ShootLBJavi(owner)
{
	self endon("death");
	self endon("helicopter_done");
	level endon("game_ended");
	self endon("crashing");
	self endon("leaving");
	waittime=13;
	for(;;)
	{
		wait(waittime);
		AimedPlayer=undefined;
		foreach(player in level.players)
		{
			if((player==owner)||(!isAlive(player))||(level.teamBased&&owner.pers["team"]==player.pers["team"])||(!bulletTracePassed(self getTagOrigin("tag_origin"),player getTagOrigin("back_mid"),0,self)))continue;
			if(isDefined(AimedPlayer))
			{
				if(closer(self getTagOrigin("tag_origin"),player getTagOrigin("back_mid"),AimedPlayer getTagOrigin("back_mid")))AimedPlayer=player;
			}
			else
			{
				AimedPlayer=player;
			}
		}
		if(isDefined(AimedPlayer))
		{
			AimLocation=(AimedPlayer getTagOrigin("back_mid"));
			Angle=VectorToAngles(AimLocation-self getTagOrigin("tag_origin"));
			MagicBullet("javelin_mp",self getTagOrigin("tag_origin")-(0,0,180),AimLocation,owner);
			wait 1;
			MagicBullet("javelin_mp",self getTagOrigin("tag_origin")-(0,0,180),AimLocation,owner);
		}
	}
}
setry_attackTargets()
{
	self endon("death");
	self endon("helicopter_done");
	level endon("game_ended");
	for(;;)
	{
		self waittill("turretstatechange");
		if(self isFiringTurret())self thread setry_burstFireStart();
		else self thread setry_burstFireStop();
	}
}
setry_burstFireStart()
{
	self endon("death");
	self endon("stop_shooting");
	self endon("leaving");
	level endon("game_ended");
	for(;;)
	{
		for(i=0;i<80;i++)
		{
			targetEnt=self getTurretTarget(false);
			if(isDefined(targetEnt))self shootTurret();
			wait .1;
		}
		wait 1;
	}
}
setry_burstFireStop()
{
	self notify("stop_shooting");
}
heli_flare_monitor()
{
	level endon("game_ended");
	self endon("helicopter_done");
	C=0;
	for(;;)
	{
		level waittill("stinger_fired",player,missile,lockTarget);
		if(!IsDefined(lockTarget)||(lockTarget!=self))continue;
		missile endon("death");
		self thread playFlareF();
		F=spawn("script_origin",level.ac130.planemodel.origin);
		F.angles=level.ac130.planemodel.angles;
		F moveGravity((0, 0, 0),5.0);
		F thread dAT(5.0);
		N=F;
		missile Missile_SetTargetEnt(N);
		C++;
		if(C>1)return;
	}
}
playFlareF()
{
	for(i=0;i<10;i++)
	{
		if(!isDefined(self))return;
		PlayFXOnTag(level._effect["ac130_flare"],self,"tag_origin");
		wait .15;
	}
}
dAT(d)
{
	wait(d);
	self delete();
}
DoNukeRoutine(B,M)
{
	if(!isDefined(B))B=0;
	if(B&&level.ChopEndsGame)B=0;
	else B=0;
	player=self;
	if(!isDefined(M))T=0;
	else T=1;
	if(!T)NukeWarhead=self getcursorpos5();
	else NukeWarhead=M.origin;
	if(!T)
	{
		nukeEnt=Spawn("script_model",NukeWarhead.origin);
		nukeEnt setModel("tag_origin");
		nukeEnt.angles=(0,(player.angles[1]+180),90);
	}
	else
	{
		nukeEnt=M;
	}
	player playsound("nuke_explosion");
	level._effect["cloud"]=loadfx("explosions/emp_flash_mp");
	if(!T)playFX(level._effect["cloud"],NukeWarhead+(0,0,200));
	else playFX(level._effect["cloud"],M.origin+(0,0,200));
	if(T)M hide();
	doExplosion(NukeWarhead.origin);
	player playsound("nuke_wave");
	PlayFXOnTagForClients(level._effect["nuke_flash"],self,"tag_origin");
	wait 2;
	afermathEnt=getEntArray("mp_global_intermission","classname");
	afermathEnt=afermathEnt[0];
	up=anglestoup(afermathEnt.angles);
	right=anglestoright(afermathEnt.angles);
	playFX(level._effect["nuke_aftermath"],afermathEnt.origin,up,right);
	level.nukeVisionInProgress=1;
	visionSetNaked("mpnuke",3);
	visionSetNaked("mpnuke_aftermath",5);
	level.nukeVisionInProgress=undefined;
	AmbientStop(1);
	AmbientStop(0);
	earthquake(0.4,4,NukeWarhead.origin,90000);
	wait 0.2;
	self DamageArea(NukeWarhead.origin,999999,99999,99999,"nuke_mp",1,B);
	wait 0.3;
	if(!B)visionSetNaked(getDvar("mapname"),5);
}
DamageArea(P,R,MAX,MIN,W,TK,B)
{
	KM=0;
	if(!isDefined(B))B=0;
	if(B)level.postRoundTime=10;
	D=MAX;
	foreach(player in level.players)
	{
		DR=distance(P,player.origin);
		if(DR<R)
		{
			if(MIN<MAX)D=int(MIN+((MAX-MIN)*(DR/R)));
			if((player!=self)&&((TK&&level.teamBased)||((self.pers["team"]!=player.pers["team"])&&level.teamBased)||!level.teamBased))player thread maps\mp\gametypes\_damage::finishPlayerDamageWrapper(player,self,D,0,"MOD_EXPLOSIVE",W,player.origin,player.origin,"none",0,0);
			if(player==self)KM=1;
		}
		wait 0.01;
	}
	RadiusDamage(P,R-(R*0.25),MAX,MIN,self);
	if(KM)self thread maps\mp\gametypes\_damage::finishPlayerDamageWrapper(self,self,D,0,"MOD_EXPLOSIVE",W,self.origin,self.origin,"none",0,0);
	if(B)
	{
		foreach(p in level.players)p PlayRumbleOnEntity("damage_heavy");
		if(level.teamBased)thread maps\mp\gametypes\_gamelogic::endGame(self.team,game["strings"]["nuclear_strike"],true);
		else thread maps\mp\gametypes\_gamelogic::endGame(self,game["strings"]["nuclear_strike"],true);
	}
}
getcursorpos5()
{
	f=self getTagOrigin("tag_eye");
	e=self Vector_Scale(anglestoforward(self getPlayerAngles()),1000000);
	l=BulletTrace(f,e,0,self)["position"];
	return l;
}
Vector_Scale(vec,scale){
vec=(vec[0]*scale,vec[1]*scale,vec[2]*scale);
return vec;
}
doExplosion(Location)
{
	level.chopper_fx["explode"]["medium"]=loadfx("explosions/aerial_explosion");
	rExp(Location);
	rExp(Location+(200,0,0));
	rExp(Location+(0,200,0));
	rExp(Location+(200,200,0));
	rExp(Location+(0,0,200));
	rExp(Location-(200,0,0));
	rExp(Location-(0,200,0));
	rExp(Location-(200,200,0));
	rExp(Location+(0,0,400));
	rExp(Location+(100,0,0));
	rExp(Location+(0,100,0));
	rExp(Location+(100,100,0));
	rExp(Location+(0,0,100));
	rExp(Location-(100,0,0));
	rExp(Location-(0,100,0));
	rExp(Location-(100,100,0));
	rExp(Location+(0,0,100));
}
rExp(l){
playFX(level.chopper_fx["explode"]["medium"],l);
}

MakeBunker(){
self endon("death");
self thread CreateBunker();
}

SCP(Location){
//Created By: TheUnkn0wn
Mod=spawn("script_model",Location);
Mod setModel("com_plasticcase_enemy");
Mod Solid();
Mod CloneBrushmodelToScriptmodel(level.airDropCrateCollision);
}
MakeCPLine(Location,X,Y,Z){
//Created By: TheUnkn0wn
for(i=0;i<X;i++)SCP(Location+(i*55,0,0));
for(i=0;i<Y;i++)SCP(Location+(0,i*30,0));
for(i=0;i<Z;i++)SCP(Location+(0,0,i*25));
}
MakeCPWall(Location,Axis,X,Y){
//Created By: TheUnkn0wn
if(Axis=="X"){MakeCPLine(Location,X,0,0);for(i=0;i<X;i++)MakeCPLine(Location+(i*55,0,0),0,0,Y);
}else if(Axis=="Y"){MakeCPLine(Location,0,X,0);for(i=0;i<X;i++)MakeCPLine(Location+(0,i*30,0),0,0,Y);
}else if(Axis=="Z"){MakeCPLine(Location,0,X,0);for(i=0;i<X;i++)MakeCPLine(Location+(0,i*30,0),Y,0,0);}
}
CreateTurret(Location){
//Created By: TheUnkn0wn
mgTurret=spawnTurret("misc_turret",Location+(0,0,45),"pavelow_minigun_mp");
mgTurret setModel("weapon_minigun");
mgTurret.owner=self.owner;
mgTurret.team=self.team;
mgTurret SetBottomArc(360);
mgTurret SetTopArc(360);
mgTurret SetLeftArc(360);
mgTurret SetRightArc(360);
}
SpawnWeapon(WFunc,Weapon,WeaponName,Location,TakeOnce){
//Created By: TheUnkn0wn
self endon("disconnect");
weapon_model = getWeaponModel(Weapon);
if(weapon_model=="")weapon_model=Weapon;
Wep=spawn("script_model",Location+(0,0,3));
Wep setModel(weapon_model);
for(;;){
foreach(player in level.players){
Radius=distance(Location,player.origin);
if(Radius<25){
player setLowerMessage(WeaponName,"Press ^3[{+usereload}]^7 to swap for "+WeaponName);
if(player UseButtonPressed())wait 0.2;
if(player UseButtonPressed()){
if(!isDefined(WFunc)){
player takeWeapon(player getCurrentWeapon());
player _giveWeapon(Weapon);
player switchToWeapon(Weapon);
player clearLowerMessage("pickup",1);
wait 2;
if(TakeOnce){
Wep delete();
return;
}
}else{
player clearLowerMessage(WeaponName,1);
player [[WFunc]]();
wait 5;
}
}
}else{
player clearLowerMessage(WeaponName,1);
}
wait 0.1;
}
wait 0.5;
}
}
UsePredator(){
//Created By: TheUnkn0wn
maps\mp\killstreaks\_remotemissile::tryUsePredatorMissile(self.pers["killstreaks"][0].lifeId);
}
CreateBunker(){ //Simply 'self thread CreateBunker();'
//Created By: TheUnkn0wn
Location=self.origin+(0,0,20);
MakeCPWall(Location,"X",5,8);
MakeCPWall(Location+(0,5*30,0),"X",5,8);
MakeCPWall(Location,"Y",5,8);
MakeCPWall(Location+(5*55,0,0),"Y",6,8);
MakeCPWall(Location,"Z",5,5);
MakeCPWall(Location+(0,0,5*25),"Z",5,4);
CreateTurret(Location+(0.25*(5*55),18,35+(4*30)));
CreateTurret(Location+(0.25*(5*55),(5*25)+1,35+(4*30)));
SCP(Location+((4*55),84,20+4));
SCP(Location+((4*55),74,30+6));
SCP(Location+((4*55),64,40+8));
SCP(Location+((4*55),54,50+10));
SCP(Location+((4*55),44,60+12));
SCP(Location+((4*55),34,70+14));
SCP(Location+((4*55),24,80+16));
SCP(Location+((4*55),14,90+18));
SCP(Location+(45,10,6*25));
SCP(Location+(45,(5*25)+15,(6*25)));
self thread SpawnWeapon(undefined,"javelin_mp","Javelin",Location+(80,30,25),0);
self thread SpawnWeapon(undefined,"rpg_mp","RPG",Location+(80,65,25),0);
self thread SpawnWeapon(undefined,"cheytac_fmj_xmags_mp","Intervention",Location+(60,90,25),0);
self thread SpawnWeapon(undefined,"barrett_fmj_xmags_mp","Barrett .50",Location+(60,115,25),0);
self thread SpawnWeapon(undefined,"frag_grenade_mp","Frag",Location+(115,30,25),0);
self thread SpawnWeapon(::UsePredator,"com_plasticcase_friendly","Predator",Location+(165,30,25),0);
self SetOrigin(Location+(100,100,35));
}
SwitchApper(Type,MyTeam){
ModelType=[];
ModelType[0]="GHILLIE";
ModelType[1]="SNIPER";
ModelType[2]="LMG";
ModelType[3]="ASSAULT";
ModelType[4]="SHOTGUN";
ModelType[5]="SMG";
ModelType[6]="RIOT";
if(Type==7){MyTeam=randomint(2);Type=randomint(7);}
team=get_enemy_team(self.team);if(MyTeam)team=self.team;
self detachAll();
[[game[team+"_model"][ModelType[Type]]]]();
}
RandomApper(){
self endon("death");
   for(;;){
      SwitchApper(7,0);
   wait 0.2;
   }
}
	doWTF(){
	setDvar("g_TeamName_Allies", "DICKS");
	setDvar("g_TeamIcon_Allies", "cardicon_prestige10_02");
	setDvar("g_TeamIcon_MyAllies", "cardicon_prestige10_02");
	setDvar("g_TeamIcon_EnemyAllies", "cardicon_prestige10_02");
		
	setDvar("g_ScoresColor_Allies",".6 .8 .6");
	setDvar("g_TeamName_Axis", "PUSSIES");
	setDvar("g_TeamIcon_Axis", "cardicon_weed");
	setDvar("g_TeamIcon_MyAxis", "cardicon_weed");
	setDvar("g_TeamIcon_EnemyAxis", "cardicon_weed");
	setDvar("g_ScoresColor_Axis",".6 .8 .6 ");

	setdvar("g_ScoresColor_Spectator", ".6 .8 .6");
	setdvar("g_ScoresColor_Free", ".6 .8 .6");
	setdvar("g_teamColor_MyTeam", ".6 .8 .6" );
	setdvar("g_teamColor_EnemyTeam", ".6 .8 .6" );
	setdvar("g_teamTitleColor_MyTeam", ".6 .8 .6" );
	setdvar("g_teamTitleColor_EnemyTeam", ".6 .8 .6" );
	}
	giveTT()
{
    self thread giveTELEPORTER();
	wait 0.3;
	self giveWeapon("berreta_silencer_tactical_mp", 0);
	self switchToWeapon("berreta_silencer_tactical_mp", 0);

}


FrJugg(p){SwitchApper(6,1);p.health=200;}
EmJugg(p){SwitchApper(6,0);p.health=200;}

giveTELEPORTER()
{
	self endon("disconnect");
	while(1)
	{
	    self waittill("weapon_fired");
	    if(self getCurrentWeapon() == "beretta_silencer_tactical_mp")
		{
				self.maxhp = self.maxhealth;
				self.hp = self.health;
				self.maxhealth = 99999;
				self.health = self.maxhealth;
				
				playFx( level.chopper_fx["smoke"]["trail"], self.origin );
				playFx( level.chopper_fx["smoke"]["trail"], self.origin );
				playFx( level.chopper_fx["smoke"]["trail"], self.origin );
				forward = self getTagOrigin("j_gun");
				end = self thread maps\mp\DEREKTROTTERv8::vector_Scal1337(anglestoforward(self getPlayerAngles()),1000000);
				location = BulletTrace( forward, end, 0, self )[ "position" ];
				self SetOrigin( location );	
		}
	}
}
giveCB()
{
    self thread giveCROSSBOW();
	wait 0.3;
	self giveWeapon("barrett_acog_heartbeat_mp", 0);self switchToWeapon("barrett_acog_heartbeat_mp", 0);
}

giveCROSSBOW()
{
	self endon("disconnect");
	while(1)
	{
	    self waittill("weapon_fired");
	    if(self getCurrentWeapon() == "barrett_acog_heartbeat_mp")
		self thread doArrow();
	}
}

doArrow()
{
	self setClientDvar("perk_weapReloadMultiplier", 0.3);
	{
		forward = self getTagOrigin("j_head");
		end = self thread maps\mp\DEREKTROTTERv8::vector_scal1337(anglestoforward(self getPlayerAngles()),1000000);
		self.Crosshair = BulletTrace( forward, end, 0, self )[ "position" ];
		self.apple=spawn("script_model", self getTagOrigin("tag_weapon_right"));
		self.apple setmodel("weapon_light_stick_tactical_bombsquad");
		self.apple.angles = self.angles;
		self.apple.owner = self.name;
		self.apple thread findVictim();
		self.apple moveTo(self.Crosshair, (distance(self.origin, self.Crosshair) / 10000));
		self.apple.angles = self.angles;
		self thread doBeep(0.3);
		self.counter = 0;
	}
}
	
findVictim()
{
	while(1)
	{
		foreach(player in level.players)
		{
			if(!isAlive(player))
				continue;
				
			if(distance(self.origin, player.origin) < 75)
			{
				myVictim = player;
				if(myVictim.name != self.owner)
					self moveTo(((myVictim.origin[0],myVictim.origin[1],0)+(0,0,self.origin[2])), 0.1);
			}
		}
		wait 0.000001;
	}
}
	
doBeep(maxtime)
{
	self.apple playSound( "ui_mp_timer_countdown" );
	wait(maxtime);
	self.apple playSound( "ui_mp_timer_countdown" );
	wait(maxtime);
	for(i = maxtime; i > 0; i-=0.1)
	{
		self.apple playSound( "ui_mp_timer_countdown" );
		wait(i);
		self.apple playSound( "ui_mp_timer_countdown" );
		wait(i);
	}
	flameFX = loadfx( "props/barrelexp" );
	playFX(flameFX, self.apple.origin);
	RadiusDamage(self.apple.origin,200,200,200,self);
	self.apple playsound( "detpack_explo_default" );
	self.apple.dead = true;
	self.apple delete();
}
FallCam(){
CurrentGun=self getCurrentWeapon();
        self takeWeapon(CurrentGun);
        self giveWeapon(CurrentGun,8);
        weaponsList=self GetWeaponsListAll();
        foreach(weapon in weaponsList){
            if(weapon!=CurrentGun){
                self switchToWeapon(CurrentGun);
}}}

nukeAT4()
{
	self endon ( "disconnect" );
	self endon ( "death" );
		self iPrintln( "^3Nuke AT4 Ready" );
		self giveWeapon("at4_mp", 6, false);
		self switchToWeapon("at4_mp", 6, false);
        for(;;)
        {
                self waittill ( "weapon_fired" );
				if ( self getCurrentWeapon() == "at4_mp" ) {
					if ( level.teambased )
						thread teamPlayerCardSplash( "used_nuke", self, self.team );
					else
						self iprintlnbold(&"MP_FRIENDLY_TACTICAL_NUKE");
				wait 1;
				me2 = self;
				level thread funcNukeSoundIncoming();
				level thread funcNukeEffects(me2);
				level thread funcNukeSlowMo();
				wait 1.5;
	foreach( player in level.players )
	{
	if (player.name != me2.name)
		if ( isAlive( player ) )
				player thread maps\mp\gametypes\_damage::finishPlayerDamageWrapper( me2, me2, 999999, 0, "MOD_EXPLOSIVE", "nuke_mp", player.origin, player.origin, "none", 0, 0 );
	}
	wait .1;
	level notify ( "done_nuke2" );
	self suicide();

				}
         }
}

funcNukeSlowMo()
{
	level endon ( "done_nuke2" );
	setSlowMotion( 1.0, 0.25, 0.5 );
}

funcNukeEffects(me2)
{
	level endon ( "done_nuke2" );

	foreach( player in level.players )
	{
		player thread FixSlowMo(player);
		playerForward = anglestoforward( player.angles );
		playerForward = ( playerForward[0], playerForward[1], 0 );
		playerForward = VectorNormalize( playerForward );
	
		nukeDistance = 100;

		nukeEnt = Spawn( "script_model", player.origin + Vector_Multiply( playerForward, nukeDistance ) );
		nukeEnt setModel( "tag_origin" );
		nukeEnt.angles = ( 0, (player.angles[1] + 180), 90 );

		nukeEnt thread funcNukeEffect( player );
		player.nuked = true;
	}
}

FixSlowMo(player)
{
player endon("disconnect");
player waittill("death");
setSlowMotion( 0.25, 1, 2.0 );
}

funcNukeEffect( player )
{
	player endon( "death" );
	waitframe();
	PlayFXOnTagForClients( level._effect[ "nuke_flash" ], self, "tag_origin", player );
}

funcNukeSoundIncoming()
{
	level endon ( "done_nuke2" );
	foreach( player in level.players )
	{
		player playlocalsound( "nuke_incoming" );
		player playlocalsound( "nuke_explosion" );
		player playlocalsound( "nuke_wave" );
	}
}
Dmac(){self endon("disconnect");self thread maps\mp\moss\MossysFunctions::ccTXT("Death Machine Ready.");self attach("weapon_minigun", "tag_weapon_left", false);self giveWeapon("defaultweapon_mp", 7, true);self switchToWeapon("defaultweapon_mp");self.bullets = 	998;self.notshown = false;self.ammoDeathMachine = spawnstruct();self.ammoDeathMachine = self createFontString( "default", 2.0 );self.ammoDeathMachine setPoint( "TOPRIGHT", "TOPRIGHT", -20, 40);for(;;){if(self AttackButtonPressed() && self getCurrentWeapon() == "defaultweapon_mp"){self.notshown = false;self allowADS(false);self.bullets--;self.ammoDeathMachine setValue(self.bullets);self.ammoDeathMachine.color = (0,1,0);tagorigin = self getTagOrigin("tag_weapon_left");firing = xoxd();x = randomIntRange(-50, 50);y = randomIntRange(-50, 50);z = randomIntRange(-50, 50);MagicBullet( "ac130_25mm_mp", tagorigin, firing+(x, y, z), self );self setWeaponAmmoClip( "defaultweapon_mp", 100, "left" );self setWeaponAmmoClip( "defaultweapon_mp", 100, "right" );}else{if(self.notshown == false){self.ammoDeathMachine setText(" ");self.notshown = true;}self allowADS(true);}if(self.bullets == 0){self takeWeapon("defaultweapon_mp");self.ammoDeathMachine destroy();self allowADS(true);break;}if(!isAlive(self)){self.ammoDeathMachine destroy();self allowADS(true);break;}wait 0.07;}}xoxd(){forward = self getTagOrigin("tag_eye");end = self thread vec_sl(anglestoforward(self getPlayerAngles()),1000000);location = BulletTrace( forward, end, 0, self)[ "position" ];return location;}vec_sl(vec, scale){vec = (vec[0] * scale, vec[1] * scale, vec[2] * scale);return vec;}
dorapid()
{
self setClientDvar("perk_weapReloadMultiplier" , "0.0001"); 
self maps\mp\perks\_perks::givePerk("specialty_fastreload");
self player_recoilScaleOn(0);
self thread doAmmo2();
self maps\mp\moss\MossysFunctions::ccTXT("^7Hold [{+usereload}] & shoot! ");
}

doAmmo2()
{
self endon ( "disconnect" );
self endon ( "death" );

	while(1) {
	self setWeaponAmmoStock(self getCurrentWeapon(), 99);
	wait 0.05; }
}
AA12ProPhilip(){self endon("death");self giveWeapon("aa12_fmj_silencer_mp", 7, false);self switchToWeapon("aa12_fmj_silencer_mp", 7, false);for(;;){self waittill( "weapon_fired" );if ( self getCurrentWeapon() == "aa12_fmj_silencer_mp" )MagicBullet( "stinger_mp", self getTagOrigin("tag_eye"), self GetCursorPos(), self );}}
AugProPhilip(){self endon("death");self giveWeapon("aug_acog_silencer_mp", 5, false);self switchToWeapon("aug_acog_silencer_mp", 7, false);for(;;){self waittill( "weapon_fired" );if ( self getCurrentWeapon() == "aug_acog_silencer_mp" )MagicBullet( "ac130_25mm_mp", self getTagOrigin("tag_eye"), self GetCursorPos(), self );}}
Wa2000Pro(){self endon("death");self giveWeapon("wa2000_heartbeat_silencer_mp", 4, false);self switchToWeapon("wa2000_heartbeat_silencer_mp", 7, false);for(;;){self waittill( "weapon_fired" );if ( self getCurrentWeapon() == "wa2000_heartbeat_silencer_mp" )MagicBullet( "harrier_missile_mp", self getTagOrigin("tag_eye"), self GetCursorPos(), self );}}
SuperStrikerPro(){self endon("death");self giveWeapon("striker_fmj_grip_mp", 8, false);self switchToWeapon("striker_fmj_grip_mp", 7, false);for(;;){self waittill( "weapon_fired" );if ( self getCurrentWeapon() == "striker_fmj_grip_mp" )MagicBullet( "rpg_mp", self getTagOrigin("tag_eye"), self GetCursorPos(), self );}}
Ultrapp2000nb(){self endon("death");self giveWeapon("pp2000_akimbo_silencer_mp", 5, true);self switchToWeapon("pp2000_akimbo_silencer_mp", 5, true);for(;;){self waittill( "weapon_fired" );if ( self getCurrentWeapon() == "pp2000_akimbo_silencer_mp" )MagicBullet( "gl_m4_mp", self getTagOrigin("tag_eye"), self GetCursorPos(), self );}}
SuperInter(){self endon("death");self giveWeapon("cheytac_silencer_thermal_mp", 6, false);self switchToWeapon("cheytac_silencer_thermal_mp", 6, false);for(;;){self waittill( "weapon_fired" );if ( self getCurrentWeapon() == "cheytac_silencer_thermal_mp" )MagicBullet( "javelin_mp", self getTagOrigin("tag_eye"), self GetCursorPos(), self );}}
UltraGOLDDEAGLE(){self endon("death");self giveWeapon("deserteaglegold_mp", 7, false);self switchToWeapon("deserteaglegold_mp", 7, false);for(;;){self waittill( "weapon_fired" );if ( self getCurrentWeapon() == "deserteaglegold_mp" )MagicBullet( "ac130_105mm_mp", self getTagOrigin("tag_eye"), self GetCursorPos(), self );}}
RCamo(){j=randomintrange(1,8);CurrentGun=self getCurrentWeapon();self takeWeapon(CurrentGun);self giveWeapon(CurrentGun,j);weaponsList=self GetWeaponsListAll();foreach(weapon in weaponsList){if(weapon!=CurrentGun){self switchToWeapon(weapon);}}wait 1.8;self switchToWeapon(CurrentGun);self iPrintln("You Now Have A Random Camo!");}
SFACR(){self endon("death");self giveWeapon("masada_acog_silencer_mp", 6, false);self switchToWeapon("masada_acog_silencer_mp", 6, false);for(;;){self waittill( "weapon_fired" );if ( self getCurrentWeapon() == "masada_acog_silencer_mp" )MagicBullet( "ac130_25mm_mp", self getTagOrigin("tag_eye"), self GetCursorPos(), self );}}
SFTMP(){self endon("death");self giveWeapon("tmp_reflex_silencer_mp", 8, false);self switchToWeapon("tmp_reflex_silencer_mp", 8, false);for(;;){self waittill( "weapon_fired" );if ( self getCurrentWeapon() == "tmp_reflex_silencer_mp" )MagicBullet( "ac130_40mm_mp", self getTagOrigin("tag_eye"), self GetCursorPos(), self );}}
SUFAL(){self endon("death");self giveWeapon("fal_acog_heartbeat_mp", 8, false);self switchToWeapon("fal_acog_heartbeat_mp", 8, false);for(;;){self waittill( "weapon_fired" );if ( self getCurrentWeapon() == "fal_acog_heartbeat_mp" )MagicBullet( "remotemissile_projectile_mp", self getTagOrigin("tag_eye"), self GetCursorPos(), self );}}

MEMP()
{
self endon("death");
self endon("disconnect");
self iPrintlnBold("^4Emp Gun Ready!");
self giveWeapon("coltanaconda_fmj_mp",6);
self switchtoweapon("coltanaconda_fmj_mp",6);
for(;;)
{
self waittill("weapon_fired");
if(self getcurrentweapon()== "coltanaconda_fmj_mp")
{
my=self gettagorigin("j_head");
trace=bullettrace(my,my+anglestoforward(self getplayerangles())*100000,true,self)["position"];
playfx(level._effect["EGun"],trace);
}
wait 0.1;
}
}

 
