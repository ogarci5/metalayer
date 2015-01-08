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

  def total_pages
    (self.total.to_f / self.pagination['page_size'].to_i).ceil
  end

  def page_number
    ((self.pagination['page_start'].to_i / self.pagination['page_size'].to_f) + 1).to_i
  end

  def pages
    if self.total_pages < 5
      (1..5).map do |x|
        if x < total_pages
          {number: x, status: 'disabled'}
        else
          {number: x, status: nil}
        end
      end
    elsif self.page_number < 4
      (1..5).map {|x| {number: x, status: nil}}
    elsif self.page_number + 1 < self.total_pages
      ((self.page_number-2)..(self.page_number+2)).map {|x| {number: x, status: nil}}
    else
      ((self.total_pages - 4)..self.total_pages).map {|x| {number: x, status: nil}}
    end
  end


  def api_call
    Curl::Easy.http_post(BASE_URL+'list', @query.to_json) do |curl|
      curl.headers['Accept'] = 'application/json'
      curl.headers['Content-Type'] = 'application/json'
    end
  end
end