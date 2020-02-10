class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    DB[:conn].execute("create table dogs (id integer, name text, breed text)")
  end

  def self.drop_table
    DB[:conn].execute("drop table dogs")
  end

  def save
    if @id
      update
    else
      DB[:conn].execute("insert into dogs (name, breed) values (?, ?)", @name, @breed)
      @id = DB[:conn].execute("select last_insert_rowid() from dogs")[0][0]
    end
    self
  end

  def self.create(args)
    dog = Dog.new(args)
    dog.save
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    self.new_from_db(DB[:conn].execute("select * from dogs where id = ?", id).first)
  end

  def self.find_or_create_by(name:, breed:)
    row = DB[:conn].execute("select * from dogs where name = ? and breed = ?", name, breed).first
    if row
      self.new_from_db(row)
    else
      self.create(name: name, breed: breed)
    end
  end

  def self.find_by_name(name)
    self.new_from_db(DB[:conn].execute("select * from dogs where name = ?", name).first)
  end

  def update
    DB[:conn].execute("update dogs set name = ?, breed = ? where id = ?", @name, @breed, @id)
  end
end
