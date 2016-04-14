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
  Impersonate._uiIsOpen=if Impersonate._uiIsOpen then false else true


Template.body.events
  'click [data-impersonate]': (event, template) ->
    userId = $(event.currentTarget).attr "data-impersonate"
    Impersonate.do userId

  'click [data-unimpersonate]': (event, template)->
    Impersonate.undo()

  'click':(event,template)->
    unless $(event.target).closest(".rp_impersonate_accordion").length
      toggleAccordian() if Impersonate._uiIsOpen

Template.registerHelper "isImpersonating", (userId)->
  isImpersonating(userId)


Meteor.startup ()->
  _logout=Meteor.logout
  Tracker.autorun ->
    if Meteor.userId()
      if Impersonate.canImpersonate Impersonate._user or Meteor.userId()
        unless Impersonate._view
          Impersonate._view=Blaze.render Template.rp_impersonate_accordion,$('body')[0]

  Meteor.logout=()->
    console.log "logging out via custom code"
    Impersonate.reset()
    _logout.apply(Meteor,arguments)

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
    @subscribe('rp_impersonate_pub',50)


Template.rp_impersonate_accordion.rendered=->
  toggleLastMenu=()->
    @$(".rp_impersonate_accordion li > .sub-menu").last().addClass('active').slideToggle('normal')
  _.delay(toggleLastMenu,300)


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

Template.rp_impersonate_roleItem.events
  'click .roleItemLink':(evt,temp)->
    item=temp.$(evt.currentTarget).next()
    unless item.hasClass('active')
      $('.rp_impersonate_accordion li > .active').slideToggle('normal').removeClass('active')
      item.addClass('active').slideToggle('active')



















