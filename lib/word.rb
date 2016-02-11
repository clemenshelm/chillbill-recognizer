class Word
  attr_reader :text, :bounding_box

  def initialize(text, x:, y:, width:, height:)
    @text = text.encode(invalid: :replace).freeze
    bounding_box_attrs = {x: x, y: y, width: width, height: height}.freeze
    @bounding_box = OpenStruct.new bounding_box_attrs
  end
end
