default
{
    state_entry()
    {
        llCollisionSound("",1.0);
        llCollisionFilter(llGetObjectName(),"",0);
        llSetDamage(100.0);
    }
    collision_start(integer c)
    {
        llDie();
        llSetDamage(0.0);
    }
    land_collision_start(vector x)
    {
        llDie();
        llSetDamage(0.0);
    }
    moving_end()//Kills bullet if it gets stuck not moving
    {
        float bvel=llVecMag(llGetVel());
        if(bvel<5.0)llDie();
    }
}
