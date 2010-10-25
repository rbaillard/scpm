class PeopleController < ApplicationController

  before_filter :require_login

  def index
    @people = Person.find(:all, :order=>"company_id, name")
  end

  def new
    @person = Person.new
    Company.create(:name=>"SQLI") if Company.find(:first) == nil
    @companies = Company.all
  end

  def create
    @person = Person.new(params[:person])
    if not @person.save
      render :action => 'new'
      return
    end
    redirect_to('/people')
  end

  def show
    @people = Person.find(:all, :order=>"name")
    id            = params[:id]
    @person       = Person.find(id)
    @person.update_timeline
    @requests     = @person.requests
    @next         = @requests.select { |r| if r.start_date ==""; return true; else; Date.parse(r.start_date) >= Date.today() and Date.parse(r.start_date) <= Date.today()+30; end}.sort_by { |r| r.start_date}
  end

  def edit
    @person = Person.find(params[:id])
    @companies = Company.all
  end

  def update
    id = params[:id]
    @person = Person.find(id)
    if @person.update_attributes(params[:person]) # do a save
      redirect_to "/people/show/#{@person.id}"
    else
      render :action => 'edit'
    end
  end

end
