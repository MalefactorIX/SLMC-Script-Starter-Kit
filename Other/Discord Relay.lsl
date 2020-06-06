//Refer to this page for more information: https://sites.google.com/site/tomeofmaliciousintent/misc/discord-relay
string url = ""; //Discord webhook url
string oname;
discord(key id)
{
    string dname=llGetDisplayName(id);
    string uname = llKey2Name(id);
    if(dname)uname+=" ("+dname+")";
    list info = [
        "content", uname+" has toggled the system",//Your message is here
        "username",oname,//This is the name that shows up in the Discord channel
        "embeds","",//Shit I didn't bother messing with
        "tts", "false",//Text-to-Speech toggle
        "avatar_url", "https://cdn.discordapp.com/embed/avatars/0.png"//The avatar used by the message
    ];
    llHTTPRequest(url,[
        HTTP_METHOD,"POST",
        HTTP_MIMETYPE,"application/json",
        HTTP_VERIFY_CERT,TRUE,
        HTTP_VERBOSE_THROTTLE,TRUE,
        HTTP_PRAGMA_NO_CACHE,TRUE ],
        llList2Json(JSON_OBJECT,info));
}
float time;
float delay=300.0;//How often it can be triggered.
default
{
    state_entry()
    {
        oname=llGetObjectName();
    }
    touch_start(integer total_number)
    {
        if(time)
        {
            if(llFabs(llGetTime()-time)<delay)return;
        }
        discord(llDetectedKey(0));
        time=llGetTime();
    }
}
