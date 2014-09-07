markdown = require('markdown').markdown

mAccount = require './account'

module.exports = exports = app.db.collection 'tickets'

sample =
  account_id: ObjectID()
  created_at: Date()
  updated_at: Date()
  title: 'Ticket Title'
  content: 'Ticket Content(Markdown)'
  content_html: 'Ticket Conetnt(HTML)'
  status: 'open/pending/finish/closed'

  payload:
    public: false

  members: [
    ObjectID()
  ]

  replies: [
    _id: ObjectID()
    account_id: ObjectID()
    created_at: Date()
    content: 'Reply Content(Markdown)'
    content_html: 'Reply Conetnt(HTML)'
    payload: {}
  ]

exports.createTicket = (account, title, content, members, status, payload, callback) ->
  members_id = _.map (members) ->
    return member._id

  exports.insert
    account_id: account._id
    created_at: new Date()
    updated_at: new Date()
    title: title
    content: content
    content_html: markdown.toHTML content
    status: status
    members: membersID
    payload: payload
    replies: []
  , (err, result) ->
    callback err, _.first result

exports.createReply = (ticket, account, content, status, callback) ->
  data =
    _id: new ObjectID()
    account_id: account._id
    created_at: new Date()
    content: content
    content_html: markdown.toHTML content
    payload: {}

  exports.update _id: ticket._id,
    $push:
      replies: data
    $set:
      status: status
      updated_at: new Date()
  , ->
    unless exports.getMember ticket, account
      exports.addMember ticket, account, ->
        callback null, data
    else
      callback null, data

exports.addMember = (ticket, account, callback) ->
  exports.update _id: ticket._id,
    $push:
      members: account._id
    $set:
      updated_at: new Date()
  , (err) ->
    throw err if err
    callback()

exports.getMember = (ticket, account) ->
  return _.find(ticket.members, (member) -> member.equals(account._id))

exports.sendMailToAdmins = (title, content) ->
  mAccount.find
    group: 'root'
  .toArray (err, accounts) ->
    for account in accounts
      mAccount.sendEmail account, title, content
