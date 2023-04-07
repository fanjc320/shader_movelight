using System.Collections;
using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using System.Security.Cryptography;

public static class SkinnedMeshHelper
{
    public static Transform[] GetNewBones(SkinnedMeshRenderer root, SkinnedMeshRenderer source)
    {
        return root.bones
            .Where(x => source.bones.Select(s => s.name).Contains(x.name)).ToArray();//!!!!!!!!
    }
}


//When you work with linq try to simplify logic first, and break it on steps.
//So first, you need to find all elements with CommunityName, Where statement will help with it:

//var commList = community.Where(com => com.CommunityName == "TestCommunity");
//Now in commList we got them. Second you need new array(IEnumerable) with Ids:

//rawIds = commList.Select(x => x.IdCommunity);
//https://stackoverflow.com/questions/41934402/lambda-where-expression


//Did you add the Select() after the Where() or before?

//You should add it after, because of the concurrency logic:

// 1 Take the entire table  
// 2 Filter it accordingly  
// 3 Select only the ID's  
// 4 Make them distinct.  
//If you do a Select first, the Where clause can only contain the ID attribute because all other attributes have already been edited out.

//Update: For clarity, this order of operators should work:

//db.Items.Where(x => x.userid == user_ID).Select(x => x.Id).Distinct();
//Probably want to add a .toList() at the end but that's optional :)

//https://stackoverflow.com/questions/9410321/using-select-and-where-in-a-single-linq-statement