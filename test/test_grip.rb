require 'helper'

class Foo
  include MongoMapper::Document
  plugin Grip
  
  many :bars

  attachment :image
  attachment :pdf
end

class Bar
  include MongoMapper::EmbeddedDocument
  plugin Grip
  
  attachment :file
end

class GripTest < Test::Unit::TestCase
  def setup
    MongoMapper.database.collections.each(&:remove)
    @grid = Mongo::Grid.new(MongoMapper.database)

    dir    = File.dirname(__FILE__) + '/fixtures'
    @pdf   = File.open("#{dir}/sample.pdf",  'r')
    @pdf_contents = File.read("#{dir}/sample.pdf")
    @image = File.open("#{dir}/cthulhu.png", 'r')
    @image_contents = File.read("#{dir}/cthulhu.png")
    @file   = File.open("#{dir}/azathoth.jpg",  'r')
    @file_contents = File.read("#{dir}/azathoth.jpg")
    
    @doc = Foo.create(:image => @image, :pdf => @pdf, :bars => [Bar.new(:file => @file)])
    @doc.reload
  end

  def teardown
    @pdf.close
    @image.close
    @file.close
  end

  test "assigns keys correctly" do
    assert_equal 27582, @doc.image_size
    assert_equal 8775,  @doc.pdf_size

    assert_equal "image/png",       @doc.image_type
    assert_equal "application/pdf", @doc.pdf_type
    assert_equal "image/jpeg",      embedded_doc.file_type

    assert_not_nil @doc.image_id
    assert_not_nil @doc.pdf_id
    assert_not_nil embedded_doc.file_id
    assert_kind_of Mongo::ObjectID, @doc.image_id
    assert_kind_of Mongo::ObjectID, @doc.pdf_id
    assert_kind_of Mongo::ObjectID, embedded_doc.file_id

    assert_equal "image/png", @grid.get(@doc.image_id).content_type
    assert_equal "application/pdf", @grid.get(@doc.pdf_id).content_type
    assert_equal "image/jpeg", @grid.get(embedded_doc.file_id).content_type
  end

  test "assigns file name from path if original file name not available" do
    assert_equal 'cthulhu.png', @doc.image_name
    assert_equal 'sample.pdf',  @doc.pdf_name
    assert_equal 'azathoth.jpg', embedded_doc.file_name
  end

  test "assigns file name from original filename if available" do
    begin
      file = Tempfile.new('testing.txt')
      def file.original_filename
        'testing.txt'
      end
      
      doc = Foo.create(:image => file)
      assert_equal 'testing.txt', doc.image_name
    ensure
      file.close
    end
  end

  test "responds to keys" do
    [ :pdf_size,   :pdf_id,   :pdf_name,   :pdf_type,
      :image_size, :image_id, :image_name, :image_type
    ].each do |method|
      assert @doc.respond_to?(method)
    end
  end

  test "saves attachments correctly" do
    assert_equal @pdf_contents, @doc.pdf.read
    assert_equal @image_contents, @doc.image.read
    assert_equal @file_contents, embedded_doc.file.read
  end

  test "cleans up attachments on destroy" do
    @doc.destroy
    assert_raises(Mongo::GridError) { @grid.get(@doc.image_id) }
    assert_raises(Mongo::GridError) { @grid.get(@doc.pdf_id) }
    assert_raises(Mongo::GridError) { @grid.get(embedded_doc.file_id) }
  end
  
  def embedded_doc
    @doc.bars.first
  end
end