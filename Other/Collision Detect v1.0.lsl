/*Set up a UI that sends the following Link Messages
- Normal - Chat message will be sent for every hit, lethal or not.
- Clamped - Chat message with the last few hits will be sent after the avatar teleports (usually from death).
- Off - Changes to a state without the collision/changed event so you won't get hit reports.
*/
key o;
integer on=2;//2=clamped, 1=chat spam, 0=off
integer dead;//deaded state
list last;//Clamped storage
integer statechange;//housecleaning
update()
{
    if(dead)
    {
        llOwnerSay("Last few collisions:"+(string)last);
        dead=0;
        last=[];
        llSetTimerEvent(0.0);
    }
}
default
{
    state_entry()
    {
        o=llGetOwner();
        if(on)state cdon;
    }
    link_message(integer s, integer n, string m, key id)
    {
        if(m=="Normal")
        {
            ++statechange;
            on=1;
            llOwnerSay("Collision Detector set to Normal Mode");
        }
        else if(m=="Clamped")
        {
            ++statechange;
            on=2;
            llOwnerSay("Collision Detector set to Clamped Mode");
        }
        else if(m=="Off")
        {
            on=0;
            llOwnerSay("Collision Detector Disabled");
        }
        if(statechange)state cdon;
    }
    attach(key id)
    {
        if(id)
        {
            if(id==o);
            else
            {
                llTriggerSound("c8d5c830-b70d-dbd3-d663-feeb85732006",1.0);
                llResetScript();
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
state cdon
{
    attach(key id)
    {
        if(id)
        {
            if(id==o);
            else
            {
                llTriggerSound("c8d5c830-b70d-dbd3-d663-feeb85732006",1.0);
                llResetScript();
            }
        }
    }
    link_message(integer s, integer n, string m, key id)
    {
        if(m=="Normal")
        {
            on=1;
            llOwnerSay("Collision Detector set to Normal Mode");
        }
        else if(m=="Clamped")
        {
            on=2;
            llOwnerSay("Collision Detector set to Clamped Mode");
        }
        else if(m=="Off")
        {
            ++statechange;
            on=0;
            llOwnerSay("Collision Detector Disabled");
        }
        if(statechange)state cdon;
    }
    ///CD
    changed(integer c)
    {
        if(!on)return;
        if(c&CHANGED_TELEPORT&&last!=[]&&on>1)
        {
            if(!dead)
            {
                ++dead;
                llSetTimerEvent(2.0);//This is used to make sure the last collision had time to process into the list
            }
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
                //integer att=(integer)((string)llGetObjectDetails(rezzerkey,[OBJECT_ATTACHED_POINT]));
                //Returns 0 if not attached
                //Returns 31-38 if attached to HUD
                //Use this if you suspect people are being asspies.
                string name = llDetectedName(0);
                float vel = llVecMag(llDetectedVel(0));
                string owner=llDetectedOwner(0);
                if(owner==o)owner="yourself";
                else if(owner!=NULL_KEY)
                {
                    owner=llKey2Name(owner);
                    if(owner=="")owner=(string)"secondlife:///app/agent/"+(string)llDetectedOwner(0)+ "/about";
                }
                string cm;
                //else
                {
                    if(vel>0.0)cm = name+" @ "+(string)vel +"m/s by "+ owner;
                    else cm = name+" by "+owner;
                    string name=(string)llGetObjectDetails(rezzerkey,[OBJECT_NAME]);
                    if(name!=""&&!llDetectedGroup(0))cm+="
                    - Object was rezzed by "+name;
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
