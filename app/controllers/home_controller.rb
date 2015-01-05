class HomeController < ApplicationController
  def index
    @companies = Company.all
  end

  def show

    @companies = Company.where(params).paginate(params.extract!(:page_start, :page_size)).order(params[:by].to_sym => params[:dir])
    respond_to do |format|
      format.json { render @companies.send }
      format.html { render partial: 'table', layout: false }
    end
  end
end
