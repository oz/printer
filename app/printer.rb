# encoding: utf-8

class Printer < Sinatra::Application
  set :root, PRINTER_ROOT + '/app'
  set :public, PRINTER_ROOT + '/app/static'

  # Bla bla...
  get '/' do
    haml :index
  end

  # --------------------------------------------------------------------------
  # JSON methods
  before do
    layout false

    # Parse date params
    params[:before] = DateTime.parse(params[:before]).to_time if params[:before]
    params[:after]  = DateTime.parse(params[:after]).to_time  if params[:after]
  end

  provides :json

  # List all jobs
  get '/jobs' do
    jobs = Job.all
    jobs = filter_by_dates(jobs)
    paginate(jobs).to_json
  end

  # List known job types, also known as their kind.
  #
  # GET /job_types
  # GET /job_kinds
  get /\/job_(type|kind)s/ do
    # FIXME there is map/reduce within MongoDB: Use Job.map_reduce.
    Job.all.map(&:kind).sort.uniq.to_json
  end

  # Filter jobs on a given field/value.  This is rather dangerous and
  # ill-advised security-wise, but the app is still at pre-alpha stage and
  # should not be a public API either...  The correct way is to implement this
  # as a private method, and declare public APIs around it. -- oz
  #
  # GET /jobs/by_kind/print
  # GET /jobs/by_owner/oz
  # GET /jobs/by_some_field/some_value
  get '/jobs/by_:key/:value' do
    jobs = Job.where(params[:key].to_sym => params[:value])
    jobs = filter_by_dates(jobs)
    paginate(jobs).to_json
  end

  protected

  # Paginate a list of objects from Mongoid, and add pagination headers.
  #
  # @param [#total_pages, #total_entries, #paginate, #klass, Mongoid::Criteria]
  # @return [ Array ]
  def paginate(list)
    list = list.paginate page:     params[:page],
                         per_page: list.klass.per_page
    headers 'X-Total-Pages'   => list.total_pages.to_s,
            'X-Total-Entries' => list.total_entries.to_s
    list
  end

  # Apply before/after date filters to a collection (Mongoid::Criteria), when
  # the before and/or after params are present.
  #
  # @param [#created_before, #created_after]
  # @return Mongoid::Criteria
  def filter_by_dates(list)
    list = list.created_after(params[:after])   if params[:after]
    list = list.created_before(params[:before]) if params[:before]
    list
  end


end
