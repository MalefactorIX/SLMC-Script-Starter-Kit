rotation spread()
{
    float base=5.0;
    float half=base*0.5;
    vector spreadvector=<llFrand(base)-half,llFrand(base)-half,llFrand(base)-half>*DEG_TO_RAD;
    return llEuler2Rot(spreadvector);
}
fire(float vel)
{
    rotation rot=llGetCameraRot();
    llRezObject("TBullet",llGetCameraPos()+<5.0,0.0,0.0>*rot,<vel,0.0,0.0>*rot*spread(),rot,1);
}
default
{
    state_entry()
    {
        llRequestPermissions(llGetOwner(),0x414);
    }
    attach(key id)
    {
        if(id)llRequestPermissions(id,0x414);
    }
    link_message(integer s, integer n, string m, key id)
    {
        fire((float)n);
    }
    /*run_time_permissions(integer p)
    {
        if(p)return;
    }*/
}
