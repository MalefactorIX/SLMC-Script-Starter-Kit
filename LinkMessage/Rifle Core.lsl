integer fx;
integer drawn;
integer vel=175;
integer amax=30;
integer ammo;
integer t;
//
integer bi;
fire()
{
    //llTriggerSound("",1.0);
    bi=!bi;
    if(bi)llMessageLinked(LINK_THIS,vel,"","");
    else llMessageLinked(fx,vel,"","");
    ammo--;
    if(ammo<1)reload();
    else llResetTime();
}
integer r;
float delay=2.0;
reload()
{
    if(r)return;
    t=0;
    ++r;
    if(ammo)ammo=amax+1;
    else ammo=amax;
    //llPlaySound("",1.0);
    //llStartAnimation("Reload");
    llOwnerSay("Reloading...");
    llResetTime();
}
integer ao;
integer last=2;
string aim="aim";
string hold="hold";
switch(integer ml)
{
    if(ml)
    {
        llStartAnimation(aim);
        llStopAnimation(hold);
    }
    else
    {
        llStartAnimation(hold);
        llStopAnimation(aim);
    }
    last=ml;
}
stop()
{
    llStopAnimation(aim);
    llStopAnimation(hold);
}
key o;
integer altchan;
integer hear;
default
{
    state_entry()
    {
        integer l=llGetNumberOfPrims()+1;
        while(l--)
        {
            string name=llGetLinkName(l);
            if(name=="fx")fx=l;
        }
        hear=llListen(altchan,"",o=llGetOwner(),"");
        llListen(9001,"",o,"");
        llRequestPermissions(o,0x414);
    }
    run_time_permissions(integer p)
    {
        if(p&0x20)llDetachFromAvatar();
        else if(p)
        {
            ++drawn;
            last=2;
            llSetLinkAlpha(-1,1.0,-1);
            llSetTimerEvent(0.5);
            llTakeControls(CONTROL_ML_LBUTTON,1,1);
            if(ammo)llOwnerSay("Altchan set to "+(string)altchan);
            else reload();
        }
    }
    attach(key id)
    {
        if(id)
        {
            if(id==o)
            {
                if(drawn)llRequestPermissions(o,0x414);
            }
            else
            {
                llOwnerSay("Hey New Owner!");
                llResetScript();
            }
        }
        else 
        {
            if(drawn)stop();
            //llTriggerSound("",1.0);
        }
    }
    listen(integer chan, string name, key id, string message)
    {
        message=llToLower(message);
        list parse=llParseString2List(message,[":"],[" "]);
        string type=llList2String(parse,0);
        if(message=="r"&&drawn)reload();
        else if(message=="draw"&&!drawn)llRequestPermissions(o,0x414);
        else if(message=="sling"&&drawn)
        {
            drawn=0;
            llSetLinkAlpha(-1,0.0,-1);
            llSetTimerEvent(0.0);
            stop();
            llReleaseControls();
        }
        else if(message=="hsling")llRequestPermissions(o,0x30);
        else if(message=="gao")
        {
            ao=!ao;
            llOwnerSay("AO set to "+(string)ao);
            if(ao)last=2;
            else if(drawn)stop();
        }
        else if(type=="vel")
        {
            vel=(integer)llList2String(parse,1);
            if(vel<5)vel=175;
            llOwnerSay("Velocity set to "+(string)vel);
        }
        else if(type=="chan")
        {
            altchan=(integer)llList2String(parse,1);
            if(altchan<0)altchan=0;
            llListenRemove(hear);
            hear=llListen(altchan,"",o,"");
            llOwnerSay("Altchan set to "+(string)altchan);
        }
    }
    control(key id, integer h, integer c)
    {
        //h&c=Just pressed
        //h = Already pressed, but being held
        //c = Key was just release
        if(r)return;
        else if(h&c&&!t)
        {
            ++t;
            fire();
            //llLoopSound("",1.0);
        }
        else if(h&&t)
        {
            if(llGetTime()>0.075)fire();
        }
        else if(c&&t)
        {
            t=0;
            //llStopSound();
        }
    }
    timer()
    {
        if(r)
        {
            if(llGetTime()<delay)return;
            r=0;
            llOwnerSay("Reloaded!");
        }
        else if(ao)
        {
            integer ml=llGetAgentInfo(o)&AGENT_MOUSELOOK;
            if(ml!=last)switch(ml);
        }
        
    }
}
