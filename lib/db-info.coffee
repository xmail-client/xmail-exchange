Mapper = require 'sqlite-orm'
Migration = Mapper.Migration

Migration.createTable 'ExchangeAccount', (t) ->
  t.addColumn 'email', Mapper.TEXT
  t.addColumn 'username', Mapper.TEXT
  t.addColumn 'password', Mapper.TEXT
  t.addColumn 'url', Mapper.TEXT
  t.addColumn 'folderSyncState', Mapper.TEXT
  t.addReference 'rootFolderId', 'ExchangeFolder'

Migration.createTable 'ExchangeFolder', (t) ->
  t.addColumn 'name', Mapper.TEXT
  t.addColumn 'folderId', Mapper.TEXT
  t.addColumn 'flags', Mapper.INTEGER
  t.addReference 'parentId', 'ExchangeFolder'
  t.addReference 'accountId', 'ExchangeAccount'

Migration.createTable 'FileBuffer', (t) ->
  t.addColumn 'offset', Mapper.INTEGER
  t.addColumn 'length', Mapper.INTEGER

Migration.createTable 'ExchangeMessage', (t) ->
  t.addColumn 'itemId', Mapper.TEXT
  t.addColumn 'changeKey', Mapper.TEXT
  t.addColumn 'subject', Mapper.TEXT
  t.addColumn 'body', Mapper.TEXT
  t.addColumn 'sentTime', Mapper.TEXT
