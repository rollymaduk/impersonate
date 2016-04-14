Meteor.publish 'rp_impersonate_pub',(limit=50)->
  [Meteor.users.find({},{limit:limit}),Meteor.roles.find({})]


Meteor.methods
  impersonate:(params)->
    {fromUser,toUser,token}=params
    try
      check toUser,String
      userExists=Meteor.users.findOne(toUser)
      if userExists
        unless fromUser and token
          canImpersonate=Impersonate.canImpersonate(@userId)
          unless canImpersonate then throw new Meteor.Error 403, "Permission denied. Need to be admin to impersonate."
        token= Meteor._get(Meteor.users.findOne(fromUser or @userId), "services", "resume", "loginTokens", 0, "hashedToken")
        @setUserId toUser
        {fromUser:@userId, toUser:toUser, token:token }
      else
        throw new Meteor.Error 404, "User not found. Can't impersonate nil"
    catch
      throw new Meteor.Error 405,"Invalid Input, No impersonation user info found"
