class Widget < ActiveRecord::Base
   belongs_to :dashboard

  serialize :settings

  validates :name, :kind, :source, :update_interval, :dashboard_id, :presence => true

  attr_accessible :name, :kind, :source, :update_interval, :dashboard_id, :col, :row, :size_x, :size_y, :settings

  after_initialize :set_defaults
  
  class << self

    def list_available
      puts "-----------list_available entry"
      path = Rails.root.join("app/assets/javascripts/angular/widgets")
      puts "-----path"
      puts path
      puts Dir["#{path}/*"].map { |f| File.basename(f, '.*') }
      Dir["#{path}/*"].map { |f| File.basename(f, '.*') }
    end
    
    def for_dashboard(id)
      where(:dashboard_id => id)
    end

    # settings specific attributes handling
    def slice_attributes(input)
      input.symbolize_keys!
      default_set = accessible_attributes.to_a.map(&:to_sym)
      input.slice(*default_set).merge(:settings => input.except(*default_set))
    end
  end

  # flatten settings hash
  def as_json(options = {})
    result = super(:except => :settings)
    result.merge!((settings || {}).stringify_keys)
    result
  end

  protected

  def validate_source_attributes
    source_plugins = Sources[Sources.widget_type_to_source_type(kind)]
    puts ("#{source_plugins.inspect} #{source}")
    source_attrs   = source_plugins.fetch(source)
    attrs          = source_attrs.fetch(:custom_fields) + source_attrs.fetch(:default_fields)
    attrs.each do |field|
      if field[:mandatory]
        errors.add(field[:name], "#{field[:name]} is a required field") unless settings[field[:name].to_sym].present?
      end
    end
  end

  def set_defaults
    self.update_interval ||= 10
  end

  
end