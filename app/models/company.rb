class Company
  include HTTParty
  base_uri 'http://grok.metalayer.com/api/companies/1/'

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

  def self.paginate(options = {})
    # Build the query
    query = {
      pagination: {
        page_start: options[:offset],
        page_size: options[:size]
      }
    }
    CompanyRelation.new(query)
  end

  # Arguments are field: :direction
  def self.order(options = {})
    # Build the query
    query = {
      sort: '%s %s' % options.to_a.first
    }
    CompanyRelation.new(query)
  end

  private
    def selected_hash(hash)
      hash.keys
    end
end

=begin

{
  "pagination": {
    "sort": "company_name asc",
    "page_start": 0,
    "page_size": 10
  },
  "filters": {
    "city": {
      "selected": "Brooklyn"
    },
    "revenue": {
      "max": 15000000,
      "selected": {
        "max": 15000000,
        "min": null
      },
      "min": 0
    },
    "employees": {
      "max": 300,
      "selected": {
        "max": 300,
        "min": null
      },
      "min": 0
    },
    "state": {
      "selected": "NY"
    },
    "has_crossreference": {
      "selected": true
    },
    "is_private": {
      "selected": true
    }
  }
}
=end

class CompanyRelation

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

  def where(options = {})
    @query[:filters].merge!(
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
    )
    self
  end

  def paginate(options = {})
    @query[:pagination].merge!(options)
    self
  end

  def order(options = {})
    @query[:pagination].reverse_merge!(sort: '%s %s' % options.to_a.first)
  end

  def each(&block)
    post('list.json')
  end
end
