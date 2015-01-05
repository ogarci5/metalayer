class Company
  # Defaults
  @@ranges ||= {revenue: 0..15000000, employees: 0..300}

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

end

class CompanyRelation < Company
  BASE_URL = 'http://grok.metalayer.com/api/companies/1/'

  FILTERS_DEFAULT = {
    city: {
      selected: nil
    },
    revenue: {
      max: 15000000,
      selected: {
        max: 15000000,
        min: 0
      },
      min: 0
    },
    employees: {
      max: 300,
      selected: {
        max: 300,
        min: nil
      },
      min: 0
    },
    state: {
      selected: nil
    },
    has_crossreference: {
      selected: true
    },
    is_private: {
      selected: true
    }
  }

  ORDER_DEFAULT = {sort: 'company_name asc'}

  PAGINATION_DEFAULT = ORDER_DEFAULT.merge(page_start: 0, page_size: 10)

  def initialize(query = {})
    @query = query.reverse_merge(pagination: PAGINATION_DEFAULT, filters: FILTERS_DEFAULT)
  end

  def paginate(options = {})
    @query[:pagination].merge!(options)
    self
  end

  def order(options = {})
    @query[:pagination].merge!(sort: '%s %s' % options.to_a.first)
    self
  end

  def each(&block)
    c = Curl::Easy.http_post(BASE_URL+'list', @query.to_json) do |curl|
      curl.headers['Accept'] = 'application/json'
      curl.headers['Content-Type'] = 'application/json'
    end
  end

  def send
    c = Curl::Easy.http_post(BASE_URL+'list', @query.to_json) do |curl|
      curl.headers['Accept'] = 'application/json'
      curl.headers['Content-Type'] = 'application/json'
    end
    ActiveSupport::JSON.decode(c.body)
  end
end
