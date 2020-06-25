/*Raycast Pros:
- Bypasses RC Blockers, get lost with that shit
- Does not offset through shit
- Is actually balancable and not braindead retarded.
- Is not agentlist
- Uses infinitely less resources to a standard physical round.
- Makes cheating blatantly obvious

Raycast Cons:
- Uses only raycast and has no failsafe.
- Punishes bad aiming habits
- Damage prim can get eaten by rezqueue and delay kills.
- David Blaine isn't in the game.*/

float spread;//Degrees of spread, so 10 would be 10 Degrees. Spread is effectively half this value, so 10 would be 5 degrees maximum spread for that shot.
float rng()//RNGs spread, because I didn't want to copy and paste it 3 times.
{
    float n=0.003490658476*(llFrand(spread)-(spread*0.5));//
    return n;
}
rotation spr()//Generates spread rotation
{
    rotation sp=llEuler2Rot(<rng(),rng(),rng()>);
    return sp;
}
float recover=1.5;//How long it takes to fully reset spread.
fire(vector color)
{
    float time=llGetAndResetTime();
    if(time<recover)spread*=1.0-(time/recover);
    else spread=0.0;//Accuracy recovery
    while(color.z)
    {
        rotation rot=llGetCameraRot();
        if(color.y)raycast();
        else llRezObject(bullet,llGetCameraPos()+<5.0,0.0,0.0>*rot,<color.x,0.0,0.0>*spr()*rot,rot,1);//Physical Bullet
        ++spread;
        color=llGetColor(0);
    }
}
raycast()
{
    integer rp;
    vector pos=llGetCameraPos();//inb4WHYNOOFFSET
    list ray=llCastRay(pos,pos+<1000.0,0.0,0.0>*llGetCameraRot(),[RC_DATA_FLAGS,RC_GET_ROOT_KEY,RC_MAX_HITS,10]);
    integer l=llGetListLength(ray);
    //llSay(0,llDumpList2String(ray," | "));//Debug
    list agents=llGetAgentList(AGENT_LIST_REGION,[]);//Used to pass target information to damage prim.
    @start;
    //@ Loop ftw
    if(rp>=l)return;//If we have completed list without a valid hit, exit global
    key hit=llList2String(ray,rp);
    integer phantom=(integer)((string)llGetObjectDetails(hit,[OBJECT_PHANTOM]));
    if(phantom)//Hit Raycast Blocker (GTFO)
    {
        rp+=2;
        jump start;
    }
    else if(llGetAgentSize(hit))//Hit avatar
    {
        if(hit==o)//Whitelist owner, this is why we don't offset.
        {
            rp+=2;
            jump start;
        }
        integer n=llListFindList(agents,[hit]);
        if(n>-1)
        {
            if(!n)n=-1;
            llRezObject(rcbullet,llGetPos()+<0.0,0.0,4.0>,ZERO_VECTOR,ZERO_ROTATION,n);
            //llOwnerSay("Hit "+llKey2Name(hit));//This can get spammy but if you don't want to make a hit notification sound or hud, then by all means have fun.
            rp=l;//Remove this allows shows to penetrate multiple avatars, which is cool on bolt-action weapons and even cooler if you pull it off.
        }
    }
    else rp=l;//If no avatar and illegal RC wall was hit, exit global
    jump start;
}
string bullet="[LLCS]Bullet.DMG";//Name of physical bullet
string rcbullet="[LLCS]Bullet.RC";//Name of RC damage prim
key o;//Owner
default
{
    state_entry()
    {
        llRequestPermissions(o=llGetOwner(),0x414);
    }
    attach(key id)
    {
        if(id)llRequestPermissions(o=id,0x414);
    }
    link_message(integer s, integer vel, string ray, key id)//Link Message Firing (Semi Auto)
    {
        fire(<vel,(integer)ray,1.0>);
    }
    changed(integer c)//Loop Firing (Color)
    {
        if(c&CHANGED_COLOR)
        {
            vector new=llGetColor(0);
            if(new.z)fire(new);
        }
    }
    run_time_permissions(integer p)
    {
        if(p)llTakeControls(CONTROL_ML_LBUTTON,1,1);
    }
}
