class ImpersonateUtil
  constructor:(options)->
    {@allowedRules,@_user,@_token,@_active,@_view,@_uiIsOpen,@_canImpersonate,@field1,@field2}=options

  canImpersonate:(userId)->
    if Meteor.isClient
      console.log @allowedRules
      roles=_.values(Meteor.user().roles)[0]
      res=_.intersection(@allowedRules,roles).length>0
      res
    else
      Roles.userIsInRole userId,@allowedRules

  do:(toUser,cb)->
    params={toUser:toUser}
    if @_user and @_token
      _.extend(params,{fromUser:@_user,token:@_token})

    Meteor.call "impersonate",params,(err,res)=>
      unless err
        unless @_user
          {fromUser,token}=res
          @_user=fromUser
          @_token=token
        @_active.set(true)
        Meteor.connection.setUserId(toUser)
        if !!(cb and cb.constructor and cb.apply)
          cb.apply @, [err, toUser]

  undo:(cb)->
    @do(@_user,(err,res)->
      unless err
        @_active.set false
      if !!(cb and cb.constructor and cb.apply)
        cb.apply @, [err, res.toUser]
    )

  reset: ()->
    @undo (err,res)->
      unless err
        @_user= null
        @_token= null
        @_active.set(false)
        @_canImpersonate.set(false)
        Blaze.remove(@_view)
        @_view=undefined
        @_uiIsOpen=false


Impersonate=new ImpersonateUtil({
  allowedRules:['admin']
  _user: null
  _token: null
  _active: new ReactiveVar false if Meteor.isClient
  field1:'username'
  field2: ''
  _canImpersonate:new ReactiveVar false if Meteor.isClient
  _view:null
  _uiIsOpen:false
})








