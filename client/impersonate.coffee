Impersonate =
  _user: null
  _token: null
  _active: new ReactiveVar false
  field1:'username'
  field2: ''
  _canImpersonate:new ReactiveVar false
  _view:null

  reset: ()->
    @_user= null
    @_token= null
    @_active.set(false)
    @_canImpersonate.set(false)
    Blaze.remove(@_view) if @_view
    @_view=undefined


  do: (toUser, cb)->
    params =
      toUser: toUser

    if Impersonate._user
      params.fromUser = Impersonate._user
      params.token = Impersonate._token

    console.log Impersonate._user
    console.log Impersonate._token

    Meteor.call 'impersonate', params,
      (error, response)->
        if error
          console.log "Can't impersonate user: ", error
        else
          if !Impersonate._user
            Impersonate._user = response.fromUser
            Impersonate._token = response.token

          Impersonate._active.set true
          Meteor.connection.setUserId(response.toUser)

          ###Router.go Impersonate.route###
        if !!(cb and cb.constructor and cb.apply)
          cb.apply @, [error, response.toUser]

  undo: (cb)->
    Impersonate.do Impersonate._user, (error, response)->
      if !error
        Impersonate._active.set false
      if !!(cb and cb.constructor and cb.apply)
        cb.apply @, [error, response.toUser]

addSlimScroll=(selector)->
  selector.each (i,v)->
    if $(v).height()>=100
      $(v).slimScroll({height: '100px',allowPageScroll:true})
      $(v).removeClass('rp_roles')

isImpersonating=(userId)->
  Impersonate._active.get() and userId == Meteor.userId()

toggleAccordian=->
  $('.rp_accordion_body').slideToggle('normal')
  addSlimScroll($('.rp_roles'))


Template.body.events
  'click [data-impersonate]': (event, template) ->
    userId = $(event.currentTarget).attr "data-impersonate"
    Impersonate.do userId

  'click [data-unimpersonate]': (event, template)->
    Impersonate.undo()

Template.registerHelper "isImpersonating", (userId)->
  isImpersonating(userId)


Meteor.startup ()->
  Tracker.autorun ->
    if Meteor.userId()
      user= Impersonate._user or Meteor.userId()
      if user
        Meteor.call 'canImpersonate',user,(err,res)->
          unless err
            Impersonate._canImpersonate.set res
            unless Impersonate._view
              Impersonate._view=Blaze.render Template.rp_impersonate_accordion,$('body')[0] if res
            console.log 'show widget'
    else
      console.log 'hide widget'
      Impersonate.reset()




Template.registerHelper 'rp_impersonate_group',(groups,role)->
  users=Roles.getUsersInRole(role).fetch()
  if users.length
    [{group:'all',users:users}]
  else
    _.map(groups,(group)->
      users=Roles.getUsersInRole(role,group).fetch()
      if users.length
        {group:group,users:users}
    )


Template.registerHelper 'rp_impersonate_user',(user)->
  field_1_Items=Impersonate.field1.split('.')
  field_2_Items=Impersonate.field2.split('.')
  field1=Meteor._get(user,field_1_Items...)
  if user
    field2=if field_2_Items.length then Meteor._get(user,field_2_Items...) else ''
    "#{field1} #{field2}"
  else ""


Template.rp_impersonate_user.rendered=->
  sel=$("##{@data._id}")
  selector=sel.closest('div.rp_roles')
  addSlimScroll(selector)
  sel.iCheck({
    checkboxClass: 'icheckbox_futurico',
    radioClass: 'iradio_futurico'
  })
  @autorun =>
    state=if isImpersonating(@data._id) then 'check' else 'uncheck'
    sel.iCheck(state)
    null
  null


Template.rp_impersonate_accordion.created=->
  @autorun =>
    user=Impersonate._user or Meteor.userId()
    @subscribe('rp_impersonate_pub',user)


Template.rp_impersonate_accordion.rendered=->
  @$(".rp_impersonate_accordion li > .sub-menu").last().addClass('active').slideToggle('normal')


Template.rp_impersonate_accordion.events
  'click .rp_accordion_footer':(evt,temp)->
    toggleAccordian()

Template.rp_impersonate_accordion.helpers
  roles:->
   Roles.getAllRoles()

  canImpersonate:->
    Impersonate._canImpersonate.get()



  groups:->
    groups=Meteor.users.find().map (doc)->
      Roles.getGroupsForUser doc
    _.uniq(_.flatten(groups))



















