//Q. Where's the security?
//A. The script can only be saved to an experience script by experience moderators or owners. In addition, it requires the region/parcel to whitelist the experience and it gives sim owners the ability to blacklist it as well if people are creating malicious experiences using this (PS: Be sure to report the malicious experience if they are).
//You can save this script to any experience you control, but it will only sync with boards under the same experience.

string last;//Stores last valid board string.
//Each entry is stored as follows: BOARD_UUID,NAME:BOARD_DESC,AMOUNT_OF_PEOPLE,DATE
//BOARD_UUID:Allows boards to keep track of their own entries and where they are in this list.
//NAME - Name of region
//BOARD_DESC - Description of the board object. Can be used to define sim names as specific group names.
//DATE - When that sim last reported in. If a board is not updated for 24 hours, it is assumed dead and removed.
text()//I could take the time and create a spritesheet for text and have it look all pretty
//Or I can be lazy and use floating text, not like I'm being paid to do this or anything
{
    list parse=llCSV2List(last);
    //Index 0 = Board UUID
    //Index 1 = SimName:BoardName
    //Index 2 = Number of People
    //Index 3 = Date
    integer l=llGetListLength(parse);
    integer i;
    string output;
    while(i<l)
    {
        if(llList2String(parse,3)==llGetDate())//Only display information from boards which have updated today
        {
            string name=llList2String(parse,i+1);
            integer break=llSubStringIndex(name,":");
            string boardname=llGetSubString(name,break+1,-1);
            if(llStringLength(boardname)>3&&allowboardnames)name=boardname;
            else name=llGetSubString(name,0,break-1);
            output+=name+" ["+llList2String(parse,2)+"]\n";
        }
        else llSay(0,"Skipping "+llList2String(parse,i+1));
        i+=4;
    }
    if(output)llSetText(output,<1.0,1.0,1.0>,0.5);
    else llSetText("No sims registered",<1.0,0.0,0.0>,0.5);
}
integer read=1;//Tells the board if its reading or writing data;
update()//Updates datakey with board info
{
    //llSay(0,last);//Dumps current data before update
    read=0;//We're going to update
    list parse=llCSV2List(last);
    //if(llList2String(parse,0)=="null")parse=llDeleteSubList(parse,0,0);//Removes null string from key creation
    string mykey=llGetKey();
    list newdata=[mykey,llGetRegionName()+":"+llGetObjectDesc(),llGetRegionAgentCount(),llGetDate()];
    integer n=llListFindList(parse,[mykey]);
    if(n>-1)parse=llListReplaceList(parse,newdata,n,n+3);//Checks to see if we already have data
    else parse+=newdata;//Adds new data to existing data
    llUpdateKeyValue(keyname,llList2CSV(parse),1,last);
}
integer allowboardnames=1;//Set to 0 to force all entries to use their sim name instead of their board description.
string keyname="SIMBOARDS_DPS";//DataKey name for boards to sync onto.
default
{
    state_entry()
    {
       llReadKeyValue(keyname);
       //llCreateKeyValue(keyname,"null");//Used to create the key if it does not exist.
       llSetTimerEvent(300.0);//How often to update board
    }

    dataserver(key id, string data)
    {
        if((integer)llGetSubString(data,0,0))
        {
            last=llGetSubString(data,2,-1);
            if(read)update();
            else text();
        }
        else 
        {
            integer error=(integer)llGetSubString(data,2,-1);
            if(error!=14)llRegionSay(DEBUG_CHANNEL,"Board Sync Failure ["+(string)read+"]: "+llToUpper(llGetExperienceErrorMessage(error)));
            else llCreateKeyValue(keyname,"null");
        }
    }
    timer()
    {
        read=1;
        llSetTimerEvent(300.0);//How often to update board
    }
}
