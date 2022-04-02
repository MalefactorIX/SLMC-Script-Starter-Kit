//[CD3] Now reports all rezzer sources for better anti-grief detection.

key o;//Memes
//The existence of a second state is solely to prevent the collision event from triggering while the collision detector is disabled. Makes things 100% more complex than needed but it does provide some benefits to region performance.
//It is entirely optional and only this version of our collision detector possesses this reconfiguration. ("If it ain't broke - Don't fix it", etc)
///CD
integer on=2;// 0 = Off, 1 = Spam, 2 = Mildly Helpful
integer dead;//IS IT KILL.
list last;//Used for clamped outputs.
integer statechange;//Used to tell shit to do shit
update()//This is here so that it may be used across multiple states. Though that is not the case here
{
    if(dead)
    {
        llOwnerSay("Last few collisions:"+(string)last);
        llSetTimerEvent(0.0);
        dead=0;
        last=[];
    }
}
procm(string message)//This is here so blah blah blah states
{
    message=llToLower(message);//Normalize input
    list parse=llParseString2List(message,[":"],[" "]);//tl;dr - cd:normal, cd:off, cd:clamped
    string type=llList2String(parse,0);//Parse input type
    if(type=="cd")//Was a CD specific command inputed?
    {
        string stat=llList2String(parse,1);//Parse command type
        if(stat=="off")//Is it kill?
        {
            if(on)statechange=1;//If on, force state change to turn off.
            on=0;
            last=[];
            llOwnerSay("CD Off");
        }
        else if(stat=="clamped")//Is it tolerable?
        {
            if(!on)statechange=1;//If off, change states to on.
            on=2;
            llOwnerSay("CD On, Clamped Mode");
        }
        else //if(stat=="normal")//Is it unbearable?
        //Also, optional text is optional. Invalid inputs will default to normal mode whilst disabled.
        {
            if(!on)statechange=1;//Deja Vu, I have been to this place before.
            on=1;
            llOwnerSay("CD On, Normal Mode");
        }
    }
    //else kys();
}
default
{
    state_entry()
    {
        llListen(0,"",o=llGetOwner(),"");//Channel 0 hype, also this sets the owner key.
        llListen(9005,"",o,"");//Auxillary channel hype
        llRequestPermissions(o,0x10);//Used for permissions check, optional in this case but originally written for use with animations.
    }
    listen(integer chan, string name, key id, string message)
    {
        procm(message);
        if(statechange)state cdon;//If the state was changed, this toggles the event
    }
    attach(key id)//git gud
    {
        if(id)
        {
            //llSetObjectName("Collision Detector");
            if(id==o)llRequestPermissions(o,0x10);//I honestly forgot why this took anims short of just having something to trigger run_time_permissions.
            else
            {
                llTriggerSound("e1c25d0d-2d69-1dbc-5894-82ce6466905d",1.0);
                llResetScript();
            }
        }
    }
    run_time_permissions(integer p)
    {
        if(p)
        {
            llSetTimerEvent(0.0);//Has no use in this state.
            if(on)state cdon;//exdee
        }
    }

    state_exit()
    {
        statechange=0;
    }
}
state cdon
{
    state_entry()
    {
        llListen(0,"",o=llGetOwner(),"");
        llListen(9001,"",o,"");
        llRequestPermissions(o,0x10);
    }
    listen(integer chan, string name, key id, string message)
    {
        procm(message);
        if(statechange)state default;
    }
    attach(key id)
    {
        if(id)
        {
            //llSetObjectName("Collision Detector");
            if(id==o)llRequestPermissions(o,0x10);
            else
            {
                llTriggerSound("c8d5c830-b70d-dbd3-d663-feeb85732006",1.0);
                llResetScript();
            }
        }
    }
    ///CD
    changed(integer c)
    {
        if(c&CHANGED_TELEPORT&&last!=[]&&on>1)//Used during clamped mode.
        {
            if(!dead)
            {
                ++dead;//Update display state.
                llSetTimerEvent(2.0);//This is used to make sure the last collision had time to process into the list if the collision event did not properly handle it.
            }
        }
    }
    run_time_permissions(integer p)
    {
        if(p)
        {
            if(on)return;//Safety catch
            state default;
        }
    }
    collision_start(integer c)
    {
        if(on)
        {
            integer hit = llDetectedType(0);
            if(hit&(2|8)&&~hit&1)
            {
                string rezzerkey=(string)llGetObjectDetails(llDetectedKey(0),[OBJECT_REZZER_KEY]);
                integer att=(integer)((string)llGetObjectDetails(rezzerkey,[OBJECT_ATTACHED_POINT]));
                //Returns 0 if not attached
                //Returns 31-38 if attached to HUD
                string name = llDetectedName(0);
                float vel = llVecMag(llDetectedVel(0));
                string owner=llDetectedOwner(0);
                if(owner==o)owner="yourself";
                else owner=llKey2Name(owner);
                string cm;
                if(owner=="")cm=name+" by an unknown unit";
                else
                {
                    if(vel>0.0)cm = name+" @ "+(string)vel +"m/s by "+ owner;
                    else cm = name+" by "+owner;
                    if(att>30&&att<39)cm+="
                    [Warning] Object was rezzed by HUD attachment named "+(string)llGetObjectDetails(rezzerkey,[OBJECT_NAME]);
                    else cm+="Rezzed by "+(string)llGetObjectDetails(rezzerkey,[OBJECT_NAME]);
                }
                if(on>1)
                {
                    if(llGetListLength(last)>5)last=llDeleteSubList(last,0,0);
                    if(c>1){last+="
                    "+cm+" + "+(string)(c-1);}
                    else last+="
                    "+cm;
                }
                else
                {
                    if(c>1)llOwnerSay(cm +" + "+(string)(c-1));
                    else llOwnerSay(cm);
                }
            }
        }
    }
    timer()
    {
        update();
    }
    state_exit()
    {
        statechange=0;
    }
}
//inb4 Nicole Zarco steals this and resells it as their own work.
