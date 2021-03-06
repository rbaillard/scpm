class LogsController < ApplicationController

  layout 'tools'
  before_filter :require_login

  def index
    @logs = Log.paginate(:all, :include=>['person'], :order=>"id desc", :page=>params[:page], :per_page=>25)
    @results = render_to_string(:partial=>'results')
  end

  def group_by
    @group_by = params[:by] || session[:log_group_by]
    session[:log_group_by] = @group_by
    @logs = Log.paginate_by_sql("select people.name as uname, al.ip, al.controller_action, al.controller, al. browser, count(*) as C from logs al left outer join people on people.id=al.person_id group by #{@group_by} order by C desc", :page=>params[:page], :per_page=>25)
    @results = render_to_string(:partial=>'results')
  end

  def last_logins
    @group_by = 'last_logins'
    @logs = Log.paginate_by_sql("select people.name as uname, MAX(al.created_at) as d from logs al left outer join people on people.id=al.person_id group by uname order by d desc", :page=>params[:page], :per_page=>25)
    @results = render_to_string(:partial=>'results')
  end

  def chat_sessions
    @sessions = ChatSession.find(:all, :order=>"created_at desc")
  end

end
