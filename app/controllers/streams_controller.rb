class StreamsController < ApplicationController
  layout "general"
  
  # GENERAL ACTIONS
  def index
  end
  
  def show
    id = params['id']
    @stream = Stream.find(id)
  end
  
  def show_stream_projects
    id = params['id']
    @stream = Stream.find(id)
    @projects = Project.find(:all,:conditions => ["workstream = ?", Workstream.find(@stream.workstream).name])
  end
  
  def show_stream_informations
    id = params['id']
    @stream = Stream.find(id)
    # Get all Requests
    # @requests = Request.find(:all,:conditions => ["stream_id = ?", id])
  end
  
  def show_stream_review
    id = params['id']
    @review_type = params['type']
    @stream = Stream.find(id) 
    
    reviews = StreamReview.find(:all,:conditions => ["stream_id = ? and review_type_id = ?",@stream.id, @review_type],:order => "created_at DESC")
    @last_review = reviews[0]
    
    @old_reviews = Array.new
    review_index = 0;
    reviews.each do |review|
      @old_reviews << review if review_index != 0
      review_index += 1
    end
  end
  
  # link a request to a Stream, based on request workstream
  def link
    request_id        = params[:id]
    request           = Request.find(request_id)
    project_name      = request.project_name
    workpackage_name  = request.workpackage_name
    brn               = request.brn
    workstream        = request.workstream
    
    stream = Stream.find_with_workstream(workstream)
    if not stream
    render(:text=>"Stream not found")
    end

    request.stream_id = stream.id
    request.save
    render(:text=>"saved")
  end
  
  # FORM REVIEW - EDIT/UPDATE
  def edit_review
    id = params['id']
    @review = StreamReview.find(id)
  end
  
  def update_review
    review = StreamReview.find(params[:id])
    review.text = params[:review][:text]
    review.save
    redirect_to :action=>:show, :id=>review.stream_id
  end
  
  # FORM REVIEW - CREATE/REVIEW
  def add_review_form
    id = params['id']
    type = params['type']
    last_review = StreamReview.first(:conditions => ["stream_id = ? and review_type_id = ?",id ,type], :order => "created_at DESC")
    @review = StreamReview.new
    @review.stream_id = id 
    if(last_review)   
      @review.text = last_review.text
    end
    @review.review_type_id = type
  end
  
  def create_review
    review                = StreamReview.create(params[:review])
    review.stream_id      = params[:review][:stream_id]
    review.review_type_id = params[:review][:review_type_id]
    review.author_id      = current_user.id
    review.save
    redirect_to :action=>:show, :id=>review.stream_id
  end
  
  def cut_review
  end 
  
  def destroy_review
    StreamReview.find(params[:id].to_i).destroy
    render(:nothing=>true)
  end
  
  
  # List streams
  
  def mark_as_read
    s           = Stream.find(params[:id])
    s.read_date = Time.now
    s.save
    render(:nothing=>true)
  end

end
