regionend(vector init, rotation rot)//Note, this method will not work with values in excess of 509
{
    vector dest=init+<500.0,0.0,0.0>*rot;//So we only add 500 here.
    vector norm=llVecNorm(dest-init);
    float x=llFabs(dest.x);
    float y=llFabs(dest.y);
    vector inter;
    float b;//Total distance to walk back
    if(x>y)
    {
        if(dest.x>0.0)b=dest.x-255.0;
        else b=dest.x;
        //Cross multiply, if a/b = c/d, then a*d=c*b is also true
        //We should assume norm.x (or 'A') is 1.0 at all times, if not then C is 1.0, and we need to solve for D.
        //norm.x/b = 1.0/???
        //Then we get, norm.x*??? = b. Divide b by norm.x
        if(norm.x<1.0)
        {
            if(norm.x)b=b/norm.x;//Is it possible to do this to a vector and skip a few steps?
            else //Improbable, yes. Impossible? Not sure.
            {
                llOwnerSay("You should not be seeing this. If you are, tell the creator.");
                return;
            }
        }
        inter=<dest.x-(b*norm.x),dest.y-(b*norm.y),dest.z-(b*norm.z)>;//Then we let the math work from there
    }
    else //Same shit, different axis
    {
        if(dest.y>0.0)b=dest.y-255.0;
        else b=dest.y;
        if(norm.y<1.0)
        {
            if(norm.y)b=b/norm.y;
            else //Improbable, yes. Impossible? Not sure.
            {
                llOwnerSay("You should not be seeing this. If you are, tell the creator.");
                return;
            }
        }
        inter=<dest.x-(b*norm.x),dest.y-(b*norm.y),dest.z-(b*norm.z)>;
    }
    //llOwnerSay((string)norm+"|"+(string)dest+"|"+(string)b+"|"+(string)inter+"|"+(string)llVecNorm(inter-init));
    //First and Last values should be the same, and the 'inter' value must be between <0,0,z> and <255,255,z>
    llSleep(0.1);//Better
    if(llSetRegionPos(inter)<1)llDie();
    else
    {
        llTriggerSound("cf5e1be7-e00c-d36a-8e5b-7b31e8c9417a",1.0);
        llSetRegionPos(inter+<5.0,0.0,0.0>*rot);
    }
}
fire()
{
    vector init=llGetPos();
    rotation rot=llGetRot();
    list ray=llCastRay(init,init+<5000.0,0.0,0.0>*rot,[RC_REJECT_TYPES,RC_REJECT_PHYSICAL,RC_DATA_FLAGS,RC_GET_ROOT_KEY,RC_MAX_HITS,10]);
    //llSay(0,llDumpList2String(ray," | "));
    integer l=llGetListLength(ray);
    //key,pos,...,total_returns
    integer i;
    integer pass;
    vector last;
    while(i<l)
    {
        key id=llList2Key(ray,i);
        if(id!=o)//Ownerguard
        {
            if(llGetAgentSize(id))llOwnerSay("/me hit "+llKey2Name(id));//Hit avatar
            else
            {
                if((integer)((string)llGetObjectDetails(id,[OBJECT_PHANTOM])))
                {
                    llOwnerSay("Hit raycast blocker ["+llKey2Name(id)+"] owned by "+llKey2Name(llGetOwnerKey(id)));
                    //Raycast Blocker
                }
                else
                {
                    last=llList2Vector(ray,i+1);
                    if(last)
                    {
                        ++pass;
                        l=0;
                    }
                }
            }
        }
        else llOwnerSay("Hit owner");
        if(l)i+=2;
    }
    if(pass<1)regionend(init,rot);
    else
    {
        llSleep(0.1);//Best
        llSetRegionPos(last);
        //llOwnerSay("Hit object ["+llKey2Name(llList2Key(ray,i))+"] at "+(string)last);
        llSleep(1.0);
        llDie();
    }
}
key o;
default
{
    state_entry()
    {
        o=llGetOwner();
        //llSay(0, "Ready");
        //FX
    }
    /*touch_start(integer p)
    {
        o=llGetOwner();
        if(p)fire();
    }*/
    on_rez(integer p)
    {
        //llSleep(0.1);//Bad
        o=llGetOwner();
        if(p)fire();
    }
    changed(integer c)
    {
        if(c&CHANGED_REGION)
        {
            llTriggerSound("cf5e1be7-e00c-d36a-8e5b-7b31e8c9417a",1.0);
            fire();
        }
    }
}
