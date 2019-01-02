class Room
  attr_accessor :id, :title, :date_created, :price, :url

  def self.create_from_hash(hash) # instantiate and saving
    new_from_hash(hash).save
  end

  def self.new_from_hash(hash) # just instantiate - extending
    room = self.new
    room.title = hash[:title]
    room.date_created = hash[:date_created]
    room.price = hash[:price]
    room.url = hash[:url]

    room # dangling return value
  end

  def self.by_price(order = "ASC")
     case order
     when "ASC"
       self.all.sort_by{|r| r.price}
     when "DESC"
       self.all.sort_by{|r| r.price}.reverse
     end
  end
  # Room.by_price("ASC") #=> lowest price room first
  # Room.by_price("DESC") #=> highest price room first


  def self.new_from_db(row)
    self.new.tap do |room|
      room.id = row[0]
      room.title = row[1]
      room.date_created = row[2]
      room.price = row[3]
      room.url = row[4]
    end
  end

  def save
    insert
  end

  def self.all
    # 1.hit the database
    sql = <<-SQL
      SELECT * FROM rooms;
    SQL
    #2. get all of the rows
    rows = DB[:connection].execute(sql)
    # reify - go from a row [1, "title", date, price, url] to an instance #<Room>

    # 3. for each row get one row
    rows.collect do |row|
      # 4. instantiate an object
      #5. because I am using collect these instance(self.new_from_db(row)) are going to be my return value
      self.new_from_db(row)
    end
  end

  def insert
    # I need a database!!!!
    # puts "YOU ARE ABOUT TO SAVE #{self}"
    sql = <<-SQL
    INSERT INTO rooms (title, date_created, price, url) VALUES (?, ?, ?, ?)
    SQL

    DB[:connection].execute(sql,self.title,self.date_created,self.price,self.url)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS rooms (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      date_created DATETIME,
      price TEXT,
      url TEXT
      )
    SQL

    DB[:connection].execute(sql)
  end
end
