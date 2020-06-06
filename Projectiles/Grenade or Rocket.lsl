//Start parameter determines fuse time.
//Positive Numbers start the timer when thrown
//Negative numbers start the timer after first impact
//0 will set the grenade to detonate on impact
integer armed;
vector vel;
boom(vector pos, integer timed)
{
    llSetLinkPrimitiveParamsFast(-1,[PRIM_PHYSICS,0,PRIM_PHANTOM,1,PRIM_COLOR,-1,ZERO_VECTOR,0.0,PRIM_GLOW,-1,0.0]);
    if(timed)
    {
        vel=pos;
        return;
    }
    list ray=llCastRay(pos,pos-(vel*0.075),[]);
    vector raypos=llList2Vector(ray,1);
    if(raypos)llSetRegionPos(vel=raypos);
    else vel=pos;
}
default
{
    on_rez(integer p)
    {
        vel=llGetVel();
        if(p)
        {
            if(p>0)
            {
                llSetTimerEvent(p);
                armed=-1;
            }
            else ++armed;
        }
    }
    collision_start(integer c)
    {
        if(armed)
        {
            if(armed<0)return;
            llSetTimerEvent(llFabs(llGetStartParameter()));
            armed=-1;
        }
        else
        {
            boom(llGetPos(),0);
            state boomed;
        }
    }
    land_collision_start(vector c)
    {
        if(armed)
        {
            if(armed<0)return;
            llSetTimerEvent(llFabs(llGetStartParameter()));
            armed=-1;
        }
        else
        {
            boom(c,0);
            state boomed;
        }
    }
    timer()
    {
        boom(llGetPos(),1);
        state boomed;
    }
}
state boomed
{
    state_entry()
    {
         //particles here
         //sound here
        llSensor("","",AGENT,5.0,PI);
    }
    sensor(integer d)
    {
        list agents=llGetAgentList(AGENT_LIST_REGION,[]);
        while(d--)
        {
            key hit=llDetectedKey(d);
            list ray=llCastRay(llDetectedPos(d),vel,[RC_REJECT_TYPES,RC_REJECT_AGENTS]);
            if(llList2Vector(ray,1)==ZERO_VECTOR)
            {
                integer param=llListFindList(agents,[hit]);
                if(param==0)param=-1;
                llRezObject("Fragmentation Blast.DMG",vel,ZERO_VECTOR,ZERO_ROTATION,param);
            }
        }
        llSleep(1.0);
        llDie();
    }
    no_sensor()
    {
        llSleep(1.0);
        llDie();
    }
}
