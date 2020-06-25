vector tar(key id)
{
    return (vector)((string)llGetObjectDetails(id,[OBJECT_POS]));
}
float falloffstart=40.0;//What distance to start falloff
float falloffamt=1.0;//How much per meter should damage drop
float minimumdam=25.0;//Minimum Damage weapon can do
float basedam=65.0;//Maximum damage weapon can do.
//This example would work for a normal rifle.
default
{
    on_rez(integer p)
    {
        if(p)
        {
            vector init=llGetPos();
            if(p<0)p=0;
            key id=llList2Key(llGetAgentList(AGENT_LIST_REGION,[]),p);
            vector tpos;
            llSetRegionPos(tpos=tar(id));
            float dist=llVecDist(llGetPos(),init);
            if(dist<0.5)llDie();//Object-entry check, helps keep some prims from flooding into spawns during rez delay.
            else
            {
                float damage=basedam;
                if(llVecDist(tpos,init)>falloffstart)
                {
                    damage-=dist*falloffamt;
                    if(damage<minimumdam)damage=minimumdam;
                }
                llSetDamage(damage);
                llResetTime();
                llSetStatus(STATUS_PHANTOM,0);
                while(llGetTime()<2.0&&!llGetAgentInfo(id)&AGENT_SITTING)llSetRegionPos(tar(id));
                llSetStatus(STATUS_PHYSICS,1);
                llSleep(0.1);
                llDie();
            }
        }
    }
}
