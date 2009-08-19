module DbCharmer
  class ConnectionFactory
    @@connection_classes = {}

    def self.reset!
      @@connection_classes = {}
    end

    def self.connect(db_name, should_exist = false)
      @@connection_classes[db_name.to_s] ||= establish_connection(db_name.to_s, should_exist)
    end

    def self.establish_connection(db_name, should_exist = false)
      abstract_class = generate_abstract_class(db_name, should_exist)
      DbCharmer::ConnectionProxy.new(abstract_class)
    end

    def self.generate_abstract_class(db_name, should_exist = false)
      module_eval <<-EOF, __FILE__, __LINE__ + 1
        class #{abstract_connection_class_name db_name} < ActiveRecord::Base
          self.abstract_class = true
          establish_real_connection_if_exists(:#{db_name}, #{!!should_exist})
        end
      EOF

      abstract_connection_class_name(db_name).constantize
    end

    def self.abstract_connection_class_name(db_name)
      "::AutoGeneratedAbstractConnectionClass#{db_name.camelize}"
    end
  end
end