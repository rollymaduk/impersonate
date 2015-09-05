Impersonate =
  admins: ['admin']
  adminGroups: []
  limit:50

  canImpersonate:(userId)->
    allowImpersonate=false
    if Impersonate.admins?.length?
      allowImpersonate =Roles.userIsInRole userId,Impersonate.admins
    else
      if Impersonate.adminGroups
        i = 0
        while i < Impersonate.adminGroups.length
          roleGroup = Impersonate.adminGroups[i]
          allowImpersonate = Roles.userIsInRole userId, roleGroup.role, roleGroup.group
          if allowImpersonate
            break
          i++
    allowImpersonate

Meteor.publish 'rp_impersonate_pub',(userId)->
  if Impersonate.canImpersonate(userId)
    limit=Impersonate.limit or 50
    [Meteor.users.find({},{limit:limit}),Meteor.roles.find({},{limit:limit})]
  else
    @ready()


Meteor.methods
  canImpersonate:(userId) ->
    Impersonate.canImpersonate(userId)

  impersonate: (params)->

    currentUser = @userId;
    check currentUser, String
    check params, Object
    check params.toUser, String

    if params.fromUser || params.token
      check params.fromUser, String
      check params.token, String

    if Meteor.users.findOne params.toUser
      allowImpersonate = false

      allowImpersonate=Impersonate.canImpersonate(params.fromUser or currentUser)

      if !allowImpersonate and !params.token
        throw new Meteor.Error 403, "Permission denied. Need to be admin to impersonate."

      if params.token
        selector =
          _id: params.fromUser
          "services.resume.loginTokens.hashedToken": params.token

        isValid = !!Meteor.users.findOne selector
        if !isValid
          throw new Meteor.Error 403, "Permission denied. Can't impersonate with this token."
      else
        user = Meteor.users.findOne({ _id: currentUser }) || {}
        params.token = Meteor._get(user, "services", "resume", "loginTokens", 0, "hashedToken")

      @setUserId params.toUser
      # Set session variable to impersonating
      { fromUser: currentUser, toUser: params.toUser, token: params.token }
    else
      throw new Meteor.Error 404, "User not found. Can't impersonate nil"



