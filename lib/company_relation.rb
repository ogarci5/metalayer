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
        min: 0
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

  ORDER_DEFAULT = {sort: 'company_name_s asc'}

  PAGINATION_DEFAULT = ORDER_DEFAULT.merge(page_start: 0, page_size: 10)

  FIELD_MAPPINGS = {name: :company_name_s, company_name: :company_name_s, city: :city_s, state: :state_s,
                    industry: :industry_s, revenue: :annual_revenue_l, annual_revenue: :annual_revenue_l,
                    employees: :employees_l}.with_indifferent_access

  attr_reader :results
  attr_reader :query

  def initialize(query = {})
    @query = query.reverse_merge(pagination: PAGINATION_DEFAULT, filters: FILTERS_DEFAULT)
  end

  def results
    @results ||= ActiveSupport::JSON.decode(self.api_call.body).with_indifferent_access
  end

  def paginate(options = {})
    @query[:pagination].merge!(options)
    self
  end

  def order(options = {})
    key = options.keys.first
    options[FIELD_MAPPINGS[key]] = options.delete key
    @query[:pagination].merge!(sort: '%s %s' % options.to_a.first)
    self
  end

  def each(&block)
    body = self.results
    if block_given?
      body['results'].each{|result| block.call(result)}
    else
      body['results'].each
    end
  end

  def send
    self.results
  end

  def total
    self.results['pagination']['total_count']
  end

  def pagination
    self.results['pagination']
  end

  def last_two_pages
    last = (self.total.to_f / self.pagination['page_size'].to_i).ceil
    (last-1)..last
  end


  def api_call
    Curl::Easy.http_post(BASE_URL+'list', @query.to_json) do |curl|
      curl.headers['Accept'] = 'application/json'
      curl.headers['Content-Type'] = 'application/json'
    end
  end
end