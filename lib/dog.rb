require_relative "../config/environment"

class Dog
    attr_accessor :id, :name, :breed

    def initialize(name:, breed:, id:nil)
        @name = name
        @breed = breed
        @id = id
    end

    def upsert
        self.id ? self.update : self.save
    end

    def save
        sql = "INSERT INTO dogs (name, breed) VALUES (?, ?);"
        DB[:conn].execute(sql, @name, @breed)
        dog = self.class.find_by_name(@name)
        @id = dog.id
        dog
    end

    def update
        sql = "
            UPDATE dogs
            SET name=?, breed=?
            WHERE id = ?;
        "
        DB[:conn].execute(sql, @name, @breed, @id)
        self
    end

    def self.new_from_db(record)
        self.new({
            :id => record[0],
            :name => record[1],
            :breed => record[2]
        })
    end

    def self.create(attributes)
        dog = self.new(attributes)
        dog.save
        dog
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?;"
        record = DB[:conn].execute(sql, id).first
        self.new_from_db(record)
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?;"
        record = DB[:conn].execute(sql, name).first
        self.new_from_db(record) if record
    end

    def self.find(name, breed)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"
        record = DB[:conn].execute(sql, name, breed).first
        self.new_from_db(record) if record
    end

    def self.create_table
        sql = "
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        "
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs;"
        DB[:conn].execute(sql)
    end

    def self.find_or_create_by dog
        found_dog = self.find(dog[:name], dog[:breed])
        if dog[:id]
            self.find_by_id(id)
        elsif found_dog
            found_dog
        else
            Dog.create(dog)
        end
        self.find(dog[:name], dog[:breed])
    end
end
