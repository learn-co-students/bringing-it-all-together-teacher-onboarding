class Dog
  attr_accessor :name, :breed
  attr_reader :id
  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end
  
  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end
  
  def save
    sql = "INSERT INTO dogs (name,breed)
    VALUES(?,?)"
    DB[:conn].execute(sql,self.name,self.breed)
    result = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")
    @id = result[0][0]
    self
  end
  
  def self.create(name:, breed:)
    dog = Dog.new(name: name,breed: breed)
    dog.save
  end
  
  def self.find_by_id(dog_id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, dog_id)
    Dog.new(name: result[0][1], breed: result[0][2], id: result[0][0])
  end
  
  def self.find_or_create_by(name:,breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    result = DB[:conn].execute(sql,name, breed)
    
    if result[0]
      Dog.new(name: result[0][1], breed: result[0][2], id: result[0][0])
    else
      Dog.create(name: name, breed: breed)
    end
  end
  
  def self.new_from_db(row)
    dog = Dog.new(id: row[0],name: row[1], breed: row[2])
    sql = "INSERT INTO dogs (name,breed,id)
    VALUES(?,?,?)"
    result = DB[:conn].execute(sql,row[1],row[2],row[0])
    dog
  end
  
  def self.find_by_name(dog_name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, dog_name)
    Dog.new(name: result[0][1], breed: result[0][2], id: result[0][0])
  end
  
  def update
    sql = "UPDATE dogs SET name = ?, breed =? WHERE id = ?"
    DB[:conn].execute(sql, self.name,self.breed,self.id)
  end
end