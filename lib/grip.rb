require 'mime/types'

# require 'tempfile'
# if thumbnailable?
#   tmp = Tempfile.new("thumb_#{filename}")
#   MojoMagick::resize(uploaded_file.path, tmp.path, {:width => 50, :height => 40, :scale => '>'})
#   self.thumbnail = tmp.read
# end

module Grip
  module ClassMethods
    def attachment(name)
      write_inheritable_attribute(:attachment_definitions, {}) if attachment_definitions.nil?
      attachment_definitions[name] = {}

      after_save     :save_attachments
      before_destroy :destroy_attached_files

      key "#{name}_id".to_sym,    ObjectId
      key "#{name}_name".to_sym,  String
      key "#{name}_size".to_sym,  Integer
      key "#{name}_type".to_sym, String

      define_method(name) do
        self.class.grid.get(self["#{name}_id"])
      end

      define_method("#{name}=") do |file|
        self["#{name}_id"]   = Mongo::ObjectID.new
        self["#{name}_size"] = File.size(file)
        self["#{name}_name"] = File.basename(file.path)
        self["#{name}_type"] = file.content_type rescue MIME::Types.type_for(file.path).to_s
        self.class.attachment_definitions[name] = file
      end
    end

    def grid
      @grid ||= Mongo::Grid.new(database)
    end

    def attachment_definitions
      read_inheritable_attribute(:attachment_definitions)
    end
  end

  module InstanceMethods
    private
      def save_attachments
        self.class.attachment_definitions.each do |attachment|
          name, file = attachment
          content_type = self["#{name}_type"]
          
          if file.respond_to?(:read)
            self.class.grid.put(file.read, self["#{name}_name"], :content_type => content_type, :_id => self["#{name}_id"])
          end
        end
      end

      def destroy_attached_files
        self.class.attachment_definitions.each do |name, attachment|
          self.class.grid.delete(self["#{name}_id"])
        end
      end
  end
end
