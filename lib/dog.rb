class Dog
    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, @name, @breed)
        latest_dog = DB[:conn].execute("SELECT * FROM dogs ORDER BY ID DESC LIMIT 1").flatten
        if self.id==nil
            self.id = latest_dog[0]
        end
        self
    end

    def self.create(attribute_hash)
        new_dog = Dog.new(attribute_hash)
        new_dog.save
    end

    def self.new_from_db(row)
        new_dog_hash = {}
        new_dog_hash[:id] = row[0]
        new_dog_hash[:name] = row[1]
        new_dog_hash[:breed] = row[2]
        Dog.create(new_dog_hash)
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
        SQL
        result = DB[:conn].execute(sql, id).flatten
        Dog.new_from_db(result)
    end

    def self.find_or_create_by(attribute_hash)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? AND breed = ?
        SQL
        dog = DB[:conn].execute(sql, attribute_hash[:name], attribute_hash[:breed])

        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
            dog = Dog.create(attribute_hash)
        end
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?
        SQL
        result = DB[:conn].execute(sql, name).flatten
        Dog.new_from_db(result)
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL
        DB[:conn].execute(sql, @name, @breed, @id)
    end
end