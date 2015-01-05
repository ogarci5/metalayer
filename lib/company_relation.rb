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

  attr_writer :results
  attr_reader :query

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



  def results
    @results ||= self.api_call
  end

  def each(&block)
    c = self.results
    body = ActiveSupport::JSON.decode(c.body)
    if block_given?
      body['results'].each {|result| block.call(result)}
    else
      body['results'].each
    end
  end

  def send
    c = self.results
    ActiveSupport::JSON.decode(c.body)
  end

  def total
    c = self.results
    body = ActiveSupport::JSON.decode(c.body)
    body['pagination']['total_count']
  end

  protected
    def api_call
      Curl::Easy.http_post(BASE_URL+'list', @query.to_json) do |curl|
        curl.headers['Accept'] = 'application/json'
        curl.headers['Content-Type'] = 'application/json'
      end
    end
end