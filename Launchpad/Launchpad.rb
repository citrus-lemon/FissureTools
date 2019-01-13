#!/usr/bin/env ruby -w

require "sqlite3"
require "SecureRandom"

class Launchpad

  module ItemField
    module_function
    RowID    = 0
    UUID     = 1
    Flags    = 2
    Type     = 3
    ParentID = 4
    Ordering = 5
  end

  module TypeID
    module_function
    System = 1
    Page   = 3
    Widget = 6
    App    = 4
    Group  = 2

    def [](id)
      {
        1 => 'system',
        3 => 'page',
        6 => 'widget',
        4 => 'app',
        2 => 'group',
      }[id]
    end
  end

  def initialize(launchpadDB = nil)
    @path = launchpadDB = launchpadDB ||
      `find /private/var/folders -name com.apple.dock.launchpad 2> /dev/null`.split("\n")
      .map { |path|
        d =  File.join(path, 'db/db')
        d if File.exist?(d) }
      .select{ |p| true if p }.first
    @db = SQLite3::Database.new launchpadDB, {:readonly => true}
  end

  attr_reader :path

  def lastInsertItem
    result = @db.execute <<-SQL
      SELECT rowid, uuid, flags, type, parent_id, ordering FROM items ORDER BY rowid DESC LIMIT 1
    SQL
    result[0]
  end

  def item(itemID)
    result = @db.execute <<-SQL
      SELECT rowid, uuid, flags, type, parent_id, ordering FROM items WHERE rowid = '#{itemID}'
    SQL
    result[0]
  end

  def nextOrdering(parentID = 1)
    result = @db.execute <<-SQL
      SELECT rowid, ordering FROM items WHERE parent_id = '#{parentID}' ORDER BY rowid DESC LIMIT 1
    SQL
    result[0] ? result[0][1] + 1 : 0
  end

  def createNewPage(parentID = 1)
    parent = self.item(parentID)
    raise "parent node #{parentID} is not RootPage or Group" unless parent[ItemField::UUID] == 'ROOTPAGE' or parent[ItemField::Type] == TypeID::Group
    newUUID = SecureRandom.uuid.upcase
    @db.execute <<-SQL
      UPDATE dbinfo SET value = 1 WHERE key = 'ignore_items_update_triggers'
    SQL
    nextpage = self.nextOrdering(parentID)
    @db.execute <<-SQL
      INSERT INTO items (uuid,flags,type,parent_id,ordering) VALUES (
        '#{newUUID}',     -- random UUID
        '0',              -- flags 0
        '#{TypeID.Page}', -- type 3
        '#{parentID}',    -- Parent ID
        '#{nextpage}'     -- next page
      )
    SQL
    last = self.lastInsertItem
    @db.execute <<-SQL
      INSERT INTO groups (item_id) VALUES ('#{last[0]}')
    SQL
    last[0]
  end

  def createNewGroup()
    newUUID = SecureRandom.uuid.upcase
    @db.execute <<-SQL
      INSERT INTO items (uuid,flags,type,parent_id,ordering) VALUES (
        '#{newUUID}',
        '1',
        '#{TypeID.Group}',
        '#{parentID}',
        '#{nextpage(parentID)}'
      );
    SQL
  end

  def move(itemID, parentID)
    list = @db.execute <<-SQL
      SELECT rowid FROM items
      WHERE (rowid = '#{parentID}') AND (type = '3')
    SQL
    raise "no such Page #{parentID}" unless list[0]
    @db.execute <<-SQL
      UPDATE items SET parent_id = '#{parentID}'
      WHERE rowid = '#{itemID}'
    SQL
    self.item(itemID)
  end

  def listItems
    @db.execute <<-SQL
      SELECT items.rowid, items.parent_id, items.ordering -- 0:rowid, 1:parent_id, 2:ordering
        , apps.title, groups.title                        -- 3:title, 4:title(group)
        , items.uuid                                      -- 5:UUID
        , categories.uti                                  -- 6:UTI
        , items.flags, items.type                         -- 7:flags, 8:type
      FROM items
      LEFT JOIN image_cache ON items.rowid = image_cache.item_id
      LEFT JOIN apps        ON items.rowid = apps.item_id
      LEFT JOIN categories  ON apps.category_id = categories.rowid
      LEFT JOIN groups      ON items.rowid = groups.item_id
      ORDER BY items.parent_id, items.ordering
    SQL
  end

  def listApps
    result = @db.execute <<-SQL
      SELECT apps.item_id, apps.title, apps.bundleid, categories.uti as categories
      FROM apps
      LEFT JOIN items       ON items.rowid = apps.item_id
      LEFT JOIN categories  ON apps.category_id = categories.rowid
    SQL
    result.map do |record|
      {
        :ID       => record[0],
        :title    => record[1],
        :bundleID => record[2],
        :category => record[3]
      }
    end
  end

  def printList
    self.listItems.map do |o|
      print o[0].to_s.ljust(5)
      print o[1].to_s.ljust(5)
      print o[2].to_s.ljust(5)
      print (o[7] ? o[7].to_s(2) : '').rjust(11,'0'), ' '
      print TypeID[o[8]].to_s.ljust(7)
      print o[5].to_s.ljust(38)
      print o[3] || o[4] && ('* ' + o[4])
      puts
    end
  end
end

def readLaunchpadSpringboard
  col = `defaults read com.apple.dock springboard-rows 2>/dev/null || echo 7`.to_i
  row = `defaults read com.apple.dock springboard-columns 2>/dev/null || echo 5`.to_i
  [col, row]
end

if __FILE__ == $0
  
  require 'pry'

  lp = $lp = Launchpad.new
  def open
    `open -a 'DB Browser for SQLite' #{$lp.path}`
  end

  Pry.start self, :prompt => [ proc{ "&=> "}, proc { " ->" } ]

end