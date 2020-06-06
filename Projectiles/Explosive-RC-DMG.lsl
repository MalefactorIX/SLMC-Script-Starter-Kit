vector tar(key id)
{
    return (vector)((string)llGetObjectDetails(id,[OBJECT_POS]));
}
default
{
    on_rez(integer p)
    {
        if(p)
        {
            vector init=llGetPos();
            if(p<0)p=0;
            key id=llList2Key(llGetAgentList(AGENT_LIST_REGION,[]),p);
            vector tcheck=tar(id);
            if(llVecDist(tcheck,llGetPos())>0.5)
            {
                llOwnerSay("Unable to move to target location");
                llDie();
                return;
            }
            float falloff=llVecDist(init,tcheck);
            if(falloff<25.0)llSetDamage(100.0);
            else llSetDamage(100.0-((dist-25.0)*0.3));//Hits 0 at like 325m
            llResetTime();
            llSetStatus(STATUS_PHANTOM,0);
            while(llGetTime()<2.0)llSetRegionPos(tar(id));
            llSetStatus(STATUS_PHYSICS,1);
            llSleep(0.1);
            llDie();
        }
    }
}
