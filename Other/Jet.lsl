integer VehicleStarted;
string  pose = "pose";
float speed=60.0;
float turn=25.0;
vector LinearEngine;
VehicleCore()
{
    llSetVehicleType(VEHICLE_TYPE_AIRPLANE);

    llSetVehicleFlags(VEHICLE_FLAG_CAMERA_DECOUPLED);

    llSetVehicleVectorParam(  VEHICLE_LINEAR_MOTOR_DIRECTION        , < 00.0 , 00.0 , 00.0 >   );
    llSetVehicleFloatParam(   VEHICLE_LINEAR_MOTOR_TIMESCALE        , 1.00                     );
    llSetVehicleFloatParam(   VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE  , 10.00                     );
    llSetVehicleVectorParam(  VEHICLE_LINEAR_FRICTION_TIMESCALE     , < 02.0 , 00.5 , 00.5 >   );


    llSetVehicleVectorParam(  VEHICLE_ANGULAR_MOTOR_DIRECTION       , < 00.0 , 30.0 , 15.0 >   );
    llSetVehicleFloatParam(   VEHICLE_ANGULAR_MOTOR_TIMESCALE       , 00.5                   );
    llSetVehicleFloatParam(   VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE , 00.06                    );
    llSetVehicleFloatParam(   VEHICLE_ANGULAR_FRICTION_TIMESCALE    , 00.06                    );

    llSetVehicleFloatParam(   VEHICLE_VERTICAL_ATTRACTION_TIMESCALE , 100000.00                    );
    llSetVehicleFloatParam(   VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY, 00.00                  );
    llSetVehicleFloatParam(   VEHICLE_LINEAR_DEFLECTION_EFFICIENCY  , 00.00                    );
    llSetVehicleFloatParam(   VEHICLE_LINEAR_DEFLECTION_TIMESCALE   , 00.00                    );
    llSetVehicleFloatParam(   VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY , 00.10                    );
    llSetVehicleFloatParam(   VEHICLE_ANGULAR_DEFLECTION_TIMESCALE  , 06.00                    );
    llSetVehicleRotationParam(VEHICLE_REFERENCE_FRAME               , ZERO_ROTATION            );

    llSetStatus(STATUS_PHYSICS, FALSE);
    llSetStatus(STATUS_BLOCK_GRAB_OBJECT|STATUS_BLOCK_GRAB,1);
    //llSetRot(ZERO_ROTATION);
    llStopSound();
    llSitTarget( < -0.2 , 0.0 , 0.0 >, ZERO_ROTATION);
    llSetCameraAtOffset(  < 10.0  , 0.0 , 0.0 > );
    llSetCameraEyeOffset( < -20.0 , 0.0 , 0.0 > );
    llCollisionSound("", 1.0);
    llCollisionSprite("");
    llStopSound();
}
key o;
eject()
{
    llOwnerSay("Ejecting passengers...");
    key id=llAvatarOnLinkSitTarget(2);
    if(id)llUnSit(id);
    id=llAvatarOnLinkSitTarget(3);
    if(id)llUnSit(id);
    id=llAvatarOnLinkSitTarget(4);
    if(id)llUnSit(id);
    id=llAvatarOnLinkSitTarget(5);
    if(id)llUnSit(id);
}
vector init;
integer held;
default
{
    on_rez(integer p)
    {
        if(p)
        {
            llSleep(0.1);
            llOwnerSay("@sit:"+(string)llGetKey()+"=force");
            init=llGetPos();
            //llListen(1,"",llGetOwner(),"eject");
        }
    }
    state_entry()
    {
        VehicleCore();
    }
    changed(integer change)
    {
        if (change & CHANGED_LINK)
        {
            o = llAvatarOnSitTarget();

            if (o == llGetOwner())
            {
                llRequestPermissions(o, 0x414);
                VehicleStarted = TRUE;
            }
            else
            {
                if (VehicleStarted) {llDie();}
                llUnSit(o);
                llResetScript();
            }
        }
    }
    run_time_permissions(integer perms)
    {
        if (perms)
        {
            llLoopSound("1c895735-9b6f-0ecb-6afc-91c275f545d6",1.0);
            llStartAnimation(pose);
            llSetAlpha(0.0,-1);
            llTakeControls(CONTROL_FWD|CONTROL_BACK|CONTROL_LEFT|CONTROL_ROT_LEFT|CONTROL_RIGHT|CONTROL_ROT_RIGHT|CONTROL_UP|CONTROL_DOWN,TRUE,TRUE);
            llSetTimerEvent(0.2);
        }
    }
    link_message(integer s, integer n, string m, key id)
    {
        if(n)
        {
            LinearEngine=ZERO_VECTOR;
            llLoopSound("1c895735-9b6f-0ecb-6afc-91c275f545d6",1.0);
            llSetStatus(STATUS_PHYSICS,0);
            llSetRegionPos(init);
            llSetRot(ZERO_ROTATION);
        }
    }
    timer()
    {
        if(~llGetStatus(STATUS_PHYSICS))llSetStatus(STATUS_PHYSICS,1);
        if(llGetAgentInfo(o)&AGENT_MOUSELOOK&&!held)llRotLookAt(llGetCameraRot(),1.0,0.5);
        else llStopLookAt();
        llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, LinearEngine);
    }
    control(key uid, integer hld, integer cng)
    {
        vector en_ang;
        if (hld & CONTROL_FWD)en_ang.y += turn;
        else if (hld & CONTROL_BACK)en_ang.y += -turn;
        if (CONTROL_ROT_LEFT & hld||CONTROL_LEFT & hld)
        {
            if(LinearEngine.x>0.0)en_ang.x = -turn;
            else en_ang.z = turn;
        }
        else if(CONTROL_ROT_RIGHT & hld||CONTROL_RIGHT & hld)
        {
            if(LinearEngine.x>0.0)en_ang.x = turn;
            else en_ang.z = -turn;
        }
        if (hld &cng& CONTROL_UP)
        {
            if(LinearEngine.x<20.0)
            {
                llLoopSound("608c764a-9870-4263-d8eb-9da5cfca5576",1.0);
                LinearEngine.x =speed*0.34;
            }
            else if(LinearEngine.x<40)
            {
                llLoopSound("303bf844-ccb4-cade-f1d1-1b41881f2ad5",1.0);
                LinearEngine.x=speed*0.67;
            }
            else LinearEngine.x=speed;
        }
        else if (hld &cng& CONTROL_DOWN)
        {
            LinearEngine.x =0.0;
            llLoopSound("1c895735-9b6f-0ecb-6afc-91c275f545d6",1.0);
        }
        if(hld)held=1;
        else held=0;
        llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION,en_ang);
        llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, LinearEngine);
    }
}
