class Company
  # Defaults
  @@ranges ||= {revenue: 0..15000000, employees: 0..300}

  attr_reader :company_name, :city, :state, :industry, :annual_revenue, :employees

  # Setup for ranges
  def self.set_ranges(ranges = {})
    ranges.each do |key, value|
      @@ranges[key] = value
    end
  end

  # Available filters
  #
  # has_crossreference: true *
  # is_private: true *
  # city: city_name
  # state: state_name(abbr)
  # revenue: min..max
  # employees: min..max
  #
  #  * defaults
  def self.where(options = {})
    # Build the query
    options.reverse_merge!(@@ranges)
    query = {
      filters: {
        city: {selected: options[:city]},
        state: {selected: options[:state]},
        has_crossreference: {selected: options.fetch(:has_crossreference, true)},
        is_private: {selected: options.fetch(:is_private, true)},
        revenue: { 
          max: @@ranges[:revenue].max,
          selected: {
            max: options[:revenue].max,
            min: options[:revenue].min
          },
          min: @@ranges[:revenue].min
        },
        employees: {
          max: @@ranges[:employees].max,
          selected: {
            max: options[:employees].max,
            min: options[:employees].min
          },
          min: @@ranges[:employees].min
        }
      }
    }
    CompanyRelation.new(query)
  end

  # Uses the defaults
  def self.all
    CompanyRelation.new
  end

  def initialize(params)
    params.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end
end